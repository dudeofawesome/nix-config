file: (
  if (builtins.pathExists file) then
    file
  else
    { }
)
