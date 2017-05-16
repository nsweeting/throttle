defmodule Throttle.Config do
  @moduledoc false
  
  def get(key, default \\ nil) do
    Application.get_env(:throttle, key, default)
  end
end
