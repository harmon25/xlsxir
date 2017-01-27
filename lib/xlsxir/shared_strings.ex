defmodule Xlsxir.SharedStrings do
  @moduledoc """
  Hold onto shared strings xml for parsing
  """
  @doc """
  SharedStrings struct
  """
  defstruct  xml: "", strings: %{}
  @type t :: %__MODULE__{xml: String.t, strings: map}
  use GenServer


  def start_link(args) do
    GenServer.start_link(__MODULE__, %Xlsxir.SharedStrings{xml: args[:xml]}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def get_handle() do
    GenServer.call(__MODULE__, :zip)
  end

  def handle_call(:zip, _from, %{zip: zip} = state) do
    {:reply, zip, state}
  end

end
