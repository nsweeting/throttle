defmodule Throttle.Control.Config do
  alias Throttle.Config

  def all do
    Config.get(:controls, [])
  end

  def find(name) when is_atom(name) do
    Config.get(:controls, [])[name]
  end
end
