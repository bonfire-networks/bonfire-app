defmodule VoxPublica.Repo.Migrations.ImportWorld do
  use Ecto.Migration

  import CommonsPub.Accounts.Account.Migration
  import CommonsPub.Emails.Email.Migration
  import CommonsPub.LocalAuth.LoginCredential.Migration
  import CommonsPub.Profiles.Profile.Migration
  import CommonsPub.Users.User.Migration

  def change do
    # accounts
    migrate_account()
    migrate_email()
    migrate_login_credential()
    # users
    migrate_user()
    migrate_profile()
  end

end
