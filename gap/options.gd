DeclareOperation("PKGMAN_Option", [IsString, IsRecord, IsString]);
DeclareOperation("PKGMAN_Option", [IsString, IsRecord]);

DeclareUserPreference(rec(
  name        := "dependencies",
  description := "",
  default     := true,
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "git",
  description := "",
  default     := "ask",
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "proceed",
  description := "",
  default     := "ask",
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "suggested",
  description := "",
  default     := false,
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "upgrade",
  description := "",
  default     := "ask",
  values      := [true, false, "ask"],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "interactive",
  description := "",
  default     := true,
  values      := [true, false],
  multi       := false
));

DeclareUserPreference(rec(
  name        := "distroLocation",
  description := "",
  default     := "https://github.com/gap-system/PackageDistro/releases/download/{}/package-infos.json.gz",
  check       := IsString
));

DeclareUserPreference(rec(
  name        := "distroVersion",
  description := "",
  default     := "latest",
  check       := IsString
));

DeclareUserPreference(rec(
  name        := "pkgDirectory",
  description := "",
  default     := Concatenation(GAPInfo.UserGapRoot, "/pkg"),
  check       := IsString
));

DeclareUserPreference(rec(
  name        := "version",
  description := "",
  default     := "",
  check       := IsString
));
