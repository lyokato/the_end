defmodule TheEnd.ListenerGatherer do

  @callback gather(module) :: [pid]

end
