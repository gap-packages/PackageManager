#!/bin/sh

set -e

GAPROOT="$1"
PKGDIR="$2"

# Some helper functions for printing user messages
notice()    { printf "%s\n" "$@" ; }
warning()   { printf "WARNING: %s\n" "$@" ; }
error()     { printf "ERROR: %s\n" "$@" ; exit 1 ; }

notice "Using GAP root $GAPROOT"

# Many package require GNU make. So use gmake if available,
# for improved compatibility with *BSD systems where "make"
# is BSD make, not GNU make.
if command -v gmake >/dev/null 2>&1
then
  MAKE="gmake"
else
  MAKE="make"
fi

# print the given command plus arguments, single quoted, then run it
echo_run() {
  # when printf is given a format string with only one format specification,
  # it applies that format string to each argument in sequence
  notice "Running $(printf "'%s' " "$@")"
  "$@"
}

(
set -e

cd "$PKGDIR"

if [ -x autogen.sh ] && [ ! -x configure ]
then
  echo_run ./autogen.sh
fi
if [ -x configure ]
then
  # We want to know if this is an autoconf configure script
  # or not, without actually executing it!
  if grep Autoconf ./configure > /dev/null
  then
    echo_run ./configure --with-gaproot="$GAPROOT"
    # hack: run `make clean` in case the package was built before with different settings
    echo_run "$MAKE" clean
  else
    echo_run ./configure "$GAPROOT"
    # hack: run `make clean` in case the package was built before with different settings
    echo_run "$MAKE" clean
    # hack: in browse and edim, `make clean` removes `Makefile` so run configure
    # again to ensure we can actually build them (we could restrict this hack to
    # the two offending packages, but since non-autoconf configure is super cheap,
    # there seems little reason to bother)
    echo_run ./configure "$GAPROOT"
  fi
  echo_run "$MAKE"
fi
) || error "Failed to build $PKG"
