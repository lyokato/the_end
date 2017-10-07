defmodule TheEnd.ListenerGatherer.Phoenix do

  @behaviour TheEnd.ListenerGatherer

  import Supervisor, only: [which_children: 1]

  def gather(endpoint) do
    endpoint_server = Module.concat(endpoint, Server)
    for {{:ranch_listener_sup, _}, pid, _, _} <- which_children(endpoint_server), do: pid
  end

end
