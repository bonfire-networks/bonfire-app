if Bonfire.LightweightTestApplication.enabled?() do
  Bonfire.LightweightTestApplication.setup_test!()
else
  Bonfire.Common.Testing.configure_start_test(migrate: true)
end
