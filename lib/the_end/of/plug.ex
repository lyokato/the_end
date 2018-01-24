defmodule TheEnd.Of.Plug do

  use Supervisor

  def child_spec(opts) do
    TheEnd.Specs.child_spec(__MODULE__, opts)
  end

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    TheEnd.Specs.children(TheEnd.ListenerGatherer.Plug, opts)
    |> Supervisor.init(strategy: :one_for_one)
  end

end
