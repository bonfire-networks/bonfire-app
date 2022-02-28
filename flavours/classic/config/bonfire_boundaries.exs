import Config

config :bonfire_boundaries,
  disabled: false

verbs = %{
  see:     %{id: "0BSERV1NG11ST1NGSEX1STENCE", verb: "See"}, # see/discover it as part of a list of things (eg in feeds and search)
  read:    %{id: "0EAD1NGSVTTER1YFVNDAMENTA1", verb: "Read"}, # read the contents if you know the ID (eg. you known the username or have a direct link)
  create:  %{id: "4REATE0RP0STBRANDNEW0BJECT", verb: "Create"},
  edit:    %{id: "4HANG1NGVA1VES0FPR0PERT1ES", verb: "Edit"},
  delete:  %{id: "4AKESTVFFG0AWAYPERMANENT1Y", verb: "Delete"},
  follow:  %{id: "20SVBSCR1BET0THE0VTPVT0F1T", verb: "Follow"},
  like:    %{id: "11KES1ND1CATEAM11DAPPR0VA1", verb: "Like"},
  boost:   %{id: "300ST0R0RANN0VCEANACT1V1TY", verb: "Boost"},
  flag:    %{id: "71AGSPAM0RVNACCEPTAB1E1TEM", verb: "Flag"},
  reply:   %{id: "71TCREAT1NGA11NKEDRESP0NSE", verb: "Reply"},
  mention: %{id: "0EFERENC1NGTH1NGSE1SEWHERE", verb: "Mention"},
  tag:     %{id: "4ATEG0R1S1NGNGR0VP1NGSTVFF", verb: "Tag"},
  message: %{id: "40NTACTW1THAPR1VATEMESSAGE", verb: "Message"},
}

all_verb_names = Enum.map(verbs, &elem(&1, 0))

negative_grants = fn verbs ->
  Enum.reduce(verbs, %{}, &Map.put(&2, &1, false))
end

