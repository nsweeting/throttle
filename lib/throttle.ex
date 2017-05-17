defmodule Throttle do
  alias Throttle.Cache
  alias Throttle.Control
  alias Throttle.Request

  def allow?(control) when is_tuple(control) do
    case Control.to_request(control) do
      %Request{allowed: true} -> true
      %Request{allowed: false} -> false
      _ -> true
    end
  end

  def allow?(control_name) when is_atom(control_name) do
    control_name
    |> Control.find
    |> allow?
  end
end
