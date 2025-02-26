#!/bin/sh

set -e
set -x

GAPROOT="$1"
PKGDIR="$2"

# Many package require GNU make. So use gmake if available,
# for improved compatibility with *BSD systems where "make"
# is BSD make, not GNU make.
if command -v gmake >/dev/null 2>&1
then
  alias make=gmake
fi

cd "$PKGDIR"

if [ -x autogen.sh ] && [ ! -x configure ]
then
  ./autogen.sh
fi
if [ -x configure ]
then
  ./configure --with-gaproot="$GAPROOT"
  # hack: run `make clean` in case the package was built before with different settings
  make clean
  make
fi
