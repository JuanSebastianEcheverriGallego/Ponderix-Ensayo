namespace Ponderix.Api.Dominio;

/// <summary>Un criterio de evaluación con su peso (porcentaje) y la nota obtenida.</summary>
public sealed record Criterio(string? Nombre, decimal Peso, decimal Nota);

/// <summary>Cuerpo de la petición POST /api/notas/calcular.</summary>
public sealed record SolicitudCalculo(IReadOnlyList<Criterio>? Criterios);

/// <summary>Aporte de un criterio a la nota final (nota × peso / 100).</summary>
public sealed record DetalleCriterio(string Nombre, decimal Peso, decimal Nota, decimal Aporte);

/// <summary>Resultado del cálculo ponderado.</summary>
public sealed record ResultadoCalculo(decimal NotaFinal, string Nivel, IReadOnlyList<DetalleCriterio> Detalle);

/// <summary>Plantilla de criterios precargada (por ejemplo, la rúbrica de CI).</summary>
public sealed record Rubrica(string Id, string Titulo, IReadOnlyList<Criterio> Criterios);
