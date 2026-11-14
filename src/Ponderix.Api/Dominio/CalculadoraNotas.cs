namespace Ponderix.Api.Dominio;

/// <summary>
/// Calcula una nota ponderada en escala 0.0 – 5.0 y la clasifica según los
/// niveles de la rúbrica de la práctica (Excelente, Bueno, Aceptable, Deficiente).
/// </summary>
public static class CalculadoraNotas
{
    public const decimal NotaMinima = 0.0m;
    public const decimal NotaMaxima = 5.0m;
    public const decimal PesoTotalEsperado = 100m;
    public const int MaximoCriterios = 20;

    /// <summary>Tolerancia para aceptar sumas como 33.33 + 33.33 + 33.34.</summary>
    private const decimal ToleranciaPeso = 0.01m;

    /// <summary>
    /// Devuelve los errores de validación agrupados por campo.
    /// Un diccionario vacío significa que la solicitud es válida.
    /// </summary>
    public static Dictionary<string, string[]> Validar(SolicitudCalculo? solicitud)
    {
        var errores = new Dictionary<string, List<string>>();

        void Agregar(string campo, string mensaje)
        {
            if (!errores.TryGetValue(campo, out var lista))
            {
                lista = [];
                errores[campo] = lista;
            }
            lista.Add(mensaje);
        }

        var criterios = solicitud?.Criterios;
        if (criterios is null || criterios.Count == 0)
        {
            Agregar("criterios", "Debe enviar al menos un criterio.");
            return Convertir(errores);
        }

        if (criterios.Count > MaximoCriterios)
        {
            Agregar("criterios", $"Se admiten como máximo {MaximoCriterios} criterios.");
        }

        for (var i = 0; i < criterios.Count; i++)
        {
            var c = criterios[i];
            if (c is null)
            {
                Agregar($"criterios[{i}]", "El criterio no puede ser nulo.");
                continue;
            }
            if (string.IsNullOrWhiteSpace(c.Nombre))
            {
                Agregar($"criterios[{i}].nombre", "El nombre es obligatorio.");
            }
            if (c.Peso <= 0 || c.Peso > PesoTotalEsperado)
            {
                Agregar($"criterios[{i}].peso", "El peso debe ser mayor que 0 y como máximo 100.");
            }
            if (c.Nota < NotaMinima || c.Nota > NotaMaxima)
            {
                Agregar($"criterios[{i}].nota", $"La nota debe estar entre {NotaMinima:0.0} y {NotaMaxima:0.0}.");
            }
        }

        var sumaPesos = criterios.Where(c => c is not null).Sum(c => c.Peso);
        if (Math.Abs(sumaPesos - PesoTotalEsperado) > ToleranciaPeso)
        {
            Agregar("criterios", $"La suma de los pesos debe ser 100 (actual: {sumaPesos:0.##}).");
        }

        return Convertir(errores);
    }

    /// <summary>Calcula la nota final. Lanza ArgumentException si la solicitud no es válida.</summary>
    public static ResultadoCalculo Calcular(SolicitudCalculo solicitud)
    {
        var errores = Validar(solicitud);
        if (errores.Count > 0)
        {
            throw new ArgumentException(string.Join(" ", errores.Values.SelectMany(v => v)), nameof(solicitud));
        }

        var detalle = solicitud.Criterios!
            .Select(c => new DetalleCriterio(
                c.Nombre!.Trim(),
                c.Peso,
                c.Nota,
                Math.Round(c.Nota * c.Peso / PesoTotalEsperado, 3, MidpointRounding.AwayFromZero)))
            .ToList();

        var notaFinal = Math.Round(
            solicitud.Criterios!.Sum(c => c.Nota * c.Peso / PesoTotalEsperado),
            2,
            MidpointRounding.AwayFromZero);

        return new ResultadoCalculo(notaFinal, ClasificarNivel(notaFinal), detalle);
    }

    /// <summary>Niveles definidos en la tabla «Interpretación de niveles» de la práctica.</summary>
    public static string ClasificarNivel(decimal nota) => nota switch
    {
        >= 4.5m => "Excelente",
        >= 3.5m => "Bueno",
        >= 2.5m => "Aceptable",
        _ => "Deficiente"
    };

    private static Dictionary<string, string[]> Convertir(Dictionary<string, List<string>> errores) =>
        errores.ToDictionary(kv => kv.Key, kv => kv.Value.ToArray());
}
