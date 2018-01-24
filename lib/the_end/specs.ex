defmodule TheEnd.Specs do

  @moduledoc """
  Provides a common spec list for supervisor manages both
  `TheEnd.AcceptanceStopper` and `TheEnd.RequestDrainer`
  """

  @default_timeout 5_000

  def child_spec(module, opts) do

    timeout  = Keyword.get(opts, :timeout, @default_timeout)

    %{
      id: module,
      start: {module, :start_link, [opts]},
      shutdown: timeout + 15,
      type: :supervisor
    }
  end

  def children(gatherer, opts) do

    endpoint = Keyword.fetch!(opts, :endpoint)
    timeout  = Keyword.get(opts, :timeout, @default_timeout)

    [

      {TheEnd.RequestDrainer,
       [endpoint: endpoint, gatherer: gatherer, timeout: timeout]},

      {TheEnd.AcceptanceStopper,
       [endpoint: endpoint, gatherer: gatherer]}

    ]
  end

end
