{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    absinthe = buildMix rec {
      name = "absinthe";
      version = "1.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0hwnq3kwnaywz4b9kgz90gnf6b8nd1khqzrn9nfb5jdg35amnsjn";
      };

      beamDeps = [ dataloader decimal nimble_parsec telemetry ];
    };

    absinthe_error_payload = buildMix rec {
      name = "absinthe_error_payload";
      version = "1.1.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1jia5f48mahfck40bfbacz017xxifcjxxkg0fm068b2azpr2w9ly";
      };

      beamDeps = [ absinthe ecto ];
    };

    absinthe_phoenix = buildMix rec {
      name = "absinthe_phoenix";
      version = "2.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "139gnamfbba5hyk1fx1zf8vfr0j17fd9q0vxxp9cf39qbj91hsfk";
      };

      beamDeps = [ absinthe absinthe_plug decimal phoenix phoenix_html phoenix_pubsub ];
    };

    absinthe_plug = buildMix rec {
      name = "absinthe_plug";
      version = "1.5.8";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0nkfk5gqbg8yvlysgxfcak7y4lsy8q2jfyqyhql5hwvvciv43c5v";
      };

      beamDeps = [ absinthe plug ];
    };

    argon2_elixir = buildMix rec {
      name = "argon2_elixir";
      version = "3.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mywrvzzm76glvajzxrdg6ka49xby30fpk9zl4dxamzm18kknxcb";
      };

      beamDeps = [ comeonin elixir_make ];
    };

    bamboo = buildMix rec {
      name = "bamboo";
      version = "2.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1z74mnizzk5gnjpqplqkjhfxj1pz58gfsa21w15wnh1ggnx18fwc";
      };

      beamDeps = [ hackney jason mime plug ];
    };

    bamboo_smtp = buildMix rec {
      name = "bamboo_smtp";
      version = "4.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03agpqf1hg2gyxjlcbg08zxksgjxywxiiarvjdbjv1cn2dzic2dd";
      };

      beamDeps = [ bamboo gen_smtp ];
    };

    benchee = buildMix rec {
      name = "benchee";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "14vdbvmkkqhcqvilq1w8zl895f4hpbv7fw2q5c0ml5h3a1a7v9bx";
      };

      beamDeps = [ deep_merge statistex ];
    };

    benchee_html = buildMix rec {
      name = "benchee_html";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16g6d5ppjcvwybkn0nwj1r8hj8pkjf53xl0n8b5gabs3mjdaz02j";
      };

      beamDeps = [ benchee benchee_json ];
    };

    benchee_json = buildMix rec {
      name = "benchee_json";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0713xiiil0dvwavxgxsd0zwz1946gkxnhk9lf3w0ad8jz49xh1fs";
      };

      beamDeps = [ benchee jason ];
    };

    bypass = buildMix rec {
      name = "bypass";
      version = "2.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "103bv5wfzw82kvvq4hlas9virrjczvnbpsc4hfhfz9mpln7xzdfr";
      };

      beamDeps = [ plug plug_cowboy ranch ];
    };

    cachex = buildMix rec {
      name = "cachex";
      version = "3.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfbbij81zmk6p75z33wg04mfcjqsxzzh67vclllvfjgmfqj609p";
      };

      beamDeps = [ eternal jumper sleeplocks unsafe ];
    };

    castore = buildMix rec {
      name = "castore";
      version = "0.1.17";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1yb3470p0mfawdy34gaa5lkhqrb8d35jai9235snxljjxlkl516r";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ha6vmf5p3xlbf5w1msa89frhvfk535rnyfybz9wdmh6vdms8v96";
      };

      beamDeps = [];
    };

    changelog = buildMix rec {
      name = "changelog";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0jpq3s01gmhd22g08bf3inwc2w142kxnmbkmcla2slr15drraway";
      };

      beamDeps = [ hex_core req ];
    };

    cldr_utils = buildMix rec {
      name = "cldr_utils";
      version = "2.17.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "072cy36x1lnfm0w7g54jkz10syjmf9z0ylxspvwj1v628zk6fmlw";
      };

      beamDeps = [ castore certifi decimal ];
    };

    combine = buildMix rec {
      name = "combine";
      version = "0.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06s5y8b0snr1s5ax9v3s7rc6c8xf5vj6878d1mc7cc07j0bvq78v";
      };

      beamDeps = [];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pw4rhhsh8mwj26dkbxz2niih9j8pc3qijlpcl8jh208rg1cjf1y";
      };

      beamDeps = [];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1746n8ba11amp1xhwzp38yfii2h051za8ndxlwdykyqqljq1wb3j";
      };

      beamDeps = [];
    };

    cowboy = buildErlangMk rec {
      name = "cowboy";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1phv0a1zbgk7imfgcm0dlacm7hbjcdygb0pqmx4s26jf9f9rywic";
      };

      beamDeps = [ cowlib ranch ];
    };

    cowboy_telemetry = buildRebar3 rec {
      name = "cowboy_telemetry";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pn90is3k9dq64wbijvzkqb6ldfqvwiqi7ymc8dx6ra5xv0vm63x";
      };

      beamDeps = [ cowboy telemetry ];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.11.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ac6pj3x4vdbsa8hvmbzpdfc4k0v1p102jbd39snai8wnah9sgib";
      };

      beamDeps = [];
    };

    crypto_rand = buildMix rec {
      name = "crypto_rand";
      version = "1.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "118nvawarrkd9lg96ikhd35n0apq3ccm0bx0mrhgw68ilzz7c6kh";
      };

      beamDeps = [];
    };

    dataloader = buildMix rec {
      name = "dataloader";
      version = "1.0.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0gwnrlrvylar2mdlgi9y9pylk8c3la3c2k71mjrg9pcsq3771kal";
      };

      beamDeps = [ ecto telemetry ];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0s1nx1gi96r8g7x8y7cklz8z823a6llh4fk996i5xxcr3flkrrag";
      };

      beamDeps = [ connection telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xzm8hfhn8q02rmg8cpgs68n5jz61wvqg7bxww9i1a6yanf6wril";
      };

      beamDeps = [];
    };

    deep_merge = buildMix rec {
      name = "deep_merge";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0c2li2a3hxcc05nwvy4kpsal0315yk900kxyybld972b15gqww6f";
      };

      beamDeps = [];
    };

    earmark = buildMix rec {
      name = "earmark";
      version = "1.5.0-pre1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ykbak30ncjfy5xgr35pd5zqhlj9gad3129gcywrby9fmmrh9v16";
      };

      beamDeps = [ earmark_parser ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.26";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1g5ajj6l4j1nnkd6vcnhp8vk6kzn04f62xh68z2m434aky4n1m28";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.8.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1m42zrwnv2pjggl9y94wpdjfbq7lyf600fj62l2v8bflp244497r";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_dev_logger = buildMix rec {
      name = "ecto_dev_logger";
      version = "0.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s7x55h7g1xdg8980skm1bwpvsifl21dfq3rrrs17zsym8q27y0i";
      };

      beamDeps = [ ecto jason ];
    };

    ecto_erd = buildMix rec {
      name = "ecto_erd";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0v6bm7f9psazkhir072wj6h1pjcb1919jr5jvx4cxfjcjq448dmr";
      };

      beamDeps = [ ecto html_entities ];
    };

    ecto_psql_extras = buildMix rec {
      name = "ecto_psql_extras";
      version = "0.7.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ra9jh2p1jp1hn4g7aynivbrj52y9c20aspmqw6ksbkp3cpv079i";
      };

      beamDeps = [ ecto_sql postgrex table_rex ];
    };

    ecto_ranked = buildMix rec {
      name = "ecto_ranked";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "14p1lwylhhhzvcqpfjq1d68gi168jbjhjr4ik1nwz8mc76ai37kz";
      };

      beamDeps = [ ecto_sql ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.8.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16rjcz9qa2gabl7nlpifi7i0ay5mzkm4jw58a7rgdnp6p5zv331l";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    eflambe = buildRebar3 rec {
      name = "eflambe";
      version = "0.2.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13sh0nh36wag4aj6pg8ghl15l7nwdldn3qraglqhi5767qm6k60w";
      };

      beamDeps = [ meck ];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05ppvbhqi5m9zk1c4xnrki814sqhxrc7d1dpvfmwm2v7qm8xdjzm";
      };

      beamDeps = [];
    };

    email_checker = buildMix rec {
      name = "email_checker";
      version = "0.2.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "02p54gvj54j6q853jdyy3pk84pasabdzzsq8vz4fkp1mn1g0xb74";
      };

      beamDeps = [];
    };

    eqrcode = buildMix rec {
      name = "eqrcode";
      version = "0.1.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wbn23l17my4bjlnhnn4ssb9i499c2qn91pmnrxd63vaqdry6c6s";
      };

      beamDeps = [];
    };

    eternal = buildMix rec {
      name = "eternal";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10p7m6kv2z2c16gw36wgiwnkykss4lfkmm71llxp09ipkhmy77rc";
      };

      beamDeps = [];
    };

    ex_aws_s3 = buildMix rec {
      name = "ex_aws_s3";
      version = "2.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "017iswr9m2kwri2m5j3r9m0b7hk4vqqddbqy09k5d4nfz6vg0i00";
      };

      beamDeps = [ ex_aws sweet_xml ];
    };

    ex_cldr = buildMix rec {
      name = "ex_cldr";
      version = "2.31.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "15qws35l1psv9g6d14771dvlr2332pcxdh3mn6c9shzn96qmf4aj";
      };

      beamDeps = [ castore certifi cldr_utils decimal gettext jason nimble_parsec ];
    };

    ex_cldr_languages = buildMix rec {
      name = "ex_cldr_languages";
      version = "0.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yj4rj4r0wdzhrwkg1xdg1x28d1pp3kk8fr45n3v9d5pfbpizyr2";
      };

      beamDeps = [ ex_cldr jason ];
    };

    ex_cldr_plugs = buildMix rec {
      name = "ex_cldr_plugs";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03wlqiiyjjz5v5xr3hdgyik853fqhym8362q5nprfh46is11rqqy";
      };

      beamDeps = [ ex_cldr gettext jason plug ];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.28.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1vgqqf5cf0cw18aw593ll9qk9bsqm6hvvf6xr24iv49lvl1x11dz";
      };

      beamDeps = [ earmark_parser makeup_elixir makeup_erlang ];
    };

    ex_json_schema = buildMix rec {
      name = "ex_json_schema";
      version = "0.9.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0sfdjp8lbjcxwjv9pgcp26al3l95j3d83v38xy630cwxw8nj4hbh";
      };

      beamDeps = [ decimal ];
    };

    ex_machina = buildMix rec {
      name = "ex_machina";
      version = "2.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1y2v4j1zg1ji8q8di0fxpc3z3n2jmbnc85d6hx68j4fykfisg6j1";
      };

      beamDeps = [ ecto ecto_sql ];
    };

    ex_ulid = buildMix rec {
      name = "ex_ulid";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0q08y8xw2q4dr1w6g3rcyjlgib2w2wz26znycfan7i7bg93zvgm2";
      };

      beamDeps = [];
    };

    ex_unit_notifier = buildMix rec {
      name = "ex_unit_notifier";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cp3msbal2pc4w1bydibqs91r7qdl60xgi5fy3bqmrhdsp4l907k";
      };

      beamDeps = [];
    };

    expo = buildMix rec {
      name = "expo";
      version = "0.1.0-beta.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0bgpbfhz5ky5nv617kk2ibld11arhpanzpdxkk2jck4j399gqvl8";
      };

      beamDeps = [ nimble_parsec ];
    };

    exsync = buildMix rec {
      name = "exsync";
      version = "0.2.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "15h8x398jwag80l9gf5q8r9pmpxgj5py8sh6m9ry9fwap65jsqpp";
      };

      beamDeps = [ file_system ];
    };

    faker = buildMix rec {
      name = "faker";
      version = "0.17.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0slacn8z5xnk8i0kpgs1y8zl7hlzg19hfl83adgmrlizm62avm57";
      };

      beamDeps = [];
    };

    fast_ngram = buildMix rec {
      name = "fast_ngram";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1gf11p1rx3bgq9xs8rmd9k74byayl3vgpwjvg88xh503n32lkjch";
      };

      beamDeps = [];
    };

    file_info = buildMix rec {
      name = "file_info";
      version = "0.0.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19c14xv0xzbl3m6y5p7dlxn8sfqi9bff8pv722837ff8q80svrsh";
      };

      beamDeps = [ mimetype_parser ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1p0myxmnjjds8bbg69dd6fvhk8q3n7lb78zd4qvmjajnzgdmw6a1";
      };

      beamDeps = [];
    };

    finch = buildMix rec {
      name = "finch";
      version = "0.12.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19p59gi9kxfgwalcriy35k9wb9jv8krb8wa2gyvxrrsr4krs639j";
      };

      beamDeps = [ castore mime mint nimble_options nimble_pool telemetry ];
    };

    flame_on = buildMix rec {
      name = "flame_on";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cg0b0clldw66zg1qajg4x9n9k8a5n2khgyzn36xhf8g75pdwggp";
      };

      beamDeps = [ ecto gettext jason meck phoenix_ecto phoenix_live_dashboard phoenix_live_view ];
    };

    floki = buildMix rec {
      name = "floki";
      version = "0.32.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18w1qv9syz464914d61q3imryqgwxqbc0g0ygczlly2a7rqirffl";
      };

      beamDeps = [ html_entities ];
    };

    flow = buildMix rec {
      name = "flow";
      version = "0.15.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10a5f6aawhb43w518qmjl0vg8dc3xwa50vcrpja8864asd6vvv6p";
      };

      beamDeps = [ gen_stage ];
    };

    gen_smtp = buildRebar3 rec {
      name = "gen_smtp";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yb7541zx0x76gzk0m1m8fkl6524jhl8rxc59l6g5a5wh1b3gq2y";
      };

      beamDeps = [ ranch ];
    };

    gen_stage = buildMix rec {
      name = "gen_stage";
      version = "0.14.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xld8m2l9a7pbzmq7vp0r9mz4pkisrjpslgbjs9ikhwlkllf4lw4";
      };

      beamDeps = [];
    };

    geo = buildMix rec {
      name = "geo";
      version = "3.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ljmnbz3a0kh0hri64df87c8zic9xk6bxqffcfqchzj3wn92hgz2";
      };

      beamDeps = [ jason ];
    };

    geo_postgis = buildMix rec {
      name = "geo_postgis";
      version = "3.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1m5abb98a0kl24ysmawznqz2m5vylm17q88rvd35b003gzwwkn28";
      };

      beamDeps = [ geo jason postgrex ];
    };

    geocoder = buildMix rec {
      name = "geocoder";
      version = "1.1.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s2dd0bnk9hbzihibqzdbbs8xwc0q9ma9phr7rmr1fm8crmh7dm7";
      };

      beamDeps = [ geohash httpoison jason poolboy towel ];
    };

    geohash = buildMix rec {
      name = "geohash";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1qhflfwv2mbcrhsr670cc27mfbqflxyfrvmr3ji72bv8wkvr3vcq";
      };

      beamDeps = [];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.19.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08kjwyc48sl69as1h3db17qy64bmjh31q1lvpanrk0ibj705dihh";
      };

      beamDeps = [];
    };

    git_cli = buildMix rec {
      name = "git_cli";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16xg5rkx86xa5zg7iwkx7a72dnwfnbnd7w8i6m6iz9469hprbjvq";
      };

      beamDeps = [];
    };

    git_diff = buildMix rec {
      name = "git_diff";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1i65w8yfg856a8j98pfb8grdajbfwbvagmnn82qida98d2apmm65";
      };

      beamDeps = [];
    };

    grumble = buildMix rec {
      name = "grumble";
      version = "0.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "031x514zcaf12jz0238z0d9fnpp8f0lh04kh4b875q25l7jqk857";
      };

      beamDeps = [ recase ];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.18.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13hja14kig5jnzcizpdghj68i88f0yd9wjdfjic9nzi98kzxmv54";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    hex_core = buildRebar3 rec {
      name = "hex_core";
      version = "0.8.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06p65hlm29ky03vs3fq3qz6px2ylwp8b0f2y75wdf5cm0kx2332b";
      };

      beamDeps = [];
    };

    hpax = buildMix rec {
      name = "hpax";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09n8qrmcxlrhlyz5mh0nrk15rwvnqhzcz7x3yz5612jan2hdbrqa";
      };

      beamDeps = [];
    };

    html_entities = buildMix rec {
      name = "html_entities";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1k7xyj0q38ms3n5hbn782pa6w1vgd6biwlxr4db6319l828a6fy5";
      };

      beamDeps = [];
    };

    html_sanitize_ex = buildMix rec {
      name = "html_sanitize_ex";
      version = "1.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03lv6vfh0fbpxax0p58zarcmak4513jhf5arml4r2snhhn2w5xmf";
      };

      beamDeps = [ mochiweb ];
    };

    httpoison = buildMix rec {
      name = "httpoison";
      version = "1.8.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q3r7v84zbyggqr35mpd689g4p205ja0iqi9j9mm2vcdcxnnl59m";
      };

      beamDeps = [ hackney ];
    };

    hut = buildRebar3 rec {
      name = "hut";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0qxmkazkakrmvd9n1im4ad43wxgh189fqcd9lfsz58fqan2x45by";
      };

      beamDeps = [];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sjcjibl34sprpf1dgdmzfww24xlyy34lpj7mhcys4j4i6vnwdwj";
      };

      beamDeps = [ unicode_util_compat ];
    };

    inflex = buildMix rec {
      name = "inflex";
      version = "2.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1n1d2s9kspqbg8n9blcqafi8k8rayayz3gxh379vdsafvc2pvh8l";
      };

      beamDeps = [];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b620901micds3q2pfnwcp861hjiwx0wpyahgvnf142k4m8izz2k";
      };

      beamDeps = [ decimal ];
    };

    joken = buildMix rec {
      name = "joken";
      version = "2.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lcqkhl1ylk9ldsg3w1m926101rsdj2i9hly9zfdxchj65q7rz6l";
      };

      beamDeps = [ jose ];
    };

    jose = buildMix rec {
      name = "jose";
      version = "1.11.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lj715gzl022yc47qsg9712x8nc9wi7x70msv8c3lpym92y3y54q";
      };

      beamDeps = [];
    };

    jumper = buildMix rec {
      name = "jumper";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cvlbfkapkvbwaijmjq3cxg5m6yv4rh69wvss9kfj862i83mk31i";
      };

      beamDeps = [];
    };

    libgraph = buildMix rec {
      name = "libgraph";
      version = "0.13.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ij8q71kvxbdd19210r22i240rn8w4fhn1hhdys40m31xxp5gwkq";
      };

      beamDeps = [];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19jpprryixi452jwhws3bbks6ki3wni9kgzah3srg22a3x8fsi8a";
      };

      beamDeps = [ nimble_parsec ];
    };

    makeup_diff = buildMix rec {
      name = "makeup_diff";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b5lp51h664rm16060s198l740241saj655h2vmsza1knidsssqq";
      };

      beamDeps = [ makeup ];
    };

    makeup_eex = buildMix rec {
      name = "makeup_eex";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0r590a2bx8kw1mnc4li1cns3nl86z0z32fsb3bphkaxa9scs04fi";
      };

      beamDeps = [ makeup makeup_elixir makeup_html nimble_parsec ];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "0.16.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rrqydcq2bshs577z7jbgdnrlg7cpnzc8n48kap4c2ln2gfcpci8";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    makeup_erlang = buildMix rec {
      name = "makeup_erlang";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fvw0zr7vqd94vlj62xbqh0yrih1f7wwnmlj62rz0klax44hhk8p";
      };

      beamDeps = [ makeup ];
    };

    makeup_graphql = buildMix rec {
      name = "makeup_graphql";
      version = "0.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1yz880a673zm934kxi7smz726yadm9ifyr5y9flm539qp82ap41k";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    makeup_html = buildMix rec {
      name = "makeup_html";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hpdh4rfyrc19g9lnc2i7cj4gjcfvmq48cj00w0kx4wdrdylx90c";
      };

      beamDeps = [ makeup ];
    };

    makeup_js = buildMix rec {
      name = "makeup_js";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xgabml7rjkcx67ba26zvv661civx1s6b4lwcyqkg5rcnmg1l31z";
      };

      beamDeps = [ makeup ];
    };

    makeup_sql = buildMix rec {
      name = "makeup_sql";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "066iiksn44waykm6scchpq69hkqcpb7nfd1r9v2bhbxdi3zj6vjm";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    mappable = buildMix rec {
      name = "mappable";
      version = "0.2.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1dd8y4hlwymaykvrip66gryln939xww6f2s2c6pi1v2yra8r538q";
      };

      beamDeps = [];
    };

    meck = buildRebar3 rec {
      name = "meck";
      version = "0.9.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09jq0jrsd3dwzjlnwqjv6m9r2rijgiv57yja6jl41p2p2db4yd41";
      };

      beamDeps = [];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "1.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19qrpnmaf3w8bblvkv6z5g82hzd10rhc7bqxvqyi88c37xhsi89i";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [];
    };

    mimetype_parser = buildMix rec {
      name = "mimetype_parser";
      version = "0.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lm8yzcmg17nhvr4p4dbmamb280a9dzqx4rwv66ffz40cz2q13vx";
      };

      beamDeps = [];
    };

    mint = buildMix rec {
      name = "mint";
      version = "1.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "106x9nmzi4ji5cqaddn76pxiyxdihk12z2qgszcdgd2rrjxsaxff";
      };

      beamDeps = [ castore hpax ];
    };

    mix_test_interactive = buildMix rec {
      name = "mix_test_interactive";
      version = "1.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1bnvzyzxg8q5rcynlaika54m89ngdp2r4mrxp6p9n2s0k1fqabah";
      };

      beamDeps = [ file_system typed_struct ];
    };

    mix_test_watch = buildMix rec {
      name = "mix_test_watch";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hrfh7hg3iwmvzwwyshdddgjxwc2ci898lyak7c0zdybfv2b3djj";
      };

      beamDeps = [ file_system ];
    };

    mix_unused = buildMix rec {
      name = "mix_unused";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0c1vagzrcwfh0n17sjram1v1azbl7x4c1iq9sc57d8985ls6nbq8";
      };

      beamDeps = [ libgraph ];
    };

    mochiweb = buildRebar3 rec {
      name = "mochiweb";
      version = "2.22.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mbnl017as88jqj121l4viizpnpn703kx8f8s5vcb0yj2p9izgfb";
      };

      beamDeps = [];
    };

    mock = buildMix rec {
      name = "mock";
      version = "0.3.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0p3yrx049fdw88kjidngd2lkwqkkyck5r51ng2dxj7z41539m92d";
      };

      beamDeps = [ meck ];
    };

    mogrify = buildMix rec {
      name = "mogrify";
      version = "0.9.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "17b9dy40rq3rwn7crjggjafibxz4ys4nqq81adcf486af3yi13f1";
      };

      beamDeps = [];
    };

    mox = buildMix rec {
      name = "mox";
      version = "1.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wpyh6wp76lyx0q2cys23rpmci4gj1pqwnqvfk467xxanchlk1pr";
      };

      beamDeps = [];
    };

    nebulex = buildMix rec {
      name = "nebulex";
      version = "2.3.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04svmb2i78psj5bcrxw4fvqm010pfkg91pmxnqndmm59hzkc5rq9";
      };

      beamDeps = [ shards telemetry ];
    };

    neuron = buildMix rec {
      name = "neuron";
      version = "5.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "001xwg081kj59lazgxqy0kjckvbl76k3vbnvman7fkz34a7315vm";
      };

      beamDeps = [ httpoison jason ];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0bd0pi3sij9vxhiilv25x6n3jls75g3b38rljvm1x896ycd1qw76";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.2.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1c3hnppmjkwnqrc9vvm72kpliav0mqyyk4cjp7vsqccikgiqkmy8";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0gv59waa505mz2gi956sj1aa6844c65w2dp2qh2jfgsx15am0w8w";
      };

      beamDeps = [];
    };

    nimble_totp = buildMix rec {
      name = "nimble_totp";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1cshbdz6hss32hbipi9iyxx10zvad93ninivzg9cqds6y5gx3v3z";
      };

      beamDeps = [];
    };

    oban = buildMix rec {
      name = "oban";
      version = "2.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wx5009rwj3a2bs9ffsq81i9dqkh7bfs6wh7ghhw8z4g86na4m19";
      };

      beamDeps = [ ecto_sql jason postgrex telemetry ];
    };

    ok = buildMix rec {
      name = "ok";
      version = "2.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1mf48gxaa1rpiawz4wqjfx1jjkq8rwrln604qx3z6nqiiwzpnd7h";
      };

      beamDeps = [];
    };

    openid_connect = buildMix rec {
      name = "openid_connect";
      version = "0.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0nmid9ly8627a8qbpmax4w55cscqhqcldd4xz3zbp7ngd997bcn4";
      };

      beamDeps = [ httpoison jason jose ];
    };

    pane = buildMix rec {
      name = "pane";
      version = "0.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12pz0i5gjln4clv1k9l61n9slbm1sizw2c1989vlfbgmhv5958i7";
      };

      beamDeps = [];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [];
    };

    pbkdf2_elixir = buildMix rec {
      name = "pbkdf2_elixir";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11ih753qj6i8h92rifak60cckp4w1sf6chx888yqjqryb04big59";
      };

      beamDeps = [ comeonin ];
    };

    periscope = buildMix rec {
      name = "periscope";
      version = "0.5.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1i49lrg45h9vzqmsl1b65yhaszc33hq2mkbn1v1sbzxxwi0z3gjf";
      };

      beamDeps = [];
    };

    phil_columns = buildMix rec {
      name = "phil_columns";
      version = "3.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0s070kgrwkqq82yr40wzs7qfw6zpvf72spfxz5s590f4csimz8qa";
      };

      beamDeps = [ ecto_sql inflex ];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.6.11";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hpv9f3759xi8kkb800f3ihfy98j95zrbpdsiy8s8pn2h17y6r0n";
      };

      beamDeps = [ jason phoenix_pubsub phoenix_view plug plug_cowboy plug_crypto telemetry ];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1h9wnjmxns8y8dsr0r41ks66gscaqm7ivk4gsh5y07nkiralx1h9";
      };

      beamDeps = [ ecto phoenix_html plug ];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "3.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ky5idgid1psz6hmh2b2kmj6n974axww74hrxwv02p6jasx9gv1n";
      };

      beamDeps = [ plug ];
    };

    phoenix_live_dashboard = buildMix rec {
      name = "phoenix_live_dashboard";
      version = "0.6.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lmq1m7k465i9mzw35l7bx69n85mibwzd76976840r43sw6sakzg";
      };

      beamDeps = [ ecto ecto_psql_extras mime phoenix_live_view telemetry_metrics ];
    };

    phoenix_live_reload = buildMix rec {
      name = "phoenix_live_reload";
      version = "1.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b5blinpmzdgspgk0dsy01bfjwwnhikb1gfiwnx8smazdrkrcrvn";
      };

      beamDeps = [ file_system phoenix ];
    };

    phoenix_live_view = buildMix rec {
      name = "phoenix_live_view";
      version = "0.17.11";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "169zqjil0x6552fzpgdkywv0nxkzy2jscdariz8hxydp8hcpjxvi";
      };

      beamDeps = [ jason phoenix phoenix_html telemetry ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1nfqrmbrq45if9pgk6g6vqiply2sxc40is3bfanphn7a3rnpqdl1";
      };

      beamDeps = [];
    };

    phoenix_view = buildMix rec {
      name = "phoenix_view";
      version = "1.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mis1z24wmd78sfpiik2f0ypqsjisbhn3fxdyrk14289gg90msbs";
      };

      beamDeps = [ phoenix_html ];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.13.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1zrlg9k1h17x3pw9zyy4cg593iakpy2647gk57495kjvjnwwdf82";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_cowboy = buildMix rec {
      name = "plug_cowboy";
      version = "2.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0i0hxbpkbgv2zi4z04x0l207dgbks2kj4h6kr1h8sq68fkvqfvpa";
      };

      beamDeps = [ cowboy cowboy_telemetry plug ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1nxnxj62iv4yvm4771jbxpj3l4brn2crz053y12s998lv5x1qqw7";
      };

      beamDeps = [];
    };

    poolboy = buildRebar3 rec {
      name = "poolboy";
      version = "1.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1qq116314418jp4skxg8c6jx29fwp688a738lgaz6h2lrq29gmys";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.16.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "142535k22dl5zdq757fhmnih7kk4lnq43llhzvjs8b9js79f3amf";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    puid = buildMix rec {
      name = "puid";
      version = "1.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1apzy5wc5xs48dzb749a3ynh4ivpav9g8liqybxw8xp554g6klgv";
      };

      beamDeps = [ crypto_rand ];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfz5ld54pkd2w25jadyznia2vb7aw9bclck21fizargd39wzys9";
      };

      beamDeps = [];
    };

    recase = buildMix rec {
      name = "recase";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "032fib052caapihmxhnrzbap4kigwdq5hsaanna4lbsmkxm7bx9n";
      };

      beamDeps = [];
    };

    redirect = buildMix rec {
      name = "redirect";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vnnq3hgvv9qkia4q7172xpn0f9xaizg3i1pzj7ai1frvq8yc21i";
      };

      beamDeps = [ phoenix plug ];
    };

    req = buildMix rec {
      name = "req";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0waajl84kq59p7vbd66z42qlpm06hb830k5qxskhzppf8zha64hj";
      };

      beamDeps = [ finch jason mime plug ];
    };

    scribe = buildMix rec {
      name = "scribe";
      version = "0.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0bn6lgqp69b0xgygn5v7v6vqyxmz8zs403n51rgi1ci8dafdla9q";
      };

      beamDeps = [ pane ];
    };

    secure_random = buildMix rec {
      name = "secure_random";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1az658qpha6pnlns37pn9l201wck4ahrvldgp91s2h1rbvqm95qv";
      };

      beamDeps = [];
    };

    sentry = buildMix rec {
      name = "sentry";
      version = "8.0.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10qqkqvykw8v3xdw9j19jgg3kwjfdrp9sz3wg0vk2bqnf822s6h5";
      };

      beamDeps = [ hackney jason plug plug_cowboy ];
    };

    shards = buildRebar3 rec {
      name = "shards";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0h908jkxyxd0n17pckl85svvi2gfps92hxv68c1c8lzhzf57hmrc";
      };

      beamDeps = [];
    };

    sleeplocks = buildRebar3 rec {
      name = "sleeplocks";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q823i5bisc83pyssgrqkggyxiasm7b8dygzj2r943adzyp3gvl4";
      };

      beamDeps = [];
    };

    sobelow = buildMix rec {
      name = "sobelow";
      version = "0.11.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0g558rki9198a2plgdadsbjxaalyh6nhma84jf0g95pzgqx3d5wq";
      };

      beamDeps = [ jason ];
    };

    solid = buildMix rec {
      name = "solid";
      version = "0.12.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1cc31r7m818p0n5jrn5bq03pjjplfpi75yimlfzsxjdnnlnkc8hp";
      };

      beamDeps = [ nimble_parsec ];
    };

    sourceror = buildMix rec {
      name = "sourceror";
      version = "0.11.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x2y3sixpcr8qh107vscjl10lwvcrbrmfqycfpn6qbspwn785di2";
      };

      beamDeps = [];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [];
    };

    statistex = buildMix rec {
      name = "statistex";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09vcm2sz2llv00cm7krkx3n5r8ra1b42zx9gfjs8l0imf3p8p7gz";
      };

      beamDeps = [];
    };

    stream_data = buildMix rec {
      name = "stream_data";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wg2p5hwf7qmkwsc1i3q7h558f7sr9f13y8i6kds9bb9q3pd4aq1";
      };

      beamDeps = [];
    };

    surface = buildMix rec {
      name = "surface";
      version = "0.7.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1f30wan3k3jnhrmdnyq4i8zhm7i74jjgmjjiw5ijp8v04m0jnlrk";
      };

      beamDeps = [ jason phoenix_live_view sourceror ];
    };

    sweet_xml = buildMix rec {
      name = "sweet_xml";
      version = "0.7.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fpmwhqgvakvdpbwmmyh31ays3hzhnm9766xqyzp9zmkl5kwh471";
      };

      beamDeps = [];
    };

    table_rex = buildMix rec {
      name = "table_rex";
      version = "3.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "141404hwnwnpspvhs112j2la8dfnvkwr0xy14ff42w6nljmj72k7";
      };

      beamDeps = [];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0j6zq3y7xz768djz25x55gampyhd9nv6ax9dzx67f52nyyhv49xp";
      };

      beamDeps = [];
    };

    telemetry_metrics = buildMix rec {
      name = "telemetry_metrics";
      version = "0.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1iilk2n75kn9i95fdp8mpxvn3rcn3ghln7p77cijqws13j3y1sbv";
      };

      beamDeps = [ telemetry ];
    };

    telemetry_poller = buildRebar3 rec {
      name = "telemetry_poller";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vjgxkxn9ll1gc6xd8jh4b0ldmg9l7fsfg7w63d44gvcssplx8mk";
      };

      beamDeps = [ telemetry ];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.4.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mv48vgby1fv9b2npc0ird3y4isr10np3a3yas3v5hfyz54kll6m";
      };

      beamDeps = [ castore finch hackney jason mime mint telemetry ];
    };

    text = buildMix rec {
      name = "text";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hwbi09q0j7zd7qm402g9ci1gk14bqq29mbxcjmh0bxx4jx6b8jw";
      };

      beamDeps = [ flow ];
    };

    text_corpus_udhr = buildMix rec {
      name = "text_corpus_udhr";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1f1z5wk315r2gnxk0b2f9xjkj597sc4jx6wvz1q31w2fh1m0nsh5";
      };

      beamDeps = [ text ];
    };

    timex = buildMix rec {
      name = "timex";
      version = "3.7.8";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0d8lz1y8kjzgiakvl5kzmc5ijfx8chfml9g5d5fj1ddabzf8wfwg";
      };

      beamDeps = [ combine gettext tzdata ];
    };

    towel = buildMix rec {
      name = "towel";
      version = "0.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yivgnaxdlfcv0rc35bviy47z8n9rkpis38k3rw9xpyqwvkwbdz7";
      };

      beamDeps = [];
    };

    typed_struct = buildMix rec {
      name = "typed_struct";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0v8v3l8j7g3ran3f9gc2nc1mkj6kwfdr6kshm2cf3r0zlv1xa2y5";
      };

      beamDeps = [];
    };

    tzdata = buildMix rec {
      name = "tzdata";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11wpm1mjla8hbkb5mssprg3gsq1v24s8m8nyk3hx5z7aaa1yr756";
      };

      beamDeps = [ hackney ];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08952lw8cjdw8w171lv8wqbrxc4rcmb3jhkrdb7n06gngpbfdvi5";
      };

      beamDeps = [];
    };

    unsafe = buildMix rec {
      name = "unsafe";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rahpgz1lsd66r7ycns1ryz2qymamz1anrlps986900lsai2jxvc";
      };

      beamDeps = [];
    };

    versioce = buildMix rec {
      name = "versioce";
      version = "1.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1r8f6h5cpr8n0inrr9rwqpzhyb6jszisyy4fzzwf9xfcfdjkdflx";
      };

      beamDeps = [ git_cli ];
    };

    waffle = buildMix rec {
      name = "waffle";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0kcd4m32m7njvcz80ayqa1m611j473x16f1xq85nsnycb8hbzv6y";
      };

      beamDeps = [ ex_aws ex_aws_s3 hackney sweet_xml ];
    };

    wallaby = buildMix rec {
      name = "wallaby";
      version = "0.29.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05blrcapk8hia1n9qmz9h6n8ji6c0hr0bhgm3w5bpb8k9c63dc91";
      };

      beamDeps = [ ecto_sql httpoison jason phoenix_ecto web_driver_client ];
    };

    web_driver_client = buildMix rec {
      name = "web_driver_client";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03rmn2m89h1qbskdjx3vf0v1spbxjb7g0mc43inr4x1ypj961k43";
      };

      beamDeps = [ hackney jason tesla ];
    };

    zest = buildMix rec {
      name = "zest";
      version = "0.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0jlpldb94wm1v2kavvsy5h7w5mvjmxnkssl48mp2iphmysnddqpb";
      };

      beamDeps = [];
    };
  };
in self

