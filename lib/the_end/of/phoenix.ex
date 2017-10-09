defmodule TheEnd.Of.Phoenix do

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    TheEnd.Specs.children(TheEnd.ListenerGatherer.Phoenix, opts)
    |> supervise(strategy: :one_for_one)
  end

end
