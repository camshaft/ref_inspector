defmodule RefInspector do
  @moduledoc """
  RefInspector Application
  """

  use Application

  def start(_type, _args) do
    options  = [ strategy: :one_for_one, name: RefInspector.Supervisor ]
    children = [ ]

    sup = Supervisor.start_link(children, options)
    :ok = RefInspector.Config.yaml_path |> load()

    sup
  end

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  defdelegate load(file), to: RefInspector.Database

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: map
  defdelegate parse(ref), to: RefInspector.Database
end
