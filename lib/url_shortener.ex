defmodule UrlShortener do
  alias UrlShortener.Links
  alias Database.Link

  def shorten(long_url) do
    short = "localhost:4001/" <> short_link(long_url)
    visited = Time.utc_now()

    case Links.create_link(short, long_url, visited) do
      %Link{} = link ->
        link

      {:aborted, {:already_exists, link}} ->
        updated =
          link
          |> Links.update_visit_info()

        {:error, updated}
    end
  end

  def short_link(long_url) do
    short_url =
      long_url
      |> clean_link()
      |> String.codepoints()
      |> Enum.shuffle()
      |> Enum.take(3)
      |> Enum.shuffle()

    random_nums =
      for num <- 1..4 do
        :rand.uniform(num)
      end

    (short_url ++ random_nums)
    |> Enum.join()
  end

  def clean_link(url) do
    Regex.replace(~r/\W/, url, "")
  end
end
