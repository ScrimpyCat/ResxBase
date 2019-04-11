defmodule ResxBase.MixProject do
    use Mix.Project

    def project do
        [
            app: :resx_base,
            description: "RFC 4648 encoding/decoding transformer for the resx library",
            version: "0.1.0",
            elixir: "~> 1.7",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            dialyzer: [plt_add_deps: :transitive]
        ]
    end

    def application do
        [extra_applications: [:logger]]
    end

    defp deps do
        [
        ]
    end
end
