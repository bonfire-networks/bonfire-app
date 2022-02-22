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
  create_verbs: [
    block:  Bonfire.Data.Social.Block,
    boost:  Bonfire.Data.Social.Boost,
    follow: Bonfire.Data.Social.Follow,
    flag:   Bonfire.Data.Social.Flag,
    like:   Bonfire.Data.Social.Like,
  ],
  circles: %{
    guest:        %{id: "0AND0MSTRANGERS0FF1NTERNET", name: "Guests"},
    local:        %{id: "3SERSFR0MY0VR10CA11NSTANCE", name: "Local Users"},
    activity_pub: %{id: "7EDERATEDW1THANACT1V1TYPVB", name: "ActivityPub Peers"},
    # stereotypes
    followers:    %{id: "7DAPE0P1E1PERM1TT0F0110WME", name: "My Followers"},
    block:        %{id: "7N010NGERC0NSENTT0Y0VN0WTY", name: "Block"},
    silence:      %{id: "7N010NGERWANTT011STENT0Y0V", name: "Silence"},
  },
  acls: %{
    guests_may_read:       %{id: "7W1DE1YAVA11AB1ET0SEENREAD", name: "Publically visible"},
    locals_may_read:       %{id: "10CA1SMAYSEEANDREAD0N1YN0W", name: "Locally visible"},
    locals_may_interact:   %{id: "710CA1SMY1NTERACTN0TREP1YY", name: "Local users may read and interact"},
    locals_may_reply:      %{id: "710CA1SMY1NTERACTANDREP1YY", name: "Local users may read, interact and reply"},
    ### stereotypes - access levels
    # i_may_* - mix one of these in as appropriate when creating something
    i_may_read:            %{id: "71MAYSEEANDREADMY0WNSTVFFS", name: "I may read"},
    i_may_interact:        %{id: "71MAY1NTERACTW1MY0WNSTVFFS", name: "I may read and interact"},
    i_may_administer:      %{id: "71MAYADM1N1STERMY0WNSTVFFS", name: "I may administer"},
    # mentions_may_* - mix one of these in when composing a custom acl for mentions
    mentions_may_read:     %{id: "7MENT10NSCANREADTH1STH1NGS", name: "Mentions may read"},
    mentions_may_interact: %{id: "7MENT10NSCAN1NTERACTW1TH1T", name: "Mentions may read and interact"},
    mentions_may_reply:    %{id: "7MENT10NSCANEVENREP1YT01TS", name: "Mentions may read, interact and reply"},
    ### stereotypes - always mix in
    negative:              %{id: "7AC0MPVTERBESAY1NGN0THANKS", name: "Negative"},
  },
  grants: %{
    guests_may_read:     %{guest: [:read, :see]},
    locals_may_interact: %{local: [:read, :see, :mention, :tag, :boost, :flag, :like, :follow]},
    locals_may_reply:    %{local: [:read, :see, :mention, :tag, :boost, :flag, :like, :follow, :reply]},
  }

alias Bonfire.Me.Users

block_verbs = verbs |> Enum.reduce(%{}, &Map.put(&2, elem(&1, 0), false)) # stops them from seeing you, or anything else
silence_verbs = [:mention] |> Enum.reduce(%{}, &Map.put(&2, &1, false)) # stops you from hearing them

config :bonfire_me, Users,
  default_boundaries: %{ # default boundaries created for new users
    circles: %{
      followers: %{stereotype: :followers},
      block:     %{stereotype: :block},
      silence:   %{stereotype: :silence},
    },
    acls: %{
      i_may_read:       %{stereotype: :i_may_read,       name: "I may read"},
      i_may_reply:      %{stereotype: :i_may_interact,   name: "I may read, interact and reply"},
      i_may_administer: %{stereotype: :i_may_administer, name: "I may administer"},
      negative:         %{stereotype: :negative,         name: "Blocked"},
    },
    grants: %{
      i_may_read:       %{SELF:  [:read, :see]},
      i_may_reply:      %{SELF:  [:read, :see, :create, :mention, :tag, :boost, :flag, :like, :follow, :reply]},
      i_may_administer: %{SELF:  [:read, :see, :edit, :delete]},
      negative:         %{block: block_verbs, silence: silence_verbs},
    },
    controlleds: %{
      # by default, we may administer ourselves. within contexts, we
      # may add more depending on whether the user is local or remote.
      SELF: [:guests_may_read, :locals_may_interact, :i_may_administer]
    },
  }
