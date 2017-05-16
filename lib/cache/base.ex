defmodule Throttle.Cache.Base do
  @moduledoc ~S"""
  
  """

  @type request :: %Throttle.Request{}

  @callback get_count(request) :: request
end