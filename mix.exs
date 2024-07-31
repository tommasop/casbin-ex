defmodule Acx.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_casbin,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Acx, []}
    ]
  end

  # specifies which paths to compile per environment
  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.11"},
      {:redix, "~> 1.5"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Stagedates Casbin library."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "ex_casbin",
      organization: "stagedates",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Proprietary"],
      links: %{"GitHub" => "https://github.com/stagedates/ex_casbin"}
    ]
  end
end
