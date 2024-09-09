#! @Description
#!   Attempts to download and install a package from an archive located at the
#!   given URL.  Returns <K>true</K> if the installation was successful, and
#!   <K>false</K> otherwise.
#! @Arguments url
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromArchive");

DeclareGlobalFunction("PKGMAN_TarTopDirectory");

PKGMAN_ArchiveFormats := [".tar.gz", ".tar.bz2"];
