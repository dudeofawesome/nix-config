{ lib, ... }:
{
  programs.claude-code.mutableSettings = lib.mkDefault true;
}
