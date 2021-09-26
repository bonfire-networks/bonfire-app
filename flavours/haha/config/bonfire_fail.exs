import Config

config :bonfire_fail,
  common_errors: %{
    unauthorized: {403, "You do not have permission to %s."},
    not_found: {404, "%s Not Found."},
    unauthenticated: {401, "You need to log in first."},
    needs_login: {401, "You need to log in first."},
    invalid_credentials: {401, "We couldn't find an account with the details you provided."},
    deletion_error: {400, "Could not delete:"},
    bad_header: {400, "Bad request: malformed header."},
    no_access: {403, "This site is by invitation only."},
    token_expired: {403, "This link or token has expired, please request a fresh one."},
    already_claimed: {403, "This link or token was already used, please request a fresh one if necessary."},
    token_not_found: {403, "This token was not found, please request a fresh one."},
    user_disabled: {403, "This user account is disabled. Please contact the instance administrator."},
    email_not_confirmed: {403, "Please confirm your email address first."},
    unknown_resource: {400, "Unknown resource."},
    invalid_argument: {400, "Invalid arguments passed."},
    password_hash_missing: {401, "Reset your password to login."},
    user_not_found: {404, "User not found."},
    unknown: {500, "Something went wrong."}
  }
