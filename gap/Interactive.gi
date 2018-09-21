InstallGlobalFunction(PKGMAN_FlushOutput,
function()
    PrintTo(OutputTextUser(), "\c");
end);

InstallGlobalFunction(PKGMAN_AskYesNoQuestion,
function(question...)
  local stream, out, default, ans;

  question := Concatenation(question);

  stream := InputTextUser();
  out := OutputTextUser();

  PrintTo(out, question);
  default := ValueOption( "default" );
  if default = true then
    PrintTo(out, " [Y/n] "); PKGMAN_FlushOutput();
  elif default = false then
    PrintTo(out, " [y/N] "); PKGMAN_FlushOutput();
  else
    default := fail;
    PrintTo(out, " [y/n] "); PKGMAN_FlushOutput();
  fi;

  while true do
    ans := CharInt(ReadByte(stream));
    if ans in "yYnN" then
      PrintTo(out, [ans,'\n']);
      ans := ans in "yY";
      break;
    elif ans in "\n\r" and default <> fail then
      PrintTo(out, "\n");
      ans := default;
      break;
    elif ans = '\c' then
      # HACK since Ctrl-C does not work
      PrintTo(out, "\nUser aborted\n"); 
      # HACK, undocumented command      
      JUMP_TO_CATCH("abort");
    fi;
  od;

  CloseStream(stream);
  return ans;
end);
