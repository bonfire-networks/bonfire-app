defmodule VoxPublica.Repo.Migrations.ImportWorld do
  use Ecto.Migration

  import CommonsPub.Accounts.Account.Migration
  import CommonsPub.Accounts.Accounted.Migration
  import CommonsPub.Characters.Character.Migration
  import CommonsPub.Circles.Circle.Migration
  import CommonsPub.Emails.Email.Migration
  import CommonsPub.LocalAuth.LoginCredential.Migration
  import CommonsPub.Profiles.Profile.Migration
  import CommonsPub.Users.User.Migration

  def change do
    # accounts
    migrate_account()
    migrate_accounted()
    migrate_circle()
    migrate_email()
    migrate_login_credential()
    # users
    migrate_user()
    migrate_character()
    migrate_profile()
  end

end
