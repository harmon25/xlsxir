defmodule Xlsxir.Worksheet do
  import SweetXml
  alias Xlsxir.{Parsers}

  @moduledoc """
  Documentation for Xlsxir.Worksheet
  """

  @doc """
  Worksheet struct
  """
  defstruct name: nil, rel_id: nil, id: nil, path: nil, data: [], dimension: { nil, nil }
  @type t :: %__MODULE__{name: String.t, rel_id: String.t, id: integer, path: iolist, data: [], dimension: tuple}

  use GenServer


  def start_link(args) do
#    IO.puts "SHEET ARGS!"
#    IO.inspect args
    GenServer.start_link(__MODULE__, args)
  end

  # expecting :sheet struct and :wb name
  def init([sheet: sheet, wb: wb]) do
    %{handle: handle} = Xlsxir.Zip.get_handle(wb)
    {:ok, {_file_name, sheet_xml }} = :zip.zip_get(sheet.path, handle)

    [start_sheet, end_sheet] = Parsers.worksheet_dimensions(sheet_xml)

    {:ok, {wb, %__MODULE__{sheet | dimension: {start_sheet, end_sheet}}}}
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


  def info({:undefined, pid, :worker, [Xlsxir.Worksheet]}) do
    GenServer.call(pid, :info)
  end
  @doc """
  Returns sheet a Xlsxir.Sheet struct
  ## Examples
      iex> Xlsxir.Worksheet.info(pid)
        %Xlsxir.Sheet{}
  """
  def info(pid) do
    GenServer.call(pid, :info)
  end


  def handle_call(:info, _from, ws) do
    {:reply, ws, ws}
  end

  def handle_call(:name, _from, ws) do
    {:reply, ws.name, ws}
  end

end
