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
          "ms-python"."vscode-pylance" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-pylance";
            publisher = "ms-python";
            version = "2024.12.1";
            sha256 = "05gwlrdvdd7w3mahb59207766m0pvwq0asjwczazl7jmv1gdp49f";
          };
          "esbenp"."prettier-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "prettier-vscode";
            publisher = "esbenp";
            version = "11.0.0";
            sha256 = "1fcz8f4jgnf24kblf8m8nwgzd5pxs2gmrv235cpdgmqz38kf9n54";
          };
          "visualstudioexptteam"."vscodeintellicode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscodeintellicode";
            publisher = "visualstudioexptteam";
            version = "1.3.2";
            sha256 = "1yy1fb1marblz6n5rvwyjn3nwyfgzwg0ybyvh9ikwa2qgp4v2dyv";
          };
          "ms-azuretools"."vscode-docker" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-docker";
            publisher = "ms-azuretools";
            version = "1.29.3";
            sha256 = "1j35yr8f0bqzv6qryw0krbfigfna94b519gnfy46sr1licb6li6g";
          };
          "dbaeumer"."vscode-eslint" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-eslint";
            publisher = "dbaeumer";
            version = "3.0.13";
            sha256 = "0yjrylvkw5q9w7kjigndm5m66qn8nranrm0m7qna8ggi0f2nz5cp";
          };
          "eamodio"."gitlens" = vscode-utils.extensionFromVscodeMarketplace {
            name = "gitlens";
            publisher = "eamodio";
            version = "2024.12.1004";
            sha256 = "0pn89czm04gynckbpih85pjyjidznh1wr6635xvmn0ygfs7098as";
          };
          "visualstudioexptteam"."intellicode-api-usage-examples" =
            vscode-utils.extensionFromVscodeMarketplace
              {
                name = "intellicode-api-usage-examples";
                publisher = "visualstudioexptteam";
                version = "0.2.9";
                sha256 = "0x9lrdz90xl78bg8h4v2rxbsla6rsmdz5zpxy8nicsy1cbwl647k";
              };
          "ms-vscode-remote"."remote-wsl" = vscode-utils.extensionFromVscodeMarketplace {
            name = "remote-wsl";
            publisher = "ms-vscode-remote";
            version = "0.88.5";
            sha256 = "01ajd3pg0a2nfdbfqfbzcix3alr8wpzymqgqlmqyv34fhr2hcc6d";
          };
          "pkief"."material-icon-theme" = vscode-utils.extensionFromVscodeMarketplace {
            name = "material-icon-theme";
            publisher = "pkief";
            version = "5.15.0";
            sha256 = "1v0hv6ddnzd3199ys46lqfa7fcaw6azwfqy4r65rgypxmkc5x1y0";
          };
          "github"."vscode-pull-request-github" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-pull-request-github";
            publisher = "github";
            version = "0.101.2024111810";
            sha256 = "012dm1x7wlhqa4dcb364m7b52g6mi9i2kvzb7vq0j9kxrlbwmh5c";
          };
          "ms-vscode-remote"."remote-ssh" = vscode-utils.extensionFromVscodeMarketplace {
            name = "remote-ssh";
            publisher = "ms-vscode-remote";
            version = "0.116.2024111219";
            sha256 = "1vwkfc4iwvqrcs3r0gkz2aikl8dgzdznasajfs489da8vi3zc30v";
          };
          "ms-vscode-remote"."remote-ssh-edit" = vscode-utils.extensionFromVscodeMarketplace {
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.87.0";
            sha256 = "1qqsnzn9z11jr72n7cl0ab6i9mv49c0ijcp699zbglv5092gmrf9";
          };
          "ms-vsliveshare"."vsliveshare" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vsliveshare";
            publisher = "ms-vsliveshare";
            version = "1.0.5941";
            sha256 = "0qpbq4j2mz1cv10bn7kdipyjany7j5zw71p3djp2dz9a5i1pmcxk";
          };
          "ms-vscode"."remote-explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "remote-explorer";
            publisher = "ms-vscode";
            version = "0.5.2024111900";
            sha256 = "1iz6hyi2h8blccmqd1vvv1a0w7sbibkfii9rjvzik4vgrbzf2blf";
          };
          "golang"."go" = vscode-utils.extensionFromVscodeMarketplace {
            name = "go";
            publisher = "golang";
            version = "0.43.4";
            sha256 = "1qzqq2clsg3mka30k97z9l1lc457ijvxq05c831lhk4s4df9xbpw";
          };
          "donjayamanne"."githistory" = vscode-utils.extensionFromVscodeMarketplace {
            name = "githistory";
            publisher = "donjayamanne";
            version = "0.6.20";
            sha256 = "0x9q7sh5l1frpvfss32ypxk03d73v9npnqxif4fjwcfwvx5mhiww";
          };
          "streetsidesoftware"."code-spell-checker" = vscode-utils.extensionFromVscodeMarketplace {
            name = "code-spell-checker";
            publisher = "streetsidesoftware";
            version = "4.0.23";
            sha256 = "0vja6q3d3gar1vldy92k3b9x4hmbdfg39j3zvh3qqfvlf6b9msfw";
          };
          "editorconfig"."editorconfig" = vscode-utils.extensionFromVscodeMarketplace {
            name = "editorconfig";
            publisher = "editorconfig";
            version = "0.16.4";
            sha256 = "0fa4h9hk1xq6j3zfxvf483sbb4bd17fjl5cdm3rll7z9kaigdqwg";
          };
          "dart-code"."dart-code" = vscode-utils.extensionFromVscodeMarketplace {
            name = "dart-code";
            publisher = "dart-code";
            version = "3.103.20241211";
            sha256 = "1cmjh16fy2g4i6ya7aikl4kah2qmib8ix6jbwj6c1w28xrnxgpjk";
          };
          "yzhang"."markdown-all-in-one" = vscode-utils.extensionFromVscodeMarketplace {
            name = "markdown-all-in-one";
            publisher = "yzhang";
            version = "3.6.2";
            sha256 = "1n9d3qh7vypcsfygfr5rif9krhykbmbcgf41mcjwgjrf899f11h4";
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
            version = "0.13.62";
            sha256 = "146p3bms8cn1h0p0yqjfid7hgf6093mgfjalrw7c9948v68xxc8p";
          };
          "naumovs"."color-highlight" = vscode-utils.extensionFromVscodeMarketplace {
            name = "color-highlight";
            publisher = "naumovs";
            version = "2.8.0";
            sha256 = "14capk3b7rs105ij4pjz42zsysdfnkwfjk9lj2cawnqxa7b8ygcr";
          };
          "tomoki1207"."pdf" = vscode-utils.extensionFromVscodeMarketplace {
            name = "pdf";
            publisher = "tomoki1207";
            version = "1.2.2";
            sha256 = "16rs255x569ahxldw8ra799w078h97aa2b11j97ipqgh6s5nax4b";
          };
          "shd101wyy"."markdown-preview-enhanced" = vscode-utils.extensionFromVscodeMarketplace {
            name = "markdown-preview-enhanced";
            publisher = "shd101wyy";
            version = "0.8.15";
            sha256 = "1q1pm2dzi33z0bbhgrbrp73y75yvl2d8na7nmgsmy8pipn5r2vb9";
          };
          "mikestead"."dotenv" = vscode-utils.extensionFromVscodeMarketplace {
            name = "dotenv";
            publisher = "mikestead";
            version = "1.0.1";
            sha256 = "0rs57csczwx6wrs99c442qpf6vllv2fby37f3a9rhwc8sg6849vn";
          };
          "gruntfuggly"."todo-tree" = vscode-utils.extensionFromVscodeMarketplace {
            name = "todo-tree";
            publisher = "gruntfuggly";
            version = "0.0.226";
            sha256 = "0yrc9qbdk7zznd823bqs1g6n2i5xrda0f9a7349kknj9wp1mqgqn";
          };
          "ms-vscode"."hexeditor" = vscode-utils.extensionFromVscodeMarketplace {
            name = "hexeditor";
            publisher = "ms-vscode";
            version = "1.11.1";
            sha256 = "1dm3l23pwxr2bslwy6aik6lxfz101zna95vcrh2g7dglklx5h7j4";
          };
          "equinusocio"."vsc-material-theme-icons" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vsc-material-theme-icons";
            publisher = "equinusocio";
            version = "3.8.10";
            sha256 = "1vb41bc6s8yrn147dv8pr7zyv0nlwipnyvwcjjpniywil70ybrx3";
          };
          "msjsdiag"."vscode-react-native" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-react-native";
            publisher = "msjsdiag";
            version = "1.13.0";
            sha256 = "0s0npjnzqj3g877b9kqgc07dipww468sfbiwnf55yvvcxyhb7g6f";
          };
          "ms-kubernetes-tools"."vscode-kubernetes-tools" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-kubernetes-tools";
            publisher = "ms-kubernetes-tools";
            version = "1.3.18";
            sha256 = "068bpv00sxkja8cw2p26mrjbrgksclqr6lcks48lsnspz2jmcrds";
          };
          "codezombiech"."gitignore" = vscode-utils.extensionFromVscodeMarketplace {
            name = "gitignore";
            publisher = "codezombiech";
            version = "0.9.0";
            sha256 = "0ww0x28m83fv5zdqkmz108rsxb60fyy5y0ksknb2xchirzwhayi0";
          };
          "firefox-devtools"."vscode-firefox-debug" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-firefox-debug";
            publisher = "firefox-devtools";
            version = "2.10.0";
            sha256 = "0k8xws4wyj0ps1bhsl5ipkm7qsxdd6j745vj15n33ybyz2gjc8am";
          };
          "ms-python"."black-formatter" = vscode-utils.extensionFromVscodeMarketplace {
            name = "black-formatter";
            publisher = "ms-python";
            version = "2024.5.13171011";
            sha256 = "1c9ss4qs12clv783sxsrs11ayj0h2ymp08czcl72h0p363dlk92q";
          };
          "alefragnani"."bookmarks" = vscode-utils.extensionFromVscodeMarketplace {
            name = "bookmarks";
            publisher = "alefragnani";
            version = "13.5.0";
            sha256 = "06pmlmd3wahplhv5r8jdk19xlv2rmhiggmmw6s30pnys2bj5va50";
          };
          "wallabyjs"."quokka-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "quokka-vscode";
            publisher = "wallabyjs";
            version = "1.0.675";
            sha256 = "0abi84rk29cakqvvzgpffr1v5d02r207hr4qvnax6ri88d887b5w";
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
          "stylelint"."vscode-stylelint" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-stylelint";
            publisher = "stylelint";
            version = "1.4.0";
            sha256 = "0xqfwn0337adp76cfl693z02r6djiswk9fknj3jx5d23hm303i0a";
          };
          "tamasfe"."even-better-toml" = vscode-utils.extensionFromVscodeMarketplace {
            name = "even-better-toml";
            publisher = "tamasfe";
            version = "0.19.2";
            sha256 = "0q9z98i446cc8bw1h1mvrddn3dnpnm2gwmzwv2s3fxdni2ggma14";
          };
          "graphql"."vscode-graphql" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-graphql";
            publisher = "graphql";
            version = "0.12.1";
            sha256 = "0msn7p8sxs9wfb4ksgarlp4cwif0fsy7a8406aflq9mdq4jrgwkx";
          };
          "bierner"."markdown-mermaid" = vscode-utils.extensionFromVscodeMarketplace {
            name = "markdown-mermaid";
            publisher = "bierner";
            version = "1.27.0";
            sha256 = "1c9nvi2r3frbyi2ygff2zh3ylvr4df585mb6b5r8n6g5aa9kzp6k";
          };
          "gitlab"."gitlab-workflow" = vscode-utils.extensionFromVscodeMarketplace {
            name = "gitlab-workflow";
            publisher = "gitlab";
            version = "5.23.2";
            sha256 = "0dzfgpdy2myh9q1x8hrhp8gzvnvf4rrp02y4l1gnr5mmi538sw8k";
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
          "mathiasfrohlich"."kotlin" = vscode-utils.extensionFromVscodeMarketplace {
            name = "kotlin";
            publisher = "mathiasfrohlich";
            version = "1.7.1";
            sha256 = "0zi8s1y9l7sfgxfl26vqqqylsdsvn5v2xb3x8pcc4q0xlxgjbq1j";
          };
          "wmaurer"."change-case" = vscode-utils.extensionFromVscodeMarketplace {
            name = "change-case";
            publisher = "wmaurer";
            version = "1.0.0";
            sha256 = "0dxsdahyivx1ghxs6l9b93filfm8vl5q2sa4g21fiklgdnaf7pxl";
          };
          "yoavbls"."pretty-ts-errors" = vscode-utils.extensionFromVscodeMarketplace {
            name = "pretty-ts-errors";
            publisher = "yoavbls";
            version = "0.6.1";
            sha256 = "0pjhai8p4zm186hr61fn6z1mhrw639wvkgnsfy6sr093f7bgdx9f";
          };
          "shopify"."ruby-lsp" = vscode-utils.extensionFromVscodeMarketplace {
            name = "ruby-lsp";
            publisher = "shopify";
            version = "0.8.16";
            sha256 = "19bpka43kp4fi6jyd95fs3nlwyq61ymr23all97jgsdlvwwh3kwd";
          };
          "castwide"."solargraph" = vscode-utils.extensionFromVscodeMarketplace {
            name = "solargraph";
            publisher = "castwide";
            version = "0.24.1";
            sha256 = "0y9y30jyq49vzwn3wn8r922fnbzqskqa42wcmkv6v8waw0da9pik";
          };
          "ryu1kn"."partial-diff" = vscode-utils.extensionFromVscodeMarketplace {
            name = "partial-diff";
            publisher = "ryu1kn";
            version = "1.4.3";
            sha256 = "0x3lkvna4dagr7s99yykji3x517cxk5kp7ydmqa6jb4bzzsv1s6h";
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
          "redhat"."ansible" = vscode-utils.extensionFromVscodeMarketplace {
            name = "ansible";
            publisher = "redhat";
            version = "24.12.1";
            sha256 = "14gblwvsi6l34vsg7sjd1cc27v8di9sficpgvd1pimavvk7ps5nx";
          };
          "mads-hartmann"."bash-ide-vscode" = vscode-utils.extensionFromVscodeMarketplace {
            name = "bash-ide-vscode";
            publisher = "mads-hartmann";
            version = "1.43.0";
            sha256 = "157n2m9dhb26q6yvd16rb5yi2k8k7f7v6vd03vyvvy0rhv7454i2";
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
          "pkief"."material-product-icons" = vscode-utils.extensionFromVscodeMarketplace {
            name = "material-product-icons";
            publisher = "pkief";
            version = "1.7.1";
            sha256 = "1g75m55fc6nnfazpgmjxc48kw8abv85sglmmmjglwwgwi0di2xlj";
          };
          "bpruitt-goddard"."mermaid-markdown-syntax-highlighting" =
            vscode-utils.extensionFromVscodeMarketplace
              {
                name = "mermaid-markdown-syntax-highlighting";
                publisher = "bpruitt-goddard";
                version = "1.7.0";
                sha256 = "06j6anw19smbkllsf1zz5x582z1jnx0sba64hmhmfj27v7v9qfan";
              };
          "coolbear"."systemd-unit-file" = vscode-utils.extensionFromVscodeMarketplace {
            name = "systemd-unit-file";
            publisher = "coolbear";
            version = "1.0.6";
            sha256 = "0sc0zsdnxi4wfdlmaqwb6k2qc21dgwx6ipvri36x7agk7m8m4736";
          };
          "vitest"."explorer" = vscode-utils.extensionFromVscodeMarketplace {
            name = "explorer";
            publisher = "vitest";
            version = "1.8.3";
            sha256 = "1xmdl2ljjly6wyikz4pg4sv8d0fgwqhf8dsmlxmil0ys54rqj71h";
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
            version = "0.0.25";
            sha256 = "0qh6sh8ldwdqggzk62yrg9i64p0cdbx80h7cmmzm27bi2nn4s7q8";
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
          "bmalehorn"."vscode-fish" = vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-fish";
            publisher = "bmalehorn";
            version = "1.0.38";
            sha256 = "0njljmszyq51z1kmmiggdn2jpi4n6mm97gkywkzcaq3k744ryj20";
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
            version = "0.8.0";
            sha256 = "1x8xv7lwpfm06b07vzqc3mvzi2bmq82awmnv33qqzr0gzx6rdrgw";
          };
        }
        (
          lib.attrsets.optionalAttrs (isLinux && (isi686 || isx86_64)) {
            "ms-python"."python" = vscode-utils.extensionFromVscodeMarketplace {
              name = "python";
              publisher = "ms-python";
              version = "2024.23.2024121003";
              sha256 = "1a2rwjw3rjbh78qg6qz6jb8r5b3f3fwahpa97fy6vfp9404km9vg";
              arch = "linux-x64";
            };
            "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
              name = "jupyter";
              publisher = "ms-toolsai";
              version = "2024.11.2024102401";
              sha256 = "1cq1xp70bgpl2gmz544y5vrpqg0wsy0ziyk4wg2pbs0g5vw38n7j";
              arch = "linux-x64";
            };
            "hashicorp"."terraform" = vscode-utils.extensionFromVscodeMarketplace {
              name = "terraform";
              publisher = "hashicorp";
              version = "2.34.2024101517";
              sha256 = "0gkidiawk3cs0hjz5algzlih1aba5cav3s28mvwvvp5908fdl7gh";
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
          "ms-python"."python" = vscode-utils.extensionFromVscodeMarketplace {
            name = "python";
            publisher = "ms-python";
            version = "2024.23.2024121003";
            sha256 = "01nqm8kh0wr0caqfwxxfv41cn4ln44y3vkmkj76897x1k74hl6gg";
            arch = "linux-arm64";
          };
          "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
            name = "jupyter";
            publisher = "ms-toolsai";
            version = "2024.11.2024102401";
            sha256 = "1fd9xhssnqgglc9mim5lmdzkn0drvb43164myv76x0s67av8ca0v";
            arch = "linux-arm64";
          };
          "hashicorp"."terraform" = vscode-utils.extensionFromVscodeMarketplace {
            name = "terraform";
            publisher = "hashicorp";
            version = "2.34.2024101517";
            sha256 = "1q8c0cab1i5v0hbrb51g08b4lp15xbxdb3bma0pbrv1q3q9ah5yn";
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
        "ms-python"."python" = vscode-utils.extensionFromVscodeMarketplace {
          name = "python";
          publisher = "ms-python";
          version = "2024.23.2024121003";
          sha256 = "04wwyngawri218545j08zx983vy7wnsdzwfq4nylmww736gzljn2";
          arch = "darwin-x64";
        };
        "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
          name = "jupyter";
          publisher = "ms-toolsai";
          version = "2024.11.2024102401";
          sha256 = "1102mkq6920ywwpjafmzcyyznax53kb38dx8rgdkr2c0hg7hnvbn";
          arch = "darwin-x64";
        };
        "hashicorp"."terraform" = vscode-utils.extensionFromVscodeMarketplace {
          name = "terraform";
          publisher = "hashicorp";
          version = "2.34.2024101517";
          sha256 = "0lsa3jdi5zv6dgs13g1k3cyk7si518197mr5cy27ryn963y2gp8b";
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
      "ms-python"."python" = vscode-utils.extensionFromVscodeMarketplace {
        name = "python";
        publisher = "ms-python";
        version = "2024.23.2024121003";
        sha256 = "02qildhxkcz5qvb9yx7l4mbwzabdrgd05j48nlm4p3cfy872knj4";
        arch = "darwin-arm64";
      };
      "ms-toolsai"."jupyter" = vscode-utils.extensionFromVscodeMarketplace {
        name = "jupyter";
        publisher = "ms-toolsai";
        version = "2024.11.2024102401";
        sha256 = "0v69n4qzqg5dx783xhlzq6wci0gvmarip3v9696wm0gjdwsl2rv2";
        arch = "darwin-arm64";
      };
      "hashicorp"."terraform" = vscode-utils.extensionFromVscodeMarketplace {
        name = "terraform";
        publisher = "hashicorp";
        version = "2.34.2024101517";
        sha256 = "14h318y6hllsrk916h7spdqfclpf46qqh4hllrk5svn2h86p6d32";
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
