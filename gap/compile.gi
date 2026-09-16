InstallMethod(CompilePackage,
"for a string",
[IsString],
string -> CompilePackage(string, rec()));

InstallMethod(CompilePackage,
"for a string and a record",
[IsString, IsRecord],
function(name, prefs)
  local names;
  
  # Check input
  if IsEmpty(PackageInfo(name)) then
    Info(InfoPackageManager, 1, "No package named \"", name, "\" is installed");
    return false;
  elif IsEmpty(PKGMAN_UserPackageInfo(name)) then
    Info(InfoPackageManager, 1, "The ", name, " package is installed, but not in the user package directory");
    Info(InfoPackageManager, 1, "You can install a user-managed version with InstallPackage(\"", name, "\")");
    return false;
  fi;
  
  # Compile all dependencies or just this package?
  if PKGMAN_Pref("compileDeps", prefs, "Compile package dependencies as well?") then
    names := List(PKGMAN_DependencyGraph([[name, ""]], prefs), pkg -> pkg.name);
  else
    names := [name];
  fi;
  return ForAll(names, PKGMAN_CompilePackageByName);
end);

InstallGlobalFunction(PKGMAN_CompilePackageByName,
function(name)
  # Compile just the package with this name.
  # If multiple copies exist, compile the most recent one and any git ones.
  # return true if all compilations are successful or not needed
  local info, repos, dirs;

  # Locate the package
  info := PKGMAN_UserPackageInfo(name);
  repos := PKGMAN_UserPackageGitRepoPaths(name);

  # Package not installed
  if Length(info) = 0 then
    return false;
  fi;

  # Compile the most up-to-date installation, and any git ones
  dirs := Union([info[1].InstallationPath], repos);
  return ForAll(dirs, dir -> PKGMAN_CompileDir(dir));
end);

InstallGlobalFunction(PKGMAN_CompileDir,
function(dir)
  local info, prerequisites, exec, pkg_dir, gap_root;

  info := PKGMAN_GetPackageInfo(dir);
  if info = fail then
    return false;
  fi;

  # Run the prerequisites file if it exists
  # Note: this is mainly for installing Semigroups from GitHub
  prerequisites := Filename(Directory(dir), "prerequisites.sh");
  if IsReadableFile(prerequisites) then
    Info(InfoPackageManager, 3, "Running prerequisites.sh for ", info.PackageName, "...");
    exec := PKGMAN_Exec(dir, prerequisites);
  fi;

  # Check requirements, and prepare command
  pkg_dir := Filename(Directory(dir), "..");
  gap_root := PKGMAN_GapRootDir();
  if gap_root = fail then
    return false;
  fi;

  # Is the compilation script available?
  if not (IsString(PKGMAN_BuildPackagesScript) and IsReadableFile(PKGMAN_BuildPackagesScript)) then
    Info(InfoPackageManager, 1, "Compilation script not found");
    return false;
  fi;

  # Call the script
  Info(InfoPackageManager, 3, "Running compilation script on ", dir, " ...");
  exec := PKGMAN_Exec(".", PKGMAN_BuildPackagesScript, gap_root, dir);
  if exec = fail or exec.code <> 0 or PositionSublist(exec.output, "Failed to build") <> fail then
    Info(InfoPackageManager, 1, "Compilation failed for package '", info.PackageName, "'");
    Info(InfoPackageManager, 1, "(package may still be usable)");
    if exec <> fail then
      PKGMAN_InfoWithIndent(2, exec.output, 2);
    fi;
    return false;
  else
    PKGMAN_InfoWithIndent(4, exec.output, 2);
  fi;
  return true;
end);
