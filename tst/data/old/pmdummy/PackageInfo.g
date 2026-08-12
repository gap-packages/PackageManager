#
# A minimal dummy package for the PackageManager tests.  It is served by the
# test HTTP server (see tst/http-server.g); "@SERVER@" is replaced by the
# address of that server when the file is served, but not inside the tarball.
#
# Note that the tarball of this package unpacks into a directory whose name
# does not contain the version number, which is what we want to test.
#
SetPackageInfo( rec(

PackageName := "pmdummy",
Subtitle := "A dummy package for the PackageManager tests",
Version := "1.0",
Date := "01/01/2020",  # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "The GAP",
    LastName := "Team",
    Email := "support@gap-system.org",
  ),
],

PackageWWWHome := "http://@SERVER@/",
ArchiveURL := "http://@SERVER@/pmdummy-1.0",
README_URL := "http://@SERVER@/README.md",
PackageInfoURL := "http://@SERVER@/PackageInfo.g",
ArchiveFormats := ".tar.gz",

Status := "other",

AbstractHTML := "A dummy package for the PackageManager tests",

PackageDoc := rec(
  BookName := "pmdummy",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "A dummy package for the PackageManager tests",
),

Dependencies := rec(
  GAP := ">= 4.12",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := [],
),

AvailabilityTest := ReturnTrue,

));
