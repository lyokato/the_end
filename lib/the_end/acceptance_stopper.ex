defmodule TheEnd.AcceptanceStopper do

  import Supervisor, only: [terminate_child: 2]

  defstruct endpoint: nil,
            gatherer: nil

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do

    Process.flag(:trap_exit, true)

    gatherer = Keyword.fetch!(opts, :gatherer)
    endpoint = Keyword.fetch!(opts, :endpoint)

    {:ok, %__MODULE__{endpoint: endpoint,
                      gatherer: gatherer}}

  end

  def terminate(:normal, state),        do: regular_terminate(state)
  def terminate(:shutdown, state),      do: regular_terminate(state)
  def terminate({:shutdown, _}, state), do: regular_terminate(state)
  def terminate(_reason, _state),       do: :ok

  defp regular_terminate(state) do
    stop_acceptors(state.gatherer, state.endpoint)
    :ok
  end

  defp stop_acceptors(gatherer, endpoint) do
    gatherer.gather(endpoint)
    |> Enum.each(&terminate_child(&1, :ranch_acceptors_sup))
  end

end
