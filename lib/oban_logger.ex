defmodule Bonfire.ObanLogger do
  require Logger

  def handle_event([:oban, :job, :exception], measure, meta, _) do
    extra =
      meta.job
      |> Map.take([:id, :args, :meta, :queue, :worker])
      |> Map.merge(measure)

    Logger.error(meta.error)

    Sentry.capture_exception(meta.error, stacktrace: meta.stacktrace, extra: extra)
  end
end
