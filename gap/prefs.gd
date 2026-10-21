DeclareOperation("PKGMAN_Pref", [IsString, IsRecord, IsString]);
DeclareOperation("PKGMAN_Pref", [IsString, IsRecord]);

PKGMAN_TFA := "Possible values: true, false, or \"ask\".";

DeclareUserPreference(rec(
  name        := "dependencies",
  description := ["Whether to install all required packages when a package is installed.", PKGMAN_TFA],
  default     := true,
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "git",
  description := ["Whether to try pulling any checked out Git repositories when upgrading packages.", PKGMAN_TFA],
  default     := "ask",
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "proceed",
  description := ["When installing a package, a plan will first be computed and shown to the user, including version numbers and dependencies, before the installation goes ahead. This preference can be set to: true to proceed with the installation without prompting; false to automatically cancel the installation (a dry run); or \"ask\" to interactively prompt the user to confirm."],
  default     := "ask",
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "suggested",
  description := ["Whether to include suggested as well as required dependencies when installing a package.", PKGMAN_TFA],
  default     := false,
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "upgrade",
  description := ["Whether to upgrade packages that have already been installed if a new version is found by an install command.", "If this is set to true, install commands will always upgrade packages and their dependencies to the latest versions; if false, upgrades will only be applied if necessary to meet specified version requirements; if \"ask\" then the user will be prompted to choose interactively."],
  default     := "ask",
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "compile",
  description := ["Whether to attempt to compile newly installed packages.", PKGMAN_TFA],
  default     := true,
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "compileDeps",
  description := ["Whether to attempt to compile the dependencies of a package during installation.", PKGMAN_TFA],
  default     := true,
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "interactive",
  description := ["Whether to allow interactive prompting in PackageManager functions. Set this to false to disable all prompting.", "If false, all PackageManager preferences that are set to \"ask\" will instead be treated as if they were true."],
  default     := true,
  values      := [true, false],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "distroLocation",
  description := ["The URL to download the GAP package distribution info from.", "If it contains the wildcard symbol {} then this will be filled in with the value of the distroVersion preference."],
  default     := "https://github.com/gap-system/PackageDistro/releases/download/{}/package-infos.json.gz",
  check       := IsString
));

DeclareUserPreference(rec(
  name        := "distroVersion",
  description := ["The version of the package distribution info to use.", "Set this to \"latest\" to get the latest accepted versions of all packages, some of which might not work on older versions of GAP. Or set this to a GAP version such as \"v4.16.1\" to get packages chosen to be compatible with that release."],
  default     := "latest",
  check       := IsString
));

DeclareUserPreference(rec(
  name        := "version",
  description := ["The required version number to use for packages that are being installed.", "This preference will not usually need to be set, since different packages have different version numbers. But it can be overridden using the prefs record argument passed to InstallPackage.", "The default value \"\" is satisfied by any version number."],
  default     := "",
  check       := IsString
));

DeclareUserPreference(rec(
  name        := "branch",
  description := ["The name of the branch to check out when cloning a Git repository.", "If this is set to fail, then the default branch will be used."],
  default     := fail,
  check       := pref -> pref = fail or IsString(pref)
));
