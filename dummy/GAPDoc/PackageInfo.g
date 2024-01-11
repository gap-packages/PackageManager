#############################################################################
##  
##  PackageInfo.g for the package `GAPDoc'                       Frank Lübeck

##  With a new release of the package at least the entries .Version, .Date and
##  .ArchiveURL must be updated.

SetPackageInfo( rec(


PackageName := "GAPDoc",
Subtitle := "A Meta Package for GAP Documentation",
Version := "0.2",  # SABOTAGED by M Torpey!  This is way older than it should be
##  DD/MM/YYYY format:
Date := "17/10/2018",
License := "GPL-2.0-or-later",

SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/frankluebeck/GAPDoc"
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
ArchiveURL := 
          "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/GAPDoc-1.6.2",
ArchiveFormats := ".tar.bz2",
Persons := [
  rec(
  LastName := "Lübeck",
  FirstNames := "Frank",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "Frank.Luebeck@Math.RWTH-Aachen.De",
  WWWHome := "http://www.math.rwth-aachen.de/~Frank.Luebeck",
  Place := "Aachen",
  Institution := "Lehrstuhl D für Mathematik, RWTH Aachen",
  PostalAddress := "Dr. Frank Lübeck\nLehrstuhl D für Mathematik\nRWTH Aachen\nTemplergraben 64\n52062 Aachen\nGERMANY\n"
  ),
  rec(
  LastName := "Neunhöffer",
  FirstNames := "Max",
  IsAuthor := true,
  IsMaintainer := false,
  #Email := "neunhoef at mcs.st-and.ac.uk",
  WWWHome := "http://www-groups.mcs.st-and.ac.uk/~neunhoef/",
  #Place := "St Andrews",
  #Institution := "School of Mathematics and Statistics, St Andrews",
  )
],
Status := "accepted",
CommunicatedBy := "Steve Linton (St Andrews)",
AcceptDate := "10/2006",
              
README_URL := 
"http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/README.txt",
PackageInfoURL := 
"http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/PackageInfo.g",
AbstractHTML := "This package contains a definition of a structure for <span class='pkgname'>GAP</span> (package) documentation, based on XML. It also contains  conversion programs for producing text-, PDF- or HTML-versions of such documents, with hyperlinks if possible.",
PackageWWWHome := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc",
PackageDoc := [rec(
  BookName := "GAPDoc",
  ArchiveURLSubset := ["doc", "example"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "a meta package for GAP documentation",
  Autoload := true
  ),
  rec(
  BookName := "GAPDoc Example",
  ArchiveURLSubset := ["example", "doc"],
  HTMLStart := "example/chap0.html",
  PDFFile := "example/manual.pdf",
  SixFile := "example/manual.six",
  LongTitle := "example help book for GAPDoc",
  Autoload := false
  )],
Dependencies := rec(
  GAP := "4.7.6",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [["IO", ">= 2.3"]],
  ExternalConditions := 
            ["(La)TeX installation for converting documents to PDF",
              "BibTeX installation to produce unified labels for refs"]
),
AvailabilityTest := ReturnTrue,
Keywords := ["GAP documentation", "help system", "XML", "pdf", "hyperlink",
            "unicode", "BibTeX", "BibXMLext"]
));

