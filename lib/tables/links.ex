defmodule UrlShortener.Links do
  require Amnesia
  require Amnesia.Helper

  require Database.Link

  alias Database.Link

  def create_link(short_url, long_url, last_visited, visits \\ 0) do
    Amnesia.transaction do
      %Link{short_url: short_url, long_url: long_url, visits: visits, last_visited: last_visited}
      |> Link.write()
    end
    |> IO.inspect()
  end

  def get_link(short_url) do
    Amnesia.transaction do
      Link.read(short_url)
    end
    |> case do
      %Link{} = link -> link
      _ -> {:error, :not_found}
    end
  end

  def update_visit_info(short_url) do
    Amnesia.transaction do
      link = Link.read(short_url)

      case link do
        %Link{} = link ->
          link
          |> update_time()
          |> add_visits()

        _ ->
          {:error, :not_found}
      end
    end
  end

  defp update_time(%Link{} = link) do
    link
    |> Map.update(:last_visited, Time.utc_now(), fn _ -> Time.utc_now() end)
    |> Link.write()
  end

  defp add_visits(%Link{} = link) do
    link
    |> Map.update(:visits, 0, fn old_vists -> old_vists + 1 end)
    |> Link.write()
  end
end
