defmodule Bonfire.ObanLogger do
  def handle_event([:oban, :job, :exception], measure, meta, _) do
    extra =
      meta
      |> Map.take([:id, :args, :queue, :worker])
      |> Map.merge(measure)

    Sentry.capture_message(meta.error, stacktrace: meta.stacktrace, extra: extra)
  end
end
