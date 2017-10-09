defmodule TheEnd do

  @moduledoc ~S"""
  This library provides a graceful shutdown support for your Phoenix, or plain Plug application.

  Original idea is

  [https://gist.github.com/aaronjensen/33cc2aeb74746cac3bcb40dcefdd9c09](https://gist.github.com/aaronjensen/33cc2aeb74746cac3bcb40dcefdd9c09)

  Many of the logic in this library is borrowed from here.
  I added a little bit componentization

  Now, with this library, you can support graceful shutdown for your application built with

  - Plug
  - Phoenix 1.3
  - 1.2 or more older version of Phoenix

  And you also can use only `TheEnd.AcceptanceStopper`, without waiting pending requests to finish.
  This is for WebSocket application.

  ## Usage

  ### Phoenix Endpoint

      children = [

        supervisor(MyApp.Endpoint, []),

        # ... other supervisors/workers

        # you should set this supervisor at last
        supervisor(
          TheEnd.Of.Phoenix,
          [[timeout: 10_000, endpoint: MyApp.Endpoint]],
          [shutdown: 15_000]
        )
      ]
      Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)

  If your Phoenix version is 1.2 or older, use `TheEnd.Of.LegacyPhoenix` instead of `TheEnd.Of.Phoenix`.

  ### Plug

  Your need a Plug wrapper supervisor

      defmodule MyApp.HTTPSupervisor do

        use Supervisor

        def start_link() do
          Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
        end

        def init(_args) do
          [Plug.Adapters.Cowboy.child_spec(:http,
            MyApp.Router, [], [port: 3000])]
          |> supervise(strategy: :one_for_one)
        end

      end

  And at your application supervisor setting

      children = [

        supervisor(MyApp.HTTPSupervisor, []),

        # ... other supervisors/workers

        # you should set this supervisor at last
        supervisor(
          TheEnd.Of.Plug,
          [[timeout: 10_000, endpoint: MyApp.Endpoint]],
          [shutdown: 15_000]
        )
      ]
      Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)

  Or else if you don't need to wait for requests to finish.

      children = [

        supervisor(MyApp.HTTPSupervisor, []),

        # ... other supervisors/workers

        # you should set this worker at last
        worker(
          TheEnd.AcceptanceStopper,
          [[gatherer: TheEnd.ListenerGatherer.Plug, endpoint: MyApp.HTTPSupervisor]]
        )
      ]
      Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)

  You can choose **gatherer** option for your situation

    - `TheEnd.ListenerGatherer.Plug`
    - `TheEnd.ListenerGatherer.Phoenix`
    - `TheEnd.ListenerGatherer.LegacyPhoenix`

  """
end
