{ osConfig }: package_name: (
  builtins.any (pkg: pkg.name == package_name) osConfig.homebrew.casks
)
