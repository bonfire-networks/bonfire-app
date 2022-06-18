defmodule Bonfire.ObanLogger do
  require Logger

  def setup do

    :telemetry.attach("bonfire-oban-errors", [:oban, :job, :exception], &Bonfire.ObanLogger.handle_event/4, [])
  end

  def handle_event([:oban, :job, :exception], measure, meta, _) do
    extra =
      meta.job
      |> Map.take([:id, :args, :meta, :queue, :worker])
      |> Map.merge(measure)

    Bonfire.Common.Utils.debug_log(extra, meta.error, meta.stacktrace, :error)
  end
end
