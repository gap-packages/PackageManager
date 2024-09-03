#! @Description
#!   Attempts to download and install a package from a git repository located at
#!   the given URL.  Returns <K>false</K> if something went wrong, and
#!   <K>true</K> otherwise.
#!
#!   If the optional string argument <A>branch</A> is specified, this function
#!   will install the branch with this name.  Otherwise, the repository's
#!   default branch will be used.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell &ndash; to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   <A>interactive</A> can be set to <K>false</K>.
#! @Arguments url[, interactive][, branch]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromGit");

DeclareGlobalFunction("PKGMAN_NameOfGitRepo");
