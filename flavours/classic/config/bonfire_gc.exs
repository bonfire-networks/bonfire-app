import Config

config :bonfire_gc,
  mixins: [
    # these mixins should be deleted if their 
    delete: [
      Bonfire.Data.AccessControl.InstanceAdmin,
      Bonfire.Data.Identity.Email,
      Bonfire.Data.Identity.Accounted,
      Bonfire.Data.Identity.Named,
      Bonfire.Data.Social.Inbox,
      Bonfire.Data.Social.Profile,
      Bonfire.Data.ActivityPub.Peered,
      Bonfire.Data.Social.Created,
      Bonfire.Data.ActivityPub.Actor,
      Bonfire.Data.Identity.Credential,
      Bonfire.Boundaries.Stereotype,
      Bonfire.Data.Social.Replied,
      Bonfire.Tag.Tagged,
      Bonfire.Data.Identity.Caretaker,
      Bonfire.Data.Identity.Self,
      Bonfire.Data.Social.PostContent
    ],
  ]
