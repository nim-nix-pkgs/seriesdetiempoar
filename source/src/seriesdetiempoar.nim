## Series de Tiempo de Argentina
## =============================
##
## - API del `Servicio de Series de Tiempo de Argentina. <https://datosgobar.github.io/series-tiempo-ar-api/open-api>`_ para `Nim. <https://nim-lang.org>`_
## .. raw:: html
##   <video src="argentina.mp4" muted autoplay loop width=300 height=400 ></video>
import asyncdispatch, httpclient, json, strformat, uri

const
  seriesdetiempoar_api_url* =
    when defined(ssl): "https://apis.datos.gob.ar/series/api/" ## Base API URL for all API calls (SSL).
    else: "http://apis.datos.gob.ar/series/api/" ## Base API URL for all API calls (No SSL).
  valid_representation_mode = ["value", "change", "percent_change", "change_a_year_ago", "percent_change_a_year_ago"]  ## Valid Values for this argument.
  valid_collapse = ["year", "quarter", "semester", "month", "week", "day"] ## Valid Values for this argument.
  valid_collapse_aggregation = ["avg", "sum", "end_of_period", "min", "max"] ## Valid Values for this argument.
  valid_header = ["titles", "ids", "descriptions"] ## Valid Values for this argument.
  valid_sort = ["asc", "desc"] ## Valid Values for this argument.
  valid_metadata = ["none", "only", "simple", "full"] ## Valid Values for this argument.
  header_api_data = {"dnt": "1", "accept": "application/vnd.api+json", "content-type": "application/vnd.api+json"}
let json_api_headers = newHttpHeaders(header_api_data) ## HTTP Headers for JSON APIs.

type
  SeriesDeTiempoArBase*[HttpType] = object  ## Base Object
    proxy*: Proxy  ## Network IPv4 / IPv6 Proxy support, Proxy type.
    timeout*: byte  ## Timeout Seconds for API Calls, byte type, 0~255.
  SDT* = SeriesDeTiempoArBase[HttpClient]           ## GeoRefAr API  Sync Client.
  AsyncSDT* = SeriesDeTiempoArBase[AsyncHttpClient] ## GeoRefAr API Async Client.

template proxi(this: untyped): untyped =
  ## Template to use Proxy when its declared.
  when declared(this.proxy): this.proxy else: nil

proc apicall(this: SDT | AsyncSDT, api_url: string): Future[JsonNode] {.multisync.} =
  let client =
    when this is AsyncSDT: newAsyncHttpClient(proxy=proxi(this))
    else: newHttpClient(timeout=this.timeout.int * 1000, proxy=proxi(this))
  client.headers = json_api_headers
  let response =
    when this is AsyncSDT: await client.get(api_url)
    else: client.get(api_url)
  result = parseJson(await response.body)

proc series*(this: SDT | AsyncSDT, ids: string, representation_mode="value",
             collapse="", collapse_aggregation="avg",
             limit: range[1..1000] = 100, start=0, start_date="", end_date="",
             header="titles", s0rt="asc", metadata="simple"): Future[JsonNode] {.multisync.} =
  ## Permite realizar varias busquedas sobre el listado de provincias en simultaneo.
  assert representation_mode in valid_representation_mode, "representation_mode must be one of " & $valid_representation_mode
  assert collapse in valid_collapse or collapse == "", "collapse must be one of " & $valid_collapse
  assert collapse_aggregation in valid_collapse_aggregation, "collapse_aggregation must be one of " & $valid_collapse_aggregation
  assert header in valid_header, "header must be one of " & $valid_header
  assert s0rt in valid_sort, "s0rt must be one of " & $valid_sort
  assert metadata in valid_metadata, "metadata must be one of " & $valid_metadata
  let
    a = fmt"&representation_mode={representation_mode}"
    b = fmt"&collapse_aggregation={collapse_aggregation}"
    c = fmt"&limit={limit}"
    d = fmt"&start={start}"
    e = fmt"&header={header}"
    f = fmt"&sort={s0rt}"
    g = fmt"&metadata={metadata}"
    h = fmt"&ids={ids}"
    j = if collapse != "": fmt"&collapse={collapse}" else: ""
    k = if start_date != "": fmt"&start_date={start_date}" else: ""
    l = if end_date != "": fmt"&end_date={end_date}" else: ""
  result = await this.apicall(seriesdetiempoar_api_url & "series?format=json" & a & b & c & d & e & f & h & j & k & l)

proc search*(this: SDT | AsyncSDT, q: string, dataset_theme="", units="", dataset_source="",
             dataset_publisher_name="", catalog_id=""): Future[JsonNode] {.multisync.} =
  ## Permite realizar varias busquedas sobre el listado de departamentos en simultaneo.
  let
    a = fmt"&q={encodeUrl(q)}"
    b = if dataset_theme != "": fmt"&dataset_theme={dataset_theme}" else: ""
    c = if units != "": fmt"&units={units}" else: ""
    d = if dataset_source != "": fmt"&dataset_source={dataset_source}" else: ""
    e = if dataset_publisher_name != "": fmt"&dataset_publisher_name={dataset_publisher_name}" else: ""
    f = if catalog_id != "": fmt"&catalog_id={catalog_id}" else: ""
  result = await this.apicall(seriesdetiempoar_api_url & "search?format=json" & a & b & c & d & e & f)



runnableExamples: # "nim doc georefar.nim" corre estos ejemplos y genera documentacion.
  import asyncdispatch, json
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
