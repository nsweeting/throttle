defmodule Throttle do
  alias Throttle.{Context, Result}

  def allow?(context_name) when is_atom(context_name) do
    context_name
    |> Context.find
    |> allow?
  end

  def allow?(context) when is_tuple(context) do
    context
    |> Context.new
    |> allow?
  end

  def allow?(%Context{} = context) do
    context
    |> execute_context
    |> handle_result
  end

  def execute_context(%Context{} = context) do
    context
    |> Result.new
    |> Result.put_count
    |> Result.put_allowed
    |> Result.put_delay
  end

  defp handle_result(%Result{allowed: true} = result), do: {:ok, result}
  defp handle_result(%Result{allowed: false} = result), do: {:error, result}
  defp handle_result(_ = result), do: {:ok, result}
end
