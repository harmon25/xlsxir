
defmodule Xlsxir.Styles do
  use GenServer
  @moduledoc """
  Hold onto shared strings xml for parsing
  """
  @doc """
  SharedStrings struct
  """
  defstruct  xml: "", num_formats: [], fonts: [],
             fills: [], borders: [], style_refs: [],
             cell_styles: [], table_styles: []

  @type t :: %__MODULE__{xml: String.t, num_formats: list, fonts: list,
                         fills: list, borders: list, style_refs: list,
                         cell_styles: list,table_styles: list}


  def start_link(args) do
    xml = Keyword.get(args, :xml, "")
    GenServer.start_link(__MODULE__, %__MODULE__{xml: xml}, name: __MODULE__)
  end

  # can do parsing here, call back immediatly affter start link, have xml in state
  def init(state) do
    {:ok, state}
  end

  def xml(pid) do
    GenServer.call(pid, :xml)
  end

  def handle_call(:xml, _from, %__MODULE__{xml: xml} = state) do
    {:reply, xml, state}
  end

end
