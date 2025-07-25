# Do not modify this file!  It was generated by `update-extensions.sh`
# and may be overwritten by future invocations.  Please make changes
# to extensions.toml instead.

# Warning, this file is autogenerated by nix4vscode. Don't modify this manually.
{ pkgs, lib }:

let
  inherit (pkgs.stdenv)
    isDarwin
    isLinux
    isi686
    isx86_64
    isAarch32
    isAarch64
    ;
  vscode-utils = pkgs.vscode-utils;
  merge = lib.attrsets.recursiveUpdate;
in
merge
  (merge
    (merge
      (merge
        {
          "alesbrelih"."gitlab-ci-ls" = vscode-utils.extensionFromVscodeMarketplace {
            name = "gitlab-ci-ls";
            publisher = "alesbrelih";
            version = "1.0.0";
            sha256 = "0bxd7zm55b6y72jppaqw77g9asfqpi2whsq5j6pq23zp3q43603g";

          };
          "beardedbear"."beardedtheme" = vscode-utils.extensionFromVscodeMarketplace {
            name = "beardedtheme";
            publisher = "beardedbear";
            version = "10.1.0";
            sha256 = "0c0kcl08j8ii65h5mkpgssgqgshhkf49adgxd5xh1klx8qn2zjgc";

          };
          "blueglassblock"."better-json5" = vscode-utils.extensionFromVscodeMarketplace {
            name = "better-json5";
            publisher = "blueglassblock";
            version = "1.4.0";
            sha256 = "18pfihbci91fzmpkls75wasdli85qbhn6lb8c69rymgmp8n8cn42";

          };
          "bpruitt-goddard"."mermaid-markdown-syntax-highlighting" =
            vscode-utils.extensionFromVscodeMarketplace
              {
                name = "mermaid-markdown-syntax-highlighting";
                publisher = "bpruitt-goddard";
                version = "1.7.4";
                sha256 = "05943phx80bh9xl3xhdxr0qpp7grpja7z28virkm7kwvs3h7xpi0";

              };
          "bradlc"."vscode-tailwindcss" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-tailwindcss";
            publisher = "bradlc";
            version = "0.14.25";
            sha256 = "0aanllx1fnjbd5wvaqx857xx2y32104czbfyi41nvs586i83nw1m";

          };
          "bruno-api-client"."bruno" = vscode-utils.extensionFromVscodeMarketplace {
            name = "bruno";
            publisher = "bruno-api-client";
            version = "3.1.0";
            sha256 = "0l46jafrf2mfii72gv4ikhygks1s29ys36p71517bdk2rjfj5d4c";

          };
          "castwide"."solargraph" = vscode-utils.extensionFromVscodeMarketplace {
            name = "solargraph";
            publisher = "castwide";
            version = "0.25.0";
            sha256 = "121k1a3g6jz5iwjbkyr6iqgn7pfkckadr9nlgmccfjw2f6884ag5";

          };
          "connor4312"."nodejs-testing" = vscode-utils.extensionFromVscodeMarketplace {
            name = "nodejs-testing";
            publisher = "connor4312";
            version = "1.7.0";
            sha256 = "1zipnl3z1fnp4m52rx854lbk44kdapdb4ki90l42nrnyfr9w5w8j";

          };
          "deerawan"."vscode-dash" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-dash";
            publisher = "deerawan";
            version = "2.4.0";
            sha256 = "0bj3sris57r4nm8n9z9dxsriv23ym2sjq5b6b1608nadkbvgkab2";

          };
          "drknoxy"."eslint-disable-snippets" = vscode-utils.extensionFromVscodeMarketplace {
            name = "eslint-disable-snippets";
            publisher = "drknoxy";
            version = "1.4.1";
            sha256 = "1djjknfg81cjbn4bcalc7gg9fha5lzwmpmmrzm68n87qvld58hs4";

          };
          "eeyore"."yapf" = vscode-utils.extensionFromVscodeMarketplace {
            name = "yapf";
            publisher = "eeyore";
            version = "2025.5.107163247";
            sha256 = "0rq1aq1algw1bv3s5sjmi327zy0yzq2qhmy3xisig6fn1r20fc83";

          };
          "effectful-tech"."effect-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "effect-vscode";
            publisher = "effectful-tech";
            version = "0.2.3";
            sha256 = "0nh49k7s51i99m02d44jy8z3wjynmdigrsf8xa1jcn8y2lahd3k0";

          };
          "fabiospampinato"."vscode-diff" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-diff";
            publisher = "fabiospampinato";
            version = "2.1.2";
            sha256 = "1i8ysv7zisjvvjbg5qn98lpv3rclw94bp3qx6sixvy4rayxsz5c2";

          };
          "flesler"."url-encode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "url-encode";
            publisher = "flesler";
            version = "1.1.0";
            sha256 = "16lj8r97277zrwrjr4lsv8qzv5mz0h8insz3vvggyzgm55cx7dpf";

          };
          "fwcd"."kotlin" = vscode-utils.extensionFromVscodeMarketplace {
            name = "kotlin";
            publisher = "fwcd";
            version = "0.2.36";
            sha256 = "1cwncjvarq3g0cmn9afdd15s81nms0kcawnj3midhr4hchap2aml";

          };
          "ghmcadams"."lintlens" = vscode-utils.extensionFromVscodeMarketplace {
            name = "lintlens";
            publisher = "ghmcadams";
            version = "7.5.0";
            sha256 = "18zfpq7f39hifw5ha9cvvn675r1mbd9sx0lmywphb9mv21f7ya1y";

          };
          "github"."vscode-github-actions" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-github-actions";
            publisher = "github";
            version = "0.27.2";
            sha256 = "06afix94nxb9vbkgmygg02pyczb09cmvr1l8d2b9alsxhk2i0r69";

          };
          "github"."vscode-pull-request-github" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-pull-request-github";
            publisher = "github";
            version = "0.112.0";
            sha256 = "0gi9ib9cf5h7p3l1mxs1z4wjv69kwjxngw6fz071362q7215fp1g";

          };
          "gitlab"."gitlab-workflow" = vscode-utils.extensionFromVscodeMarketplace {
            name = "gitlab-workflow";
            publisher = "gitlab";
            version = "6.35.0";
            sha256 = "0clm21yxyz2brzlqfc5dsysbvscs2hhh1bvpsh2344z1c7waim5j";

          };
          "gracefulpotato"."rbs-syntax" = vscode-utils.extensionFromVscodeMarketplace {
            name = "rbs-syntax";
            publisher = "gracefulpotato";
            version = "0.3.0";
            sha256 = "0k0vll5fh7shwdaj1czkzzrhrv9jg2qcvzr3wcg3rh9j3k8m0ilm";

          };
          "graphql"."vscode-graphql" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-graphql";
            publisher = "graphql";
            version = "0.13.2";
            sha256 = "1aqsash65s2xkqhnm6s6mxq7ahw179376lv420wsn4yri0hs4vpl";

          };
          "graphql"."vscode-graphql-execution" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-graphql-execution";
            publisher = "graphql";
            version = "0.3.2";
            sha256 = "17qdgkxvnsb5bjz33bnzzk1g988rca1r2krm4y2f3z1hg4lbc7bh";

          };
          "idleberg"."applescript" = vscode-utils.extensionFromVscodeMarketplace {
            name = "applescript";
            publisher = "idleberg";
            version = "0.27.2";
            sha256 = "14rqi7nlcj4lrpc697kc9kx195np8arcx13rf70z94dqyj2glbnz";

          };
          "inferrinizzard"."prettier-sql-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "prettier-sql-vscode";
            publisher = "inferrinizzard";
            version = "1.6.0";
            sha256 = "1d4vf3gh2x4ycf8ppvvb5d6rsg2ayckd05rkp3w1kw5gxgzmzalp";

          };
          "jnoortheen"."nix-ide" = vscode-utils.extensionFromVscodeMarketplace {
            name = "nix-ide";
            publisher = "jnoortheen";
            version = "0.4.22";
            sha256 = "1ib8czlqhqq1rz6jrazfd9z3gfqdwqazxdvwmsyp765m0vf78xcg";

          };
          "mrmlnc"."vscode-scss" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-scss";
            publisher = "mrmlnc";
            version = "0.10.0";
            sha256 = "08kdvg4p0aysf7wg1qfbri59cipllgf69ph1x7aksrwlwjmsps12";

          };
          "ms-kubernetes-tools"."vscode-kubernetes-tools" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-kubernetes-tools";
            publisher = "ms-kubernetes-tools";
            version = "1.3.25";
            sha256 = "0br5cvawffjddk5j7806pqilb09vfi34yja1blwasq8zjvs3a6k8";

          };
          "ms-vscode"."remote-explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "remote-explorer";
            publisher = "ms-vscode";
            version = "0.5.0";
            sha256 = "1gws544frhss2x2i7s50ipaalcz6ai2688ykcgvinxsxv9x2gnq4";

          };
          "msjsdiag"."vscode-react-native" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-react-native";
            publisher = "msjsdiag";
            version = "1.13.0";
            sha256 = "0s0npjnzqj3g877b9kqgc07dipww468sfbiwnf55yvvcxyhb7g6f";

          };
          "mxsdev"."typescript-explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "typescript-explorer";
            publisher = "mxsdev";
            version = "0.4.2";
            sha256 = "114ha3fixhfz2dnswvnkg8rwzw5il425n96ixb7j4iiyj5zgnz10";

          };
          "novy"."vsc-gcode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vsc-gcode";
            publisher = "novy";
            version = "0.0.4";
            sha256 = "0mz862fb7r340rhibyp5r03gsps86g9d04g8kibfsjybs5v7wvlm";

          };
          "orta"."vscode-jest" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-jest";
            publisher = "orta";
            version = "6.4.4";
            sha256 = "0djkrj2wbxm17z09n4c15208md70n1ihy5jsmhqq7dh0gkdbj138";

          };
          "oven"."bun-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "bun-vscode";
            publisher = "oven";
            version = "0.0.28";
            sha256 = "0w31hmbc11xvw14k7lba32gqcpqlsj7md790m0h5vbfzlslallas";

          };
          "rooveterinaryinc"."roo-cline" = vscode-utils.extensionFromVscodeMarketplace {
            name = "roo-cline";
            publisher = "rooveterinaryinc";
            version = "3.23.16";
            sha256 = "0p7rzfgdmpmmbz39n3iv83sbcyjd8yihxq9vbxqs1cxxfk31smkl";

          };
          "seeker-dk"."node-modules-viewer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "node-modules-viewer";
            publisher = "seeker-dk";
            version = "0.0.5";
            sha256 = "11ifaih53xb77mbjwqhhphpwglj6d41fy9s1yz67952251s93ab7";

          };
          "terrastruct"."d2" = vscode-utils.extensionFromVscodeMarketplace {
            name = "d2";
            publisher = "terrastruct";
            version = "0.8.8";
            sha256 = "12yj9ammrhrh0cnyr30x3d87d4n7q7j19cggdvyblbwmdln66ycy";

          };
          "tomoyukim"."vscode-mermaid-editor" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-mermaid-editor";
            publisher = "tomoyukim";
            version = "0.19.1";
            sha256 = "146g7m2dgh7wfncvi48z1jym7aayz2qr3x03hpqf93yk0gvi369i";

          };
          "tyriar"."lorem-ipsum" = vscode-utils.extensionFromVscodeMarketplace {
            name = "lorem-ipsum";
            publisher = "tyriar";
            version = "1.3.1";
            sha256 = "16crr9wci9cxf0mpap1pkpcnvk2qm3amp9zsrf891cyknb59w4w8";

          };
          "ultram4rine"."vscode-choosealicense" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-choosealicense";
            publisher = "ultram4rine";
            version = "0.9.4";
            sha256 = "1hs8sjbq9rvs8wkaxx9nh9swbdca9rfkamf2mcvp3gyw7d5park2";

          };
          "vitest"."explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "explorer";
            publisher = "vitest";
            version = "1.26.3";
            sha256 = "06yxzx80flrl10n21y9gzafbwbhzskd21v7236738xdxd98nkm24";

          };
          "weaveworks"."vscode-gitops-tools" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-gitops-tools";
            publisher = "weaveworks";
            version = "0.27.0";
            sha256 = "18bi3mnwb3igb2wl1r3vs4ayl5jgmrjngapl5z1dz8n2f478mh7c";

          };
          "yutengjing"."open-in-external-app" = vscode-utils.extensionFromVscodeMarketplace {
            name = "open-in-external-app";
            publisher = "yutengjing";
            version = "0.11.0";
            sha256 = "1fpz6mgfl9dk92larjqx9n6xlg5lixzi5a9qw2rkzazhi5m2ghms";

          };
        }
        (
          lib.attrsets.optionalAttrs (isLinux && (isi686 || isx86_64)) {
            "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
              name = "jupyter";
              publisher = "ms-toolsai";
              version = "2025.4.1";
              sha256 = "0k0nvkf3zhms9jha48a786z1jz1w0g8d5a4xmnvlil7aywr7y4v5";
              arch = "linux-x64";

            };
            "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
              name = "semanticdiff";
              publisher = "semanticdiff";
              version = "0.10.0";
              sha256 = "16793ndcjr5ng10wfn1qb20vqa9bjb1zsnw3d4alck700kznc0jr";
              arch = "linux-x64";

            };
          }
        )
      )
      (
        lib.attrsets.optionalAttrs (isLinux && (isAarch32 || isAarch64)) {
          "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
            name = "jupyter";
            publisher = "ms-toolsai";
            version = "2025.4.1";
            sha256 = "154jss8lk5g7r5bsqppwhr54pgwwf8w39yp9hl6bymkwdgmll7dc";
            arch = "linux-arm64";

          };
          "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
            name = "semanticdiff";
            publisher = "semanticdiff";
            version = "0.10.0";
            sha256 = "1x6368n0makddgps0arasr0na07yh2xcp4l9dzaw4fi3vh3mqmln";
            arch = "linux-arm64";

          };
        }
      )
    )
    (
      lib.attrsets.optionalAttrs (isDarwin && (isi686 || isx86_64)) {
        "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
          name = "jupyter";
          publisher = "ms-toolsai";
          version = "2025.4.1";
          sha256 = "1yw01g6h1vc0jifk5lgg4q7vnfk0xjzp9vq3z4fnbdg21yqabcd3";
          arch = "darwin-x64";

        };
        "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
          name = "semanticdiff";
          publisher = "semanticdiff";
          version = "0.10.0";
          sha256 = "1lxak8608kzqd8g5aidlgvb9d1fx5vz84z4aph8j6hxhqfz76wjv";
          arch = "darwin-x64";

        };
      }
    )
  )
  (
    lib.attrsets.optionalAttrs (isDarwin && (isAarch32 || isAarch64)) {
      "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
        name = "jupyter";
        publisher = "ms-toolsai";
        version = "2025.4.1";
        sha256 = "12jj7mp18g12yaw106a8asn58nyvn5bcl3ni12alczcfw9pjiki5";
        arch = "darwin-arm64";

      };
      "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
        name = "semanticdiff";
        publisher = "semanticdiff";
        version = "0.10.0";
        sha256 = "1x6iffgx2cwvrc4qlpdxcrnn8vdmki05vap445kwn28f3dvim4a2";
        arch = "darwin-arm64";

      };
    }
  )
