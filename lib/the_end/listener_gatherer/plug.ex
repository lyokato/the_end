defmodule TheEnd.ListenerGatherer.Plug do

  @behaviour TheEnd.ListenerGatherer

  import Supervisor, only: [which_children: 1]

  def gather(endpoint) do
    for {{:ranch_listener_sup, _}, pid, _, _} <- which_children(endpoint),
      do: pid
  end

end
