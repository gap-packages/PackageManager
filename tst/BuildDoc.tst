# Get AutoDoc (for testing)
gap> InstallPackage("autodoc");
true
gap> LoadPackage("autodoc", false);
true

# Install a package from a git repository, and modify it
gap> InstallPackage("https://github.com/gap-packages/Example.git");
true
gap> dir := First(DirectoryContents(PKGMAN_PackageDir()),
>                 f -> StartsWith(f, "Example"));;
gap> dir := Filename(Directory(PKGMAN_PackageDir()), dir);;
gap> dir <> fail;
true
gap> readme := Filename(Directory(dir), "README.md");;
gap> FileString(readme, "Some change I've made", true);;  # edit file
gap> UpdatePackage("example");
#I  Uncommitted changes in git repository
false
gap> RemovePackage("example", false);
true

# Install a package from a git repository not ending in .git
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo", false);
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "RegisterPackageTNUMDemo"));
true
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo", false);
#I  Package already installed at target location
false

# Install a package from a git repository by branch
gap> InstallPackageFromGit("https://github.com/gap-packages/MathInTheMiddle.git", false, "master");
true
gap> RemovePackage("MathInTheMiddle", false);
true
gap> InstallPackageFromGit("https://github.com/gap-packages/MathInTheMiddle.git", "master");
true
gap> RemovePackage("MathInTheMiddle", false);
true
gap> InstallPackageFromGit("https://github.com/gap-packages/orb.git", false, "fiaenfq");
#I  Cloning unsuccessful
false
gap> InstallPackageFromGit("https://github.com/gap-packages/orb.git", "master", true);
Error, PackageManager: InstallPackageFromGit:
<interactive> should be true or false
gap> InstallPackageFromGit("https://github.com/a/b.git", false, 3);
Error, PackageManager: InstallPackageFromGit:
<branch> should be a string
gap> InstallPackageFromGit("https://github.com/a/b.git", 3);
Error, PackageManager: InstallPackageFromGit:
2nd argument should be true, false, or a string
gap> InstallPackageFromGit("https://github.com/a/b.git", true, "master", "lol");
Error, PackageManager: InstallPackageFromGit:
requires 1, 2 or 3 arguments (not 4)

# Interactive tests (via hacking in/out streams)
gap> uuid_0_5 := Concatenation("https://github.com/gap-packages/uuid/releases/",
>                              "download/v0.5/uuid-0.5.tar.gz");;
gap> InstallPackage(uuid_0_5);
#E  component `License' must be bound to a nonempty string containing an SPDX \
ID
#I  PackageInfo.g validation failed
#I  There may be problems with the package
true
gap> InstallPackage("uuid", false);  # older version already installed
#E  component `License' must be bound to a nonempty string containing an SPDX \
ID
#I  PackageInfo.g validation failed
#I  There may be problems with the package
true
gap> out := "";;
gap> f_in := InputTextUser;;
gap> oldPrint := Print;;
gap> newPrint := function(args...)
>   CallFuncList(PrintTo, Concatenation([OutputTextString(out, true)], args));
> end;;
gap> MakeReadWriteGlobal("InputTextUser");
gap> MakeReadWriteGlobal("Print");
gap> InputTextUser := {} -> InputTextString("n");;
gap> Print := newPrint;;
gap> res := RemovePackage("uuid");;
gap> Print := oldPrint;;
gap> res;
false
gap> PositionSublist(out,
>                    Concatenation("Really delete directory ",
>                                  Filename(Directory(PKGMAN_PackageDir()),
>                                           "uuid-0.5/"),
>                                  " ? [y/N] n\n")) <> fail;
true
gap> InputTextUser := {} -> InputTextString("y\ny\n");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := InstallPackage("uuid", true);;
gap> Print := oldPrint;;
gap> res;
true
gap> exp1 := Concatenation("Package \"uuid\" version 0.5 is installed, but ",
>                          PKGMAN_DownloadPackageInfo(GetPackageURLs().uuid).Version,
>                          " is available. Install it? [y/N] y\n");;
gap> exp2 := Concatenation("Remove old version of uuid at ",
>                          Filename(Directory(PKGMAN_PackageDir()), "uuid-0.5/"),
>                          " ? [y/N] y\n");;
gap> PositionSublist(out, exp1) <> fail;
true
gap> PositionSublist(out, exp2) <> fail;
true
gap> RemovePackage("uuid", false);
true
gap> InstallPackage(uuid_0_5);
#E  component `License' must be bound to a nonempty string containing an SPDX \
ID
#I  PackageInfo.g validation failed
#I  There may be problems with the package
true
gap> InputTextUser := {} -> InputTextString("y");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := RemovePackage("uuid", true);;
gap> Print := oldPrint;;
gap> res;
true
gap> PositionSublist(out,
>                    Concatenation("Really delete directory ",
>                                  Filename(Directory(PKGMAN_PackageDir()),
>                                           "uuid-0.5/"),
>                                  " ? [y/N] y\n")) <> fail;
true
gap> if ForAny(DirectoryContents(PKGMAN_PackageDir()), f -> StartsWith(f, "io")) then
>   RemovePackage("io", false);;
> fi;
gap> InstallPackage("https://github.com/gap-packages/io.git");
true
gap> InputTextUser := {} -> InputTextString("y");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := InstallPackage("io");;
gap> Print := oldPrint;;
gap> res;
true
gap> exp := "Package \"io\" already installed via git. Update it? [y/N] y\n";;
gap> PositionSublist(out, exp) <> fail;
true
gap> RemovePackage("io", false);
true
gap> InputTextUser := {} -> InputTextString("y");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := UpdatePackage("uuid");;
gap> Print := oldPrint;;
gap> res;
true
gap> exp := "#I  Package \"uuid\" not installed in user package directory\n";;
gap> Append(exp, "Would you like to install uuid? [Y/n] y\n");
gap> PositionSublist(out, exp) <> fail;
true
gap> RemovePackage("uuid", false);
true
gap> InstallPackage(uuid_0_5);
#E  component `License' must be bound to a nonempty string containing an SPDX \
ID
#I  PackageInfo.g validation failed
#I  There may be problems with the package
true
gap> InputTextUser := {} -> InputTextString("y\n");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := UpdatePackage("uuid");;
gap> Print := oldPrint;;
gap> res;
true
gap> exp := Concatenation("Remove old version of uuid at ",
>                         Filename(Directory(PKGMAN_PackageDir()), "uuid-0.5/"),
>                         " ? [y/N] y\n");;
gap> PositionSublist(out, exp) <> fail;
true
gap> RemovePackage("uuid", false);
true
gap> InstallPackage("https://github.com/gap-packages/uuid.git");
true
gap> InputTextUser := {} -> InputTextString("y\n");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := InstallPackage("https://github.com/gap-packages/uuid.git");;
gap> Print := oldPrint;;
gap> res;
true
gap> exp := Concatenation("Package \"uuid\" already installed via git. ",
>                         "Update it? [y/N] y\n");;
gap> PositionSublist(out, exp) <> fail;
true
gap> RemovePackage("uuid", false);
true
gap> InputTextUser := f_in;;
gap> MakeReadOnlyGlobal("InputTextUser");
gap> MakeReadOnlyGlobal("Print");
gap> Print(InputTextUser, "\n");
function (  )
    return InputTextFile( "*stdin*" );
