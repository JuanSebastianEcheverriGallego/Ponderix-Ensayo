using Ponderix.Api;
using Ponderix.Api.Dominio;
using Ponderix.Api.Infraestructura;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();
builder.Services.AddProblemDetails();
builder.Services.AddSingleton(_ => BuildInfo.Cargar(builder.Environment.ContentRootPath));

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler();
    app.UseHsts();
}

// HTTPS se fuerza en Azure con la opción "HTTPS Only" del App Service (TLS termina en el balanceador).
app.UseDefaultFiles();
app.UseStaticFiles();

// Comprobación de salud usada por Azure App Service y por la pipeline de CD.
app.MapHealthChecks("/health");

// Trazabilidad: qué versión, ejecución de CI y commit están publicados.
app.MapGet("/api/version", (BuildInfo info, IWebHostEnvironment env) => Results.Ok(new
{
    aplicacion = AppInfo.Nombre,
    version = AppInfo.Version,
    novedad = AppInfo.Novedad,
    build = info.Build,
    commit = info.Commit,
    rama = info.Rama,
    fechaBuild = info.FechaBuild,
    entorno = env.EnvironmentName
}));

app.MapGet("/api/rubricas", () => Results.Ok(Rubricas.Todas));

app.MapPost("/api/notas/calcular", (SolicitudCalculo? solicitud) =>
{
    var errores = CalculadoraNotas.Validar(solicitud);
    return errores.Count > 0
        ? Results.ValidationProblem(errores)
        : Results.Ok(CalculadoraNotas.Calcular(solicitud!));
});

app.Run();

// Necesario para que las pruebas de integración (WebApplicationFactory) accedan a Program.
public partial class Program;
