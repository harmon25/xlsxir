defmodule Xlsxir do
  use Application
  @book_files [book: 'xl/workbook.xml', styles: 'xl/styles.xml', strings: 'xl/sharedStrings.xml']

  @moduledoc """
  Application module, probably not necessary...
  Not sure if necessary, can start with `Xlsxir.Workbook.load(args)`
  """

  # we are a supervisor, not starting children till we have an excel sheet to parse.
  # with the named workers bellow, could not parse multiple workbooks at once.
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link([], opts)
  end

  @doc """
  Load a workbook, ready to process sheets.

  ## Examples
      iex> f = Path.join(:code.priv_dir(:xlsxir), "test_workbook.xlsx")
      iex> {:ok, workbook} = Xlsxir.load(f)

  """
  def load(workbook) do
    import Supervisor.Spec, warn: false

    wb = String.to_charlist(workbook)
    {:ok, handle} = :zip.zip_open(wb  ,[:memory])
    {:ok, {_styles_name, styles_xml }} = :zip.zip_get(@book_files[:styles], handle)
    {:ok, {_strings_name, strings_xml }} = :zip.zip_get(@book_files[:strings], handle)

    workers = [worker(Xlsxir.Styles, [[xml: styles_xml]], [name: Xlsxir.Styles]),
               worker(Xlsxir.SharedStrings, [[xml: strings_xml]], [name: Xlsxir.SharedStrings]),
               worker(Xlsxir.Zip, [[zip: handle, path: wb]], [name: Xlsxir.Zip]),
               supervisor(Xlsxir.Workbook, [[handle: handle]], [])]

      Enum.each(workers, &Supervisor.start_child(__MODULE__, &1))

  end


end
