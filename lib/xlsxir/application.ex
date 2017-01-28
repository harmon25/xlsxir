defmodule Xlsxir.Application do
  @xlsxir_reg :xlsxir_registry
  import Supervisor.Spec, warn: false


  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    # Define workers and child supervisors to be supervised
    children = [supervisor(Registry, [:duplicate, @xlsxir_reg, [partitions: 1 ]]),
                worker(Xlsxir.Zip, [[]], [name: Xlsxir.Zip])]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Xlsxir.Supervisor]
    Supervisor.start_link(children, opts)
  end

def load_workbook(workbook, name) do
  args = [path: workbook, name: name]
  Supervisor.start_child(Xlsxir.Supervisor, supervisor(Xlsxir.WorkbookSuper, [args], [id: name]))
end

def launch_worksheet(ws_super, worksheet, wb_name) do
  Supervisor.start_child(ws_super, [[sheet: worksheet, wb: wb_name]])
end




end
