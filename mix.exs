defmodule ExReferer.Mixfile do
  use Mix.Project

  def project do
    [ app:        :ex_referer,
      name:       "ExReferer",
      source_url: "https://github.com/elixytics/ex_referer",
      version:    "0.1.0",
      elixir:     ">= 0.14.0",
      deps:       deps(Mix.env),
      docs:       &docs/0 ]
  end

  def application do
    [ applications: [ :yamerl ],
      mod:          { ExReferer, [] } ]
  end

  defp deps(:docs) do
    deps(:prod) ++
      [ { :ex_doc,   github: "elixir-lang/ex_doc" },
        { :markdown, github: "devinus/markdown" } ]
  end

  defp deps(_) do
    [ { :yamerl, github: "yakaz/yamerl" } ]
  end

  defp docs do
    [ readme:     true,
      main:       "README",
      source_ref: System.cmd("git rev-parse --verify --quiet HEAD") ]
  end
end
