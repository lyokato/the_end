defmodule TheEnd.ListenerGatherer.LegacyPhoenix do

  @behaviour TheEnd.ListenerGatherer

  import Supervisor, only: [which_children: 1]

  def gather(endpoint) do
    for {Phoenix.Endpoint.Server, pid, _, _}  <- which_children(endpoint),
        {{:ranch_listener_sup, _}, pid, _, _} <- which_children(pid),
      do: pid
  end

end
