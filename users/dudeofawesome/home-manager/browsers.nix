# https://github.com/Kreyren/nixos-config/blob/central/src/nixos/users/kreyren/home/modules/web-browsers/firefox/firefox.nix
{ lib, pkgs, machine-class, config, ... }: {
  programs.firefox = {
    enable = machine-class == "pc";
    package = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin null;

    profiles = {
      dudeofawesome = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          onepassword-password-manager
          # search-engines-helper
          clearurls
          darkreader
          facebook-container
          multi-account-containers
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

        search = {
          default = "DuckDuckGo";
          force = true;

          engines = {
            "Kagi" = {
              urls = [{
                template = "https://kagi.com/search";
                params = [{ name = "q"; value = "{searchTerms}"; }];
              }];

              iconUpdateURL = "https://kagi.com/favicon.ico";
            };

            "NPM" = {
              urls = [{
                template = "https://www.npmjs.com/search";
                params = [{ name = "q"; value = "{searchTerms}"; }];
              }];

              iconUpdateURL = "https://static-production.npmjs.com/58a19602036db1daee0d7863c94673a4.png";
              definedAliases = [ "@npm" ];
            };
            "Glassdoor" = {
              urls = [{
                template = "https://www.glassdoor.com/Search/results.htm";
                params = [{ name = "keyword"; value = "{searchTerms}"; }];
              }];

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
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "channel"; value = "unstable"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];

              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nix" "@nixp" ];
            };
            "Nix Options" = {
              urls = [{
                template = "https://search.nixos.org/options";
                params = [
                  { name = "channel"; value = "unstable"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];

              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nixo" ];
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
          # disable advertising
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

          "browser.urlbar.placeholderName" = config.programs.firefox.profiles.dudeofawesome.search.default;
          "browser.urlbar.placeholderName.private" = config.programs.firefox.profiles.dudeofawesome.search.default;

          # disable built-in password manager
          "signon.rememberSignons" = false;
        };
      };
    };
  };
}
