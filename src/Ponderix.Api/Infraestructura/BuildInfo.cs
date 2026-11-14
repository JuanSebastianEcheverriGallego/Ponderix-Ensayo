using System.Text.Json;

namespace Ponderix.Api.Infraestructura;

/// <summary>
/// Metadatos de trazabilidad. La pipeline de CI escribe el archivo buildinfo.json
/// dentro del artefacto (número de ejecución, commit y rama). En local no existe
/// ese archivo y se muestran valores "local".
/// </summary>
public sealed record BuildInfo(string Build, string Commit, string Rama, string FechaBuild)
{
    public const string NombreArchivo = "buildinfo.json";

    public static BuildInfo Local { get; } = new("local", "local", "local", "local");

    private static readonly JsonSerializerOptions Opciones = new() { PropertyNameCaseInsensitive = true };

    public static BuildInfo Cargar(string directorio)
    {
        var ruta = Path.Combine(directorio, NombreArchivo);
        if (!File.Exists(ruta))
        {
            return Local;
        }

        try
        {
            var leido = JsonSerializer.Deserialize<BuildInfo>(File.ReadAllText(ruta), Opciones);
            return leido is null
                ? Local
                : new BuildInfo(
                    leido.Build ?? Local.Build,
                    leido.Commit ?? Local.Commit,
                    leido.Rama ?? Local.Rama,
                    leido.FechaBuild ?? Local.FechaBuild);
        }
        catch (JsonException)
        {
            return Local;
        }
    }
}
