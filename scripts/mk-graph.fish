#!/usr/bin/env -S nix
#! nix shell nixpkgs#fish nixpkgs#graphviz nixpkgs#gnused --command fish

set output_svg ./generation.svg

set generation (readlink /nix/var/nix/profiles/system/)

set dot_file (
  nix-store --query --graph "$generation" \
  | sed -E \
    -e '1a\
  rankdir=BT;\
  graph [ratio=0.9];\
  bgcolor="#181818";\
  node [\
    fontcolor = "#e6e6e6",\
    style = filled,\
    color = "#e6e6e6",\
    fillcolor = "#333333"\
  ]\
  edge [\
    color = "#e6e6e6",\
    fontcolor = "#e6e6e6"\
    penwidth = 2.0\
  ]' \
    -e 's/fillcolor = "#ff0000"//g' \
)

echo "Found $(echo "$dot_file" | grep -o 'label = ' | wc -l | xargs) nodes"

echo "$dot_file" | dot -Tsvg >"$output_svg"
echo "$dot_file" | dot -Tpng -Gdpi=10 >"generation.png"
