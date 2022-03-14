import Config

config :bonfire_boundaries,
  disabled: false # you wouldn't want to do that.

### Verbs are like permissions. Each represents some activity or operation that may or may not be able to perform.
verbs = %{
  see:     %{id: "0BSERV1NG11ST1NGSEX1STENCE", verb: "See"},     # appear in lists of things or feeds.
  read:    %{id: "0EAD1NGSVTTER1YFVNDAMENTA1", verb: "Read"},    # read it (if you can find it)/
  create:  %{id: "4REATE0RP0STBRANDNEW0BJECT", verb: "Create"},  # create a post or other object.
  edit:    %{id: "4HANG1NGVA1VES0FPR0PERT1ES", verb: "Edit"},    # change the fields of an object.
  delete:  %{id: "4AKESTVFFG0AWAYPERMANENT1Y", verb: "Delete"},  # delete the object.
  follow:  %{id: "20SVBSCR1BET0THE0VTPVT0F1T", verb: "Follow"},  # follow a user or thread or whatever.
  like:    %{id: "11KES1ND1CATEAM11DAPPR0VA1", verb: "Like"},    # like an object.
  boost:   %{id: "300ST0R0RANN0VCEANACT1V1TY", verb: "Boost"},   # boost an object.
  flag:    %{id: "71AGSPAM0RVNACCEPTAB1E1TEM", verb: "Flag"},    # flag an object for an administrator to review.
  reply:   %{id: "71TCREAT1NGA11NKEDRESP0NSE", verb: "Reply"},   # reply to a user's object.
  mention: %{id: "0EFERENC1NGTH1NGSE1SEWHERE", verb: "Mention"}, # mention a user or object.
  tag:     %{id: "4ATEG0R1S1NGNGR0VP1NGSTVFF", verb: "Tag"},     # tag a user or object in an object.
  message: %{id: "40NTACTW1THAPR1VATEMESSAGE", verb: "Message"}, # send a direct message to the user.
  request: %{id: "1NEEDPERM1SS10NT0D0TH1SN0W", verb: "Request"}, # request to do another verb (eg. request to follow)
}

all_verb_names = Enum.map(verbs, &elem(&1, 0))
verbs_negative = fn verbs -> Enum.reduce(verbs, %{}, &Map.put(&2, &1, false)) end

config :bonfire,
  verbs: verbs,
  create_verbs: [
    # block:  Bonfire.Data.Social.Block,
    boost:  Bonfire.Data.Social.Boost,
    follow: Bonfire.Data.Social.Follow,
    flag:   Bonfire.Data.Social.Flag,
    like:   Bonfire.Data.Social.Like,
  ]

### Now follows quite a lot of fixtures that must be inserted into the database.

config :bonfire,
  ### Users are placed into one or more circles, either by users or by the system. Circles referenced in ACLs have the
  ### effect of applying to all users in those circles.
  circles: %{
    ### Public circles used to categorise broadly how much of a friend/do the user is.
    guest:        %{id: "0AND0MSTRANGERS0FF1NTERNET", name: "Guests"},
    local:        %{id: "3SERSFR0MY0VR10CA11NSTANCE", name: "Local Users"},
    activity_pub: %{id: "7EDERATEDW1THANACT1V1TYPVB", name: "ActivityPub Peers"},

    ### Stereotypes - placeholders for special per-user circles the system will manage.
    followers:    %{id: "7DAPE0P1E1PERM1TT0F0110WME", name: "My Followers"},
    ghost_them:   %{id: "7N010NGERC0NSENTT0Y0VN0WTY", name: "Others I ghosted"},
    silence_them: %{id: "7N010NGERWANTT011STENT0Y0V", name: "Others I silenced"},
    silence_me:   %{id: "0KF1NEY0VD0N0TWANTT0HEARME", name: "Others who silenced me"},
  },
  ### ACLs (Access Control Lists) are reusable lists of permissions assigned to users and circles. Objects in bonfire
  ### have one or more ACLs attached and we combine the results of all of them to determine whether a user is permitted
  ### to perform a particular operation.
  acls: %{
    ### Public ACLs that allow basic control over visibility and interactions.
    guests_may_see_read: %{id: "7W1DE1YAVA11AB1ET0SEENREAD", name: "Publicly discoverable and readable"},
    guests_may_see:      %{id: "50VCANF1NDMEBVTCAN0T0PENME", name: "Publicly discoverable, but contents may be hidden"},
    guests_may_read:     %{id: "50VCANREAD1FY0VHAVETHE11NK", name: "Publicly readable, but not necessarily discoverable"},
    locals_may_read:     %{id: "10CA1SMAYSEEANDREAD0N1YN0W", name: "Visible to local users"},
    locals_may_interact: %{id: "710CA1SMY1NTERACTN0TREP1YY", name: "Local users may read and interact"},
    locals_may_reply:    %{id: "710CA1SMY1NTERACTANDREP1YY", name: "Local users may read, interact and reply"},

    ### Stereotypes - placeholders for special per-user ACLs the system will manage.

    ## ACLs that confer my personal permissions on things i have created
    # i_may_read:            %{id: "71MAYSEEANDREADMY0WNSTVFFS", name: "I may read"},              # not currently used
    # i_may_interact:        %{id: "71MAY1NTERACTW1MY0WNSTVFFS", name: "I may read and interact"}, # not currently used
    i_may_administer:      %{id: "71MAYADM1N1STERMY0WNSTVFFS", name: "I may administer"},

    ## ACLs that confer permissions for people i mention (or reply to, which causes a mention)
    mentions_may_read:     %{id: "7MENT10NSCANREADTH1STH1NGS", name: "Mentions may read"},
    mentions_may_interact: %{id: "7MENT10NSCAN1NTERACTW1TH1T", name: "Mentions may read and interact"},
    mentions_may_reply:    %{id: "7MENT10NSCANEVENREP1YT01TS", name: "Mentions may read, interact and reply"},

    ## "Negative" ACLs that apply overrides for ghosting and silencing purposes.
    # TODO: are we going to use these for instance-wide blocks?
    nobody_can_anything:  %{id: "0H0STEDCANTSEE0RD0ANYTH1NG", name: "People I ghosted"},
    nobody_can_reach:     %{id: "1S11ENCEDTHEMS0CAN0TP1NGME", name: "People I silenced aren't discoverable by me"},
    nobody_can_see:       %{id: "2HEYS11ENCEDMES0CAN0TSEEME", name: "People who silenced me cannot discover me"},
  },
  ### Grants are the entries of an ACL and define the permissions a user or circle has for content using this ACL.
  ###
  ### Data structure:
  ### * The outer keys are ACL names declared above.
  ### * The inner keys are circles declared above.
  ### * The inner values declare the verbs the user is permitted to see. Either a map of verb to boolean or a list
  ###   (where values are assumed to be true).
  grants: %{
    ### Public ACLs need their permissions filling out
    guests_may_see_read:  %{guest: [:read, :see, :request]},
    guests_may_see:       %{guest: [:read, :request]},
    guests_may_read:      %{guest: [:read, :request]},
    locals_may_interact:  %{local: [:read, :see, :mention, :tag, :boost, :like, :follow, :request]}, # interact but not reply
    locals_may_reply:     %{local: [:read, :see, :mention, :tag, :boost, :like, :follow, :reply, :request]}, # interact and reply
    # TODO: are we doing this because of instance-wide blocking?
    nobody_can_anything: %{ghost_them:   verbs_negative.(all_verb_names)},
    nobody_can_reach:    %{silence_them: verbs_negative.([:mention, :message, :reply])},
    nobody_can_see:      %{silence_me: verbs_negative.([:see])},
  }
