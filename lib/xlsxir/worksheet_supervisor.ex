  defmodule Xlsxir.WorksheetSuper do
  @xlsxir_reg :xlsxir_registry
  @moduledoc """
  Workbook supervisor.
  Supervises worksheet processes to hopefully allow for parallel xml parsing of
  sheets since they are each in their own process
  """
  use Supervisor
  import SweetXml
  alias Xlsxir.{Worksheet}


  # could do more here, pass processed args as args to init,
  # rather than doing everything in init.
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    # register under workbook key
    Registry.register(:xlsxir_registry, args[:wb], "sheet_super")

    #IO.inspect args
    #path = Keyword.get(args, :path, nil)
    #handle = Zip.new_handle(path)
    # returns a zip handle to be used by future calls, cant store in supervisor,
    # going to stash the handle in another process named Xlsxir.Zip

    #{:ok, handle} = :zip.zip_open(String.to_charlist(xlsx_file)  ,[:memory])
    # reads the xml into string `book_xml`
    #{:ok, {_file_name, book_xml }} = :zip.zip_get(@book_files[:book], handle)

    sheet_workers = [worker(Worksheet, [], restart: :transient)]

     # create worker for zip handler
     # launch supervisor
   supervise(sheet_workers, strategy: :simple_one_for_one)

    #Enum.each(args[:sheets], fn s ->
    #{:ok, pid} = Supervisor.start_child(sheet_super, [s])
    #end)
  end

  @doc """
  Grab all the worksheet details from respective supervised processes

  ## Examples
      iex> f = Path.join(:code.priv_dir(:xlsxir), "test_workbook.xlsx")
      iex> Xlsxir.load(f)
      iex> Xlsxir.Workbook.sheets
      [%Xlsxir.Sheet{data: [], id: 3, name: "sheet with space",
        path: 'worksheets/sheet3.xml', rel_id: "rId3"},
       %Xlsxir.Sheet{data: [], id: 2, name: "AnotherSheet",
        path: 'worksheets/sheet2.xml', rel_id: "rId2"},
       %Xlsxir.Sheet{data: [], id: 1, name: "FirstSheet",
        path: 'worksheets/sheet1.xml', rel_id: "rId1"}]
  """
  def sheets() do
    Supervisor.which_children(__MODULE__)
    |> Enum.filter_map(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.Worksheet end,
      fn {_sheet_name, sheet_pid, _, _} -> Worksheet.info(sheet_pid) end)
  end


  def launch_sheets(pid, worksheets) do
    child_procs = Enum.map(worksheets, fn w ->
        worker(Worksheet, [w], [id: w.id])
    end)
    Supervisor.start_child(pid, child_procs)
  end

  defp via_tuple(wb_name) do
    {:via, Registry, {@xlsxir_reg, wb_name}}
  end

end
