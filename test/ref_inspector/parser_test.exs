defmodule RefInspector.ParserTest do
  use ExUnit.Case, async: true

  test "empty referer" do
    empty = %{
      referer: "",
      medium:  :unknown,
      source:  :unknown,
      term:    :none
    }

    assert RefInspector.parse("") == empty
  end

  test "completely unknown" do
    referer  = "http://i.will.not.be.found/"
    response = %{
      referer: referer,
      medium:  :unknown,
      source:  :unknown,
      term:    :none
    }

    assert RefInspector.parse(referer) == response
  end

  test "no query" do
    referer  = "http://www.google.com/search"
    response = %{
      referer: referer,
      medium:  :search,
      source:  "google",
      term:    :none
    }

    assert RefInspector.parse(referer) == response
  end

  test "google search" do
    referer  = "http://www.google.com/search?q=snowplow+referer+parser&hl=en&client=chrome"
    response = %{
      referer: referer,
      medium:  :search,
      source:  "google",
      term:    "snowplow referer parser"
    }

    assert RefInspector.parse(referer) == response
  end

  test "google empty search" do
    referer  = "http://www.google.com/search?q=&hl=en&client=chrome"
    response = %{
      referer: referer,
      medium:  :search,
      source:  "google",
      term:    ""
    }

    assert RefInspector.parse(referer) == response
  end

  test "parameters less referer" do
    referer  = "https://twitter.com/elixirlang"
    response = %{
      referer: referer,
      medium:  :social,
      source:  "twitter",
      term:    :none
    }

    assert RefInspector.parse(referer) == response
  end
end
