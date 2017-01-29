defmodule Xlsxir.SharedStrings do
  use GenServer
  @moduledoc """
  Hold onto shared strings xml for parsing
  """
  @doc """
  SharedStrings struct
  """
  defstruct  xml: "", parsed: false, count: 0,
             unique_count: 0, strings: []

  @type t :: %__MODULE__{xml: String.t, parsed: boolean, count: integer,
                        unique_count: integer, strings: list}


  def start_link([xml: _xml, wb: _wb] = args) do
    GenServer.start_link(__MODULE__, args)
  end

  # can do parsing here, call back immediatly affter start link, have xml in state
  def init([xml: xml, wb: wb]) do
    # register under workbook key
    Registry.register(:xlsxir_registry, wb, "strings")

    # pass xml through to state
    {:ok, %__MODULE__{xml: xml}}
  end

  def xml(pid) do
    GenServer.call(pid, :xml)
  end

  def handle_call(:xml, _from, %__MODULE__{xml: xml} = state) do
    {:reply, xml, state}
  end
end
