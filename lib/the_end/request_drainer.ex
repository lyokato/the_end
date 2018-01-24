defmodule TheEnd.RequestDrainer do

  @moduledoc """
  This module's process waits pending requests to finish when terminating itself.

  So, your should put this module's spec after your Endpoint's one and before AcceptTanceStopper's one

      children = [
        # ... other specs
        {TheEnd.RequestDrainer,
          [endpoint: MyApp.Endpoint, gatherer: TheEnd.ListenerGatherer.Plug, timeout: 10_000]},
        {TheEnd.AcceptanceStopper,
          [endpoint: MyApp.Endpoint, gatherer: TheEnd.ListenerGatherer.Plug]}
      ]

  ### Initialization:
    * `:endpoint` - endpoint module
    * `:gatherer` - module that implements TheEnd.ListenerGatherer behaviour
    * `:timeout` - max limit of time you can wait for requests to finish (milliseconds)

  ### See Also
    * `TheEnd.AcceptanceStopper`
    * `TheEnd.ListenerGatherer`
    * `TheEnd.ListenerGatherer.Plug`
    * `TheEnd.ListenerGatherer.Phoenix`
    * `TheEnd.ListenerGatherer.LegacyPhoenix`

  """

  @default_timeout 5_000

  require Logger

  use GenServer

  import Supervisor, only: [which_children: 1]

  defstruct endpoint: nil,
            gatherer: nil,
            timeout:    0

  def child_spec(opts) do

    timeout = Keyword.fetch!(opts, :timeout)

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      shutdown: timeout + 10,
      type: :worker
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do

    Process.flag(:trap_exit, true)

    gatherer = Keyword.fetch!(opts, :gatherer)
    endpoint = Keyword.fetch!(opts, :endpoint)
    timeout  = Keyword.get(opts, :timeout, @default_timeout)

    {:ok, %__MODULE__{endpoint: endpoint,
                      gatherer: gatherer,
                      timeout:  timeout}}

  end

  def terminate(:normal, state),        do: regular_terminate(state)
  def terminate(:shutdown, state),      do: regular_terminate(state)
  def terminate({:shutdown, _}, state), do: regular_terminate(state)
  def terminate(_reason, _state),       do: :ok

  defp regular_terminate(state) do
    timer_ref = :erlang.start_timer(state.timeout, self(), :timeout)
    handle_pending_requests(state.gatherer, state.endpoint, timer_ref, %{})
    :ok
  end

  defp handle_pending_requests(gatherer, endpoint, timer_ref, monitors) do

    monitors =
      update_monitors(gatherer, endpoint, monitors)

    case Map.size(monitors) do

      0 ->
        Logger.info("<TheEnd> no more connections")
        :erlang.cancel_timer(timer_ref)
        :ok

      n ->
        receive do

          {:DOWN, _monitor, _, _, _} ->
            Logger.info("<TheEnd> one of pending requests has finished")
            handle_pending_requests(gatherer, endpoint, timer_ref, monitors)

          {:timeout, ^timer_ref, :timeout} ->
            Logger.error("<TheEnd> timeout with #{n} connections left")
            {:error, :timeout}

          other ->
            Logger.warn("<TheEnd> unexpected message: #{inspect other}")
            handle_pending_requests(gatherer, endpoint, timer_ref, monitors)

        end

    end

  end

  defp update_monitors(gatherer, endpoint, latest) do
    gather_pending_requests(gatherer, endpoint)
    |> Map.new(fn pid ->
      {pid, latest[pid] || Process.monitor(pid)}
    end)
  end

  defp gather_pending_requests(gatherer, endpoint) do
    for listener_pid                    <- gatherer.gather(endpoint),
      {:ranch_conns_sup, sup_pid, _, _} <- which_children(listener_pid),
      {_, request_pid, _, _}            <- which_children(sup_pid),
        do: request_pid
  end

end