config :bonfire,
  verbs: verbs,
  create_verbs: [
    # block:  Bonfire.Data.Social.Block,
    boost:  Bonfire.Data.Social.Boost,
    follow: Bonfire.Data.Social.Follow,
    flag:   Bonfire.Data.Social.Flag,
    like:   Bonfire.Data.Social.Like,
  ],
  circles: %{ # global circles, and steoreotypes for user circles
    guest:        %{id: "0AND0MSTRANGERS0FF1NTERNET", name: "Guests"},
    local:        %{id: "3SERSFR0MY0VR10CA11NSTANCE", name: "Local Users"},
    activity_pub: %{id: "7EDERATEDW1THANACT1V1TYPVB", name: "ActivityPub Peers"},
    # stereotypes
    followers:    %{id: "7DAPE0P1E1PERM1TT0F0110WME", name: "My Followers"},
    ghost_them:        %{id: "7N010NGERC0NSENTT0Y0VN0WTY", name: "Others I ghosted"},
    silence_them:      %{id: "7N010NGERWANTT011STENT0Y0V", name: "Others I silenced"},
    silence_me:      %{id: "0KF1NEY0VD0N0TWANTT0HEARME", name: "Others who silenced me"},
  },
  acls: %{ # global ACLs, and steoreotypes for user ACLs
    guests_may_see_read:       %{id: "7W1DE1YAVA11AB1ET0SEENREAD", name: "Publicly discoverable and readable"},
    guests_may_see:       %{id: "Y0VCANF1NDMEBVTCAN0T0PENME", name: "Publicly discoverable, but contents may be hidden"},
    guests_may_read:       %{id: "Y0VCANREAD1FY0VHAVETHE11NK", name: "Publicly readable, but not necessarily discoverable"},
    locals_may_read:       %{id: "10CA1SMAYSEEANDREAD0N1YN0W", name: "Visible to local users"},
    locals_may_interact:   %{id: "710CA1SMY1NTERACTN0TREP1YY", name: "Local users may read and interact"},
    locals_may_reply:      %{id: "710CA1SMY1NTERACTANDREP1YY", name: "Local users may read, interact and reply"},
    ### stereotypes - access levels
    # i_may_* - mix one of these in as appropriate when creating something
    # i_may_read:            %{id: "71MAYSEEANDREADMY0WNSTVFFS", name: "I may read"},
    # i_may_interact:        %{id: "71MAY1NTERACTW1MY0WNSTVFFS", name: "I may read and interact"},
    i_may_administer:      %{id: "71MAYADM1N1STERMY0WNSTVFFS", name: "I may administer"},
    # mentions_may_* - TODO? mix one of these in when composing a custom acl for mentions
    mentions_may_read:     %{id: "7MENT10NSCANREADTH1STH1NGS", name: "Mentions may read"},
    mentions_may_interact: %{id: "7MENT10NSCAN1NTERACTW1TH1T", name: "Mentions may read and interact"},
    mentions_may_reply:    %{id: "7MENT10NSCANEVENREP1YT01TS", name: "Mentions may read, interact and reply"},
    ### stereotypes - always mix this in
    they_cannot_anything:  %{id: "0H0STEDCANTSEE0RD0ANYTH1NG", name: "People I ghosted so can't see or do anything"},
    they_cannot_reach:     %{id: "1S11ENCEDTHEMS0CAN0TP1NGME", name: "People I silenced so they can't reach me"},
    they_cannot_see:       %{id: "2HEYS11ENCEDMES0CAN0TSEEME", name: "People who silenced me so don't see me in feeds"},
  },
  grants: %{ # reusable global grants (a grant is an ACL + verbs)
    guests_may_see_read:     %{guest: [:read, :see]},
    guests_may_see:     %{guest: [:read]},
    guests_may_read:     %{guest: [:read]},
    locals_may_interact: %{local: [:read, :see, :mention, :tag, :boost, :flag, :like, :follow]},
    locals_may_reply:    %{local: [:read, :see, :mention, :tag, :boost, :flag, :like, :follow, :reply]},
    they_cannot_anything: %{ghost_them: negative_grants.(all_verb_names)}, # people/instances ghosted instance-wide can't see us (or interact with or anything)
    they_cannot_reach: %{silence_them: negative_grants.([:mention, :message, :reply])}, # people/instances silenced instance-wide can't ping us
  },
  user_default_boundaries: %{ # default boundaries created for new users
    circles: %{ # built-in circles for users
      followers:      %{stereotype: :followers}, # this one can be seen but not directly edited by the user (TODO: it instead should get updated automatically when you follow/unfollow)
      ghost_them:     %{stereotype: :ghost_them},
      silence_them:   %{stereotype: :silence_them},
      silence_me:     %{stereotype: :silence_me}, # this one is for internal use and can't be seen by the user
    },
    acls: %{ # built-in ACLs for users
      # i_may_read:       %{stereotype: :i_may_read},
      # i_may_reply:      %{stereotype: :i_may_interact},
      i_may_administer:       %{stereotype: :i_may_administer},
      they_cannot_anything:   %{stereotype: :they_cannot_anything},
      they_cannot_reach:      %{stereotype: :they_cannot_reach},
      they_cannot_see:        %{stereotype: :they_cannot_see},
    },
    grants: %{ # reusable grants for the user or their circles
      # i_may_read:         %{SELF:  [:read, :see]},
      # i_may_reply:        %{SELF:  [:read, :see, :create, :mention, :tag, :boost, :flag, :like, :follow, :reply]},
      i_may_administer:     %{SELF:  all_verb_names},
      they_cannot_anything: %{ghost_them: negative_grants.(all_verb_names)}, # people/instances I ghost can't see (or interact with or anything) me or my objects
      they_cannot_reach:    %{silence_them: negative_grants.([:mention, :message])}, # people/instances I silence can't ping me
      they_cannot_see:      %{silence_me: negative_grants.([:see])}, # people who silence me can't see me or my objects in feeds and such (but can still read them if they have a direct link)
    },
    controlleds: %{
      # set what grants to apply to the user itself
      # by default, we may administer ourselves. within contexts, we
      # may add more depending on whether the user is local or remote.
      SELF:
        [:guests_may_see_read, :locals_may_interact, :i_may_administer]
        ++ [:they_cannot_anything, :they_cannot_reach, :they_cannot_see] # should be same as object_default_boundaries
    },
  },
  object_default_boundaries: %{ # boundaries that should be applied to every new object
    acls:
      [:i_may_administer]
      ++ [:they_cannot_anything, :they_cannot_reach, :they_cannot_see]
  }
