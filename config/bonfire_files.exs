import Config

# see `Bonfire.Files.RuntimeConfig` for what env vars to set

# the feed filters this extension owns: the media an activity carries, by type. Declared here as fields on another extension's struct because `Exto` reads this at compile time and a struct's fields have to exist when it compiles; `Bonfire.Files.FeedFilters` is what applies them
config :bonfire_social, Bonfire.Social.FeedFilters,
  field: [
    media_types: Bonfire.Social.FeedFilters.AtomOrStringList,
    exclude_media_types: Bonfire.Social.FeedFilters.AtomOrStringList,
    # only media with a file of ours (an upload, or an imported file with its storage), not a link preview or an embed
    media_has_file: :boolean
  ]

# a link with an embeddable player is an audio embed (`audio/embed`) when its host is one of these or under one, or has a name without a dot in it (eg. a Funkwhale instance), else a video embed: oEmbed has no reliable audio type, and podcasts often call themselves `video.*` in Open Graph
config :bonfire_files, Bonfire.Files,
  audio_embed_hosts: [
    "spotify.com",
    "music.apple.com",
    "podcasts.apple.com",
    "soundcloud.com",
    "bandcamp.com",
    "mixcloud.com",
    "acast.com",
    "buzzsprout.com",
    "spreaker.com",
    "iheart.com",
    "podbean.com",
    "audiomack.com",
    "deezer.com",
    "tidal.com",
    "anchor.fm",
    "funkwhale",
    "castopod"
  ],
  # a link on one of these hosts (or under one) is a document embed (`document/embed`), listed by the documents feed, unless it is a paper (`research`)
  document_embed_hosts: [
    "scribd.com",
    "slideshare.net",
    "issuu.com",
    "speakerdeck.com",
    "docs.google.com",
    "yumpu.com",
    "calameo.com"
  ],
  # the kind of thing a link's page is about, stored as its `media_type` (`Bonfire.Files.link_type/2`), by the page's JSON-LD type: the first kind listing it wins. A page with a player is an embed, and an article is a `link` whatever it mentions. Each kind's schema.org type and its subtypes, from https://schema.org/version/latest/schemaorg-current-https-types.csv
  link_kinds: [
    research: ~w(ScholarlyArticle MedicalScholarlyArticle Dataset Thesis),
    book: ~w(Book Audiobook SequentialArt),
    profile: ~w(AccountingService AdultEntertainment Airline AmusementPark AnimalShelter
      ArchiveOrganization ArtGallery Attorney Audiology AutoBodyShop AutoDealer AutoPartsStore
      AutoRental AutoRepair AutoWash AutomatedTeller AutomotiveBusiness Bakery BankOrCreditUnion
      BarOrPub BeautySalon BedAndBreakfast BikeStore BookStore BowlingAlley Brewery
      CafeOrCoffeeShop Campground Casino ChildCare ClothingStore CollegeOrUniversity ComedyClub
      CommunityHealth ComputerStore Consortium ConvenienceStore Cooperative Corporation
      CovidTestingFacility DanceGroup DaySpa Dentist DepartmentStore Dermatology DiagnosticLab
      DietNutrition Distillery DryCleaningOrLaundry EducationalOrganization Electrician
      ElectronicsStore ElementarySchool Emergency EmergencyService EmploymentAgency
      EntertainmentBusiness ExerciseGym FastFoodRestaurant FinancialService FireStation Florist
      FoodEstablishment FundingAgency FundingScheme FurnitureStore GardenStore GasStation
      GeneralContractor Geriatric GolfCourse GovernmentOffice GovernmentOrganization
      GroceryStore Gynecologic HVACBusiness HairSalon HardwareStore HealthAndBeautyBusiness
      HealthClub HighSchool HobbyShop HomeAndConstructionBusiness HomeGoodsStore Hospital Hostel
      Hotel HousePainter IceCreamShop IndividualPhysician InsuranceAgency InternetCafe
      JewelryStore LegalService Library LibrarySystem LiquorStore LocalBusiness Locksmith
      LodgingBusiness MedicalBusiness MedicalClinic MedicalOrganization MensClothingStore
      MiddleSchool Midwifery MobilePhoneStore Motel MotorcycleDealer MotorcycleRepair
      MovieRentalStore MovieTheater MovingCompany MusicGroup MusicStore NGO NailSalon
      NewsMediaOrganization NightClub Notary Nursing Obstetric OfficeEquipmentStore Oncologic
      OnlineBusiness OnlineMarketplace OnlineStore Ophthalmology Optician Optometric
      Organization Otolaryngologic OutletStore Patient PawnShop Pediatric PerformingGroup Person
      PetStore Pharmacy Physician PhysiciansOffice Physiotherapy PlasticSurgery Plumber
      Podiatric PoliceStation PoliticalParty PostOffice Preschool PrimaryCare
      ProfessionalService ProfilePage Project Psychiatric PublicHealth PublicSwimmingPool
      RadioStation RealEstateAgent RecyclingCenter ResearchOrganization ResearchProject Resort
      Restaurant RoofingContractor School SearchRescueOrganization SelfStorage ShoeStore
      ShoppingCenter SkiResort SportingGoodsStore SportsActivityLocation SportsClub
      SportsOrganization SportsTeam StadiumOrArena Store TattooParlor TelevisionStation
      TennisComplex TheaterGroup TireShop TouristInformationCenter ToyStore TravelAgency
      VacationRental VeterinaryCare WholesaleStore Winery WorkersUnion),
    event: ~w(BroadcastEvent BusinessEvent ChildrensEvent ComedyEvent ConferenceEvent CourseInstance
      DanceEvent DeliveryEvent EducationEvent Event EventSeries ExhibitionEvent Festival
      FoodEvent Hackathon LiteraryEvent MusicEvent OnDemandEvent PerformingArtsEvent
      PublicationEvent SaleEvent ScreeningEvent SocialEvent SportsEvent TheaterEvent
      VisualArtsEvent),
    recipe: ~w(Recipe),
    place: ~w(Accommodation AccountingService AdministrativeArea AdultEntertainment Airport
      AmusementPark AnimalShelter Apartment ApartmentComplex Aquarium ArchiveOrganization
      ArtGallery Attorney Audiology AutoBodyShop AutoDealer AutoPartsStore AutoRental AutoRepair
      AutoWash AutomatedTeller AutomotiveBusiness Bakery BankOrCreditUnion BarOrPub Beach
      BeautySalon BedAndBreakfast BikeStore BoatTerminal BodyOfWater BookStore BowlingAlley
      Brewery Bridge BuddhistTemple BusStation BusStop CafeOrCoffeeShop Campground CampingPitch
      Canal Casino CatholicChurch Cemetery ChildCare Church City CityHall CivicStructure
      ClothingStore CollegeOrUniversity ComedyClub CommunityHealth ComputerStore Continent
      ConvenienceStore Country Courthouse CovidTestingFacility Crematorium DaySpa
      DefenceEstablishment DefinedRegion Dentist DepartmentStore Dermatology DietNutrition
      Distillery DryCleaningOrLaundry EducationalOrganization Electrician ElectronicsStore
      ElementarySchool Embassy Emergency EmergencyService EmploymentAgency EntertainmentBusiness
      EventVenue ExerciseGym FastFoodRestaurant FinancialService FireStation Florist
      FoodEstablishment FurnitureStore GardenStore GasStation GatedResidenceCommunity
      GeneralContractor Geriatric GolfCourse GovernmentBuilding GovernmentOffice GroceryStore
      Gynecologic HVACBusiness HairSalon HardwareStore HealthAndBeautyBusiness HealthClub
      HighSchool HinduTemple HobbyShop HomeAndConstructionBusiness HomeGoodsStore Hospital
      Hostel Hotel HotelRoom House HousePainter IceCreamShop IndividualPhysician InsuranceAgency
      InternetCafe JewelryStore LakeBodyOfWater Landform LandmarksOrHistoricalBuildings
      LegalService LegislativeBuilding Library LiquorStore LocalBusiness Locksmith
      LodgingBusiness MedicalBusiness MedicalClinic MeetingRoom MensClothingStore MiddleSchool
      Midwifery MobilePhoneStore Mosque Motel MotorcycleDealer MotorcycleRepair Mountain
      MovieRentalStore MovieTheater MovingCompany Museum MusicStore MusicVenue NailSalon
      NightClub Notary Nursing Obstetric OceanBodyOfWater OfficeEquipmentStore Oncologic
      Ophthalmology Optician Optometric Otolaryngologic OutletStore Park ParkingFacility
      PawnShop Pediatric PerformingArtsTheater PetStore Pharmacy Physician PhysiciansOffice
      Physiotherapy Place PlaceOfWorship PlasticSurgery Playground Plumber Podiatric
      PoliceStation Pond PostOffice Preschool PrimaryCare ProfessionalService Psychiatric
      PublicHealth PublicSwimmingPool PublicToilet RVPark RadioStation RealEstateAgent
      RecyclingCenter Reservoir Residence Resort Restaurant RiverBodyOfWater RoofingContractor
      Room School SchoolDistrict SeaBodyOfWater SelfStorage ShoeStore ShoppingCenter
      SingleFamilyResidence SkiResort SportingGoodsStore SportsActivityLocation SportsClub
      StadiumOrArena State Store SubwayStation Suite Synagogue TattooParlor TaxiStand
      TelevisionStation TennisComplex TireShop TouristAttraction TouristDestination
      TouristInformationCenter ToyStore TrainStation TravelAgency VacationRental Volcano
      Waterfall WholesaleStore Winery Zoo),
    product: ~w(BusOrCoach Car DietarySupplement Drug IndividualProduct Motorcycle MotorizedBicycle
      Product ProductCollection ProductGroup ProductModel SomeProducts Vehicle)
  ],
  # the kinds a page's Open Graph type also says, when its JSON-LD says none
  link_kinds_open_graph: [book: ["book"], profile: ["profile"]]

# the library's `%URI{}` uploads are fetched through `Bonfire.Common.HTTP` (private and loopback hosts refused on every hop, body size capped) instead of its default `:httpc` fetch
config :entrepot, :uri_fetcher, {Bonfire.Files, :fetch_body}
