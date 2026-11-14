namespace Ponderix.Api.Dominio;

/// <summary>Plantillas precargadas con los criterios y pesos de las rúbricas de la práctica.</summary>
public static class Rubricas
{
    public static IReadOnlyList<Rubrica> Todas { get; } =
    [
        new("ci", "Actividad 1 · Integración Continua (CI)",
        [
            new("Pipeline y disparador", 30m, 0m),
            new("Construcción y validación", 25m, 0m),
            new("Artefactos CI", 25m, 0m),
            new("Evidencia, explicación y equipo", 20m, 0m)
        ]),
        new("cd", "Actividad 2 · Entrega Continua (CD)",
        [
            new("Pipeline CD y artefacto", 30m, 0m),
            new("Automatización extremo a extremo", 30m, 0m),
            new("Verificación en Azure", 20m, 0m),
            new("Evidencia, explicación y equipo", 20m, 0m)
        ]),
        new("final", "Nota final de la práctica",
        [
            new("Nota CI", 50m, 0m),
            new("Nota CD", 50m, 0m)
        ])
    ];
}
