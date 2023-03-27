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
  # We want to know if this is an autoconf configure script
  # or not, without actually executing it!
  if grep Autoconf ./configure > /dev/null
  then
    ./configure --with-gaproot="$GAPROOT"
    # hack: run `make clean` in case the package was built before with different settings
    make clean
  else
    ./configure "$GAPROOT"
    # hack: run `make clean` in case the package was built before with different settings
    make clean
    # hack: in browse and edim, `make clean` removes `Makefile` so run configure
    # again to ensure we can actually build them (we could restrict this hack to
    # the two offending packages, but since non-autoconf configure is super cheap,
    # there seems little reason to bother)
    ./configure "$GAPROOT"
  fi
  make
fi
