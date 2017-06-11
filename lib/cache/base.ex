defmodule Throttle.Cache.Base do
  @moduledoc ~S"""
  
  """

  @type result :: %Throttle.Result{}

  @callback get_count(result) :: result
end