DeclareOperation("PKGMAN_Option", [IsString, IsRecord, IsString]);
DeclareOperation("PKGMAN_Option", [IsString, IsRecord]);

PKGMAN_GlobalOptions := rec(
  distro    := "latest",
  suggested := "ask",
  upgrade   := "ask",
  version   := "",
);
