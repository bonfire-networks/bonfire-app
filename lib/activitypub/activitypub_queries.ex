defmodule Bonfire.ActivityPub.Queries do

  use Bonfire.Repo.Query,
      schema: ActivityPub.Object,
      searchable_fields: [:id, :data, :local, :public, :pointer_id],
      sortable_fields: [:id, :pointer_id]
  # TODO: test querying AP table

end
