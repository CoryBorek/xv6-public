with import <nixpkgs> {};
let
  osdev-toolchain = callPackage ./osdev-toolchain.nix {};
in
mkShell {
  buildInputs = [ 
      lazygit
      gnumake
      nasm
      qemu
      bochs
      gcc11
      valgrind
      grub2
      xorriso
      gdb
      python312Full
      python312Packages.pathlib2
      python312Packages.pyparted
      python312Packages.shlib
      python312Packages.sh
      unixtools.xxd
      parted
      osdev-toolchain
      libguestfs-with-appliance

    ];
}
