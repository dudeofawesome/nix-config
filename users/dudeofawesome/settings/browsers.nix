{ lib, pkgs, ... }: {
  programs.firefox = {
    enable = true;
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
            "NPM" = {
              urls = [{
                template = "https://www.npmjs.com/search";
                params = [{ name = "q"; value = "{searchTerms}"; }];
              }];

              icon = "https://static-production.npmjs.com/58a19602036db1daee0d7863c94673a4.png";
              definedAliases = [ "@npm" ];
            };
            "Glassdoor" = {
              urls = [{
                template = "https://www.glassdoor.com/Search/results.htm";
                params = [{ name = "keyword"; value = "{searchTerms}"; }];
              }];

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

          # disable built-in password manager
          "signon.rememberSignons" = false;
        };
      };
    };
  };
}
