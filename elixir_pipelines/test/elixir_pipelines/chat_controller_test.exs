defmodule ElixirPipelines.ChatControllerTest do
  use ExUnit.Case
  use Plug.Test

  alias ElixirPipelines.Router

  @opts Router.init([])

  test "POST /v1/chat/completions" do
    ElixirPipelines.PipelineRegistry.register_pipeline(Elixir.ExamplePipeline, %{"example_valve" => "hello"})

    conn = conn(:post, "/v1/chat/completions", ~s({
      "model": "Elixir.ExamplePipeline",
      "messages": [{"role": "user", "content": "Hello"}]
    }))
    |> put_req_header("content-type", "application/json")

    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == ~s({"choices":[{"message":{"content":"Hello from the example pipeline! Your valve is: hello"}}]})
  end
end
