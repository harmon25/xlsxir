  defmodule Xlsxir.Workbook.Supervisor do
  @xlsxir_reg :xlsxir_registry
  @moduledoc """
  Workbook supervisor.
  Supervises worksheet processes to hopefully allow for parallel xml parsing of
  sheets since they are each in their own process
  """

  use Supervisor
  alias Xlsxir.{Worksheet, Styles, SharedStrings, Workbook, Zip}
  import SweetXml

  @book_files [book: 'xl/workbook.xml', styles: 'xl/styles.xml', strings: 'xl/sharedStrings.xml']

  # could do more here, pass processed args as args to init,
  # rather than doing everything in init.
  def start_link(args) do
    Supervisor.start_link(__MODULE__, [path: args[:path], name: args[:name]], name: via_tuple(args[:name]))
  end

  def init(args) do
    IO.inspect args
    path = Keyword.get(args, :path, nil)
    handle = Zip.new_handle(path)
    # returns a zip handle to be used by future calls, cant store in supervisor,
    # going to stash the handle in another process named Xlsxir.Zip

    #{:ok, handle} = :zip.zip_open(String.to_charlist(xlsx_file)  ,[:memory])
    # reads the xml into string `book_xml`
    {:ok, {_file_name, book_xml }} = :zip.zip_get(@book_files[:book], handle)
    |> IO.inspect

    # not using these just yet, also place in their own process?
     {:ok, {styles_name, styles_xml }} = :zip.zip_get(@book_files[:styles], handle)
     {:ok, {strings_name, strings_xml }} = :zip.zip_get(@book_files[:strings], handle)

    book_workers =
      [worker(Workbook,[%Workbook{name: args[:name], xml: book_xml, file_path: path}], []),
      worker(Styles, [[xml: styles_xml]], []),
      worker(SharedStrings, [[xml: strings_xml]], []),
      ]

     # create worker for zip handler
    #{:ok, pid} = Supervisor.start_child(Xlsxir.Supervisor, Supervisor.Spec.worker(Xlsxir.Zip, [[zip: handle, path: xlsx_file]], [name: Xlsxir.Zip]))
     # launch supervisor
     supervise(book_workers , strategy: :one_for_one)
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

  def styles_xml() do
   [xml] =
    Supervisor.which_children(__MODULE__)
    |> Enum.filter_map(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.Styles end,
      fn {_sheet_name, pid, _, _} -> Styles.xml(pid) end)
    |> IO.inspect


  end

  def strings_xml() do
    Supervisor.which_children(__MODULE__)
    |> Enum.filter_map(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.SharedStrings end,
      fn {_sheet_name, pid, _, _} -> SharedStrings.xml(pid) end)
    |> IO.inspect

  end


  def launch_sheet(pid, %Worksheet{} = ws) do
    Supervisor.start_child(pid, worker(Worksheet, [[ws: ws]], [id: ws.id]))
  end

  defp via_tuple(wb_name) do
    {:via, Registry, {@xlsxir_reg, wb_name}}
  end

end
