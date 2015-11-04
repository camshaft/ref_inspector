defmodule RefInspector.Database do
  @moduledoc """
  Referer database.
  """

  def parse(ref, internal \\ Application.get_env(:ref_inspector, :internal, [])) do
    uri = ref |> URI.parse()
    host = uri.host || ""

    if String.ends_with?(host, internal) do
      %RefInspector.Result{medium: :internal, referer: ref}
    else
      %{uri | host: reverse_host(host),
              path: uri.path || "/"}
      |> __MODULE__.Referers.match()
      |> Map.put(:referer, ref)
    end
  end

  @doc """
  Loads a referer database file.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(nil) do
    :ok
  end
  def load(file) do
    if File.regular?(file) do
      parse_file(file)
    else
      { :error, "Invalid file given: '#{ file }'" }
    end
  end

  @doc false
  @spec parse_query(String.t, List.t) :: String.t | :none
  def parse_query(nil, _), do: :none
  def parse_query(query, params) do
    query
    |> URI.decode_query()
    |> extract_parameter_value(params)
  end

  defp parse_file(file) do
    file
    |> :yamerl_constr.file([ :str_node_as_binary ])
    |> hd()
    |> Enum.flat_map(&parse_entry/1)
    |> compile_module()
    |> Code.eval_quoted()
    :ok
  end

  defp parse_entry({ medium, sources }) do
    medium = String.to_atom(medium)
    sources
    |> parse_sources(medium, [])
    |> sort_sources()
    |> compile_sources()
  end

  # Parsing and sorting methods

  defp parse_sources([], _, acc), do: acc
  defp parse_sources([{ name, details } | sources ], medium, acc)  do
    details    = details |> Enum.into(%{})
    domains    = Map.get(details, "domains", [])
    parameters = Map.get(details, "parameters", [])

    source = %{ name: name, parameters: parameters, medium: medium }
    acc    = parse_domains(source, domains, acc)

    parse_sources(sources, medium, acc)
  end

  defp parse_domains(_, [], acc), do: acc
  defp parse_domains(source, [ domain | domains ], acc)  do
    uri  = URI.parse("http://#{ domain }")

    host = reverse_host(uri.host || "")
    path = uri.path || "/"

    acc = [Map.merge(source, %{host: host, path: path}) | acc]

    parse_domains(source, domains, acc)
  end

  defp sort_sources(sources) do
    sources
    |> Enum.map( &Map.put(&1, :sort, "#{ &1.host }#{ &1.path }") )
    |> Enum.sort( &(String.length(&1[:sort]) > String.length(&2[:sort])) )
    |> Enum.uniq( &(&1[:sort]) )
    |> Enum.map( &Map.delete(&1, :sort) )
  end

  defp compile_sources(sources) do
    for %{host: host, path: path, medium: medium,
          name: name, parameters: parameters} <- sources do
      quote do
        def match(%{host: unquote(host) <> _,
                    path: unquote(path) <> _,
                    query: query}) do
          %unquote(RefInspector.Result){
            medium: unquote(medium),
            source: unquote(name),
            term: unquote(__MODULE__).parse_query(query, unquote(parameters))
          }
        end
      end
    end
  end

  defp extract_parameter_value(_, []), do: :none
  defp extract_parameter_value(query, [param | params]) do
    case Map.get(query, param) do
      nil ->
        extract_parameter_value(query, params)
      value ->
        value
    end
  end

  defp compile_module(sources) do
    quote do
      defmodule unquote(__MODULE__).Referers do
        unquote_splicing(sources)
        def match(_) do
          %RefInspector.Result{}
        end
      end
    end
  end

  defp reverse_host(host) do
    host
    |> String.split(".")
    |> Enum.reverse()
    |> Enum.join(".")
  end
end
