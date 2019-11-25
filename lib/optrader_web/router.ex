defmodule OptraderWeb.Router do
  use OptraderWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/api", OptraderWeb do
    pipe_through :api

    resources "/fear_and_greed", FearAndGreedController, only: [:index, :show]
    resources "/trends", TrendsController, only: [:index, :show]
  end

  scope "/", OptraderWeb do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
    get "/fear", FearAndGreedController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", OptraderWeb do
  #   pipe_through :api
  # end
end
