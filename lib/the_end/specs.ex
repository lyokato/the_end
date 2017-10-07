defmodule TheEnd.Specs do

  import Supervisor.Spec

  @default_timeout 5_000

  def children(gatherer, opts) do

    endpoint = Keyword.fetch!(opts, :endpoint)
    timeout  = Keyword.get(opts, :timeout, @default_timeout)

    [

      worker(
        TheEnd.RequestDrainer,
        [[endpoint: endpoint, gatherer: gatherer, timeout: timeout]],
        [shutdown: timeout + 10]
      ),

      worker(
        TheEnd.AcceptanceStopper,
        [[endpoint: endpoint, gatherer: gatherer]]
      )

    ]
  end

end
