# https://github.com/Kreyren/nixos-config/blob/central/src/nixos/users/kreyren/home/modules/web-browsers/firefox/firefox.nix
{
  lib,
  pkgs,
  pkgs-unstable,
  machine-class,
  config,
  ...
}:
{
  programs.firefox = {
    enable = machine-class == "pc";
    package = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin null;

    policies = {
      AutofillCreditCardEnabled = false;
      AutofillAddressEnabled = false;

      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;

      SearchBar = "unified";

      # disable junk
      DisablePocket = true;
      FirefoxHome = {
        Search = true;
        TopSites = true;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = true;
        Locked = true;
      };
      DisableSetDesktopBackground = true;
      DontCheckDefaultBrowser = true;

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          default_area = "navbar";
          private_browsing = true;
        };
        # 1Password
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          default_area = "navbar";
          private_browsing = true;
        };
        # SideBerry
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          default_area = "navbar";
          private_browsing = true;
        };

        "ATBC@EasonWong" = {
          default_area = "menupanel";
          private_browsing = false;
        };
        "addon@darkreader.org" = {
          default_area = "menupanel";
          private_browsing = false;
        };
        # Reddit Enhancement Suite
        "jid1-xUfzOsOFlzSOXg@jetpack" = {
          default_area = "menupanel";
          private_browsing = false;
        };
        # Refined Github
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
          default_area = "menupanel";
          private_browsing = false;
        };
        "tab-stash@condordes.net" = {
          default_area = "menupanel";
          private_browsing = false;
        };
        "wayback_machine@mozilla.org" = {
          default_area = "menupanel";
          private_browsing = false;
        };
        # Apollo Client Devtools
        "{a5260852-8d08-4979-8116-38f1129dfd22}" = {
          default_area = "menupanel";
          private_browsing = false;
        };
        "@react-devtools" = {
          default_area = "menupanel";
          private_browsing = false;
        };
      };

      Containers = {
        Secondary = {
          id = 0;
          color = "blue";
          icon = "fingerprint";
        };
        Paciolan = {
          id = 1;
          color = "red";
          icon = "briefcase";
        };
        Facebook = {
          id = 2;
          color = "blue";
          icon = "fence";
        };
        TikTok = {
          id = 3;
          color = "purple";
          icon = "fence";
        };
      };

    };

    profiles =
      let
        dudeofawesome = rec {
          extensions = {
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              adaptive-tab-bar-colour
              # clearurls
              darkreader
              firefox-translations
              # GraphQL Network Inspector
              # iCloud Hide My Email
              # Loggly Formatter
              onepassword-password-manager
              react-devtools
              reddit-enhancement-suite
              reduxdevtools
              refined-github
              sidebery
              tab-stash
              # ublacklist
              ublock-origin
              wayback-machine
            ];

            # enable settings management. can alternatively be applied per-extension
            # force = true;
            # settings = {
            #   "uBlock0@raymondhill.net".settings = {
            #     selectedFilterLists = [
            #       "ublock-filters"
            #       "ublock-badware"
            #       "ublock-privacy"
            #       "ublock-unbreak"
            #       "ublock-quick-fixes"
            #     ];
            #   };
            # };
          };

          containers = config.programs.firefox.policies.Containers;
          containersForce = true;

          search = {
            default = "kagi";
            privateDefault = "ddg";
            force = true;

            engines = {
              kagi = {
                name = "Kagi";
                urls = [
                  {
                    template = "https://kagi.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                  {
                    template = "https://kagi.com/api/autosuggest";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                    type = "application/x-suggestions+json";
                  }
                ];

                icon = "https://kagi.com/favicon.ico";
                definedAliases = [
                  "@kagi"
                  "@k"
                ];
              };
              kagi-assistant = {
                name = "Kagi Assistant";
                urls = [
                  {
                    template = "https://kagi.com/assistant";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "https://kagi.com/favicon-assistant-32x32.png";
                definedAliases = [
                  "@kagiass"
                  "@ka"
                ];
              };

              ddg = {
                metaData.hidden = false;
              };

              npm = {
                name = "npm";
                urls = [
                  {
                    template = "https://www.npmjs.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "https://static-production.npmjs.com/58a19602036db1daee0d7863c94673a4.png";
                definedAliases = [ "@npm" ];
              };

              github = {
                name = "GitHub";
                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "type";
                        value = "code";
                      }
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "https://github.githubassets.com/favicons/favicon.png";
                definedAliases = [
                  "@github"
                  "@gh"
                ];
              };

              glassdoor = {
                name = "Glassdoor";
                urls = [
                  {
                    template = "https://www.glassdoor.com/Search/results.htm";
                    params = [
                      {
                        name = "keyword";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "https://www.glassdoor.com/favicon.ico";
                definedAliases = [ "@gd" ];
              };
              # "Crunchbase" = {
              #   urls = [{
              #     template = "";
              #     params = [{ name = "keyword"; value = "{searchTerms}"; }];
              #   }];

              #   icon = "";
              #   definedAliases = [ "@cb" ];
              # };

              nix-packages = {
                name = "Nix Packages";
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [
                  "@nix"
                  "@nixp"
                ];
              };
              nix-options = {
                name = "Nix Options";
                urls = [
                  {
                    template = "https://mynixos.com/search";
                    params = [
                      {
                        name = "q";
                        value = "%2Foption%2F+{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nixo" ];
              };

              bing.metaData.hidden = true;
              ebay.metaData.hidden = true;
            };

            order = [
              "kagi"
              "kagi-assistant"
              "ddg"
              "google"
              "amazondotcom-us"
              "glassdoor"
              "wikipedia"
              "github"
              "npm"
              "nix-packages"
              "nix-options"
            ];
          };

          settings = {
            # automatically enable the installed extensions
            "extensions.autoDisableScopes" = 0;

            # disable junk
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "extensions.pocket.enabled" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;

            # highlight all search results
            "findbar.highlightAll" = true;
            # disable auto-search on type
            "accessibility.typeaheadfind" = false;

            "browser.shell.checkDefaultBrowser" = false;

            "browser.urlbar.placeholderName" = search.default;
            "browser.urlbar.placeholderName.private" = search.privateDefault;

            "browser.urlbar.scotchBonnet.enableOverride" = true;

            # disable built-in autofill
            "signon.rememberSignons" = false;
            "extensions.formautofill.creditCards.enabled" = false;

            # enable userChrome.css
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          userChrome = builtins.readFile ./userChrome.css;
        };
      in
      {
        inherit dudeofawesome;
        shopping-portals = {
          id = 1;

          extensions.packages =
            with pkgs.nur.repos.rycee.firefox-addons;
            [
              clearurls
              # topcashback-cashback-coupons
            ]
            ++ dudeofawesome.extensions.packages;
          search = dudeofawesome.search;
          settings = dudeofawesome.settings;
        };
      };
  };
}
