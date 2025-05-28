DeclareOperation("PKGMAN_Option", [IsString, IsRecord, IsString]);
DeclareOperation("PKGMAN_Option", [IsString, IsRecord]);

PKGMAN_GlobalOptions := rec(
  dependencies   := true,
  distroLocation := "https://github.com/gap-system/PackageDistro/releases/download/{}/package-infos.json.gz",
  distroVersion  := "latest",
  gitpull        := "ask",
  interactive    := true,
  pkgDirectory   := Concatenation(GAPInfo.UserGapRoot, "/pkg"),
  proceed        := "ask",
  suggested      := false,
  upgrade        := "ask",
  version        := "",
);
