default:
    @just --list

# Format Nix files with treefmt (all files if none specified)
format file="":
    nix fmt {{ file }}