InstallGlobalFunction(InstallPackageFromGit,
function(url, args...)
  local interactive, branch, name, dir, allinfo, info, dirs, repo, q, exec;

  # Process args
  interactive := true;
  branch := fail;
  if Length(args) = 1 then
    if args[1] in [true, false] then
      interactive := args[1];
    elif IsString(args[1]) then
      branch := args[1];
    else
      ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                    "2nd argument should be true, false, or a string");
    fi;
  elif Length(args) = 2 then
    interactive := args[1];
    branch := args[2];
    if not interactive in [true, false] then
      ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                    "<interactive> should be true or false");
    elif not IsString(branch) then
      ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                    "<branch> should be a string");
    fi;
  elif Length(args) > 2 then
    ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                  "requires 1, 2 or 3 arguments (not ",
                  Length(args) + 1, ")");
  fi;

  name := PKGMAN_NameOfGitRepo(url);
  if name = fail then
    Info(InfoPackageManager, 1, "Could not find repository name (bad URL?)");
    return false;
  fi;
  dir := Filename(Directory(PKGMAN_PackageDir()), name);

  # Check for existing repository
  allinfo := PackageInfo(name);
  info := Filtered(allinfo,
                   x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));
  dirs := List(info, i -> ShallowCopy(i.InstallationPath));
  repo := Filename(List(dirs, Directory), ".git");
  if repo <> fail then  # TODO: check it's the same remote?
    q := Concatenation("Package \"", name,
                       "\" already installed via git. Update it?");
    if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
      return UpdatePackage(name, interactive);
    fi;
  fi;

  if not PKGMAN_IsValidTargetDir(dir) then
    return false;
  fi;
  Info(InfoPackageManager, 2, "Cloning to ", dir, " ...");

  if branch = fail then
    exec := PKGMAN_Exec(".", "git", "clone", url, dir);
  else
    exec := PKGMAN_Exec(".", "git", "clone", url, dir, "-b", branch);
  fi;

  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Cloning unsuccessful");
    return false;
  fi;
  Info(InfoPackageManager, 3, "Package cloned successfully");
  PKGMAN_RefreshPackageInfo();

  # Check for PackageInfo.g
  info := Filename(Directory(dir), "PackageInfo.g");
  if not IsReadableFile(info) then
    Info(InfoPackageManager, 1, "Could not find PackageInfo.g");
    if ValueOption("keepDirectory") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Install dependencies
  if PKGMAN_InstallDependencies(dir) <> true then
    Info(InfoPackageManager, 1, "Dependencies not satisfied for ", name);
    if ValueOption("keepDirectory") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Compile, make doc, and check
  return PKGMAN_CheckPackage(dir);
end);

InstallGlobalFunction(PKGMAN_NameOfGitRepo,
function(url)
  local parts, n;
  parts := SplitString(url, "", "/:. \n\t\r");
  n := Length(parts);
  if n <> 0 and parts[n] <> "git" then
    return parts[n];
  fi;
  if parts[n] = "git" and n > 1 then
    return parts[n-1];
  fi;
  return fail;
end);