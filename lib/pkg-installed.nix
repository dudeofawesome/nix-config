{
  osConfig,
  homeConfig ? { },
}:
needle:
(
  builtins.elem needle osConfig.environment.systemPackages
  || builtins.elem needle homeConfig.home.packages
)
# needle: builtins.any (pkg: pkg == needle) osConfig.environment.systemPackages;
