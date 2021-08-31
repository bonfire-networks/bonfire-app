defmodule Bonfire.ObanLogger do
  def handle_event([:oban, :job, :exception], measure, meta, _) do
    extra =
      meta
      |> Map.take([:id, :args, :queue, :worker])
      |> Map.merge(measure)

    if is_binary(meta.error) do
      Sentry.capture_message(meta.error, stacktrace: meta.stacktrace, extra: extra)
    else
      Sentry.capture_exception(meta.error, stacktrace: meta.stacktrace, extra: extra)
    end
  end
end
