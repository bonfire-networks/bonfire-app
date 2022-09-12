# SPDX-License-Identifier: AGPL-3.0-only
if Bonfire.Common.Extend.module_enabled?(Bonfire.API.GraphQL) and
     Bonfire.Common.Extend.module_enabled?(Bonfire.ValueFlows.API.Schema) and
     Bonfire.Common.Extend.module_enabled?(Absinthe.Schema.Notation) do
  defmodule Bonfire.API.GraphQL.Schema do
    @moduledoc """
    Root GraphQL Schema.
    Only active if the `Bonfire.API.GraphQL` extension is present.
    """

    use Absinthe.Schema
    @schema_provider Absinthe.Schema.PersistentTerm

    # @pipeline_modifier Bonfire.API.GraphQL.SchemaPipelines

    require Logger

    alias Bonfire.API.GraphQL.SchemaUtils
    alias Bonfire.API.GraphQL.Middleware.CollapseErrors
    alias Absinthe.Resolution.Helpers

    @doc """
    Define dataloaders
    see https://hexdocs.pm/absinthe/1.4.6/ecto.html#dataloader
    """
    def context(ctx) do
      # IO.inspect(ctx: ctx)
      loader =
        Dataloader.add_source(
          Dataloader.new(),
          Pointers.Pointer,
          Bonfire.Common.Pointers.dataloader(ctx)
        )

      # |> Dataloader.add_source(Bonfire.Data.Social.Posts, Bonfire.Common.Pointers.dataloader(ctx) )

      Map.put(ctx, :loader, loader)
    end

    def plugins do
      [
        Absinthe.Middleware.Async,
        Absinthe.Middleware.Batch,
        Absinthe.Middleware.Dataloader
      ] ++
        Absinthe.Plugin.defaults()
    end

    def middleware(middleware, _field, _object) do
      # [{Bonfire.API.GraphQL.Middleware.Debug, :start}] ++
      middleware ++ [CollapseErrors]
    end

    import_types(Bonfire.API.GraphQL.JSON)
    import_types(Bonfire.API.GraphQL.Cursor)

    import_types(Bonfire.API.GraphQL.CommonSchema)

    # Extension Modules
    import_types(Bonfire.Me.API.GraphQL)
    import_types(Bonfire.Social.API.GraphQL)

    # import_types(CommonsPub.Locales.GraphQL.Schema)

    import_types(Bonfire.Tag.GraphQL.TagSchema)
    import_types(Bonfire.Classify.GraphQL.ClassifySchema)

    import_types(Bonfire.Quantify.Units.GraphQL)
    import_types(Bonfire.Geolocate.GraphQL)

    import_types(Bonfire.ValueFlows.API.Schema)
    import_types(Bonfire.ValueFlows.API.Schema.Subscriptions)

    import_types(Bonfire.ValueFlows.API.Schema.Observe)

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
      import_fields(:me_mutations)
      import_fields(:social_mutations)

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

    union :any_character do
      description(
        "Any type of character (eg. Category, Thread, Geolocation, etc), actor (eg. User/Person), or agent (eg. Organisation)"
      )

      # TODO: autogenerate from extensions
      # types(SchemaUtils.context_types)

      types([
        # :community,
        # :collection,
        :user,
        # :organisation,
        :category,
        :spatial_thing
      ])

      resolve_type(&schema_to_api_type/2)
    end

    union :any_context do
      description("Any type of known object")

      # TODO: autogenerate from extensions or pointers
      # types(SchemaUtils.context_types)

      types([
        # :community,
        # :collection,
        # :comment,
        # :flag,
        # :follow,
        :activity,
        :post,
        :user,
        # :organisation,
        :category,
        :tag,
        :spatial_thing,
        :intent,
        :process,
        :economic_event
      ])

      resolve_type(&schema_to_api_type/2)
    end

    def schema_to_api_type(object, recursing) do
      case object do
        %Bonfire.Data.Identity.User{} ->
          :user

        %Bonfire.Data.Social.Post{} ->
          :post

        %Bonfire.Data.Social.Activity{} ->
          :activity

        %Bonfire.Data.Social.Follow{} ->
          :follow

        # %Bonfire.Data.SharedUser{} ->
        #   :organisation

        %Bonfire.Geolocate.Geolocation{} ->
          :spatial_thing

        %Bonfire.Classify.Category{} ->
          :category

        # %Bonfire.Tag{} -> :tag
        # %ValueFlows.Planning.Intent{} -> :intent
        # %ValueFlows.Process{} -> :process
        # %ValueFlows.EconomicEvent{} -> :economic_event

        object ->
          case Bonfire.Common.Types.object_type(object) do
            type when is_atom(type) and not is_nil(type) ->
              Logger.debug("API any_context: object_type recognised: #{type}")

              if recursing != true do
                schema_to_api_type(struct(type), true)
              else
                Logger.error("API any_context: no API type is defined for schema #{type}")

                IO.inspect(object, label: "API any_context object")
                nil
              end

            _ ->
              Logger.warn(
                "API any_context: resolved to an unknown type: #{inspect(object, pretty: true)}"
              )

              nil
          end
      end
    end
  end
end
