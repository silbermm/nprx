defmodule NPRxStationFinderTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest NPRx.StationFinder

  import Mock
  alias NPRx.TestHelpers
  alias NPRx.StationFinder

  setup context do
    # make this a real NPR token if new fixtures are needed
    [token: "903cc91facef041b61ad7b423228b9eb6a9f20c612f18520aea956db7ca10d75ebd11083b4dbbe97"]
  end

  test "find stations", %{token: token} do
    use_cassette "stationfinder/stations", match_requests_on: [:query] do
      {:ok, [head | _rest] = stations } = StationFinder.stations(token)
      assert Enum.count(stations) > 1
      assert head["attributes"]["network"]["currentOrgId"] == "704"
    end
  end

  test "find stations with lat/lon", %{token: token} do
    use_cassette "stationfinder/stations_lat_lon", match_requests_on: [:query] do
      {:ok, [head | _rest] = stations } = StationFinder.stations(token, lat: "39.175398", lon: "-84.5575261,14")
      assert head["attributes"]["network"]["currentOrgId"] == "704"
    end
  end

  test "get station info", %{token: token} do
    use_cassette "stationfinder/station", match_requests_on: [:query] do
      {:ok, station} = StationFinder.station_info("704", token)
      assert station["attributes"]["network"]["name"] == "91.7 WVXU"
    end
  end
end
