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
          "esbenp"."prettier-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "prettier-vscode";
            publisher = "esbenp";
            version = "11.0.0";
            sha256 = "1fcz8f4jgnf24kblf8m8nwgzd5pxs2gmrv235cpdgmqz38kf9n54";
          };
          "github"."vscode-pull-request-github" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-pull-request-github";
            publisher = "github";
            version = "0.101.2024111810";
            sha256 = "012dm1x7wlhqa4dcb364m7b52g6mi9i2kvzb7vq0j9kxrlbwmh5c";
          };
          "ms-vscode"."remote-explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "remote-explorer";
            publisher = "ms-vscode";
            version = "0.5.2024121609";
            sha256 = "1w2wgkmix4mval5kb3ki52k0f402kp7px4xw1cvqz7xfmad4h113";
          };
          "dart-code"."dart-code" = vscode-utils.extensionFromVscodeMarketplace {
            name = "dart-code";
            publisher = "dart-code";
            version = "3.103.20241211";
            sha256 = "1cmjh16fy2g4i6ya7aikl4kah2qmib8ix6jbwj6c1w28xrnxgpjk";
          };
          "dart-code"."flutter" = vscode-utils.extensionFromVscodeMarketplace {
            name = "flutter";
            publisher = "dart-code";
            version = "3.103.20241202";
            sha256 = "18jvy5cbra66k9mp38vj8jfi10y5lln9yhd4hk1p2j5ag9swj29q";
          };
          "bradlc"."vscode-tailwindcss" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-tailwindcss";
            publisher = "bradlc";
            version = "0.13.64";
            sha256 = "14962pavlbdmqki6m7y7k9nvz1pcicrn3dw10lrcq8vxbj2bc416";
          };
          "ms-vscode"."hexeditor" = vscode-utils.extensionFromVscodeMarketplace {
            name = "hexeditor";
            publisher = "ms-vscode";
            version = "1.11.1";
            sha256 = "1dm3l23pwxr2bslwy6aik6lxfz101zna95vcrh2g7dglklx5h7j4";
          };
          "ms-kubernetes-tools"."vscode-kubernetes-tools" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-kubernetes-tools";
            publisher = "ms-kubernetes-tools";
            version = "1.3.18";
            sha256 = "068bpv00sxkja8cw2p26mrjbrgksclqr6lcks48lsnspz2jmcrds";
          };
          "msjsdiag"."vscode-react-native" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-react-native";
            publisher = "msjsdiag";
            version = "1.13.0";
            sha256 = "0s0npjnzqj3g877b9kqgc07dipww468sfbiwnf55yvvcxyhb7g6f";
          };
          "wallabyjs"."quokka-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "quokka-vscode";
            publisher = "wallabyjs";
            version = "1.0.681";
            sha256 = "15ccxd9npnnj0ivr83rcyhslvabj9knl2xa3fplphgxhizm9fax0";
          };
          "github"."vscode-github-actions" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-github-actions";
            publisher = "github";
            version = "0.27.0";
            sha256 = "0sk8cgnk4pyjxwfi3hr3qrajffvdncvq3xbjn73g3jz0ygakg7xi";
          };
          "orta"."vscode-jest" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-jest";
            publisher = "orta";
            version = "6.4.0";
            sha256 = "0asjg2ycq20qg2zyxybnmas2br08mjwhsw03y0qz24g8rkn9a7s4";
          };
          "graphql"."vscode-graphql" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-graphql";
            publisher = "graphql";
            version = "0.12.1";
            sha256 = "0msn7p8sxs9wfb4ksgarlp4cwif0fsy7a8406aflq9mdq4jrgwkx";
          };
          "gitlab"."gitlab-workflow" = vscode-utils.extensionFromVscodeMarketplace {
            name = "gitlab-workflow";
            publisher = "gitlab";
            version = "5.26.0";
            sha256 = "1xb8a834bgblc4zcrdc9v3by3wv3fls3bz3bm7rxaqyvszlpb42d";
          };
          "inferrinizzard"."prettier-sql-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "prettier-sql-vscode";
            publisher = "inferrinizzard";
            version = "1.6.0";
            sha256 = "1d4vf3gh2x4ycf8ppvvb5d6rsg2ayckd05rkp3w1kw5gxgzmzalp";
          };
          "graphql"."vscode-graphql-syntax" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-graphql-syntax";
            publisher = "graphql";
            version = "1.3.8";
            sha256 = "0dgd6d1a5hv61zf2ak66ic49vhnmyabkshv4njzv6ws6gy8pck6p";
          };
          "mrmlnc"."vscode-scss" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-scss";
            publisher = "mrmlnc";
            version = "0.10.0";
            sha256 = "08kdvg4p0aysf7wg1qfbri59cipllgf69ph1x7aksrwlwjmsps12";
          };
          "yoavbls"."pretty-ts-errors" = vscode-utils.extensionFromVscodeMarketplace {
            name = "pretty-ts-errors";
            publisher = "yoavbls";
            version = "0.6.1";
            sha256 = "0pjhai8p4zm186hr61fn6z1mhrw639wvkgnsfy6sr093f7bgdx9f";
          };
          "castwide"."solargraph" = vscode-utils.extensionFromVscodeMarketplace {
            name = "solargraph";
            publisher = "castwide";
            version = "0.24.1";
            sha256 = "0y9y30jyq49vzwn3wn8r922fnbzqskqa42wcmkv6v8waw0da9pik";
          };
          "beardedbear"."beardedtheme" = vscode-utils.extensionFromVscodeMarketplace {
            name = "beardedtheme";
            publisher = "beardedbear";
            version = "9.3.0";
            sha256 = "0nzdar1xm4sm2grm67y0fq8asry4q5cppf4jncgypmhgbh0321rk";
          };
          "fwcd"."kotlin" = vscode-utils.extensionFromVscodeMarketplace {
            name = "kotlin";
            publisher = "fwcd";
            version = "0.2.36";
            sha256 = "1cwncjvarq3g0cmn9afdd15s81nms0kcawnj3midhr4hchap2aml";
          };
          "tyriar"."lorem-ipsum" = vscode-utils.extensionFromVscodeMarketplace {
            name = "lorem-ipsum";
            publisher = "tyriar";
            version = "1.3.1";
            sha256 = "16crr9wci9cxf0mpap1pkpcnvk2qm3amp9zsrf891cyknb59w4w8";
          };
          "deerawan"."vscode-dash" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-dash";
            publisher = "deerawan";
            version = "2.4.0";
            sha256 = "0bj3sris57r4nm8n9z9dxsriv23ym2sjq5b6b1608nadkbvgkab2";
          };
          "fabiospampinato"."vscode-diff" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-diff";
            publisher = "fabiospampinato";
            version = "2.1.2";
            sha256 = "1i8ysv7zisjvvjbg5qn98lpv3rclw94bp3qx6sixvy4rayxsz5c2";
          };
          "bpruitt-goddard"."mermaid-markdown-syntax-highlighting" =
            vscode-utils.extensionFromVscodeMarketplace
              {
                name = "mermaid-markdown-syntax-highlighting";
                publisher = "bpruitt-goddard";
                version = "1.7.0";
                sha256 = "06j6anw19smbkllsf1zz5x582z1jnx0sba64hmhmfj27v7v9qfan";
              };
          "vitest"."explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "explorer";
            publisher = "vitest";
            version = "1.8.5";
            sha256 = "1j25a8zn1vg9s8scyldzbxi2f7xz9l4167na7ijvmaarhxrdbxh9";
          };
          "graphql"."vscode-graphql-execution" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-graphql-execution";
            publisher = "graphql";
            version = "0.3.1";
            sha256 = "01bdmlbphh174jvsb19196wcvym54wcg9vhr772g4jwygajf5r0s";
          };
          "mrmlnc"."vscode-json5" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-json5";
            publisher = "mrmlnc";
            version = "1.0.0";
            sha256 = "0bghvq89pp5s4liw11py8afyrlg4b02npv9ypnrnl0d2w99ab6aw";
          };
          "tomoyukim"."vscode-mermaid-editor" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-mermaid-editor";
            publisher = "tomoyukim";
            version = "0.19.1";
            sha256 = "146g7m2dgh7wfncvi48z1jym7aayz2qr3x03hpqf93yk0gvi369i";
          };
          "drknoxy"."eslint-disable-snippets" = vscode-utils.extensionFromVscodeMarketplace {
            name = "eslint-disable-snippets";
            publisher = "drknoxy";
            version = "1.4.1";
            sha256 = "1djjknfg81cjbn4bcalc7gg9fha5lzwmpmmrzm68n87qvld58hs4";
          };
          "oven"."bun-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "bun-vscode";
            publisher = "oven";
            version = "0.0.26";
            sha256 = "13ml1zk8g5g56c74acq9xrhndyj1s1k1ayadlgv9hn1b18l28lwj";
          };
          "jnoortheen"."nix-ide" = vscode-utils.extensionFromVscodeMarketplace {
            name = "nix-ide";
            publisher = "jnoortheen";
            version = "0.3.5";
            sha256 = "12sg67mn3c8mjayh9d6y8qaky00vrlnwwx58v1f1m4qrbdjqab46";
          };
          "idleberg"."applescript" = vscode-utils.extensionFromVscodeMarketplace {
            name = "applescript";
            publisher = "idleberg";
            version = "0.26.1";
            sha256 = "0dpf4lggdcbc8ay8zncj4fah88d7gqqha38xx5r4bc7jjm3d0pb4";
          };
          "ghmcadams"."lintlens" = vscode-utils.extensionFromVscodeMarketplace {
            name = "lintlens";
            publisher = "ghmcadams";
            version = "7.5.0";
            sha256 = "18zfpq7f39hifw5ha9cvvn675r1mbd9sx0lmywphb9mv21f7ya1y";
          };
          "flesler"."url-encode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "url-encode";
            publisher = "flesler";
            version = "1.1.0";
            sha256 = "16lj8r97277zrwrjr4lsv8qzv5mz0h8insz3vvggyzgm55cx7dpf";
          };
          "bruno-api-client"."bruno" = vscode-utils.extensionFromVscodeMarketplace {
            name = "bruno";
            publisher = "bruno-api-client";
            version = "3.1.0";
            sha256 = "0l46jafrf2mfii72gv4ikhygks1s29ys36p71517bdk2rjfj5d4c";
          };
          "ultram4rine"."vscode-choosealicense" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-choosealicense";
            publisher = "ultram4rine";
            version = "0.9.4";
            sha256 = "1hs8sjbq9rvs8wkaxx9nh9swbdca9rfkamf2mcvp3gyw7d5park2";
          };
          "antyos"."openscad" = vscode-utils.extensionFromVscodeMarketplace {
            name = "openscad";
            publisher = "antyos";
            version = "1.3.1";
            sha256 = "08h69gjn723wjz7k4rj47rhz90rjg14iaphxv11787gljj0lk297";
          };
          "mxsdev"."typescript-explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "typescript-explorer";
            publisher = "mxsdev";
            version = "0.4.2";
            sha256 = "114ha3fixhfz2dnswvnkg8rwzw5il425n96ixb7j4iiyj5zgnz10";
          };
          "weaveworks"."vscode-gitops-tools" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-gitops-tools";
            publisher = "weaveworks";
            version = "0.27.0";
            sha256 = "18bi3mnwb3igb2wl1r3vs4ayl5jgmrjngapl5z1dz8n2f478mh7c";
          };
          "novy"."vsc-gcode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vsc-gcode";
            publisher = "novy";
            version = "0.0.4";
            sha256 = "0mz862fb7r340rhibyp5r03gsps86g9d04g8kibfsjybs5v7wvlm";
          };
          "seeker-dk"."node-modules-viewer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "node-modules-viewer";
            publisher = "seeker-dk";
            version = "0.0.5";
            sha256 = "11ifaih53xb77mbjwqhhphpwglj6d41fy9s1yz67952251s93ab7";
          };
          "connor4312"."nodejs-testing" = vscode-utils.extensionFromVscodeMarketplace {
            name = "nodejs-testing";
            publisher = "connor4312";
            version = "1.6.3";
            sha256 = "17afry2kw0wsamdxi7i2sb6ckgqj10v7hn2imymvkrfvlb2igahf";
          };
          "gracefulpotato"."rbs-syntax" = vscode-utils.extensionFromVscodeMarketplace {
            name = "rbs-syntax";
            publisher = "gracefulpotato";
            version = "0.3.0";
            sha256 = "0k0vll5fh7shwdaj1czkzzrhrv9jg2qcvzr3wcg3rh9j3k8m0ilm";
          };
          "effectful-tech"."effect-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "effect-vscode";
            publisher = "effectful-tech";
            version = "0.1.7";
            sha256 = "0cc4gm5xyvs3y5zwvm77fdi4wypx8ffm7lrnnzzqjk022hxymd58";
          };
          "alesbrelih"."gitlab-ci-ls" = vscode-utils.extensionFromVscodeMarketplace {
            name = "gitlab-ci-ls";
            publisher = "alesbrelih";
            version = "1.0.0";
            sha256 = "0bxd7zm55b6y72jppaqw77g9asfqpi2whsq5j6pq23zp3q43603g";
          };
        }
        (
          lib.attrsets.optionalAttrs (isLinux && (isi686 || isx86_64)) {
            "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
              name = "jupyter";
              publisher = "ms-toolsai";
              version = "2024.11.2024102401";
              sha256 = "1cq1xp70bgpl2gmz544y5vrpqg0wsy0ziyk4wg2pbs0g5vw38n7j";
              arch = "linux-x64";
            };
            "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
              name = "semanticdiff";
              publisher = "semanticdiff";
              version = "0.9.0";
              sha256 = "04wcx7xpxab37392jxz46lmh7pmicy27hhh7rd353nvjg9v679ml";
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
            version = "2024.11.2024102401";
            sha256 = "1fd9xhssnqgglc9mim5lmdzkn0drvb43164myv76x0s67av8ca0v";
            arch = "linux-arm64";
          };
          "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
            name = "semanticdiff";
            publisher = "semanticdiff";
            version = "0.9.0";
            sha256 = "0gzbakpqxj9vks7ahh4gdik77y1b2w2kzw8dz660xbiyc2ww5sck";
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
          version = "2024.11.2024102401";
          sha256 = "1102mkq6920ywwpjafmzcyyznax53kb38dx8rgdkr2c0hg7hnvbn";
          arch = "darwin-x64";
        };
        "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
          name = "semanticdiff";
          publisher = "semanticdiff";
          version = "0.9.0";
          sha256 = "1785drryh0z91bivk7v9b0zb2c6qcmkm5kqzkvww5bhgwm47c236";
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
        version = "2024.11.2024102401";
        sha256 = "0v69n4qzqg5dx783xhlzq6wci0gvmarip3v9696wm0gjdwsl2rv2";
        arch = "darwin-arm64";
      };
      "semanticdiff"."semanticdiff" = vscode-utils.extensionFromVscodeMarketplace {
        name = "semanticdiff";
        publisher = "semanticdiff";
        version = "0.9.0";
        sha256 = "1g9zz4bbqvvbbaxxs9m8ysz5r990n81n4sxr5wx2ww50ram63xn1";
        arch = "darwin-arm64";
      };
    }
  )
