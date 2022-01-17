import Config

config :bonfire_boundaries,
  disabled: false

verbs = %{
  read:    %{id: "0EAD1NGSVTTER1YFVNDAMENTA1", verb: "Read"},
  see:     %{id: "0BSERV1NG11ST1NGSEX1STENCE", verb: "See"},
  create:  %{id: "4REATE0RP0STBRANDNEW0BJECT", verb: "Create"},
  edit:    %{id: "4HANG1NGVA1VES0FPR0PERT1ES", verb: "Edit"},
  delete:  %{id: "4AKESTVFFG0AWAYPERMANENT1Y", verb: "Delete"},
  follow:  %{id: "20SVBSCR1BET0THE0VTPVT0F1T", verb: "Follow"},
  like:    %{id: "11KES1ND1CATEAM11DAPPR0VA1", verb: "Like"},
  boost:   %{id: "300ST0R0RANN0VCEANACT1V1TY", verb: "Boost"},
  flag:    %{id: "71AGSPAM0RVNACCEPTAB1E1TEM", verb: "Flag"},
  mention: %{id: "0EFERENC1NGTH1NGSE1SEWHERE", verb: "Mention"},
  tag:     %{id: "4ATEG0R1S1NGNGR0VP1NGSTVFF", verb: "Tag"},
  reply:   %{id: "71TCREAT1NGA11NKEDRESP0NSE", verb: "Reply"},
}

config :bonfire,
  verbs: verbs,
  circles: %{
    guest:            %{id: "0AND0MSTRANGERS0FF1NTERNET", name: "Guests"},
    local:            %{id: "3SERSFR0MY0VR10CA11NSTANCE", name: "Local Users"},
    activity_pub:     %{id: "7EDERATEDW1THANACT1V1TYPVB", name: "ActivityPub Peers"},
    # stereotypes
    followers:        %{id: "7DAPE0P1E1PERM1TT0F0110WME", name: "My Followers"},
    blocked:          %{id: "7N010NGERC0NSENTT0Y0VN0WTY"},
  },
  acls: %{
    # read_only:           %{id: "AC10N1YACCESS1SREADACCESS1", name: "Read Only"},
    # local:               %{id: "711M1TEDT010CA1VSERSS01E1Y", name: "Locally Public"},
    guests_may_see:      %{id: "7W1DE1YAVA11AB1ET0SEENREAD", name: "Publically Visible"},
    locals_may_interact: %{id: "710CA1SMY1NTERACTN0TREP1YY", name: "Locals may interact"},
    locals_may_reply:    %{id: "710CA1SMY1NTERACTANDREP1YY", name: "Locals may Interact and Reply"},
    ### stereotypes - access levels
    i_may_see:        %{id: "71MAYSEEANDREADMY0WNSTVFFS"},
    i_may_interact:   %{id: "71MAY1NTERACTW1MY0WNSTVFFS"},
    i_may_administer: %{id: "71MAYADM1N1STERMY0WNSTVFFS"},
    ### stereotypes - always mix in
    blocked:          %{id: "7AC0MPVTERBESAY1NGN0THANKS"},
  },
  grants: %{
    guests_may_see:      %{guest: [:read, :see]},
    locals_may_interact: %{local: [:read, :see, :mention, :tag, :boost, :flag, :like, :follow]},
    locals_may_reply: %{local: [:read, :see, :mention, :tag, :boost, :flag, :like, :follow, :reply]},
  }


# ladder: replyable > interactable > visible
# circles: guests, locals, followers

# common cases:
# * public and replyable by any member or ap user
# * public and interactable, but only replyable by people on my instance
# * public read only, interactions and replies from people on my instance
# * public read only, interactions and replies from people on my instance and my followers
# * friends only:

alias Bonfire.Me.Users

blocked = Enum.reduce(verbs, %{}, &Map.put(&2, elem(&1, 0), false))

config :bonfire_me, Users,
  default_boundaries: %{
    circles: %{
      followers: %{name: "Followers", stereotype: :followers},
      blocked:   %{name: "Blocked",   stereotype: :blocked},
    },
    acls: %{
      i_may_see:        %{stereotype: :i_may_see},
      i_may_interact:   %{stereotype: :i_may_interact},
      i_may_administer: %{stereotype: :i_may_administer},
      blocked:          %{name: "Blocked", stereotype: :blocked},
    },
    grants: %{
      i_may_see:        %{SELF:  [:read, :see]},
      i_may_interact:   %{SELF:  [:read, :see, :create, :mention, :tag, :boost, :flag, :like, :follow]},
      i_may_administer: %{SELF:  [:read, :see, :edit, :delete]},
      blocked:          %{blocked: blocked},
    },
    encircles: %{
      # by default, we may administer ourselves. within contexts, we
      # may add more depending on whether the user is local or remote.
      SELF: [:i_may_administer]
    },
    always: [:blocked],
  }
