#
# PackageManager: Easily download and install GAP packages
#
# This file is a script which compiles the package manual.
#
if fail = LoadPackage("AutoDoc", "2016.02.16") then
    Error("AutoDoc version 2016.02.16 or newer is required.");
fi;

AutoDoc(rec(scaffold := true, autodoc := true));

AutoDoc(rec(autodoc := rec(files := ["doc/intro.autodoc"])));
