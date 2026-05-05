{ osConfig }:
package_name:
(builtins.any (
  pkg: if builtins.isAttrs pkg then pkg.name == package_name else pkg == package_name
) osConfig.homebrew.casks)
