using Ponderix.Api.Dominio;

namespace Ponderix.Tests;

/// <summary>Pruebas unitarias de la lógica de cálculo (no requieren servidor).</summary>
public class CalculadoraNotasTests
{
    private static SolicitudCalculo Solicitud(params (string nombre, decimal peso, decimal nota)[] criterios) =>
        new(criterios.Select(c => new Criterio(c.nombre, c.peso, c.nota)).ToList());

    [Fact]
    public void Calcular_RubricaCiCompleta_DevuelvePromedioPonderado()
    {
        var solicitud = Solicitud(
            ("Pipeline y disparador", 30, 5.0m),
            ("Construcción y validación", 25, 4.0m),
            ("Artefactos CI", 25, 4.5m),
            ("Evidencia, explicación y equipo", 20, 4.0m));

        var resultado = CalculadoraNotas.Calcular(solicitud);

        // 5.0*0.30 + 4.0*0.25 + 4.5*0.25 + 4.0*0.20 = 1.5 + 1.0 + 1.125 + 0.8 = 4.425 -> 4.43
        Assert.Equal(4.43m, resultado.NotaFinal);
        Assert.Equal("Bueno", resultado.Nivel);
        Assert.Equal(4, resultado.Detalle.Count);
        Assert.Equal(1.125m, resultado.Detalle[2].Aporte);
    }

    [Fact]
    public void Calcular_NotaFinalDeLaPractica_PromediaCiYCdAlCincuentaPorCiento()
    {
        var resultado = CalculadoraNotas.Calcular(Solicitud(("Nota CI", 50, 4.8m), ("Nota CD", 50, 4.6m)));

        Assert.Equal(4.70m, resultado.NotaFinal);
        Assert.Equal("Excelente", resultado.Nivel);
    }

    [Fact]
    public void Calcular_PesosConDecimales_AceptaTolerancia()
    {
        var resultado = CalculadoraNotas.Calcular(Solicitud(("A", 33.33m, 3m), ("B", 33.33m, 3m), ("C", 33.34m, 3m)));

        Assert.Equal(3.00m, resultado.NotaFinal);
    }

    [Theory]
    [InlineData(5.0, "Excelente")]
    [InlineData(4.5, "Excelente")]
    [InlineData(4.49, "Bueno")]
    [InlineData(3.5, "Bueno")]
    [InlineData(3.49, "Aceptable")]
    [InlineData(2.5, "Aceptable")]
    [InlineData(2.49, "Deficiente")]
    [InlineData(0.0, "Deficiente")]
    public void ClasificarNivel_RespetaLimitesDeLaRubrica(double nota, string nivelEsperado)
    {
        Assert.Equal(nivelEsperado, CalculadoraNotas.ClasificarNivel((decimal)nota));
    }

    [Fact]
    public void Validar_SinCriterios_DevuelveError()
    {
        var errores = CalculadoraNotas.Validar(new SolicitudCalculo([]));

        Assert.True(errores.ContainsKey("criterios"));
    }

    [Fact]
    public void Validar_SolicitudNula_DevuelveError()
    {
        Assert.NotEmpty(CalculadoraNotas.Validar(null));
    }

    [Fact]
    public void Validar_PesosQueNoSuman100_DevuelveError()
    {
        var errores = CalculadoraNotas.Validar(Solicitud(("A", 40, 4m), ("B", 40, 4m)));

        Assert.Contains(errores["criterios"], m => m.Contains("100"));
    }

    [Theory]
    [InlineData(-0.1)]
    [InlineData(5.1)]
    public void Validar_NotaFueraDeRango_DevuelveError(double nota)
    {
        var errores = CalculadoraNotas.Validar(Solicitud(("A", 100, (decimal)nota)));

        Assert.True(errores.ContainsKey("criterios[0].nota"));
    }

    [Fact]
    public void Validar_NombreVacio_DevuelveError()
    {
        var errores = CalculadoraNotas.Validar(Solicitud(("  ", 100, 4m)));

        Assert.True(errores.ContainsKey("criterios[0].nombre"));
    }

    [Fact]
    public void Calcular_SolicitudInvalida_LanzaArgumentException()
    {
        Assert.Throws<ArgumentException>(() => CalculadoraNotas.Calcular(Solicitud(("A", 10, 4m))));
    }

    [Fact]
    public void Rubricas_TodasLasPlantillasSuman100()
    {
        Assert.All(Rubricas.Todas, r => Assert.Equal(100m, r.Criterios.Sum(c => c.Peso)));
    }
}
