attrset:
let
  names = builtins.attrNames attrset;

  normalize =
    name:
    let
      value = attrset.${name};
    in
    if builtins.isList value then
      let
        length = builtins.length value;
      in
      if length == 0 then
        [ ]
      else if length == 1 then
        [
          {
            inherit name;
            value = builtins.head value;
          }
        ]
      else
        throw "rm-options expected ${name} to be a non-list value or a singleton list, but got a list of length ${toString length}"
    else
      [
        {
          inherit name value;
        }
      ];
in
builtins.listToAttrs (builtins.concatLists (map normalize names))
