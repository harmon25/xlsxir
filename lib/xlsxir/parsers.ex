defmodule Xlsxir.Parsers do
  import SweetXml
  alias Xlsxir.{Worksheet}

  def workbook_sheets(wb_xml) do
    wb_xml
    |> xpath(~x"//sheets/./sheet"l, name: ~x"//./@name"s, id: ~x"//./@sheetId"i, rel_id: ~x"//./@r:id"s)
    |> Enum.map(fn s ->
     struct(%Worksheet{path: String.to_charlist("xl/worksheets/sheet#{s.id}.xml")}, s) end)
  end

  def workbook_defined_names(wb_xml) do
    wb_xml |> xpath(~x"//definedNames/./definedName"l, name: ~x"//./@name"s, range: ~x"//./text()"s)
  end

  def worksheet_dimensions(ws_xml) do
    ws_xml
    |> xpath(~x"//dimension/@ref"s)
    |> String.split(":")
  end

end
