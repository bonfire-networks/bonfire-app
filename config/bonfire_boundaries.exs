use Mix.Config

config :bonfire_boundaries,
  enabled: true

config :bonfire,
  verbs: %{
    read:    "READ1NGSVTTER1YFVNDAMENTA1",
    see:     "0BSERV1NG11ST1NGSEX1STENCE",
    create:  "CREATE0RP0STBRANDNEW0BJECT",
    edit:    "CHANG1NGVA1VES0FPR0PERT1ES",
    delete:  "MAKESTVFFG0AWAYPERMANENT1Y",
    follow:  "T0SVBSCR1BET0THE0VTPVT0F1T",
    like:    "11KES1ND1CATEAM11DAPPR0VA1",
    boost:   "B00ST0R0RANN0VCEANACT1V1TY",
    flag:    "F1AGSPAM0RVNACCEPTAB1E1TEM",
    mention: "REFERENC1NGTH1NGSE1SEWHERE",
    tag:     "CATEG0R1S1NGNGR0VP1NGSTVFF",
  },
  default_circles: %{
    guest:        "RAND0MSTRANGERS0FF1NTERNET",
    local:        "VSERSFR0MY0VR10CA11NSTANCE",
    activity_pub: "FEDERATEDW1THANACT1V1TYPVB",
    admin:        "ADM1NRESP0NS1B1E0F1NSTANCE"
  },
  circle_names: %{
    guest:        "Guests",
    local:        "Local Users",
    activity_pub: "Remote Users (ActivityPub)",
    admin:        "Instance Admins"
  }
