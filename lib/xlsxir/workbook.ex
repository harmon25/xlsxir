defmodule Xlsxir.Workbook do
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
    {:ok, wb}
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
