defmodule NPR.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nprx,
      source_url: "https://github.com/silbermm/nprx",
      elixirc_paths: elixirc_paths(Mix.env),
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      name: "NPRx"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NPRx.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:integration), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:mock, "~> 0.3.1", only: [:test, :integration]},
      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:earmark, "~> 1.1", only: :dev},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false}
    ]
  end
  defp package do
    [
      licenses: ["3-Clause BSD License"],
      files: ["lib", "mix.exs", "README.md", "LICENSE*"],
      maintainers: [ "Matt Silbernagel" ],
      links: %{:GitHub => "https://github.com/silbermm/nprx"}
    ]
  end

  defp description do
    "Interact with the NPR One Rest API"
  end
end
