defmodule RefInspector.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/ref_inspector"
  @url_github "https://github.com/elixytics/ref_inspector"

  def project do
    [ app:           :ref_inspector,
      name:          "RefInspector",
      description:   "Referer parser library",
      package:       package,
      version:       "0.6.0-dev",
      elixir:        "~> 1.0",
      deps:          deps(Mix.env),
      docs:          docs,
      test_coverage: [ tool: ExCoveralls ]]
  end

  def application do
    [ applications: [ :yamerl ],
      mod:          { RefInspector, [] } ]
  end

  def deps(:docs) do
    deps(:prod) ++
      [ { :earmark, "~> 0.1" },
        { :ex_doc,  "~> 0.7" } ]
  end

  def deps(:test) do
    deps(:prod) ++
      [ { :dialyze,     "~> 0.1" },
        { :excoveralls, "~> 0.3" } ]
  end

  def deps(_) do
    [ { :poolboy, "~> 1.0" },
      { :yamerl,  github: "yakaz/yamerl" } ]
  end

  def docs do
    [ main:       "README",
      readme:     "README.md",
      source_ref: "master",
      source_url: @url_github ]
  end

  def package do
    %{ contributors: [ "Marc Neudert" ],
       files:        [ "LICENSE", "mix.exs", "README.md", "lib" ],
       licenses:     [ "Apache 2.0" ],
       links:        %{ "Docs" => @url_docs, "Github" => @url_github }}
  end
end
