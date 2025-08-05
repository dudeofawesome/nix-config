{ lib }:
{
  users = {
    "dudeofawesome" = import ./dudeofawesome;
    "josh" = import ./josh;
  };

  filterMap =
    names: users:
    (
      let
        _names = (
          if (builtins.isAttrs names) then
            (names)
          else if (builtins.isList names) then
            (lib.genAttrs names (name: name))
          else
            abort "names list passed to usersModule.filterMap must be an attrset or list"
        );
      in
      lib.pipe users [
        (lib.getAttrs (builtins.attrNames _names))
        (lib.mapAttrs' (
          name: value:
          let
            username = (if (_names ? ${name}) then _names.${name} else name);
            user_config = lib.recursiveUpdate value { user.name = username; };
          in
          {
            name = username;
            value = user_config;
          }
        ))
      ]
    );
}
