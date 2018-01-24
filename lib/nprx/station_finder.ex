defmodule NPRx.StationFinder do
  @moduledoc """
  Find stations and station information. This can be stations close to your current geographic location or any number of other criteria. For more detailed information see [the NPR docs](https://dev.npr.org/api/#!/stationfinder/searchStations)
  """
  import NPRx.HTTP

  @typedoc """
  Allowed parameters for stations endpoint
  """
  @type station_query_params :: [q: String.t, city: String.t, state: String.t, lat: String.t, lon: String.t]

  @doc """
  Get a list of stations.

  If no query parameters passed in, it returns a list of stations that are geographically closest to the calling client (based on GeoIP information)

  If one or more query parameters are passed in, it performs a search of NPR stations that match those search criteria (not taking into account the client's physical location)

  Available paramerters are:
  * `q` - Search terms to search on; can be a station name, network name, call letters, or zipcode
  * `city` - A city to look for stations from; intended to be paired with `state`
  * `state` - A state to look for stations from (using the 2-letter abbreviation); intended to be paired with `city`
  * `lat` - A latitude value from a geographic coordinate system; only works if paired with `lon`
  * `lon` - A longitude value from a geographic coordinate system; only works if paired with `lat`
  """
  @spec stations(String.t, station_query_params) :: {:ok, list()} | {:error, map() | list()}
  def stations(token, query_params \\ []) do
    get("/stationfinder/v3/stations", token, query_params)
    |> case do
      {:ok, result} -> {:ok, Map.get(result, "items")}
      error -> error
    end
  end

  @doc """
  This endpoint retrieves information about a given station, based on its numeric ID, which is consistent across all of NPR's APIs.

  A typical use case for this data is for clients who want to create a dropdown menu, modal/pop-up or dedicated page displaying more information about the station the client is localized to, including, for example, links to the station's homepage and donation (pledge) page.
  """
  @spec station_info(String.t, String.t) :: map()
  def station_info(station_id, token) do
    get("/stationfinder/v3/stations/#{station_id}", token)
  end
end
