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
            abort
        );
      in
      lib.pipe users [
        (lib.getAttrs (builtins.attrNames _names))
        (lib.mapAttrs' (
          name: value: {
            name = (if (_names ? ${name}) then _names.${name} else name);
            inherit value;
          }
        ))
      ]
    );
}
