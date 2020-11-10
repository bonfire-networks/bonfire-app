defmodule VoxPublica.Repo.Migrations.ImportWorld do
  use Ecto.Migration
  import Pointers.Migration

  import CommonsPub.Acls.Acl.Migration
  import CommonsPub.Acls.AclGrant.Migration
  import CommonsPub.Circles.Circle.Migration
  import CommonsPub.Circles.Encircle.Migration

  alias CommonsPub.Access.Access

  def up do
    migrate_circle()
    migrate_encircle()
    create_access_table do
      add :can_see, :boolean
    end
    migrate_access_grant()
    create_acl_table do
      add :guest_access_id, strong_pointer(Access), null: false
      add :local_user_access_id, strong_pointer(Access), null: false
    end
    migrate_acl_grant()

  end

  def down do

    migrate_acl_grant()
    drop_acl_table()
    migrate_access_grant()
    drop_access_table()
    migrate_encircle()
    migrate_circle()
  end

end
