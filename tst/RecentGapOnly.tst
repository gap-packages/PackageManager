# Get AutoDoc (for testing)
gap> InstallPackage("autodoc");
true
gap> LoadPackage("autodoc", false);
true
gap> SetInfoLevel(InfoAutoDoc, 0);

# Fail to build doc and compile but completes installation
# (assumes GAP is located at ../../..)
# Prints lots of #E messages in GAP 4.13 and earlier
gap> InstallPackage("https://github.com/gap-packages/grape.git");
#I  PackageInfo.g validation failed
#I  There may be problems with the package
#I  Compilation failed for package 'GRAPE'
#I  (package may still be usable)
true

# Interactive tests (via hacking in/out streams)
# Different output in GAP 4.12 and earlier
gap> uuid_0_5 := Concatenation("https://github.com/gap-packages/uuid/releases/",
>                              "download/v0.5/uuid-0.5.tar.gz");;
gap> InstallPackage(uuid_0_5);
#I  PackageInfo.g validation failed
#I  There may be problems with the package
true
gap> InstallPackage("uuid", false);  # older version already installed
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

# Check package can be recompiled and removed
gap> InstallPackage("example");
true
gap> CompilePackage("example");
true
gap> RemovePackage("example", false);
true

# PKGMAN_CompileDir error: no shell
gap> InstallPackage("example");
true
gap> InstallPackage("example");  # latest version already installed
true
gap> progs := GAPInfo.DirectoriesPrograms;;
gap> GAPInfo.DirectoriesPrograms := [];;  # terrible vandalism
gap> dir := PKGMAN_UserPackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No shell available called "sh"
#I  Compilation failed for package 'Example'
#I  (package may still be usable)
false
gap> GAPInfo.DirectoriesPrograms := progs;;
gap> RemovePackage("example", false);
true

# PKGMAN_CompileDir error: no etc/BuildPackages.sh
gap> InstallPackage("example", false);
true
gap> sysinfo_scr := PKGMAN_Sysinfo;;
gap> PKGMAN_Sysinfo := fail;;
gap> dir := PKGMAN_UserPackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No sysinfo.gap found
false
gap> PKGMAN_Sysinfo := sysinfo_scr;;
gap> RemovePackage("example", false);
true

# PKGMAN_CompileDir error: missing source
gap> InstallPackage("example");
true
gap> dir := PKGMAN_UserPackageInfo("example")[1].InstallationPath;;
gap> RemoveFile(Filename(Directory(dir), "src/hello.c"));
true
gap> PKGMAN_CompileDir(dir);
#I  Compilation failed for package 'Example'
#I  (package may still be usable)
false
gap> RemovePackage("example", false);
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

# Checking package: always compile even when another version is already installed
gap> InstallPackage("orb");
true
gap> InstallPackage("https://github.com/gap-packages/orb.git");
true
gap> git_pkginfo := First(PackageInfo("orb"), p -> EndsWith(p.InstallationPath, "orb/"));;
gap> "bin" in DirectoryContents(git_pkginfo.InstallationPath);  # check if it has been compiled
true
gap> RemoveDirectoryRecursively(git_pkginfo.InstallationPath);  # delete git version
true
gap> PKGMAN_RefreshPackageInfo();
gap> RemovePackage("orb", false);  # delete release version
true
