{ pkgs ? import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
}) {} }:
let
  binutilsVersion       = "2.36.1";
  gccVersion            = "11.2.0";
  target = "i386-jos-elf";
in
pkgs.stdenv.mkDerivation {
  name = "osdev-toolchain";
  version = "1.0";
  srcs = [
    ( pkgs.fetchurl {
      url = "http://ftpmirror.gnu.org/binutils/binutils-${binutilsVersion}.tar.gz";
      sha256 = "sha256-5o7equtsqWh7bcuu3Rs3ZQa6rS1I3iaohfxatqy4Odo=";
    })
    ( pkgs.fetchurl {
      url = "http://ftpmirror.gnu.org/gcc/gcc-${gccVersion}/gcc-${gccVersion}.tar.gz";
      sha256 = "sha256-8IN/G/gkSlzCO9lv9jZnEqeRz64B344lsTdpisom78E=";
    })
  ];
  buildInputs = [
    pkgs.gcc
    pkgs.wget
    pkgs.which
    pkgs.rsync
    pkgs.gmp
    pkgs.libmpc
    pkgs.mpfr
    pkgs.bison
    pkgs.flex 
    pkgs.gnumake
    pkgs.texinfo
  ];
  # I believe the following prevents gcc from treating "-Werror=format-security"
  # warnings as errors
  hardeningDisable = [ "format" ];
  sourceRoot = ".";
  buildPhase = ''
    echo $PWD
    ls -lah .
    # binutils
    mkdir build-binutils
    cd build-binutils
    ../binutils-${binutilsVersion}/configure \
    --target=${target} \
    --prefix="$out" \
    --with-sysroot \
    --disable-nls \
    --disable-werror
    make -j$(nproc)
    make install
    cd ..
    # gcc stage 1
    mkdir build-gcc
    cd build-gcc
    ../gcc-${gccVersion}/configure \
    --target=${target} \
    --prefix="$out" \
    --disable-nls \
    --enable-languages=c,c++ \
    --without-headers
    make -j$(nproc) all-gcc
    make -j$(nproc) all-target-libgcc
    make install-gcc
    make install-target-libgcc
    
    cd ..
    mkdir -p $out/${target}/lib
    mkdir -p $out/sysroot/lib
    rsync -a $out/${target}/lib/ $out/sysroot/lib
  '';
  meta = {
    description = "Cross-compilation toolchain for osdev";
    homepage = "https://agentdid127.com/";
    license = pkgs.lib.licenses.gpl2;
    maintainers = with pkgs.stdenv.lib.maintainers; [ ];
  };
}