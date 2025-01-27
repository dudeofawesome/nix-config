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
            onepassword-password-manager
            # clearurls
            darkreader
            facebook-container
            firefox-translations
            # GraphQL Network Inspector
            # iCloud Hide My Email
            # Loggly Formatter
            react-devtools
            reddit-enhancement-suite
            reduxdevtools
            refined-github
            sidebery
            tab-stash
            ublacklist
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

              "DuckDuckGo" = {
                metaData.hidden = false;
              };

              "NPM" = {
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
                icon = "https://github.com/favicon.ico";
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
                    template = "https://search.nixos.org/options";
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
                definedAliases = [ "@nixo" ];
              };
              "Home Manager Options" = {
                urls = [
                  {
                    template = "https://home-manager-options.extranix.com/";
                    params = [
                      {
                        name = "release";
                        value = "master";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "https://home-manager-options.extranix.com/images/favicon.png";
                definedAliases = [
                  "@home-manager"
                  "@hmo"
                ];
              };

              "Amazon".metaData.hidden = true;
              "Bing".metaData.hidden = true;
              "eBay".metaData.hidden = true;
            };

            order = [
              "DuckDuckGo"
              "Google"
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
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;

            # highlight all search results
            "findbar.highlightAll" = true;
            # disable auto-search on type
            "accessibility.typeaheadfind" = false;

            "browser.shell.checkDefaultBrowser" = false;

            "browser.urlbar.placeholderName" = search.default;
            "browser.urlbar.placeholderName.private" = search.privateDefault;

            # disable built-in password manager
            "signon.rememberSignons" = false;
          };
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
