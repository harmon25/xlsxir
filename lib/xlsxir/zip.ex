
defmodule Xlsxir.Zip do
  use GenServer

  @moduledoc """
  Holds onto zip handler for future reference, supervised by workbook
  """

  @doc """
  Workbook struct
  """
  defstruct  zip_handles: []
  @type t :: %__MODULE__{zip_handles: list}


  def start_link(args) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def new_handle(path, wb_name) do
    GenServer.call(__MODULE__, {:add_handle, path, wb_name})
  end

  def get_handle(wb_name) do
    GenServer.call(__MODULE__,  {:get_handle, wb_name})
  end

  def get_handles() do
    GenServer.call(__MODULE__, :zips)
  end

  def handle_call({:get_handle, wb_name}, _from, %__MODULE__{zip_handles: handles} = state) do

      [ handle ] =
      Enum.filter(handles, fn h ->
        h.wb == wb_name
      end)

    {:reply, handle, state}
  end

  def handle_call(:zips, _from, %__MODULE__{zip_handles: handles} = state) do
    {:reply, handles, state}
  end

  def handle_call({:add_handle, path, wb_name}, _from, %__MODULE__{zip_handles: handles} = state) do
    wb = String.to_charlist(path)
    {:ok, zip_handle} = :zip.zip_open(wb, [:memory])
    hndl = %{path: wb, handle: zip_handle, wb: wb_name}
    {:reply, zip_handle, %__MODULE__{zip_handles: [hndl | handles]} }
  end

end
