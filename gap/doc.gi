InstallGlobalFunction(PKGMAN_MakeDoc,
function(dir)
  local last_infogapdoc, last_infowarning, makedoc_g, doc_dir, doc_make_doc,
        last_dir, str, exec;
  if not IsPackageLoaded("gapdoc") then
    Info(InfoPackageManager, 1,
         "GAPDoc package not found, skipping building the documentation...");
    return;
  fi;

  # Mute GAPDoc
  if IsBoundGlobal("InfoGAPDoc") then
    last_infogapdoc := InfoLevel(ValueGlobal("InfoGAPDoc"));
    SetInfoLevel(ValueGlobal("InfoGAPDoc"), 0);
  fi;

  last_infowarning := InfoLevel(InfoWarning);
  SetInfoLevel(InfoWarning, 0);

  # Make documentation
  makedoc_g := Filename(Directory(dir), "makedoc.g");
  doc_dir := Filename(Directory(dir), "doc");
  doc_make_doc := Filename(Directory(doc_dir), "make_doc");
  if IsReadableFile(makedoc_g) then
    Info(InfoPackageManager, 3,
         "Building documentation (using makedoc.g)...");

    # Run makedoc.g, in the correct directory, without quitting
    last_dir := Filename(DirectoryCurrent(), "");
    ChangeDirectoryCurrent(dir);
    str := StringFile(makedoc_g);
    str := ReplacedString(str, "QUIT;", "");  # TODO: is there a better way?
    str := ReplacedString(str, "quit;", "");
    Read(InputTextString(str));
    ChangeDirectoryCurrent(last_dir);

  elif IsReadableFile(doc_make_doc) then
    Info(InfoPackageManager, 3,
         "Building documentation (using doc/make_doc)...");
    exec := PKGMAN_Exec(doc_dir, doc_make_doc);
    if exec.code <> 0 then
      Info(InfoPackageManager, 3, "WARNING: doc/make_doc failed");
    fi;
  else
    Info(InfoPackageManager, 3,
         "WARNING: could not build doc (no makedoc.g or doc/make_doc)");
  fi;
  if IsBoundGlobal("InfoGAPDoc") then
    SetInfoLevel(ValueGlobal("InfoGAPDoc"), last_infogapdoc);
  fi;
  SetInfoLevel(InfoWarning, last_infowarning);
end);
