  defmodule Xlsxir.WorkbookSuper do
  @xlsxir_reg :xlsxir_registry
  @moduledoc """
  Workbook supervisor.
  Supervises worksheet processes to hopefully allow for parallel xml parsing of
  sheets and other xmls since they are each in their own process
  """

  use Supervisor
  alias Xlsxir.{Styles, SharedStrings, Workbook, Zip, Worksheet, WorksheetSuper, Parsers}
  import SweetXml

  @book_files [book: 'xl/workbook.xml', styles: 'xl/styles.xml', strings: 'xl/sharedStrings.xml']

  def start_link(args) do
    Supervisor.start_link(__MODULE__, [path: args[:path], name: args[:name]])
  end

  def init(args) do
    path = Keyword.get(args, :path, nil)
    handle = Zip.new_handle(path, args[:name])

    {:ok, {_file_name, book_xml }} = :zip.zip_get(@book_files[:book], handle)

    sheets = Parsers.workbook_sheets(book_xml)
    names = Parsers.workbook_defined_names(book_xml)

    # register this supervisor process as the "Workbook"
    # this is the only process with the key "wbX" that has the value of a workbook struct.
    Registry.register(:xlsxir_registry, args[:name], %Workbook{name: args[:name], xml: book_xml, file_path: path, sheets: sheets, defined_names: names})

    # not using these just yet, also place in their own process?
     {:ok, {styles_name, styles_xml }} = :zip.zip_get(@book_files[:styles], handle)
     {:ok, {strings_name, strings_xml }} = :zip.zip_get(@book_files[:strings], handle)

    book_workers =
      [worker(Styles, [[xml: styles_xml, wb: args[:name]]], []),
      worker(SharedStrings, [[xml: strings_xml, wb: args[:name]]], []),
      supervisor(WorksheetSuper, [[wb: args[:name]]], [])
      ]

    # launch supervisor
     supervise(book_workers , strategy: :one_for_one)
  end

 # TODO
  def sheets() do
    :ok
  end

  def styles_xml() do
    :ok
  end

  def strings_xml() do
    :ok
  end

end
