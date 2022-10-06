{ lib, beamPackages, overrides ? (x: y: { }), pkgs }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {

    surface_heroicons = buildMix rec {
      name = "surface_heroicons";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "";
      };

      beamDeps = [ dataloader decimal nimble_parsec telemetry ];
    };

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
      version = "4.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0zr0syz0jgmypshavmyg8hxim2cj74b6igv3ssp05bnsibnc5ji8";
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

    browser = buildMix rec {
      name = "browser";
      version = "0.4.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1mzqniwx1px25mg79y7nq4iv7g5b18wq00w75ds1jjsaklqclxnl";
      };

      beamDeps = [ plug ];
    };

    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19bp6xh052ql3ha0v3r8999cvja5d2p6cph02mxphfaj4jsbyc53";
      };

      beamDeps = [ ];
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
      version = "0.1.18";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01kawrhxcc0i7zkygss5ia8hmkzv39q4bnrwnf0fz0mpa9jazfv1";
      };

      beamDeps = [ ];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ha6vmf5p3xlbf5w1msa89frhvfk535rnyfybz9wdmh6vdms8v96";
      };

      beamDeps = [ ];
    };

    cldr_utils = buildMix rec {
      name = "cldr_utils";
      version = "2.19.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "084n92j1sjb12y8va801r318gjj4yjay28dbjgcg6w1y6rwhzlgv";
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

      beamDeps = [ ];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pw4rhhsh8mwj26dkbxz2niih9j8pc3qijlpcl8jh208rg1cjf1y";
      };

      beamDeps = [ ];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1746n8ba11amp1xhwzp38yfii2h051za8ndxlwdykyqqljq1wb3j";
      };

      beamDeps = [ ];
    };

    content_disposition = buildMix rec {
      name = "content_disposition";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0s84d6jwi2a0p6zxy8sd70k7dl59225s9kx8icljylfvyh5wlzw7";
      };

      beamDeps = [ ];
    };

    countries = buildMix rec {
      name = "countries";
      version = "1.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1c6cddxdlm4w2dgaq94ncg3rmgdavqp88bmfjmmg36d7sbyx1r51";
      };

      beamDeps = [ yamerl ];
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

      beamDeps = [ ];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.6.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lvxzksdrc2lbl0rzrww4q5rmayf37q0phcpz2kyvxq7n2zi1qa1";
      };

      beamDeps = [ bunt file_system jason ];
    };

    css_colors = buildMix rec {
      name = "css_colors";
      version = "0.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13r2p21b3hc85dsn6ml67b4m3qni3d3mdh55rxf6mbap2sx5ydr0";
      };

      beamDeps = [ ecto ];
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

      beamDeps = [ ];
    };

    deep_merge = buildMix rec {
      name = "deep_merge";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0c2li2a3hxcc05nwvy4kpsal0315yk900kxyybld972b15gqww6f";
      };

      beamDeps = [ ];
    };

    digital_token = buildMix rec {
      name = "digital_token";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09kfwvjmjzikhy7p7s5dgkl9x011xvsb052fqfrmpvhz3pvfsy51";
      };

      beamDeps = [ cldr_utils jason ];
    };

    earmark = buildMix rec {
      name = "earmark";
      version = "1.4.30";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1n09b9x4yj3s24n837g26s49nc0q8kjhh7pgpxw40cinmsfsk5j5";
      };

      beamDeps = [ earmark_parser ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.28";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ys34w9r74k1dsligybpd5cgkv1x8nlm44y8h3f32cka509fy72h";
      };

      beamDeps = [ ];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0gdpjlj7235br072pk350qwygcsv1hm8bdfhmwbbjy0khg2ypmgy";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_autoslug_field = buildMix rec {
      name = "ecto_autoslug_field";
      version = "3.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03ycq3c6sm79sx5cxsbv3yc1zvx0ss2a8mig0qr33wc5rz3m5hlf";
      };

      beamDeps = [ ecto slugger ];
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

    ecto_nested_changeset = buildMix rec {
      name = "ecto_nested_changeset";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sm7a1n67jnx98g8a0bqpdf4nz77c9k7p4ypgira3zcixilb7ics";
      };

      beamDeps = [ ecto ];
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
      version = "3.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lv4b45j0bja98q0qhlp97a7zvb0g7x2bgkqr721m2rv0whggwx8";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05ppvbhqi5m9zk1c4xnrki814sqhxrc7d1dpvfmwm2v7qm8xdjzm";
      };

      beamDeps = [ ];
    };

    email_checker = buildMix rec {
      name = "email_checker";
      version = "0.2.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "02p54gvj54j6q853jdyy3pk84pasabdzzsq8vz4fkp1mn1g0xb74";
      };

      beamDeps = [ ];
    };

    eqrcode = buildMix rec {
      name = "eqrcode";
      version = "0.1.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wbn23l17my4bjlnhnn4ssb9i499c2qn91pmnrxd63vaqdry6c6s";
      };

      beamDeps = [ ];
    };

    esbuild = buildMix rec {
      name = "esbuild";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rgzjjb0j3m0xz8gs112dydfz7m5brlpfm2qmz7w8qyr6ars10zi";
      };

      beamDeps = [ castore ];
    };

    eternal = buildMix rec {
      name = "eternal";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10p7m6kv2z2c16gw36wgiwnkykss4lfkmm71llxp09ipkhmy77rc";
      };

      beamDeps = [ ];
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
      version = "2.33.2";
      mixEnv = "release";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1y7vx4imyqx1gh38jfxkqz6fy7cdrd2189f08h66rn2fgcaag0gx";
      };

      beamDeps = [ castore certifi cldr_utils decimal gettext jason nimble_parsec ];
    };

    ex_cldr_calendars = buildMix rec {
      name = "ex_cldr_calendars";
      version = "1.20.0";
      mixEnv = "release";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1na6gr0s5kmij68gil6gxfzb0zji3zlpw9zgvs24g0cmw9ngmfc6";
      };

      beamDeps = [ ex_cldr_numbers ex_doc jason ];
    };

    ex_cldr_currencies = buildMix rec {
      name = "ex_cldr_currencies";
      version = "2.14.1";
      mixEnv = "release";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "006y8ph53ka7miq05k011arapiapq6lhw5v29p297pissi78c2ns";
      };

      beamDeps = [ ex_cldr jason ];
    };

    ex_cldr_dates_times = buildMix rec {
      name = "ex_cldr_dates_times";
      version = "2.12.0";
      mixEnv = "release";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "187bac1ffq5z8hfbfgg6hfidb6xnz0aq84nc2yzf24lm3x644ny1";
      };

      beamDeps = [ ex_cldr_calendars ex_cldr_numbers jason ];
    };

    ex_cldr_languages = buildMix rec {
      name = "ex_cldr_languages";
      version = "0.3.3";
      mixEnv = "release";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yj4rj4r0wdzhrwkg1xdg1x28d1pp3kk8fr45n3v9d5pfbpizyr2";
      };

      beamDeps = [ ex_cldr jason ];
    };

    ex_cldr_numbers = buildMix rec {
      name = "ex_cldr_numbers";
      version = "2.27.2";
      mixEnv = "release";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0r73g7pzxi1rba9lgsr517d8795yx4a66qyck0x3lyg1jdhz90pn";
      };

      beamDeps = [ decimal digital_token ex_cldr ex_cldr_currencies jason ];
    };

    ex_cldr_plugs = buildMix rec {
      name = "ex_cldr_plugs";
      version = "1.2.0";
      mixEnv = "release";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13ngn58bx8f6yqgkb0c1vjbf5n9hr78z4gy949iyzqm7syg284g1";
      };

      beamDeps = [ ex_cldr gettext jason plug ];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.28.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10dikbqgssk734wkiahwwplh1acb12wyy9xsx6irlghi6dqv1i6j";
      };

      beamDeps = [ earmark_parser makeup_elixir makeup_erlang ];
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

    ex_marcel = buildMix rec {
      name = "ex_marcel";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1yvj7d4hw9g8hb8h83pcvjas05kkrvc0f7hcx705572s8fbw9ps8";
      };

      beamDeps = [ ];
    };

    ex_maybe = buildMix rec {
      name = "ex_maybe";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lk3nz2f8rajk62zsm1dskzcjp7w08bhlc1va6d12zswj66cgy0s";
      };

      beamDeps = [ ];
    };

    ex_ulid = buildMix rec {
      name = "ex_ulid";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0q08y8xw2q4dr1w6g3rcyjlgib2w2wz26znycfan7i7bg93zvgm2";
      };

      beamDeps = [ ];
    };

    ex_unit_notifier = buildMix rec {
      name = "ex_unit_notifier";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cp3msbal2pc4w1bydibqs91r7qdl60xgi5fy3bqmrhdsp4l907k";
      };

      beamDeps = [ ];
    };

    exconstructor = buildMix rec {
      name = "exconstructor";
      version = "1.2.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q41sdkmfz70hvz9ikzv65d048hn46c9j8fh5r96nda1kg9diqvk";
      };

      beamDeps = [ ];
    };

    exqlite = buildMix rec {
      name = "exqlite";
      version = "0.11.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11zy7l3ccqk62plksaqcfa2q9xdv1z2bfx2dlf3l5ldjzx314ksi";
      };

      beamDeps = [ db_connection elixir_make ];
    };

    faker = buildMix rec {
      name = "faker";
      version = "0.17.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0slacn8z5xnk8i0kpgs1y8zl7hlzg19hfl83adgmrlizm62avm57";
      };

      beamDeps = [ ];
    };

    fast_ngram = buildMix rec {
      name = "fast_ngram";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1gf11p1rx3bgq9xs8rmd9k74byayl3vgpwjvg88xh503n32lkjch";
      };

      beamDeps = [ ];
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

      beamDeps = [ ];
    };

    finch = buildMix rec {
      name = "finch";
      version = "0.13.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1k56zfbadpppn8flavb4aczq0npcqnlhg993l51c1k8dw76pv5a9";
      };

      beamDeps = [ castore mime mint nimble_options nimble_pool telemetry ];
    };

    floki = buildMix rec {
      name = "floki";
      version = "0.33.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ihjszkd5pbgzvp1rgvchzngn2p5n6h8ag141zrzs4sz2byka426";
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

    fsmx = buildMix rec {
      name = "fsmx";
      version = "0.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0hsi28j29ynxfpm8rrif59pxcavyz75m2ybydf3ayxp13ag63gsb";
      };

      beamDeps = [ ecto ecto_sql ];
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

      beamDeps = [ ];
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

      beamDeps = [ geo jason poison postgrex ];
    };

    geocoder = buildMix rec {
      name = "geocoder";
      version = "1.1.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08hhp9b4c995impbwp2bcb4ji1h3r5vryndh4dqpz3cm234sljdl";
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

      beamDeps = [ ];
    };

    geoip = buildMix rec {
      name = "geoip";
      version = "0.2.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06vs9057pm797ca9awqlr4fbgr5fbmvhxbmc5q8vvj0jffcm2x1i";
      };

      beamDeps = [ cachex httpoison jason ];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.20.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ggb458h60ch3inndqp9xhbailhb0jkq3xnp85sa94sy8dvv20qw";
      };

      beamDeps = [ ];
    };

    git_cli = buildMix rec {
      name = "git_cli";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16xg5rkx86xa5zg7iwkx7a72dnwfnbnd7w8i6m6iz9469hprbjvq";
      };

      beamDeps = [ ];
    };

    git_diff = buildMix rec {
      name = "git_diff";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "26fe7799c923fd4ef082efaa4b6725b47a556aa98fddc7b5017509fb4132f963";
      };

      beamDeps = [ ];
    };

    mappable = buildMix rec {
      name = "mappable";
      version = "0.2.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "3038564db78bbde442100d9252aac484be746612bc74b333fbeaeffec8087efa";
      };

      beamDeps = [ ];
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

    hpax = buildMix rec {
      name = "hpax";
      version = "0.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04wci9ifsfyd2pbcrnpgh2aq0a8fi1lpkrzb91kz3x93b8yq91rc";
      };

      beamDeps = [ ];
    };

    html_entities = buildMix rec {
      name = "html_entities";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1k7xyj0q38ms3n5hbn782pa6w1vgd6biwlxr4db6319l828a6fy5";
      };

      beamDeps = [ ];
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
      version = "1.8.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08crb48yz7r7w00pzw9gfk862g99z2ma2x6awab0rqvjd7951crb";
      };

      beamDeps = [ hackney ];
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

      beamDeps = [ ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0891p2yrg3ri04p302cxfww3fi16pvvw1kh4r91zg85jhl87k8vr";
      };

      beamDeps = [ decimal ];
    };

    jumper = buildMix rec {
      name = "jumper";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cvlbfkapkvbwaijmjq3cxg5m6yv4rh69wvss9kfj862i83mk31i";
      };

      beamDeps = [ ];
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

    matrix_reloaded = buildMix rec {
      name = "matrix_reloaded";
      version = "2.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hvg26xmqp0is7r40pdcl74yxa11yivl2rrrak1zbcdnvyvckqym";
      };

      beamDeps = [ ex_maybe result ];
    };

    meck = buildRebar3 rec {
      name = "meck";
      version = "0.9.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09jq0jrsd3dwzjlnwqjv6m9r2rijgiv57yja6jl41p2p2db4yd41";
      };

      beamDeps = [ ];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [ ];
    };

    mime = buildMix rec {
      name = "mime";
      version = "2.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0szzdfalafpawjrrwbrplhkgxjv8837mlxbkpbn5xlj4vgq0p8r7";
      };

      beamDeps = [ ];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [ ];
    };

    mimetype_parser = buildMix rec {
      name = "mimetype_parser";
      version = "0.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lm8yzcmg17nhvr4p4dbmamb280a9dzqx4rwv66ffz40cz2q13vx";
      };

      beamDeps = [ ];
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

    mint_web_socket = buildMix rec {
      name = "mint_web_socket";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18km9aj3hv1cvx6wl6lk5qgqx967y85l2dzc3qzv77m5aqkilisj";
      };

      beamDeps = [ mint ];
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

    mochiweb = buildRebar3 rec {
      name = "mochiweb";
      version = "2.22.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mbnl017as88jqj121l4viizpnpn703kx8f8s5vcb0yj2p9izgfb";
      };

      beamDeps = [ ];
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

      beamDeps = [ ];
    };

    mox = buildMix rec {
      name = "mox";
      version = "1.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wpyh6wp76lyx0q2cys23rpmci4gj1pqwnqvfk467xxanchlk1pr";
      };

      beamDeps = [ ];
    };

    neotoma = buildRebar3 rec {
      name = "neotoma";
      version = "1.7.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0a0gdr1ksjjbbxhm042awid86w6ypdmhzwx70q3zlzsnn6wj58rd";
      };

      beamDeps = [ ];
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

      beamDeps = [ ];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.2.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1c3hnppmjkwnqrc9vvm72kpliav0mqyyk4cjp7vsqccikgiqkmy8";
      };

      beamDeps = [ ];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0gv59waa505mz2gi956sj1aa6844c65w2dp2qh2jfgsx15am0w8w";
      };

      beamDeps = [ ];
    };

    nimble_totp = buildMix rec {
      name = "nimble_totp";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1cshbdz6hss32hbipi9iyxx10zvad93ninivzg9cqds6y5gx3v3z";
      };

      beamDeps = [ ];
    };

    number = buildMix rec {
      name = "number";
      version = "1.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "060gr8r24mygkgvdwc0i8bvrwyygr5n14c54lrjsjb3b16y7nffx";
      };

      beamDeps = [ decimal ];
    };

    oban = buildMix rec {
      name = "oban";
      version = "2.13.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "097isyz3mlix1qkazsgbhgvx6sp02rvs2xdviy9dgqh9nj16zlm7";
      };

      beamDeps = [ ecto_sql jason postgrex telemetry ];
    };

    oembed = buildMix rec {
      name = "oembed";
      version = "0.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1cxkdxmcqkfs5swj4kmkraq838rx7awirh00b8gn291vszjx9bpf";
      };

      beamDeps = [ exconstructor floki httpoison poison ];
    };

    pane = buildMix rec {
      name = "pane";
      version = "0.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12pz0i5gjln4clv1k9l61n9slbm1sizw2c1989vlfbgmhv5958i7";
      };

      beamDeps = [ ];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [ ];
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

      beamDeps = [ ];
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
      version = "1.6.13";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "078pj1dk6i20ml8d2vjhbhq12hhl7i2dgwjdv9k20vhp65n81n0k";
      };

      beamDeps = [ castore jason phoenix_pubsub phoenix_view plug plug_cowboy plug_crypto telemetry ];
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
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0dk00h9c3qxlq0zd8hnnjbdjs0nk996y6lh8lf7550qygvl6ak9p";
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
      version = "0.18.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01lphqh9ssx1dfclf6s2sqzi3s14zgnixjnkhaa6spmh2g6f31dp";
      };

      beamDeps = [ jason phoenix phoenix_html telemetry ];
    };

    phoenix_meta_tags = buildMix rec {
      name = "phoenix_meta_tags";
      version = "0.1.9";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0a1lf84v3x1kdqd4hilapsap327jkpry4i3v6snq87wmkzpbw19k";
      };

      beamDeps = [ phoenix_html plug ];
    };

    phoenix_profiler = buildMix rec {
      name = "phoenix_profiler";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0kysigkclcvbfb3sz982kizz7fn05x90m4rf20cbwysv5sb4lxpi";
      };

      beamDeps = [ phoenix_live_dashboard phoenix_live_view ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1nfqrmbrq45if9pgk6g6vqiply2sxc40is3bfanphn7a3rnpqdl1";
      };

      beamDeps = [ ];
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
      version = "1.2.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18plj2idhp3f0nmqyjjf2rzj849l3br0797m8ln20p5dqscj0rxm";
      };

      beamDeps = [ ];
    };

    poison = buildMix rec {
      name = "poison";
      version = "4.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "098gdz7xzfmnjzgnnv80nl4h3zl8l9czqqd132vlnfabxbz3d25s";
      };

      beamDeps = [ ];
    };

    poolboy = buildRebar3 rec {
      name = "poolboy";
      version = "1.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1qq116314418jp4skxg8c6jx29fwp688a738lgaz6h2lrq29gmys";
      };

      beamDeps = [ ];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.16.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s5jbwfzsdsyvlwgx3bqlfwilj2c468wi3qxq0c2d23fvhwxdspd";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    qr_code = buildMix rec {
      name = "qr_code";
      version = "2.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0winzwd1hf5d7s83hslgwb1qvfhn9hafnak0b9qwir2vdq7xqr5n";
      };

      beamDeps = [ ex_maybe matrix_reloaded result xml_builder ];
    };

    qrcode_ex = buildMix rec {
      name = "qrcode_ex";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19sm4jv8zngsb7mkkpha22vygd508pwfcvavwlb3n71szfbv7c4y";
      };

      beamDeps = [ ];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfz5ld54pkd2w25jadyznia2vb7aw9bclck21fizargd39wzys9";
      };

      beamDeps = [ ];
    };

    recase = buildMix rec {
      name = "recase";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "032fib052caapihmxhnrzbap4kigwdq5hsaanna4lbsmkxm7bx9n";
      };

      beamDeps = [ ];
    };

    recode = buildMix rec {
      name = "recode";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0m68k921b70lq2z3h78kkwd57ly2393rzdp747n3d4ph87q65aiy";
      };

      beamDeps = [ bunt rewrite ];
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

    remote_ip = buildMix rec {
      name = "remote_ip";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01zrrb4fakhf8wsvsivis0z3y8mbssg65adn9civahqcwpacm7wy";
      };

      beamDeps = [ combine plug ];
    };

    req = buildMix rec {
      name = "req";
      version = "0.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "150gnx1xi144kikcl2ppymj8ppgf0gkl38bn9s0sm465pf5nc1hx";
      };

      beamDeps = [ finch jason mime plug ];
    };

    result = buildMix rec {
      name = "result";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "171jc2zxcrrznwq3dpyr53pqpq9ndgrh1is63mbppz51j3ms9b67";
      };

      beamDeps = [ ];
    };

    rewrite = buildMix rec {
      name = "rewrite";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1knh3prrk7dbmkqc4jliz39c8l04dqg8p8vdf0wanyc9cn2hjvk5";
      };

      beamDeps = [ sourceror ];
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

    scrivener = buildMix rec {
      name = "scrivener";
      version = "2.7.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1n90nv9913xg8lrj1n7c4r4ym5d92fnvxf0xxvxlw9s09pna0rkq";
      };

      beamDeps = [ ];
    };

    scrivener_ecto = buildMix rec {
      name = "scrivener_ecto";
      version = "2.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0q72qc5azpha40wxi3f442bq8i5fym9460r9241v01kqd1qz22g8";
      };

      beamDeps = [ ecto scrivener ];
    };

    secure_random = buildMix rec {
      name = "secure_random";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1az658qpha6pnlns37pn9l201wck4ahrvldgp91s2h1rbvqm95qv";
      };

      beamDeps = [ ];
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

    simplex_format = buildMix rec {
      name = "simplex_format";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03d4jwlp30nipw2mg3lnf8w9izc1s787rv9b7spidczf1653wkbl";
      };

      beamDeps = [ phoenix_html ];
    };

    sleeplocks = buildRebar3 rec {
      name = "sleeplocks";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q823i5bisc83pyssgrqkggyxiasm7b8dygzj2r943adzyp3gvl4";
      };

      beamDeps = [ ];
    };

    slime = buildMix rec {
      name = "slime";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09qak4vcsx3kpngd0sa054fly5ys07zavg35a7j5y2klbpq5hfrh";
      };

      beamDeps = [ neotoma ];
    };

    slipstream = buildMix rec {
      name = "slipstream";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04x9mg0a74ri7f009wrzi3aqk5mfh68bxv1bm7qryjk56vg58xiv";
      };

      beamDeps = [ jason mint_web_socket nimble_options telemetry ];
    };

    slugger = buildMix rec {
      name = "slugger";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fmgnl4ydq4ivbfk1a934vcn0d0wb24lhnvcmqg5sq0jwz8dxl10";
      };

      beamDeps = [ ];
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
      version = "0.13.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11lzmhm6s10g1l4lsfsqxwi9cd09l49cwdvf6grrvvpkpw3xcbbd";
      };

      beamDeps = [ nimble_parsec ];
    };

    sourceror = buildMix rec {
      name = "sourceror";
      version = "0.11.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1yqdnxdvbwlcvklv2472r0pkgfjccyqgg3y6xvk6p8wni08mkdls";
      };

      beamDeps = [ ];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [ ];
    };

    statistex = buildMix rec {
      name = "statistex";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09vcm2sz2llv00cm7krkx3n5r8ra1b42zx9gfjs8l0imf3p8p7gz";
      };

      beamDeps = [ ];
    };

    stream_data = buildMix rec {
      name = "stream_data";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wg2p5hwf7qmkwsc1i3q7h558f7sr9f13y8i6kds9bb9q3pd4aq1";
      };

      beamDeps = [ ];
    };

    surface = buildMix rec {
      name = "surface";
      version = "0.9.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wm3djbx5fii6cd02f8lz39n4sffkz5ils7iw383j1qrbp9i44qk";
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

      beamDeps = [ ];
    };

    table_rex = buildMix rec {
      name = "table_rex";
      version = "3.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "141404hwnwnpspvhs112j2la8dfnvkwr0xy14ff42w6nljmj72k7";
      };

      beamDeps = [ ];
    };

    tailwind = buildMix rec {
      name = "tailwind";
      version = "0.1.9";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "02vdlm3lrigk3f1axr1hnv1fsb2d5ggz5d9v67naln6415vzh4wj";
      };

      beamDeps = [ castore ];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0j6zq3y7xz768djz25x55gampyhd9nv6ax9dzx67f52nyyhv49xp";
      };

      beamDeps = [ ];
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

    temp = buildMix rec {
      name = "temp";
      version = "0.4.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "039ys0yccxnydgq8c9c8j0diwamfs5s1a0p1id3jg945d9yrxwba";
      };

      beamDeps = [ ];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.4.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mv48vgby1fv9b2npc0ird3y4isr10np3a3yas3v5hfyz54kll6m";
      };

      beamDeps = [ castore finch hackney jason mime mint poison telemetry ];
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
      version = "3.7.9";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q8chs28k5my6nzzm61rhc2l9wkhzfn0kiqzf87i71xvwn11asb4";
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

      beamDeps = [ ];
    };

    typed_struct = buildMix rec {
      name = "typed_struct";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0v8v3l8j7g3ran3f9gc2nc1mkj6kwfdr6kshm2cf3r0zlv1xa2y5";
      };

      beamDeps = [ ];
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

      beamDeps = [ ];
    };

    unsafe = buildMix rec {
      name = "unsafe";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rahpgz1lsd66r7ycns1ryz2qymamz1anrlps986900lsai2jxvc";
      };

      beamDeps = [ ];
    };

    uuid = buildMix rec {
      name = "uuid";
      version = "1.1.8";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b7jjbkmp42rayl6nif6qirksnxgxzksm2rpq9fiyq1v9hxmk467";
      };

      beamDeps = [ ];
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
      version = "0.30.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0y1xaklk9xjg4a86qn3rx4gcn034rvdnw4r4cn0q1zwldbgm2wj5";
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

    xml_builder = buildMix rec {
      name = "xml_builder";
      version = "2.1.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xz66k24f8srn94p75hq5qkls1nfkcljil8qhgmqq5mrz16ql628";
      };

      beamDeps = [ ];
    };

    yamerl = buildRebar3 rec {
      name = "yamerl";
      version = "0.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vjf9gnchvh4qfykrxf0jw0didvfrx54wdm26z41s1gicclxnsil";
      };

      beamDeps = [ ];
    };

    zest = buildMix rec {
      name = "zest";
      version = "0.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0jlpldb94wm1v2kavvsy5h7w5mvjmxnkssl48mp2iphmysnddqpb";
      };

      beamDeps = [ ];
    };

    pointers = buildMix rec {
      name = "pointers";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "DugdtfoRAIpQi2sCm1mivmahJkh5tTYdRYbBUz8ugYo=";
      };

      beamDeps = [ ecto_sql flexto pointers_ulid ];
    };

    flexto = buildMix rec {
      name = "flexto";
      version = "0.2.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "Im7ZSvEKICZUUVx9+Jxj/YW3ibcZimYbNiR1Yj9z4Ik=";
      };

      beamDeps = [ ecto ecto_sql ];
    };

    pointers_ulid = buildMix rec {
      name = "pointers_ulid";
      version = "0.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "TDvO6i4XRN9TVeHrny2q3SPT1lS3Eh4nJVzhur3bHVI=";
      };

      beamDeps = [ ecto ecto_sql ];
    };

    tree_magic = buildMix rec {
      name = "pointers_ulid";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "";
      };

      beamDeps = [ ecto ecto_sql ];
    };

    ########################
    ### GIT DEPENDENCIES ###
    ########################

    where = buildMix rec {
      name = "where";
      version = "df249f5b8abdeb23c63dbcf1c7fc99b197c93d93";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "untangle";
        rev = "df249f5b8abdeb23c63dbcf1c7fc99b197c93d93";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    untangle = buildMix rec {
      name = "untangle";
      version = "df249f5b8abdeb23c63dbcf1c7fc99b197c93d93";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "untangle";
        rev = "df249f5b8abdeb23c63dbcf1c7fc99b197c93d93";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    verbs = buildMix rec {
      name = "verbs";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "shannonnwells";
        repo = "verbs_ex";
        rev = "4b27067385390d4d2063ec1a09f9d96b97ed9a73";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    voodoo = buildMix rec {
      name = "voodoo";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "voodoo";
        rev = "8c384a112504849b2fa663d49acef7bbad67a745";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    absinthe_client = buildMix rec {
      name = "absinthe_client";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "absinthe_client";
        rev = "818955a3e2804816abb0b4961e7b1fe88a3ff387";
        sha256 = "";
      };

      beamDeps = [ castore req slipstream ];
    };

    activity_pub = buildMix rec {
      name = "activity_pub";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "activity_pub";
        rev = "2cbb74be6ee9398b3e53ebfacfbd1e6d4bf0aaf0";
        sha256 = "";
      };

      beamDeps = [ cachex certifi combine connection cowboy cowboy_telemetry cowlib db_connection decimal earmark_parser ecto ecto_sql eternal ex_doc ex_machina ex_ulid flexto gettext hackney http_signatures idna jason jumper makeup makeup_elixir makeup_erlang meck metrics mime mimerl mock nimble_parsec oban parse_trans phoenix phoenix_ecto phoenix_html phoenix_live_dashboard phoenix_live_view phoenix_pubsub phoenix_view plug plug_cowboy plug_crypto pointers pointers_ulid postgrex ranch sleeplocks ssl_verify_fun telemetry telemetry_metrics telemetry_poller tesla timex tzdata unicode_util_compat unsafe where ];
    };

    arrows = buildMix rec {
      name = "arrows";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "arrows";
        rev = "2482f0b33f966db602fcbad68c756aa643f0f8af";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    archeometer = buildMix rec {
      name = "archeometer";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "mayel";
        repo = "archeometer";
        rev = "e388acec0137706e8da83ef11454544463b2a7a1";
        sha256 = "";
      };

      beamDeps = [ credo css_colors exqlite slime temp uuid ];
    };

    bonfire_api_graphql = buildMix rec {
      name = "bonfire_api_graphql";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_api_graphql";
        rev = "e9623c158071f57a164ab8e3e9c9c7512d7ce3a3";
        sha256 = "";
      };

      beamDeps = [ ]; # I'm not including dev dependencies
    };

    bonfire_boundaries = buildMix rec {
      name = "bonfire_boundaries";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_boundaries";
        rev = "8c540b34c19100ba0cd4283ca7bd8212cf8c1b1b";
        sha256 = "";
      };

      beamDeps = [ arrows bonfire_common bonfire_data_access_control bonfire_data_identity bonfire_ui_common certifi cldr_utils combine connection cowboy cowboy_telemetry cowlib db_connection decimal earmark earmark_parser ecto ecto_sql ex_cldr ex_ulid faker file_system flexto floki gettext git_diff hackney html_entities html_sanitize_ex idna jason makeup makeup_diff makeup_eex makeup_elixir makeup_graphql makeup_html makeup_js makeup_sql mappable metrics mime mimerl mochiweb nimble_parsec paginator pane parse_trans phoenix phoenix_gon phoenix_html phoenix_live_reload phoenix_live_view phoenix_pubsub phoenix_view plug plug_cowboy plug_crypto pointers pointers_ulid ranch recase scribe sourceror ssl_verify_fun surface surface_heroicons telemetry telemetry_metrics telemetry_poller timex tzdata unicode_util_compat where ];
    };

    bonfire_breadpub = buildMix rec {
      name = "bonfire_breadpub";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_breadpub";
        rev = "9c89c7bf91a43a6b01dac252497a3a2ba92adf6b";
        sha256 = "";
      };

      beamDeps = [ absinthe absinthe_plug bonfire_search ]; # Not sure if this is built with mix or rebar, or if we need to include deps.{git, hex} dependencies 
    };

    bonfire_classify = buildMix rec {
      name = "bonfire_classify";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_classify";
        rev = "2c2b008fb0e29b85cf8af36be0f466e87fec6bc3";
        sha256 = "";
      };

      beamDeps = [ bonfire_api_graphql bonfire_search bonfire_tag bonfire_me ]; # All these are optional, didn't include deps.{hex, git}
    };

    bonfire_common = buildMix rec {
      name = "bonfire_common";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_common";
        rev = "e3fde546c897c14570ba648d95e09388d0e6fd2e";
        sha256 = "";
      };

      beamDeps = [ arrows bonfire_data_identity certifi cldr_utils combine connection dataloader db_connection decimal earmark earmark_parser ecto ecto_sql emote ex_cldr ex_cldr_languages ex_cldr_plugs ex_ulid faker flexto floki gettext hackney html_entities html_sanitize_ex idna jason mappable metrics mime mimerl mochiweb nimble_parsec paginator parse_trans plug plug_crypto pointers pointers_ulid recase sentry ssl_verify_fun telemetry timex tzdata unicode_util_compat where zest ];
    };

    bonfire_data_access_control = buildMix rec {
      name = "bonfire_data_access_control";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_data_access_control";
        rev = "7fe8c4d77f53e2fa03c5796d95bf90f1c9051b37";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    bonfire_data_activity_pub = buildMix rec {
      name = "bonfire_data_activity_pub";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_data_activity_pub";
        rev = "db4a68a89b93c374c34a269f403b9054bd79bd5c";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    bonfire_data_assort = buildMix rec {
      name = "bonfire_data_assort";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_data_assort";
        rev = "ba8493ba162e161834f0c9b2e057202566a499ac";
        sha256 = "";
      };

      beamDeps = [ pointers ecto_ranked ];
    };

    bonfire_data_edges = buildMix rec {
      name = "bonfire_data_edges";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_data_edges";
        rev = "269a91e01db1d83d43f38962f23ca23aac5044a9";
        sha256 = "";
      };

      beamDeps = [ connection db_connection decimal ecto ecto_sql flexto pointers_ulid pointers telemetry ];
    };

    bonfire_data_identity = buildMix rec {
      name = "bonfire_data_identity";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_data_identity";
        rev = "351f418d0e79fa7da34d451a0e5bc26a0dd56b57";
        sha256 = "";
      };

      beamDeps = [ comeonin connection db_connection decimal earmark_parser ecto ecto_sql ex_ulid ex_doc flexto makeup makeup_elixir makeup_erlang nimble_parsec pbkdf2_elixir pointers pointers_ulid telemetry untangle ];
      # Apparently where and untangle are the same repo? bonfire-networks/untangle, may be different commits though
    };

    bonfire_data_shared_user = buildMix rec {
      name = "bonfire_data_shared_user";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_data_shared_user";
        rev = "97d4745ea86d2bee3da95c4a1d23bea99d673cea";
        sha256 = "";
      };

      beamDeps = [ pointers bonfire_data_identity ];
    };

    bonfire_data_social = buildMix rec {
      name = "bonfire_data_social";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_data_social";
        rev = "5971794776293bf1b22e320e243da8e4a1dbef3d";
        sha256 = "TdV9BTbom9MP5+nU8one27PSzRuFrn4QnD7tFveN8Ns=";
      };

      beamDeps = [ arrows bonfire_data_edges connection db_connection decimal earmark_parser ecto ecto_materialized_path ecto_sql flexto ex_doc makeup makeup_elixir makeup_erlang nimble_parsec pointers pointers_ulid telemetry untangle ];
      # Apparently where and untangle are the same repo? bonfire-networks/untangle, may be different commits though
    };

    ecto_materialized_path = buildMix rec {
      name = "ecto_materialized_path";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "ecto_materialized_path";
        rev = "5971794776293bf1b22e320e243da8e4a1dbef3d";
        sha256 = "";
      };

      beamDeps = [ connection db_connection decimal earmark ecto ex_doc ex_machina poolboy postgrex ];
    };


    bonfire_ecto = buildMix rec {
      name = "bonfire_ecto";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_ecto";
        rev = "e7bec619bfb0923b37da8e8572f4d7363b279c1d";
        sha256 = "";
      };

      beamDeps = [ bonfire_common bonfire_epics ];
    };

    bonfire_editor_ck = buildMix rec {
      name = "bonfire_editor_ck";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_editor_ck";
        rev = "3aa70f94200f503af8aa22a1ae77e3fe77eae10e";
        sha256 = "";
      };

      beamDeps = [ ]; # Not including deps.{hex,git}
    };

    bonfire_editor_quill = buildMix rec {
      name = "bonfire_editor_quill";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_editor_quill";
        rev = "a6d3743b982e9f7be14612391b4465473ba3ab75";
        sha256 = "";
      };

      beamDeps = [ ]; # Not including deps.{hex,git}
    };

    bonfire_epics = buildMix rec {
      name = "bonfire_epics";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_epics";
        rev = "652217237632c7210ad6d6b0c8375654ef3c0d8f";
        sha256 = "";
      };

      beamDeps = [ arrows untangle ];
      # Apparently where and untangle are the same repo? bonfire-networks/untangle, may be different commits though
    };

    bonfire_fail = buildMix rec {
      name = "bonfire_fail";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_fail";
        rev = "88686a00be6fef9d5a6dd30fe26fcd842ab3d7a3";
        sha256 = "";
      };

      beamDeps = [ untangle bonfire_common ];
    };

    bonfire_federate_activitypub = buildMix rec {
      name = "bonfire_federate_activitypub";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_federate_activitypub";
        rev = "25f19d985ed82d4003b0c4355f36c11ed31f3e20";
        sha256 = "";
      };

      beamDeps = [ floki ]; # Not including deps.{git, hex}
    };

    bonfire_files = buildMix rec {
      name = "bonfire_files";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_files";
        rev = "b90932fe939c8acd7eee3e1d8c91d835f33b6c37";
        sha256 = "";
      };

      beamDeps = [ tree_magic bonfire_api_graphql ex_aws_s3 ];
    };

    bonfire_geolocate = buildMix rec {
      name = "bonfire_geolocate";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_geolocate";
        rev = "286b7f55324addebe2af70be8d9d34a3d790b099";
        sha256 = "";
      };

      beamDeps = [ floki bonfire_api_graphql grumble bonfire_tag ];
    };

    bonfire_invite_links = buildMix rec {
      name = "bonfire_invite_links";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_invite_links";
        rev = "fbe87ee6bd8c418af7ff8b73728a23fc0fd6df9e";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    bonfire_mailer = buildMix rec {
      name = "bonfire_mailer";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_mailer";
        rev = "d8a3f4bef0cbe4b8c9db1ee107366ecf083b7824";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    bonfire_me = buildMix rec {
      name = "bonfire_me";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_me";
        rev = "9af9fea23c63ee094a76b24e855848b2c6764e93";
        sha256 = "";
      };

      beamDeps = [ bonfire_data_shared_user bonfire_api_graphql ];
    };

    bonfire_pages = buildMix rec {
      name = "bonfire_pages";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_pages";
        rev = "ed479703092ee3dbf0a87cba2f0c44e69983fa23";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    bonfire_quantify = buildMix rec {
      name = "bonfire_quantify";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_quantify";
        rev = "b9a4f9e83a64da928b2eb865649c576ed1acf74b";
        sha256 = "33SkvB5VmtMZZHNkqQZ8jHj4jzquWskveLGhKaAg76g=";
      };

      beamDeps = [ bonfire_api_graphql bonfire_me ];
    };

    bonfire_search = buildMix rec {
      name = "bonfire_search";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_search";
        rev = "2dea043a3614a258509af44eab0266b85ac8902f";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    bonfire_social = buildMix rec {
      name = "bonfire_social";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_social";
        rev = "46313f075b627f2f5dbc3a58895266b4c2d9d671";
        sha256 = "";
      };

      beamDeps = [ bonfire_api_graphql bonfire_me ];
    };

    bonfire_tag = buildMix rec {
      name = "bonfire_tag";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_tag";
        rev = "f44449ba6f2daa146bae0af2689b767272feefe3";
        sha256 = "";
      };

      beamDeps = [ bonfire_api_graphql ];
    };

    bonfire_ui_common = buildMix rec {
      name = "bonfire_ui_common";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_ui_common";
        rev = "b5c6e193317c730fb672d2dbbf242b94c06b3c2f";
        sha256 = "";
      };

      beamDeps = [ zest ];
    };

    bonfire_ui_coordination = buildMix rec {
      name = "bonfire_ui_coordination";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_ui_coordination";
        rev = "4b64eaebdb2dc88319a786a3fc84beecd159d704";
        sha256 = "";
      };

      beamDeps = [ absinthe absinthe_plug ];
    };

    bonfire_ui_kanban = buildMix rec {
      name = "bonfire_ui_kanban";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_ui_kanban";
        rev = "9f36951c167d0e6c5dc98e4d09daa55afe23b861";
        sha256 = "";
      };

      beamDeps = [ absinthe absinthe_plug ];
    };

    bonfire_ui_me = buildMix rec {
      name = "bonfire_ui_me";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_ui_me";
        rev = "810972ceb163805763905ad23cddac6102882c55";
        sha256 = "";
      };

      beamDeps = [ bonfire_tag bonfire_social ];
    };

    bonfire_ui_social = buildMix rec {
      name = "bonfire_ui_social";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_ui_social";
        rev = "60561996abdc8bd1ba97c03c014c3c31681d14de";
        sha256 = "";
      };

      beamDeps = [ bonfire_editor_ck bonfire_editor_quill bonfire_tag bonfire_boundaries ];
    };

    bonfire_ui_valueflows = buildMix rec {
      name = "bonfire_ui_valueflows";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_ui_valueflows";
        rev = "ca7265c43a7e172e6a3e7f423af254ec06327be5";
        sha256 = "";
      };

      beamDeps = [ absinthe_plug absinthe ];
    };

    bonfire_valueflows = buildMix rec {
      name = "bonfire_valueflows";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_valueflows";
        rev = "aef5cd10f22e929b1c7f43cbb75dcd6e83b9572a";
        sha256 = "";
      };

      beamDeps = [ activity_pub bonfire_search bonfire_api_graphql ];
    };

    bonfire_valueflows_api_schema = buildMix rec {
      name = "bonfire_valueflows_api_schema";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_valueflows_api_schema";
        rev = "32fff390e37b7a7d7bd1fc9f220cbc7516e4df17";
        sha256 = "";
      };

      beamDeps = [ bonfire_api_graphql ];
    };

    bonfire_valueflows_observe = buildMix rec {
      name = "bonfire_valueflows_observe";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "bonfire_valueflows_observe";
        rev = "1540b181b7e68155445c6b067cefdd5d2494bd0a";
        sha256 = "";
      };

      beamDeps = [ bonfire_api_graphql bonfire_me ];
    };

    # phil_columns = buildMix rec {
    #   name = "phil_columns";
    #   version = "3.1.0";

    #   src = pkgs.fetchFromGitHub {
    #     owner = "chickensoupwithrice";
    #     repo = "phil_columns-ex";
    #     rev = "8d728ee8db462e8355cba7f741ca8e574fc321a9";
    #     sha256 = "8LV368RRlzdM9eep799GM8lluJ2KeAj4QhF/YpO7KT8=";
    #   };

    #   beamDeps = [ ecto_sql inflex ];
    # };

    ex_aws = buildMix rec {
      name = "ex_aws";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "ex_aws";
        rev = "2979884fdadabe44cc589346b697c00d8a8d1266";
        sha256 = "+l2GHFGY+LziX0CI6g/jqilIRUmB3XHCCuoTXW4mipc=";
      };

      beamDeps = [ hackney sweet_xml ];
    };

    http_signatures = buildMix rec {
      name = "http_signatures";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "ex_aws";
        rev = "2979884fdadabe44cc589346b697c00d8a8d1266";
        sha256 = "+l2GHFGY+LziX0CI6g/jqilIRUmB3XHCCuoTXW4mipc=";
      };

      beamDeps = [ hackney sweet_xml ];
    };

    phoenix_gon = buildMix rec {
      name = "phoenix_gon";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "phoenix_gon";
        rev = "19fc96298ee191801527b89624a0f291838bd1e4";
        sha256 = "";
      };

      beamDeps = [ ];
    };

    paginator = buildMix rec {
      name = "paginator";
      version = "";

      src = pkgs.fetchFromGitHub {
        owner = "bonfire-networks";
        repo = "paginator";
        rev = "ab590556e9d2015c2373c1d167b857a17f650ac2";
        sha256 = "";
      };

      beamDeps = [ bunt calendar certifi connection db_connection decimal earmark earmark_parser ecto ecto_sql ex_doc ex_machina hackney idna inch_ex jason makeup makeup_elixir makeup_erlang metrics mimerl nimble_parsec parse_trans plug_crypto poison poolboy postgrex ssl_verify_fun telemetry tzdata unicode_util_compat ];
    };
  };
in
self

