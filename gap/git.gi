# InstallGlobalFunction(InstallPackageFromGit,
# function(url, args...)
#   local interactive, branch, name, dir, info, dirs, repo, q, exec;

#   # Process args
#   interactive := true;
#   branch := fail;
#   if Length(args) = 1 then
#     if args[1] in [true, false] then
#       interactive := args[1];
#     elif IsString(args[1]) then
#       branch := args[1];
#     else
#       ErrorNoReturn("2nd argument should be true, false, or a string");
#     fi;
#   elif Length(args) = 2 then
#     interactive := args[1];
#     branch := args[2];
#     if not interactive in [true, false] then
#       ErrorNoReturn("<interactive> should be true or false");
#     elif not IsString(branch) then
#       ErrorNoReturn("<branch> should be a string");
#     fi;
#   elif Length(args) > 2 then
#     ErrorNoReturn("requires 1, 2 or 3 arguments (not ", Length(args) + 1, ")");
#   fi;

#   name := PKGMAN_NameOfGitRepo(url);
#   if name = fail then
#     Info(InfoPackageManager, 1, "Could not find repository name (bad URL?)");
#     return false;
#   fi;
#   dir := Filename(Directory(PKGMAN_PackageDir()), name);

#   # Check for existing repository
#   info := PKGMAN_UserPackageInfo(name);
#   dirs := List(info, i -> ShallowCopy(i.InstallationPath));
#   repo := Filename(List(dirs, Directory), ".git");
#   if repo <> fail then  # TODO: check it's the same remote?
#     q := Concatenation("Package \"", name, "\" already installed via git. Update it?");
#     if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
#       return UpdatePackage(name, interactive);
#     fi;
#   fi;

#   # Check for a valid location
#   if not PKGMAN_IsValidTargetDir(dir) then
#     return false;
#   fi;

#   # Do the cloning
#   Info(InfoPackageManager, 2, "Cloning to ", dir, " ...");
#   if branch = fail then
#     exec := PKGMAN_Exec(".", "git", "clone", url, dir);
#   else
#     exec := PKGMAN_Exec(".", "git", "clone", url, dir, "-b", branch);
#   fi;

#   # Was the download successful?
#   if exec.code <> 0 then
#     Info(InfoPackageManager, 1, "Cloning unsuccessful");
#     return false;
#   fi;
#   Info(InfoPackageManager, 3, "Package cloned successfully");
#   PKGMAN_RefreshPackageInfo();

#   # Check for PackageInfo.g
#   info := Filename(Directory(dir), "PackageInfo.g");
#   if not IsReadableFile(info) then
#     Info(InfoPackageManager, 1, "Could not find PackageInfo.g");
#     PKGMAN_RemoveDirOptional(dir);
#     return false;
#   fi;

#   # Install dependencies
#   if PKGMAN_InstallDependencies(dir) <> true then
#     Info(InfoPackageManager, 1, "Dependencies not satisfied for ", name);
#     PKGMAN_RemoveDirOptional(dir);
#     return false;
#   fi;

#   # Compile, make doc, and check
#   return PKGMAN_CheckPackage(dir);
# end);

# InstallGlobalFunction(PKGMAN_NameOfGitRepo,
# function(url)
#   local parts, n;
#   parts := SplitString(url, "", "/:. \n\t\r");
#   n := Length(parts);
#   if n > 0 and parts[n] <> "git" then
#     return parts[n];
#   elif n > 1 and parts[n] = "git" then
#     return parts[n - 1];
#   fi;
#   return fail;
# end);

InstallGlobalFunction(PKGMAN_UserPackageGitRepoPaths,
function(name)
  # Returns a list of paths to all user-installed git repos for this package
  local info, dirs, repos;
  info := PKGMAN_UserPackageInfo(name);
  dirs := List(info, i -> i.InstallationPath);
  repos := Filtered(dirs, dir -> IsDirectoryPath(Concatenation(dir, ".git/")));
  return repos;
end);

InstallGlobalFunction(PKGMAN_GitPullDirectory,
function(dir)
  local status, pull, line;
  Info(InfoPackageManager, 3, "Checking git status in ", dir, "...");
  status := PKGMAN_Exec(dir, "git", "status", "-s");
  if status = fail then
    return false;
  elif status.code = 0 and status.output = "" then
    Info(InfoPackageManager, 3, "Pulling from git repository...");
    pull := PKGMAN_Exec(dir, "git", "pull", "--ff-only");
    for line in SplitString(pull.output, "\n") do
      Info(InfoPackageManager, 3, "git: ", line);
    od;
    return pull.code = 0;
  else
    Info(InfoPackageManager, 1, "Uncommitted changes in git repository");
    Info(InfoPackageManager, 2, "(at ", dir, ")");
    return false;
  fi;
end);
