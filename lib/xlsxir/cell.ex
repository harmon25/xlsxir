defmodule Xlsxir.Cell do
  @moduledoc """
  Cell Struct
  v: value
  s: style
  f: formula
  t: type
  """

  @doc """
  Workbook struct
  """
  defstruct v: nil, s: nil, f: nil, t: nil, r: nil
  @type t :: %__MODULE__{v: term, s: term, f: term, t: term, r: term}

end
