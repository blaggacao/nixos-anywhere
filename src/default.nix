{ writeShellApplication
, openssh
, gitMinimal
, rsync
, nixVersions
, coreutils
, curl
, gnugrep
, gawk
, findutils
, gnused
, lib
, mkShellNoCC
, mypy
, pixiecore
, dnsmasq
, python3
, qemu_kvm
, OVMF
}:
let
  runtimeInputs = [
    gitMinimal # for git flakes
    rsync
    # pinned because nix-copy-closure hangs if ControlPath provided for SSH: https://github.com/NixOS/nix/issues/8480
    nixVersions.nix_2_16
    coreutils
    curl # when uploading tarballs
    gnugrep
    gawk
    findutils
    gnused # needed by ssh-copy-id
  ];
in
(writeShellApplication {
  name = "nixos-anywhere";
  # We prefer the system's openssh over our own, since it might come with features not present in ours:
  # https://github.com/numtide/nixos-anywhere/issues/62
  text = ''
    export PATH=$PATH:${lib.getBin openssh}
    ${builtins.readFile ./nixos-anywhere.sh}
  '';
  inherit runtimeInputs;
}) // {
  # Dependencies for our devshell
  devShell = mkShellNoCC {
    OVMF = "${OVMF.fd}/FV/OVMF.fd";

    packages = runtimeInputs ++ [
      openssh
      mypy
      pixiecore
      dnsmasq
      python3.pkgs.netaddr
      qemu_kvm
    ];
  };
}
