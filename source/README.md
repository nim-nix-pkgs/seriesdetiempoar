# Nim-SeriesDeTiempoAR

[Series de Tiempo de Argentina](https://datosgobar.github.io/series-tiempo-ar-api/open-api) MultiSync API Client for [Nim](https://nim-lang.org). *(All Docs on Spanish because its for Argentina)*


# Uso

```nim
import seriesdetiempoar, asyncdispatch, json

## Sync client.
let sdt_client = SDT(timeout: 9)  # Timeout en Segundos.
## Las consultas son copiadas desde la Documentacion de la API.
echo sdt_client.series(ids="101.1_I2NG_2016_M_22:percent_change_a_year_ago").pretty
echo sdt_client.series(ids="168.1_T_CAMBIOR_D_0_0_26", start_date="2018-07", limit=1000).pretty
echo sdt_client.series(ids="143.3_NO_PR_2004_A_21,143.3_NO_PR_2004_A_28", limit=1000).pretty
echo sdt_client.series(ids="168.1_T_CAMBIOR_D_0_0_26,103.1_I2N_2016_M_15", metadata="full").pretty
echo sdt_client.series(ids="168.1_T_CAMBIOR_D_0_0_26:percent_change_a_year_ago", collapse="month").pretty

## Async client.
proc async_sdt() {.async.} =
  let
    async_sdt_client = AsyncSDT(timeout: 9)
    async_response = await async_sdt_client.series(ids="101.1_I2NG_2016_M_22:percent_change_a_year_ago")
  echo async_response.pretty

wait_for async_sdt()

# Ver la Doc para mas API Calls...
```


# API

- Todas las funciones retornan JSON, tipo `JsonNode`.
- Los nombres siguen los mismos nombres de la Documentacion.
- Los errores siguen los mismos errores de la Documentacion.
- Todas las API Calls son HTTP `GET`.
- El `timeout` es en Segundos.
- Para soporte de Proxy de red definir un `proxy` de tipo `Proxy`.
- No tiene codigo especifico a ningun Sistema Operativo, funciona en Linux, Windows, Mac, etc.


# FAQ

- Funciona sin SSL ?.

Si.

- Funciona con SSL ?.

Si.

- Funciona con codigo Asincrono ?.

Si.

- Funciona con codigo Sincrono ?.

Si.

- Requiere API Key ?.

No.

- Es Pago ?.

No.


# Requisites

- None.
