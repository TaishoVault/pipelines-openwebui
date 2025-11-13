defmodule ElixirPipelines.Router do
  use Plug.Router

  plug ElixirPipelines.RequestId

  plug Plug.Parsers, parsers: [:json],
                      pass: ["application/json"],
                      json_decoder: Jason

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "{\"status\": true}")
  end

  get "/v1" do
    send_resp(conn, 200, "{\"status\": true}")
  end

  get "/models" do
    ElixirPipelines.ChatController.models(conn)
  end

  get "/v1/models" do
    ElixirPipelines.ChatController.models(conn)
  end

  get "/pipelines" do
    send_resp(conn, 200, "{\"data\": []}")
  end

  get "/v1/pipelines" do
    send_resp(conn, 200, "{\"data\": []}")
  end

  post "/chat/completions" do
    ElixirPipelines.ChatController.chat_completions(conn)
  end

  post "/v1/chat/completions" do
    ElixirPipelines.ChatController.chat_completions(conn)
  end

  forward "/pipelines", to: ElixirPipelines.AdminRouter
  forward "/v1/pipelines", to: ElixirPipelines.AdminRouter

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
