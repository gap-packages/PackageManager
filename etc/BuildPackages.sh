#!/usr/bin/env bash

set -e

PACKAGES=()

while [[ "$#" -ge 1 ]]; do
  option="$1" ; shift
  case "$option" in
    --with-gaproot)   GAPROOT="$1"; shift ;;
    --with-gaproot=*) GAPROOT=${option#--with-gaproot=}; ;;

    -*)               echo "ERROR: unsupported argument $option" ; exit 1;;
    *)                PACKAGES+=("$option") ;;
  esac
done

# Some helper functions for printing user messages
notice()    { printf "%s\n" "$@" ; }
warning()   { printf "WARNING: %s\n" "$@" ; }
error()     { printf "ERROR: %s\n" "$@" ; exit 1 ; }

notice "Using GAP root $GAPROOT"

# Check whether $GAPROOT is valid
if [[ ! -f "$GAPROOT/sysinfo.gap" ]]
then
  error "$GAPROOT is not the root of a gap installation (no sysinfo.gap)" \
        "Please provide the absolute path of your GAP root directory as" \
        "first argument with '--with-gaproot=' to this script."
fi

# read in sysinfo
source "$GAPROOT/sysinfo.gap"


# detect whether GAP was built in 32bit mode
# TODO: once all packages have adapted to the new build system,
# this should no longer be necessary, as package build systems should
# automatically adjust to 32bit mode.
case "$GAP_ABI" in
  32)
    notice "Building with 32-bit ABI"
    CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
    ;;
  64)
    notice "Building with 64-bit ABI"
    CONFIGFLAGS=""
    ;;
  *)
    error "Unsupported GAP ABI '$GAParch_abi'."
    ;;
esac


# Many package require GNU make. So use gmake if available,
# for improved compatibility with *BSD systems where "make"
# is BSD make, not GNU make.
if hash gmake 2> /dev/null
then
  MAKE=gmake
else
  MAKE=make
fi

# print the given command plus arguments, single quoted, then run it
echo_run() {
  # when printf is given a format string with only one format specification,
  # it applies that format string to each argument in sequence
  notice "Running $(printf "'%s' " "$@")"
  "$@"
}

build_fail() {
  echo ""
  warning "Failed to build $PKG"
  exit 1
}

run_configure_and_make() {
  if [[ -x autogen.sh && ! -x configure ]]
  then
    ./autogen.sh
  fi
  if [[ -x configure ]]
  then
    # We want to know if this is an autoconf configure script
    # or not, without actually executing it!
    if grep Autoconf ./configure > /dev/null
    then
      echo_run ./configure --with-gaproot="$GAPROOT" $CONFIGFLAGS
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
  else
    notice "No building required for $PKG"
  fi
}

build_one_package() {
  # requires one argument which is the package directory
  PKG="$1"
  echo ""
  notice "==== Checking $PKG"
  (  # start subshell
  set -e
  cd "$PKG"
  if [[ -x prerequisites.sh ]]
  then
    ./prerequisites.sh "$GAPROOT"
  fi
  run_configure_and_make
  ) || build_fail
}

for PKG in "${PACKAGES[@]}"
do 
  # cut off the ending slash (if exists)
  PKG="${PKG%/}"
  PKG="${PKG##*/}"
  if [[ -e "$PKG/PackageInfo.g" ]]
  then
    build_one_package "$PKG"
  else
    echo
    warning "$PKG does not seem to be a package directory, skipping"
  fi
done
