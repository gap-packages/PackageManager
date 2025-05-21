DeclareOperation("PKGMAN_Option", [IsString, IsRecord, IsString]);
DeclareOperation("PKGMAN_Option", [IsString, IsRecord]);

PKGMAN_GlobalOptions := rec(
  distro      := "latest",
  gitpull     := "ask",
  install     := "ask",
  interactive := true,
  suggested   := false,
  upgrade     := "ask",
  version     := "",
);
