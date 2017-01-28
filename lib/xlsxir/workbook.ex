defmodule Xlsxir.Workbook do
  alias Xlsxir.{Worksheet, Styles, SharedStrings, Zip}
  import SweetXml

  @xlsxir_reg :xlsxir_registry

  @moduledoc """
  Documentation for Xlsxir.Worksheet
  """

  @doc """
  Workbook struct
  """
  defstruct file_path: nil, sheets: [], name: nil, xml: nil
  @type t :: %__MODULE__{file_path: String.t, sheets: list, name: String.t, xml: String.t}

  use GenServer

  def start_link(wb) do
    GenServer.start_link(__MODULE__, wb, [])
  end


  def init(wb) do
    [{wb_sup, _}] = Registry.lookup(@xlsxir_reg, wb.name)

    sheets =
     wb.xml
     |> xpath(~x"//sheets/./sheet"l, name: ~x"//./@name"s, id: ~x"//./@sheetId"i, rel_id: ~x"//./@r:id"s)
     |> Enum.map(fn s ->

        ws = struct(%Worksheet{path: String.to_charlist("worksheets/sheet#{s.id}.xml")}, s)
        #Supervisor.start_child(wb_sup, Supervisor.Spec.worker(Worksheet, [ws], [id: ws.id]))
        ws
     end)

     #Xlsxir.Workbook.Supervisor.launch_sheets(wb_sup, sheets)

    {:ok, %__MODULE__{wb | sheets: sheets} }
  end
  @doc """
  Returns just the name of the worksheet

  ## Examples
      iex> Xlsxir.Worksheet.name(pid)
      "Sheet1"
  """
  def name(pid) do
    GenServer.call(pid, :name)
  end


  @doc """
  Returns sheet a Xlsxir.Workbook struct
  ## Examples
      iex> Xlsxir.Worksheet.info(pid)
        %Xlsxir.Sheet{}
  """
  def info(pid) do
    GenServer.call(pid, :info)
  end

  def handle_call(:info, _from, wb) do
    {:reply, wb, wb}
  end

  def handle_call(:name, _from, wb) do
    {:reply, wb.name, wb}
  end

end
