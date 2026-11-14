namespace Ponderix.Api;

/// <summary>
/// Datos visibles de la aplicación. La versión se cambia de forma controlada
/// para demostrar que un commit nuevo en main llega a Azure (ver guía de Marlon).
/// </summary>
public static class AppInfo
{
    public const string Nombre = "Ponderix";

    public const string Version = "1.1.0";

    public const string Novedad = "Nueva versión desplegada automáticamente: GitHub → CI → CD → Azure.";
}
