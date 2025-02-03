# Objects
gap> PKGMAN_JsonToGap("{}");
rec(  )
gap> PKGMAN_JsonToGap("{   }");
rec(  )
gap> PKGMAN_JsonToGap(" {} ");
rec(  )
gap> PKGMAN_JsonToGap("{\"hello\": \"world\"}");
rec( hello := "world" )

# Strings
gap> PKGMAN_JsonToGap("\"hello\"");
"hello"
gap> PKGMAN_JsonToGap("\"\"");
""
gap> Print(PKGMAN_JsonToGap("\"I said \\\"hi!\\\" to him.\""), "\n");
I said "hi!" to him.
gap> PKGMAN_JsonToGap("\"Stra\\u00dfe\"");
"Straße"
gap> PKGMAN_JsonToGap("\"Sch\\u00f6nemann\"");
"Schönemann"

# Lists
gap> PKGMAN_JsonToGap("[] ");
[  ]
gap> PKGMAN_JsonToGap("[\"a\", \"b\", \"hello\"]");
[ "a", "b", "hello" ]
gap> PKGMAN_JsonToGap("[\"a\", \"b\", \"hello\", ]");
[ "a", "b", "hello" ]

# Booleans
gap> PKGMAN_JsonToGap("true");
true
gap> PKGMAN_JsonToGap("false  ");
false
gap> PKGMAN_JsonToGap("null");
fail

# Big combined examples
gap> PKGMAN_JsonToGap("{\"foo\": \"bar\", \"children\": [\"xy\", \"z\"], \"lookup\": {\"big\": false}}");
rec( children := [ "xy", "z" ], foo := "bar", lookup := rec( big := false ) )
