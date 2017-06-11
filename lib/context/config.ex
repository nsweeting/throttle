defmodule Throttle.Context.Config do
  alias Throttle.{Config, Context}

  def all do
    :contexts
    |> Config.get([])
    |> to_contexts
  end

  def find(name) when is_atom(name) do
    :contexts
    |> Config.get([])
    |> Keyword.get(name)
    |> Context.new
  end

  defp to_contexts(contexts) when is_list(contexts) do
    Enum.map(contexts, fn {_, c} -> Context.new(c) end)
  end
end
