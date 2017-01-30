defmodule Xlsxir.Helpers do
@letters [?A, ?B, ?C, ?D, ?E, ?F, ?G, ?H, ?I, ?J, ?K, ?L, ?M, ?N, ?O, ?P, ?Q, ?R, ?S, ?T, ?U, ?V, ?W, ?X, ?Y, ?Z]
@letters_w ~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
@c_regex ~r"(?<c>\D+)(?<r>\d+)"


def letters_to_list() do
  String.codepoints(@letters)
end

 # TODO
 # http://stackoverflow.com/questions/19153462/get-excel-style-column-names-from-column-number

def num_to_excel(row, col) do
  #numeric = mod(num, 26)
  col_num_to_letter(col) <> Integer.to_string(row)
end

# first run
def col_num_to_letter(c) do
  {col, rem} = divmod(c)
  col_num_to_letter({col,rem}, "")
end

# keep looping on more c > 0
def col_num_to_letter({c, rem}, result) when c == 0 do
 result <> Enum.fetch!(@letters_w, rem)
end

## first loop
def col_num_to_letter({c,_r}, result) do
  {col, rem} = divmod(c)
  res = result <> Enum.fetch!(@letters_w, rem)
  col_num_to_letter({col,rem}, res)
  #res = result <> Enum.fetch!(@letters_w, c-1)
end

def divmod(col, denominator \\ 26) do
  c = col - 1
  {Integer.floor_div(c, denominator), Integer.mod(c, denominator) }
  |> IO.inspect
end

 # TODO
def excel_to_num(excel) do
  case(split_cell(excel)) do
    {:error, reason} -> {:error, reason}
    %{"c"=> c, "r"=> r} ->
      String.to_charlist(c)

  end
end

def mod(x,y) when x > 0 do
  Kernel.rem(x,y)
end

def mod(x,y) when x < 0 do
  Kernel.rem(y+x, y)
end

def mod(0,y), do: 0

def letters() do
  @letters
end

def split_cell(cell) do
  case(Regex.named_captures(@c_regex, cell)) do
    nil -> {:error, "invalid cell string"}
     cell -> cell
  end
end

 #  Integer.floor_div(10,26) Integer.mod()

end
