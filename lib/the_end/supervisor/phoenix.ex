defmodule TheEnd.Supervisor.Phoenix do

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    TheEnd.Specs.children(TheEnd.ListenerGatherer.Phoenix, opts)
    |> supervise(strategy: :one_for_one)
  end

end
