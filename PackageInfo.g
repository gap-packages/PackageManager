#
# PackageManager: Easily download and install GAP packages
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "PackageManager",
Subtitle := "Easily download and install GAP packages",
Version := "1.4.3",
Date := "12/01/2024",  # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Michael",
    LastName := "Young",
    WWWHome := "https://mct25.host.cs.st-andrews.ac.uk/",
    Email := "mct25@st-andrews.ac.uk",
    PostalAddress := Concatenation(
               "School of Computer Science\n",
               "University of St Andrews\n",
               "Jack Cole Building, North Haugh\n",
               "St Andrews, Fife, KY16 9SX\n",
               "United Kingdom" ),
    Place := "St Andrews",
    Institution := "University of St Andrews",
  ),
  rec(
    LastName      := "GAP Team",
    FirstNames    := "The",
    IsAuthor      := false,
    IsMaintainer  := true,
    Email         := "support@gap-system.org",
  ),
],

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/gap-packages/", ~.PackageName ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
#SupportEmail   := "TODO",
PackageWWWHome  := "https://gap-packages.github.io/PackageManager/",
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL      := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "deposited",

AbstractHTML :=
  "<span class=\"pkgname\">PackageManager</span> is a basic collection of \
   simple functions for installing and removing \
   <span class=\"pkgname\">GAP</span> packages, with the eventual aim of \
   becoming a full pip-style package manager for the \
   <span class=\"pkgname\">GAP</span> system.",

PackageDoc := rec(
  BookName  := "PackageManager",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Easily download and install GAP packages",
),

Dependencies := rec(
  GAP := ">= 4.10",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [ [ "GAPDoc", ">= 1.6.1" ], [ "curlInterface", ">= 2.1.0" ] ],
  ExternalConditions := [ ],
),

Extensions := [
    rec( needed := [ [ "JuliaInterface", ">= 0.9.3" ] ],
         filename := "gap/Download.g" ),
],

AvailabilityTest := function()
        return true;
    end,

# This is a limited test suite that doesn't try to build docs,
# since the GAP Docker images don't have texlive installed.
# For a full test suite, run tst/testall.g (as Travis does).
TestFile := "tst/test-without-texlive.g",

#Keywords := [ "TODO" ],

));
