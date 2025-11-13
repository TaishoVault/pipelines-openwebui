defmodule ExamplePipeline do
  def pipe(_user_message, _model_id, _messages, _body, valves) do
    "Hello from the example pipeline! Your valve is: #{valves["example_valve"]}"
  end
end
