defmodule ElixirPipelines.AdminRouter do
  use Plug.Router

  plug ElixirPipelines.Auth

  plug :match
  plug :dispatch

  post "/add" do
    ElixirPipelines.AdminController.add(conn)
  end

  delete "/delete" do
    ElixirPipelines.AdminController.delete(conn)
  end

  post "/reload" do
    ElixirPipelines.AdminController.reload(conn)
  end
end
