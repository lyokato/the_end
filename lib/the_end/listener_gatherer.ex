defmodule TheEnd.ListenerGatherer do

  @moduledoc """
  Defines a listener-gatherer behaviour
  """

  @doc """
  search ranch's listener processes,
  traversing descendants of module process you passed as argument
  """
  @callback gather(module) :: [pid]

end
