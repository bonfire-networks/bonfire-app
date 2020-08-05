defmodule VoxPublica.Repo.Migrations.TestMigrations do
  use Ecto.Migration
  import Pointers.Migration
  
  def up() do
    create_pointable_table("foo", "01EAPGCB6V8GS3D8ZPKDTYDPPW") do
      
    end
    create_pointable_table("bar", "01EAPGCJ3VX4B7AV3Y0QKMNKC9") do

    end
  end
  def down() do
    drop_pointable_table("bar", "01EAPGCJ3VX4B7AV3Y0QKMNKC9")
    drop_pointable_table("foo", "01EAPGCB6V8GS3D8ZPKDTYDPPW")
  end

end
