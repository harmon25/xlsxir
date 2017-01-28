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
    import Supervisor.Spec, warn: false
    children = [supervisor(Registry, [:unique, @xlsxir_reg]),
                worker(Xlsxir.Zip, [[]], [name: Xlsxir.Zip])]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

defp via_tuple(wb_name) do
    {:via, Registry, {@xlsxir_reg, wb_name}}
end

  @doc """
Will find the process identifier (in our case, the `account_id`) if it exists in the registry and
is attached to a running `RegistrySample.Account` process.
If the `account_id` is not present in the registry, it will create a new `RegistrySample.Account`
process and add it to the registry for the given `account_id`.
Returns a tuple such as `{:ok, account_id}` or `{:error, reason}`
"""
def find_or_create_process(wb_name) do
  if wb_process_exists?(wb_name) do
    {:ok, wb_name}
  else
   create_wb_process wb_name
  end
end

  @doc """
  Determines if a `RegistrySample.Account` process exists, based on the `account_id` provided.
  Returns a boolean.
  ## Example
      iex> RegistrySample.AccountSupervisor.account_process_exists?(6)
      false
  """
  def wb_process_exists?(wb_name) do
    case Registry.lookup(@xlsxir_reg, wb_name) do
      [] -> false
      _ -> true
    end
  end

  @doc """
  Creates a new account process, based on the `account_id` integer.
  Returns a tuple such as `{:ok, account_id}` if successful.
  If there is an issue, an `{:error, reason}` tuple is returned.
  """
  def create_wb_process(wb_name) do
    case Supervisor.start_child(__MODULE__, [wb_name]) do
      {:ok, _pid} -> {:ok, wb_name}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
    end
  end



  def wb_count() do
      Supervisor.which_children(__MODULE__)
      |> Enum.filter(fn {_sheet_name, _sheet_pid, _, [child_mod]} -> child_mod == Xlsxir.Workbook.Supervisor end)
      |> Enum.count
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
    #{:ok, {_strings_name, strings_xml }} = :zip.zip_get(@book_files[:strings], handle)
    name = "wb_#{wb_count()}"

    Supervisor.start_child(__MODULE__, supervisor(Xlsxir.Workbook.Supervisor, [[path: workbook, name: name]], []))

  end





end
