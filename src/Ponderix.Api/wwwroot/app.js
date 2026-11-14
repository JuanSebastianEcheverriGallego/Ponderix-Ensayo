"use strict";

const filas = document.getElementById("filas");
const sumaPesos = document.getElementById("suma-pesos");
const resultado = document.getElementById("resultado");

function crearFila(criterio = { nombre: "", peso: "", nota: "" }) {
  const tr = document.createElement("tr");
  tr.innerHTML = `
    <td><input type="text" class="nombre" placeholder="Nombre del criterio" required></td>
    <td><input type="number" class="peso" min="0" max="100" step="0.01" required></td>
    <td><input type="number" class="nota" min="0" max="5" step="0.1" required></td>
    <td><button type="button" class="quitar" aria-label="Quitar criterio">✕</button></td>`;
  tr.querySelector(".nombre").value = criterio.nombre;
  tr.querySelector(".peso").value = criterio.peso;
  tr.querySelector(".nota").value = criterio.nota === 0 ? "" : criterio.nota;
  tr.querySelector(".quitar").addEventListener("click", () => { tr.remove(); actualizarSuma(); });
  tr.querySelector(".peso").addEventListener("input", actualizarSuma);
  filas.appendChild(tr);
}

function leerCriterios() {
  return [...filas.querySelectorAll("tr")].map(tr => ({
    nombre: tr.querySelector(".nombre").value,
    peso: Number(tr.querySelector(".peso").value || 0),
    nota: Number(tr.querySelector(".nota").value || 0)
  }));
}

function actualizarSuma() {
  const suma = leerCriterios().reduce((acc, c) => acc + c.peso, 0);
  sumaPesos.textContent = `Suma de pesos: ${Math.round(suma * 100) / 100} %`;
  sumaPesos.classList.toggle("error", Math.abs(suma - 100) > 0.01);
}

function cargarPlantilla(rubrica) {
  filas.innerHTML = "";
  rubrica.criterios.forEach(crearFila);
  actualizarSuma();
}

function escapar(texto) {
  const div = document.createElement("div");
  div.textContent = String(texto);
  return div.innerHTML;
}

async function calcular(evento) {
  evento.preventDefault();
  resultado.className = "resultado";
  resultado.textContent = "Calculando…";
  try {
    const respuesta = await fetch("api/notas/calcular", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ criterios: leerCriterios() })
    });
    const datos = await respuesta.json();
    if (!respuesta.ok) {
      const mensajes = Object.values(datos.errors || {}).flat();
      resultado.className = "resultado error";
      resultado.innerHTML = `<strong>Revise los datos:</strong><ul>${mensajes.map(m => `<li>${escapar(m)}</li>`).join("")}</ul>`;
      return;
    }
    const nivel = datos.nivel.toLowerCase();
    resultado.innerHTML = `
      <p class="nota-final">${datos.notaFinal.toFixed(2)} <span class="nivel ${nivel}">${escapar(datos.nivel)}</span></p>
      <table><thead><tr><th>Criterio</th><th>Peso</th><th>Nota</th><th>Aporte</th></tr></thead>
      <tbody>${datos.detalle.map(d => `<tr><td>${escapar(d.nombre)}</td><td>${d.peso} %</td><td>${d.nota}</td><td>${d.aporte}</td></tr>`).join("")}</tbody></table>`;
  } catch (error) {
    resultado.className = "resultado error";
    resultado.textContent = "No fue posible contactar la API: " + error.message;
  }
}

async function iniciar() {
  document.getElementById("agregar").addEventListener("click", () => crearFila());
  document.getElementById("formulario").addEventListener("submit", calcular);

  try {
    const rubricas = await (await fetch("api/rubricas")).json();
    const contenedor = document.getElementById("plantillas");
    rubricas.forEach(r => {
      const boton = document.createElement("button");
      boton.type = "button";
      boton.className = "secundario";
      boton.textContent = r.titulo;
      boton.addEventListener("click", () => cargarPlantilla(r));
      contenedor.appendChild(boton);
    });
    cargarPlantilla(rubricas[0]);
  } catch {
    crearFila();
  }

  try {
    const v = await (await fetch("api/version")).json();
    document.getElementById("novedad").textContent = `Versión ${v.version}: ${v.novedad}`;
    document.getElementById("pie").textContent =
      `${v.aplicacion} v${v.version} · build ${v.build} · commit ${String(v.commit).substring(0, 7)} · entorno ${v.entorno}`;
  } catch {
    document.getElementById("pie").textContent = "Versión no disponible";
  }
}

iniciar();
