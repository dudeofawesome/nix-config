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
    };

    profiles =
      let
        dudeofawesome = rec {
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            adaptive-tab-bar-colour
            # clearurls
            darkreader
            # facebook-container
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

          containers = {
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
          containersForce = true;

          search = {
            default = "Kagi";
            privateDefault = "DuckDuckGo";
            force = true;

            engines = {
              "Kagi" = {
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

                iconUpdateURL = "https://kagi.com/favicon.ico";
                definedAliases = [
                  "@kagi"
                  "@k"
                ];
              };
              "Kagi Assistant" = {
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

                iconUpdateURL = "https://kagi.com/favicon-assistant-32x32.png";
                definedAliases = [
                  "@kagiass"
                  "@ka"
                ];
              };

              "DuckDuckGo" = {
                metaData.hidden = false;
              };

              "npm" = {
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

                iconUpdateURL = "https://static-production.npmjs.com/58a19602036db1daee0d7863c94673a4.png";
                definedAliases = [ "@npm" ];
              };

              "GitHub" = {
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
                iconUpdateURL = "https://github.githubassets.com/favicons/favicon.png";
                definedAliases = [
                  "@github"
                  "@gh"
                ];
              };

              "Glassdoor" = {
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

                iconUpdateURL = "https://www.glassdoor.com/favicon.ico";
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

              "Nix Packages" = {
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
              "Nix Options" = {
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

              "Bing".metaData.hidden = true;
              "eBay".metaData.hidden = true;
            };

            order = [
              "Kagi"
              "Kagi Assistant"
              "DuckDuckGo"
              "Google"
              "Amazon.com"
              "Glassdoor"
              "Wikipedia (en)"
              "GitHub"
              "npm"
              "Nix Packages"
              "Nix Options"
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

          extensions =
            with pkgs.nur.repos.rycee.firefox-addons;
            [
              clearurls
              # topcashback-cashback-coupons
            ]
            ++ dudeofawesome.extensions;
          search = dudeofawesome.search;
          settings = dudeofawesome.settings;
        };
      };
  };
}
