defmodule ExReferer.Database do
  use GenServer

  @ets_table      :ex_referer
  @ets_table_refs :ex_referer_refs
  @ets_counter    :referers


  # GenServer lifecycle

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  def init(_) do
    :ets.new(@ets_table,      [ :set,         :protected, :named_table ])
    :ets.new(@ets_table_refs, [ :ordered_set, :protected, :named_table ])

    :ets.insert(@ets_table, [{ @ets_counter, 0 }])

    { :ok, [] }
  end

  def terminate(_, _) do
    :ets.delete(@ets_table_refs)
    :ets.delete(@ets_table)

    :ok
  end


  # GenServer callbacks

  def handle_call({ :load, file }, _from, state) do
    { :reply, load_file(file), state }
  end


  # Convenience methods

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: [ Atom.t ]
  def list(), do: :ets.tab2list(@ets_table_refs)

  @doc false
  def load(file), do: GenServer.call(__MODULE__, { :load, file })


  # Internal methods

  defp load_file(file) do
    if File.regular?(file) do
      parse_file(file)
    else
      { :error, "Invalid file given: '#{ file }'" }
    end
  end

  defp parse_file(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
      |> parse_data()
  end

  defp parse_data([]), do: :ok
  defp parse_data([ { medium, sources } | datasets ]) do
    store_refs(medium, sources)
    parse_data(datasets)
  end

  defp store_refs(medium, sources) do
    sources = Enum.map(sources, fn ({ name, details }) ->
      details = Enum.map(details, fn({ key, values }) ->
        { String.to_atom(key), values }
      end)

      { name, details }
    end)

    store_ref({ medium, sources })
  end

  defp store_ref(ref) do
    :ets.insert_new(@ets_table_refs, { update_counter(), ref })
  end

  defp update_counter(), do: :ets.update_counter(@ets_table, @ets_counter, 1)
end
