#
# Quick and simple JSON parser.
#
# Works for the package distro file, but doesn't support some features that
# might appear in other files.  In particular, there are no numbers or single
# quotes.
#
InstallGlobalFunction(PKGMAN_JsonToGap,
function(string)
  local eat, parseExpectedCharacters, skipAllWhitespace, parseSomething, 
        parseObject, parseList, parseString, parseEscapeCharacter, parseBoolean,
        pos;
  
  eat := function(expected)
    parseExpectedCharacters(expected);
    skipAllWhitespace();
  end;

  parseExpectedCharacters := function(expected)
    local len;
    len := Length(expected);
    if ForAll([1 .. len], i -> expected[i] = string[pos + i]) then
      pos := pos + len;
    else
      ErrorNoReturn("expected \"", expected, "\" but found \"", string{[pos + 1 .. pos + len]}, "\"");
    fi;
  end;
  
  skipAllWhitespace := function()
    while pos < Length(string) and string[pos + 1] in PKGMAN_WHITESPACE do
      pos := pos + 1;
    od;
  end;
  
  parseSomething := function()
    local next;
    next := string[pos + 1];
    if next = '{' then
      return parseObject();
    elif next = '[' then
      return parseList();
    elif next = '"' then  # Note: doesn't support single quotes
      return parseString();
    elif next in "tfn" then
      return parseBoolean();
    fi;
    ErrorNoReturn("could not parse entity starting with '", next, "'");
  end;

  parseObject := function()
    local r, key, value;
    r := rec();
    eat("{");
    while string[pos + 1] <> '}' do
      key := parseString();
      eat(":");
      value := parseSomething();
      r.(key) := value;
      if string[pos + 1] = ',' then
        eat(",");
      else
        break;
      fi;
    od;
    eat("}");
    return r;
  end;
  
  parseList := function()
    local l, element;
    l := [];
    eat("[");
    while string[pos + 1] <> ']' do
      element := parseSomething();
      Add(l, element);
      if string[pos + 1] = ',' then
        eat(",");
      else
        break;
      fi;
    od;
    eat("]");
    return l;
  end;
  
  parseString := function()
    local codepoints;
    parseExpectedCharacters("\"");
    codepoints := [];
    while string[pos + 1] <> '"' do
      if string[pos + 1] = '\\' then
        Add(codepoints, parseEscapeCharacter());
      else
        Add(codepoints, IntChar(string[pos + 1]));
        pos := pos + 1;
      fi;
    od;
    eat("\"");
    return Encode(Unicode(codepoints));
  end;
  
  parseEscapeCharacter := function()
    local char;
    if string[pos + 2] = 'n' then
      char := IntChar('\n');
      pos := pos + 2;
    elif string[pos + 2] = '\\' then
      char := IntChar('\\');
      pos := pos + 2;
    elif string[pos + 2] = '"' then
      char := IntChar('"');
      pos := pos + 2;
    elif string[pos + 2] = 'u' then
      char := IntHexString(string{[pos + 3 .. pos + 6]});
      pos := pos + 6;
    else
      ErrorNoReturn("unknown escape sequence: \\", string[pos + 2]);
    fi;
    return char;
  end;

  parseBoolean := function()
    local next;
    next := string[pos + 1];
    if next = 't' then
      eat("true");
      return true;
    elif next = 'f' then
      eat("false");
      return false;
    else
      eat("null");
      return fail;
    fi;
  end;
  
  pos := 0;
  skipAllWhitespace();
  return parseSomething();
end);
