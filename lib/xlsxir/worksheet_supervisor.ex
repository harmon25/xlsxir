  defmodule Xlsxir.WorksheetSuper do
  @xlsxir_reg :xlsxir_registry
  @moduledoc """
  Worksheet supervisor.
  Supervises worksheet processes to allow for parallel xml parsing
  """
  use Supervisor
  import SweetXml
  alias Xlsxir.{Worksheet}


  # could do more here, pass processed args as args to init,
  # rather than doing everything in init.
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    # register under workbook key
    Registry.register(:xlsxir_registry, args[:wb], "sheet_super")

    sheet_workers = [worker(Worksheet, [], restart: :transient)]
   supervise(sheet_workers, strategy: :simple_one_for_one)

  end


end
