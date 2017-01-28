defmodule Xlsxir.Workbook do
  @moduledoc """
  Workbook Struct - maintained as the value of the worbook supervisor
  registered under "wb0" key  in :xlsxir_reg
  """

  @doc """
  Workbook struct
  """
  defstruct file_path: nil, sheets: [], defined_names: [], name: nil, xml: nil
  @type t :: %__MODULE__{file_path: String.t, sheets: list, name: String.t, xml: String.t}


end
