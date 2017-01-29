defmodule Xlsxir do
  @moduledoc """
  Functions for manipulating Xlsxir.Application supervision tree
  """
  @xlsxir_reg :xlsxir_registry
  alias Xlsxir.{Worksheet}



  @doc """
  Load a workbook, ready to process sheets.

  ## Examples
      iex> f = Path.join(:code.priv_dir(:xlsxir), "test_workbook.xlsx")
      iex> {:ok, {workbook, pid}} = Xlsxir.load(f)

  """
  def load(workbook) do
    name = "wb#{wb_count()}"
    {:ok, _wb_super} = Xlsxir.Application.load_workbook(workbook, name)
    sheet_super = get_sheet_super(name)
    {pid, wb} = get_wb(name)
    Enum.each(wb.sheets, &Xlsxir.Application.launch_worksheet(sheet_super, &1, name))
    {:ok, {name, pid}}
  end


  @doc """
  Retrieve process and value of a workbook

  ## Examples
      iex> Xlsxir.get_wb("wb0")
      iex> {pid, %Xlsxir.Workbook{}}

  """
  def get_wb(name) do
    case(Registry.match(@xlsxir_reg, name, %{name: name})) do
      [] -> nil
      [wb] -> wb
    end
  end


  def get_wb_sheet(wb_name, s_name) do
    sheet_super = get_sheet_super(wb_name)

    resp =
    Supervisor.which_children(sheet_super)
    |> Enum.map(&Worksheet.info(&1))
    |> Enum.filter(fn s-> s.name == s_name end)

    case(resp) do
      [] -> nil
      [ws] -> ws
    end
  end


  @doc """
  Get sheet supervisor of a workbook

  ## Examples
      iex> Xlsxir.get_sheet_super("wb0")
      iex> pid
  """
  def get_sheet_super(wbname) do
    [{pid, "sheet_super"}] = Registry.match(@xlsxir_reg, wbname, "sheet_super")
    pid
  end

  @doc """
  Count of loaded workbooks

  ## Examples
      iex> Xlsxir.workbooks()
      iex> [{pid, %Xlsxir.Workbook{}}]
  """
  def wb_count() do
      Supervisor.which_children(Xlsxir.Supervisor)
      |> Enum.filter(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.WorkbookSuper end)
      |> Enum.count
  end

  @doc """
  List of loaded workbooks.

  ## Examples
      iex> Xlsxir.workbooks()
      iex> [{pid, %Xlsxir.Workbook{}}]
  """

  def workbooks() do
    Supervisor.which_children(Xlsxir.Supervisor)
    |> Enum.filter_map(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.WorkbookSuper end,
    fn {_sheet_name, sheet_pid, _, [_child_mod]} ->
        [wb] = Registry.keys(@xlsxir_reg,  sheet_pid )
        get_wb(wb)
      end)
    |> List.flatten
  end







end
