defmodule UrlShortener.Router do
  use Plug.Router

  alias UrlShortener.Links
  alias Database.Link

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> Plug.Conn.resp(:found, "")
  end

  post "/link" do
    %{"url" => url} = conn.body_params

    case UrlShortener.shorten(url) do
      %Link{} = link ->
        IO.inspect(link)

        transform = Map.from_struct(link)
        {:ok, json_link} = Jason.encode(transform)

        conn
        |> Plug.Conn.resp(200, json_link)
        |> Plug.Conn.send_resp()

      {:error, _old_link} ->
        conn
        |> Plug.Conn.resp(:found, "")
        |> Plug.Conn.put_resp_header("location", "")
    end
  end

  get "/:short_url" do
    url = "localhost:4001/#{short_url}"

    case Links.get_link(url) do
      %Link{} = link ->
        Links.update_visit_info(url)
        IO.inspect(link)

        conn
        |> Plug.Conn.resp(:found, "")
        |> Plug.Conn.put_resp_header("location", "#{link.long_url}")

      _ ->
        conn
        |> Plug.Conn.send_resp(404, "Not found.")
    end
  end

  get "/link/stats/:url" do
    url = "localhost:4001/#{url}"

    case Links.get_link(url) do
      %Link{} = link ->
        IO.inspect(link)

        transform = Map.from_struct(link)
        {:ok, json_link} = Jason.encode(transform)

        conn
        |> Plug.Conn.resp(200, json_link)
        |> Plug.Conn.send_resp()

      _ ->
        conn
        |> Plug.Conn.send_resp(404, "Not found.")
    end
  end
end
