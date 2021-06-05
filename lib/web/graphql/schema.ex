if Bonfire.Common.Utils.module_enabled?(Bonfire.GraphQL) and Bonfire.Common.Utils.module_enabled?(ValueFlows.Schema) do
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.GraphQL.Schema do
  @moduledoc "Root GraphQL Schema"
  use Absinthe.Schema
  @schema_provider Absinthe.Schema.PersistentTerm

  # import Bonfire.GraphQL.SchemaUtils

  require Logger

  alias Bonfire.GraphQL.SchemaUtils
  alias Bonfire.GraphQL.Middleware.CollapseErrors
  alias Absinthe.Middleware.{Async, Batch}

  # @pipeline_modifier OverridePhase

  def plugins, do: [Async, Batch]

  def middleware(middleware, _field, _object) do
    # [{Bonfire.GraphQL.Middleware.Debug, :start}] ++
    middleware ++ [CollapseErrors]
  end

  import_types(Bonfire.GraphQL.JSON)
  import_types(Bonfire.GraphQL.Cursor)

  import_types(Bonfire.GraphQL.CommonSchema)

  # import_types(CommonsPub.Web.GraphQL.MiscSchema)


  # Extension Modules
  # import_types(CommonsPub.Profiles.GraphQL.Schema)
  # import_types(CommonsPub.Characters.GraphQL.Schema)

  # import_types(Organisation.GraphQL.Schema)

  # import_types(CommonsPub.Locales.GraphQL.Schema)

  import_types(Bonfire.Tag.GraphQL.TagSchema)
  import_types(Bonfire.Classify.GraphQL.ClassifySchema)

  import_types(Bonfire.Quantify.Units.GraphQL)
  import_types(Bonfire.Geolocate.GraphQL)

  import_types(ValueFlows.Schema)

  import_types(ValueFlows.Observe.GraphQL)


  query do
    import_fields(:common_queries)

    # Extension Modules
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

  @doc """
  hydrate SDL schema with resolvers
  """
  def hydrate(%Absinthe.Blueprint{}, _) do
    SchemaUtils.hydrations_merge([
      &Bonfire.Geolocate.GraphQL.Hydration.hydrate/0,
      &Bonfire.Quantify.Hydration.hydrate/0,
      &ValueFlows.Hydration.hydrate/0,
      &ValueFlows.Observe.Hydration.hydrate/0
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
