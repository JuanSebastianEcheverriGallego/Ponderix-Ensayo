using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Ponderix.Api;

namespace Ponderix.Tests;

/// <summary>
/// Pruebas de integración: levantan la API en memoria (WebApplicationFactory)
/// y comprueban los endpoints que se usan en Azure y en la pipeline de CD.
/// </summary>
public class ApiTests(WebApplicationFactory<Program> factory) : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _cliente = factory.CreateClient();

    [Fact]
    public async Task Health_DevuelveHealthy()
    {
        var respuesta = await _cliente.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);
        Assert.Equal("Healthy", await respuesta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Version_DevuelveNombreYVersionDeLaAplicacion()
    {
        var json = await _cliente.GetFromJsonAsync<JsonElement>("/api/version");

        Assert.Equal(AppInfo.Nombre, json.GetProperty("aplicacion").GetString());
        Assert.Equal(AppInfo.Version, json.GetProperty("version").GetString());
        Assert.False(string.IsNullOrWhiteSpace(json.GetProperty("commit").GetString()));
        Assert.False(string.IsNullOrWhiteSpace(json.GetProperty("build").GetString()));
    }

    [Fact]
    public async Task Rubricas_DevuelveLasPlantillasCiCdYFinal()
    {
        var json = await _cliente.GetFromJsonAsync<JsonElement>("/api/rubricas");

        var ids = json.EnumerateArray().Select(r => r.GetProperty("id").GetString()).ToList();
        Assert.Equal(["ci", "cd", "final"], ids);
    }

    [Fact]
    public async Task Calcular_SolicitudValida_Devuelve200ConNotaYNivel()
    {
        var cuerpo = new
        {
            criterios = new[]
            {
                new { nombre = "Nota CI", peso = 50m, nota = 4.5m },
                new { nombre = "Nota CD", peso = 50m, nota = 5.0m }
            }
        };

        var respuesta = await _cliente.PostAsJsonAsync("/api/notas/calcular", cuerpo);
        var json = await respuesta.Content.ReadFromJsonAsync<JsonElement>();

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);
        Assert.Equal(4.75m, json.GetProperty("notaFinal").GetDecimal());
        Assert.Equal("Excelente", json.GetProperty("nivel").GetString());
    }

    [Fact]
    public async Task Calcular_PesosInvalidos_Devuelve400ConErrores()
    {
        var cuerpo = new { criterios = new[] { new { nombre = "Único", peso = 60m, nota = 4m } } };

        var respuesta = await _cliente.PostAsJsonAsync("/api/notas/calcular", cuerpo);
        var json = await respuesta.Content.ReadFromJsonAsync<JsonElement>();

        Assert.Equal(HttpStatusCode.BadRequest, respuesta.StatusCode);
        Assert.True(json.GetProperty("errors").TryGetProperty("criterios", out _));
    }

    [Fact]
    public async Task Inicio_SirveLaPaginaWeb()
    {
        var respuesta = await _cliente.GetAsync("/");
        var html = await respuesta.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);
        Assert.Contains("Ponderix", html);
    }
}
