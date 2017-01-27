defmodule Xlsxir do
  @book_files [book: 'xl/workbook.xml', styles: 'xl/styles.xml', strings: 'xl/sharedStrings.xml']

  @moduledoc """
  Application module, probably not necessary...
  Not sure if necessary, can start with `Xlsxir.Workbook.load(args)`
  """

  @doc """
  Load a workbook, ready to process sheets.

  ## Examples
      iex> f = Path.join(:code.priv_dir(:xlsxir), "test_workbook.xlsx")
      iex> {:ok, workbook} = Xlsxir.load(f)

  """
  def load(workbook) do
    wb = String.to_charlist(workbook)
    {:ok, handle} = :zip.zip_open(wb  ,[:memory])
    {:ok, {_styles_name, styles_xml }} = :zip.zip_get(@book_files[:styles], handle)
    {:ok, {_strings_name, strings_xml }} = :zip.zip_get(@book_files[:strings], handle)


    {:ok, pid} = Supervisor.start_child(Xlsxir.Supervisor, Supervisor.Spec.worker(Xlsxir.Styles, [[xml: styles_xml]], [name: Xlsxir.Styles]))
    {:ok, pid} = Supervisor.start_child(Xlsxir.Supervisor, Supervisor.Spec.worker(Xlsxir.SharedStrings, [[xml: strings_xml]], [name: Xlsxir.SharedStrings]))


    {:ok, pid} = Supervisor.start_child(Xlsxir.Supervisor, Supervisor.Spec.worker(Xlsxir.Zip, [[zip: handle, path: wb]], [name: Xlsxir.Zip]))


    {:ok, pid} = Supervisor.start_child(Xlsxir.Supervisor, Supervisor.Spec.supervisor(Xlsxir.Workbook, [[handle: handle]], []))
  end


end
