defmodule TheEnd.Mixfile do
  use Mix.Project

  def project do
    [app: :the_end,
     version: "1.0.0",
     elixir: "~> 1.4",
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
     {:ex_doc, "~> 0.15", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      description: "Graceful shutdown support for Phoenix or plain Plug application",
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/lyokato/the_end",
        "Docs"   => "https://hexdocs.pm/the_end"
      },
      maintainers: ["Lyo Kato"]
    ]
  end
end
