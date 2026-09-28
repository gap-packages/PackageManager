#
# These commands exist for backwards compatibility with the call style generally used before 2.0
#

# InstallPackage(string, interactive)
# RemovePacakge(string, interactive)
#
# In newer versions we should set the "interactive" user preference or include
#   interactive := true
# in the prefs record.
DeclareOperation("InstallPackage", [IsString, IsBool]);
DeclareOperation("RemovePackage", [IsString, IsBool]);

# UpdatePackage
#
# This had almost the same behaviour as InstallPackage, with slightly different prompting.
# Without interactivity (as in most tests and automated suites) a synonym has the same effect.
DeclareSynonym("UpdatePackage", InstallPackage);
