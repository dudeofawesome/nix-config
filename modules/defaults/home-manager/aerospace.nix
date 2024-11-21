{ pkgs, lib, osConfig, ... }:
let
  doa-lib = import ../../../lib;
  aerospace_installed = doa-lib.cask-installed { inherit osConfig; } "nikitabobko/tap/aerospace";
  enable = aerospace_installed;
in
{
  config = lib.mkIf (enable) {
    targets.darwin.defaults = {
      NSGlobalDomain = {
        # use ctrl+cmd to drag windows from anywhere
        NSWindowShouldDragOnGesture = true;
      };
    };

    quartz.windowManager.aerospace = {
      inherit enable;
      settings =
        let
          workspaces = {
            browser = "workspace browser";
            code = "workspace code";
            misc = "workspace misc";
            social = "workspace social";
          };

          workman_layout = {
            key-notation-to-key-code = {
              q = "q";
              d = "w";
              r = "e";
              w = "r";
              b = "t";
              j = "y";
              f = "u";
              u = "i";
              p = "o";
              semicolon = "p";
              leftSquareBracket = "leftSquareBracket";
              rightSquareBracket = "rightSquareBracket";
              backslash = "backslash";

              a = "a";
              s = "s";
              h = "d";
              t = "f";
              g = "g";
              y = "h";
              n = "j";
              e = "k";
              o = "l";
              i = "semicolon";
              quote = "quote";

              z = "z";
              x = "x";
              m = "c";
              c = "v";
              v = "b";
              k = "n";
              l = "m";
              comma = "comma";
              period = "period";
              slash = "slash";
            };
          };
        in
        {
          # Mouse follows focus when focused monitor changes
          # Drop it from your config, if you don't like this behavior
          # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
          # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
          # Fallback value (if you omit the key): on-focused-monitor-changed = []
          on-focused-monitor-changed = [
            # "move-mouse monitor-lazy-center"
          ];

          # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
          # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
          # Also see: https://nikitabobko.github.io/AeroSpace/goodness#disable-hide-app
          automatically-unhide-macos-hidden-apps = false;

          # Possible values: (qwerty|dvorak)
          # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
          key-mapping = workman_layout;

          # Gaps between windows (inner-*) and between monitor edges (outer-*).
          # Possible values:
          # - Constant:     gaps.outer.top = 8
          # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
          #                 In this example, 24 is a default value when there is no match.
          #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
          #                 See: https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
          gaps = let gap = 6; in {
            inner.horizontal = gap;
            inner.vertical = gap;
            outer.left = gap;
            outer.bottom = gap;
            outer.top = 0;
            outer.right = gap;
          };

          # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
          # The 'accordion-padding' specifies the size of accordion padding
          # You can set 0 to disable the padding feature
          accordion-padding = 22;

          # 'main' binding mode declaration
          # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          # 'main' binding mode must be always presented
          # Fallback value (if you omit the key): mode.main.binding = {}
          mode.main.binding = {
            # All possible keys:
            # - Letters.        a, b, c, ..., z
            # - Numbers.        0, 1, 2, ..., 9
            # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
            # - F-keys.         f1, f2, ..., f20
            # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
            #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
            # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
            #                   keypadMinus, keypadMultiply, keypadPlus
            # - Arrows.         left, down, up, right

            # All possible modifiers: cmd, alt, ctrl, shift

            # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

            # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
            # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
            # alt-enter = ''exec-and-forget osascript -e '
            # tell application "Terminal"
            #     do script
            #     activate
            # end tell'
            # ''

            # See: https://nikitabobko.github.io/AeroSpace/commands#layout
            alt-slash = "layout tiles horizontal vertical";
            alt-period = "layout horizontal vertical"; # toggle orientation
            alt-comma = "layout accordion horizontal vertical";

            ctrl-left = "workspace --wrap-around prev";
            ctrl-right = "workspace --wrap-around next";

            # See: https://nikitabobko.github.io/AeroSpace/commands#focus
            alt-n = "focus left";
            alt-e = "focus down";
            alt-o = "focus up";
            alt-i = "focus right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move
            alt-shift-n = "move left";
            alt-shift-e = "move down";
            alt-shift-o = "move up";
            alt-shift-i = "move right";
            ctrl-alt-left = "move left";
            ctrl-alt-down = "move down";
            ctrl-alt-up = "move up";
            ctrl-alt-right = "move right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#resize
            alt-shift-minus = "resize smart -50";
            alt-shift-equal = "resize smart +50";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
            # In your config, you can drop workspace bindings that you don't need
            alt-1 = workspaces.browser;
            alt-2 = workspaces.code;
            alt-3 = workspaces.misc;
            alt-4 = workspaces.social;
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
            alt-shift-1 = "move-node-to-${workspaces.browser}";
            alt-shift-2 = "move-node-to-${workspaces.code}";
            alt-shift-3 = "move-node-to-${workspaces.misc}";
            alt-shift-4 = "move-node-to-${workspaces.social}";
            alt-shift-5 = "move-node-to-workspace 5";
            alt-shift-6 = "move-node-to-workspace 6";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
            alt-tab = "workspace-back-and-forth";
            # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            alt-shift-quote = "mode service";
          };

          # 'service' binding mode declaration.
          # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          mode.service.binding = {
            esc = [ "reload-config" "mode main" ];
            r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
            f = [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
            backspace = [ "close-all-windows-but-current" "mode main" ];

            # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
            #s = ["layout sticky tiling" "mode main"];

            alt-shift-n = [ "join-with left" "mode main" ];
            alt-shift-e = [ "join-with down" "mode main" ];
            alt-shift-o = [ "join-with up" "mode main" ];
            alt-shift-i = [ "join-with right" "mode main" ];
          };

          on-window-detected =
            let
              apps-to-workspace = app-ids: workspace: (
                builtins.map
                  (app-id: {
                    "if".app-id = app-id;
                    run = "move-node-to-${workspace}";
                  })
                  app-ids
              );
            in
            lib.flatten [
              (apps-to-workspace
                [
                  "org.mozilla.firefox"
                  "com.apple.Safari"
                  "com.google.Chrome"
                ]
                workspaces.browser
              )
              (apps-to-workspace
                [
                  "com.microsoft.VSCode"
                  "com.apple.dt.Xcode"
                  "com.github.wez.wezterm"
                  "com.googlecode.iterm2"
                ]
                workspaces.code
              )
              (apps-to-workspace
                [
                  "us.zoom.xos"
                  "com.apple.iCal"
                  "com.apple.Notes"
                  "com.apple.reminders"
                ]
                workspaces.misc
              )
              (apps-to-workspace
                [
                  "org.whispersystems.signal-desktop"
                  "com.apple.MobileSMS"
                  "com.apple.mail"
                  "com.hnc.Discord"
                  "com.tinyspeck.slackmacgap"
                ]
                workspaces.social
              )

              # Automatically accordion new browser windows
              # [{
              #   "if".app-id = "org.mozilla.firefox";
              #   run = "layout accordion";
              # }]
            ];
        };
    };
  };
}