# end of global boundaries

negative_grants = [
  :nobody_can_anything, :nobody_can_reach, :nobody_can_see,   # instance-wide negative permissions
  :they_cannot_anything, :they_cannot_reach, :they_cannot_see,   # per-user negative permissions
]

### Creating a user also entails inserting a default boundaries configuration for them.
###
### Notice that the predefined circles and ACLs here correspond to (some of) the stereotypes we declared above. The
### system uses this stereotype information to identify these special circles/ACLs in the database.
config :bonfire,
  user_default_boundaries: %{
    circles: %{
      followers:    %{stereotype: :followers},    # users who have followed you
      ghost_them:   %{stereotype: :ghost_them},   # users/instances you have ghosted
      silence_them: %{stereotype: :silence_them}, # users/instances you have silenced
      silence_me:   %{stereotype: :silence_me},   # users who have silenced me
    },
    acls: %{
      ## ACLs that confer my personal permissions on things i have created
      # i_may_read:           %{stereotype: :i_may_read},
      # i_may_reply:          %{stereotype: :i_may_interact},
      i_may_administer:     %{stereotype: :i_may_administer},
      ## "Negative" ACLs that apply overrides for ghosting and silencing purposes.
      they_cannot_anything: %{stereotype: :nobody_can_anything},
      they_cannot_reach:    %{stereotype: :nobody_can_reach},
      they_cannot_see:      %{stereotype: :nobody_can_see},
    },
    ### Data structure:
    ### * The outer keys are ACL names declared above.
    ### * The inner keys are circles declared above.
    ### * The inner values declare the verbs the user is permitted to see. Either a map of verb to boolean or a list
    ###   (where values are assumed to be true).
    ### * The special key `SELF` means the creating user.
    grants: %{
      ## ACLs that confer my personal permissions on things i have created
      # i_may_read:           %{SELF:  [:read, :see]},# not currently used
      # i_may_reply:          %{SELF:  [:read, :see, :create, :mention, :tag, :boost, :flag, :like, :follow, :reply]}, # not currently used
      i_may_administer:     %{SELF:         all_verb_names},
      ## "Negative" ACLs that apply overrides for ghosting and silencing purposes.
      # People/instances I ghost can't see (or interact with or anything) me or my objects
      they_cannot_anything: %{ghost_them:   verbs_negative.(all_verb_names)},
      # People/instances I silence can't ping me
      they_cannot_reach:    %{silence_them: verbs_negative.([:mention, :message])},
      # People who silence me can't see me or my objects in feeds and such (but can still read them if they have a
      # direct link or come across my objects in a thread structure or such).
      they_cannot_see:      %{silence_me:   verbs_negative.([:see])},
    },
    ### This lets us control access to the user themselves (e.g. to view their profile or mention them)
    controlleds: %{
      SELF: [
        :guests_may_see_read, :locals_may_interact, :i_may_administer, # positive permissions
      ] ++ negative_grants
    },
  }

### Finally, we have a list of default acls to apply to newly created objects, which makes it possible for the user to
### administer their own stuff and enables ghosting and silencing to work.
config :bonfire,
  object_default_boundaries: %{
    acls: [
      :i_may_administer,                                           # positive permissions
    ] ++ negative_grants
  }
