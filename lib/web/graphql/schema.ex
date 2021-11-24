if Bonfire.Common.Utils.module_enabled?(Bonfire.GraphQL) and Bonfire.Common.Utils.module_enabled?(ValueFlows.Schema) do
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.GraphQL.Schema do
  @moduledoc "Root GraphQL Schema. Only active if the `Bonfire.GraphQL` extension is present. "
  use Absinthe.Schema
  @schema_provider Absinthe.Schema.PersistentTerm
  # @pipeline_modifier Bonfire.GraphQL.SchemaPipelines

  require Logger
  alias Bonfire.GraphQL.SchemaUtils
  alias Bonfire.GraphQL.Middleware.CollapseErrors

  @doc """
  Define dataloaders
  see https://hexdocs.pm/absinthe/1.4.6/ecto.html#dataloader
  """
  def context(ctx) do
    loader =
      Dataloader.new
      |> Dataloader.add_source(Bonfire.Data.Identity.User, Bonfire.Common.Pointers.dataloader())
      |> Dataloader.add_source(Bonfire.Data.Social.Posts, Bonfire.Common.Pointers.dataloader())
      # |> Dataloader.add_source(Foo, Foo.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [
      Absinthe.Middleware.Async,
      Absinthe.Middleware.Batch,
      Absinthe.Middleware.Dataloader
    ]
    ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, _object) do
    # [{Bonfire.GraphQL.Middleware.Debug, :start}] ++
    middleware ++ [CollapseErrors]
  end

  import_types(Bonfire.GraphQL.JSON)
  import_types(Bonfire.GraphQL.Cursor)

  import_types(Bonfire.GraphQL.CommonSchema)



  # Extension Modules
  import_types(Bonfire.Me.API.GraphQL)
  import_types(Bonfire.Social.API.GraphQL)

  # import_types(CommonsPub.Locales.GraphQL.Schema)

  import_types(Bonfire.Tag.GraphQL.TagSchema)
  import_types(Bonfire.Classify.GraphQL.ClassifySchema)

  import_types(Bonfire.Quantify.Units.GraphQL)
  import_types(Bonfire.Geolocate.GraphQL)

  import_types(ValueFlows.Schema)
  import_types(ValueFlows.GraphQL.Subscriptions)

  import_types(ValueFlows.Observe.GraphQL)


  query do
    import_fields(:common_queries)

    # Extension Modules
    import_fields(:me_queries)
    import_fields(:social_queries)
    # import_fields(:profile_queries)
    # import_fields(:character_queries)

    # import_fields(:organisations_queries)

    import_fields(:tag_queries)
    import_fields(:classify_queries)

    # import_fields(:locales_queries)

    import_fields(:measurement_query)

    import_fields(:geolocation_query)

    # ValueFlows
    import_fields(:value_flows_query)
    # import_fields(:value_flows_extra_queries)

    import_fields(:valueflows_observe_queries)
  end

  mutation do
    import_fields(:common_mutations)


    # Extension Modules
    # import_fields(:profile_mutations)
    # import_fields(:character_mutations)

    # import_fields(:organisations_mutations)

    import_fields(:tag_mutations)
    import_fields(:classify_mutations)

    import_fields(:geolocation_mutation)
    import_fields(:measurement_mutation)

    # ValueFlows

    import_fields(:value_flows_mutation)

    import_fields(:valueflows_observe_mutations)

  end

  subscription do

    import_fields(:valueflows_subscriptions)

  end


  @doc """
  hydrate SDL schema with resolvers
  """
  def hydrate(%Absinthe.Blueprint{}, _) do
    SchemaUtils.hydrations_merge([
      Bonfire.Geolocate.GraphQL.Hydration,
      Bonfire.Quantify.Hydration,
      ValueFlows.Hydration,
      ValueFlows.Observe.Hydration
    ])
  end

  # hydrations fallback
  def hydrate(_node, _ancestors) do
    []
  end

  union :any_context do
    description("Any type of known object")

    # TODO: autogenerate

    # types(SchemaUtils.context_types)

    types([
      # :community,
      # :collection,
      # :comment,
      # :flag,
      # :follow,
      # :like,
      # :user,
      # :organisation,
      :category,
      :tag,
      :spatial_thing,
      :intent
    ])

    resolve_type(fn
      # %CommonsPub.Users.User{}, _ ->
      #   :user

      # %CommonsPub.Communities.Community{}, _ ->
      #   :community

      # %CommonsPub.Collections.Collection{}, _ ->
      #   :collection

      # %CommonsPub.Threads.Thread{}, _ ->
      #   :thread

      # %CommonsPub.Threads.Comment{}, _ ->
      #   :comment

      # %CommonsPub.Follows.Follow{}, _ ->
      #   :follow

      # %CommonsPub.Likes.Like{}, _ ->
      #   :like

      # %CommonsPub.Flags.Flag{}, _ ->
      #   :flag

      # %CommonsPub.Features.Feature{}, _ ->
      #   :feature

      # %Organisation{}, _ ->
      #   :organisation

      %Bonfire.Geolocate.Geolocation{}, _ ->
        :spatial_thing

      %Bonfire.Classify.Category{}, _ ->
        :category

      %Bonfire.Tag{}, _ ->
        :tag

      %ValueFlows.Planning.Intent{}, _ ->
        :intent

      o, _ ->
        Logger.warn("Any context resolved to an unknown type: #{inspect(o, pretty: true)}")
    end)
  end
end
end
