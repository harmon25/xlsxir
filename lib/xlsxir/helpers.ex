defmodule Xlsxir.Helpers do
@letters "ABCDEFGHIJKLMNOPQRSTUVQXYZ"

def letters_to_list() do
  String.codepoints(@letters)
end

 # TODO
 # http://stackoverflow.com/questions/19153462/get-excel-style-column-names-from-column-number
def num_to_col(num) do
  numeric = mod(num, 26)
  :ok
end

 # TODO
def col_to_num(col) do
  :ok
end

def mod(x,y) when x > 0 do
  Kernel.rem(x,y)
end

def mod(x,y) when x < 0 do
  Kernel.rem(y+x, y)
end

def mod(0,y), do: 0



end
