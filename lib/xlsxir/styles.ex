
defmodule Xlsxir.Styles do
  @moduledoc """
  Hold onto shared strings xml for parsing
  """
  @doc """
  SharedStrings struct
  """
  defstruct  xml: "", styles: %{}
  @type t :: %__MODULE__{xml: String.t, styles: map}
  use GenServer


  def start_link(args) do
    xml = Keyword.get(args, :xml, "")
    GenServer.start_link(__MODULE__, %Xlsxir.Styles{xml: xml}, name: __MODULE__)
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