end
gap> Print = oldPrint;
true
gap> Print = newPrint;
false

# Bad package info
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage2.tar.gz");
#I  PackageInfo.g lacks Version field
false

# InstallPackageFromInfo fail
# (very complicated and changeable output, just checking some bits)
# (no need for all this hackery after #E messages are removed from GAP)
gap> newPrint := function(args...)
>   CallFuncList(PrintTo, Concatenation([OutputTextString(out, true)], args));
> end;;
gap> out := "";;
gap> MakeReadWriteGlobal("Print");
gap> Print := newPrint;;
gap> res := InstallPackage("https://gap-packages.github.io/PackageManager/dummy/PackageInfo.g");;
gap> Print := oldPrint;;
gap> MakeReadOnlyGlobal("Print");
gap> res;
true
gap> exp := "#E  component `Subtitle' must be bound to a string";;
gap> PositionSublist(out, exp) <> fail;
true
gap> exp := "#E  component `Version' must be bound to";;
gap> PositionSublist(out, exp) <> fail;
true
gap> exp := "#E  component `Date' must be bound to";;
gap> PositionSublist(out, exp) <> fail;
true
gap> exp := "yyyy";;
gap> PositionSublist(out, exp) <> fail;
true
gap> exp := "#E  component `ArchiveURL' must be bound to";;
gap> PositionSublist(out, exp) <> fail;
true
gap> exp := "#E  component `PackageInfoURL' must be bound to a string";;
gap> PositionSublist(out, exp) <> fail;
true
gap> exp := "#I  There may be problems with the package";;
gap> PositionSublist(out, exp) <> fail;
true

# Build doc with doc/make_doc
# (can probably re-add this after #E messages are removed from GAP)
# gap> InstallPackage("https://github.com/gap-packages/sonata.git");
# true

# The big one: install semigroups, and mess with its dependencies
# TEMP: removed since semigroups now takes around 10 minutes to compile
# gap> InstallPackage("semigroups");
# true
# gap> dig := First(PackageInfo("digraphs"),
# >                 x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));;
# gap> PKGMAN_RemoveDir(Filename(Directory(dig.InstallationPath), "bin"));
# gap> UpdatePackage("semigroups");  # should recompile digraphs
# true
# gap> dig := First(PackageInfo("digraphs"),
# >                 x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));;
# gap> RemoveFile(Filename(Directory(dig.InstallationPath), "PackageInfo.g"));
# true
# gap> UpdatePackage("semigroups");  # recompiling doesn't work
# #I  Package already installed at target location
# #I  Dependencies not satisfied
# #I  Package availability test failed
# false
# gap> RemovePackage("semigroups", false);
# true
