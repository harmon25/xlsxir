defmodule Xlsxir do
  use Application
  @book_files [book: 'xl/workbook.xml', styles: 'xl/styles.xml', strings: 'xl/sharedStrings.xml']
  @xlsxir_reg :xlsxir_registry


  @moduledoc """
  Application module, probably not necessary...
  Not sure if necessary, can start with `Xlsxir.Workbook.load(args)`
  """

  # we are a supervisor.
  def start(_type, _args) do
    parts = System.schedulers_online()
    import Supervisor.Spec, warn: false
    children = [supervisor(Registry, [:duplicate, @xlsxir_reg, [partitions: 1 ]]),
                worker(Xlsxir.Zip, [[]], [name: Xlsxir.Zip])]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end


  def get_wb(name) do
    Registry.match(@xlsxir_reg, name, %{name: name})

  end


  def get_sheet_super(wbname) do
    [{pid, "sheet_super"}] = Registry.match(@xlsxir_reg, wbname, "sheet_super")
    pid
  end



  def wb_count() do
      Supervisor.which_children(__MODULE__)
      |> Enum.filter(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.WorkbookSuper end)
      |> Enum.count
  end

  def workbooks() do
    Supervisor.which_children(__MODULE__)
    |> Enum.filter_map(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.WorkbookSuper end,
    fn {_sheet_name, sheet_pid, _, [_child_mod]} ->
        [wb] = Registry.keys(@xlsxir_reg,  sheet_pid )
        get_wb(wb)
      end)
    |> List.flatten
  end
  @doc """
  Load a workbook, ready to process sheets.

  ## Examples
      iex> f = Path.join(:code.priv_dir(:xlsxir), "test_workbook.xlsx")
      iex> {:ok, workbook} = Xlsxir.load(f)

  """
  def load(workbook) do
    import Supervisor.Spec, warn: false

    #{:ok, {_styles_name, styles_xml }} = :zip.zip_get(@book_files[:styles], handle)
    #{:ok, {_strings_name, strings_xml }} = :zsaip.zip_get(@book_files[:strings], handle)
    name = "wb#{wb_count()}"
    args = [path: workbook, name: name]

    {:ok, wb_super} =  Supervisor.start_child(__MODULE__, supervisor(Xlsxir.WorkbookSuper, [args], [id: name]))
    {:ok, name}
  end





end
