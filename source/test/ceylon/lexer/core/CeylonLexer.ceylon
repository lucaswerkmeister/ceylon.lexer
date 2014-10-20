import ceylon.lexer.core {
    CeylonLexer,
    StringCharacterStream,
    Token,
    TokenType,
    characterLiteral,
    lidentifier,
    lineComment,
    multiComment,
    stringEnd,
    stringLiteral,
    stringMid,
    stringStart,
    uidentifier,
    verbatimStringLiteral,
    whitespace
}
import ceylon.test {
    test,
    assertEquals
}

shared class CeylonLexerTest() {
    
    test
    shared void spaces()
            => singleToken("    ", whitespace, "Spaces");
    
    test
    shared void mixedWhitespace()
            => singleToken("    \t\n", whitespace, "Mixed whitespace");
    
    test
    shared void simpleLineComment()
            => singleToken("// Line comment", lineComment, "Simple line comment");
    
    test
    shared void emptyLineComment()
            => singleToken("//", lineComment, "Empty line comment");
    
    test
    shared void simpleShebangComment()
            => singleToken("#!/usr/bin/ceylon", lineComment, "Simple shebang comment");
    
    test
    shared void emptyShebangComment()
            => singleToken("#!", lineComment, "Empty shebang comment");
    
    test
    shared void simpleMultiComment()
            => singleToken("/* Multi comment */", multiComment, "Simple multi comment");
    
    test
    shared void nestedMultiComment()
            => singleToken("/* 1 /* 2 /* 3 */ 2 /* 3 */ 2 */ 1 /* 2 */ 1 */", multiComment, "Nested multi comment");
    
    test
    shared void emptyMultiComment()
            => singleToken("/**/", multiComment, "Empty multi comment");
    
    test
    shared void comments()
            => multipleTokens("Multiple comments",
        "// Line comment"->lineComment,
        "\n"->whitespace,
        "/*
          * multi
          * comment
          */"->multiComment,
        "// Line comment /* containing multi comment */"->lineComment);
    
    test
    shared void simpleLIdentifier()
            => singleToken("null", lidentifier, "Simple LIdentifier");
    
    test
    shared void prefixedLIdentifier()
            => singleToken("\\inull", lidentifier, "Prefixed LIdentifier");
    
    test
    shared void forcedLIdentifier()
            => singleToken("\\iSOUTH", lidentifier, "Forced LIdentifier");
    
    test
    shared void simpleUIdentifier()
            => singleToken("Object", uidentifier, "Simple UIdentifier");
    
    test
    shared void prefixedUIdentifier()
            => singleToken("\\IObject", uidentifier, "Prefixed UIdentifier");
    
    test
    shared void forcedUIdentifier()
            => singleToken("\\Iklass", uidentifier, "Forced UIdentifier");
    
    test
    shared void identifiers()
            => multipleTokens("Multiple identifiers",
        "Anything"->uidentifier,
        " "->whitespace,
        "a"->lidentifier,
        " "->whitespace,
        "\\iSOUTH"->lidentifier);
    
    test
    shared void simpleStringLiteral()
            => singleToken(""""Hello, World!"""", stringLiteral, "Simple string literal");
    
    test
    shared void stringLiteralWithEscapedQuote()
            => singleToken(""""\"Hello, World!\", said Tom."""", stringLiteral, "String literal with escaped quote");
    
    test
    shared void simpleVerbatimStringLiteral()
            => singleToken("\"\"\"Hello, World!\"\"\"", verbatimStringLiteral, "Simple verbatim string literal");
    
    test
    shared void verbatimStringLiteralWithQuotes()
            => singleToken("\"\"\"\"\"Verbatim string literal _content_ can begin or end with up to two quotes\"\"\"\"\"", verbatimStringLiteral, "Verbatim string literal with quotes");
    
    test
    shared void simpleStringStart()
            => singleToken("\"Hello, \`\`", stringStart, "Simple string start");
    
    test
    shared void simpleStringMid()
            => singleToken("\`\`, and welcome to \`\`", stringMid, "Simple string mid");
    
    test
    shared void simpleStringEnd()
            => singleToken("\`\`!\"", stringEnd, "Simple string end");
    
    test
    shared void stringTemplate()
    /*
     "Hello, ``"You"``, and welcome to ``"""here"""``!"
     */
            => multipleTokens("String template",
        "\"Hello, \`\`"->stringStart,
        "\"You\""->stringLiteral,
        "\`\`, and welcome to \`\`"->stringMid,
        "\"\"\"here\"\"\""->verbatimStringLiteral,
        "\`\`!\""->stringEnd);
    
    test
    shared void simpleCharacterLiteral()
            => singleToken("""'c'""", characterLiteral, "Simple character literal");
    
    test
    shared void characterLiteralWithUnicodeEscape()
            => singleToken("""'\{ELEPHANT}'""", characterLiteral, "Character literal with Unicode escape sequence");
    
    test
    shared void characterLiteralWithQuote()
            => singleToken("""'\''""", characterLiteral, "Character literal with escaped quote");
    
    void singleToken(String input, TokenType expectedType, String? message = null) {
        value lexer = CeylonLexer(StringCharacterStream(input));
        assertEquals {
            actual = lexer.nextToken();
            expected = Token(expectedType, input);
            message = message;
        };
        assertEquals {
            actual = lexer.nextToken();
            expected = null;
            message = "No more tokens expected";
        };
    }
    
    void multipleTokens(String? message, <String->TokenType>+ inputs) {
        value lexer = CeylonLexer(StringCharacterStream("".join(inputs*.key)));
        for (code->type in inputs) {
            assertEquals {
                actual = lexer.nextToken();
                expected = Token(type, code);
                message = message;
            };
        }
        assertEquals {
            actual = lexer.nextToken();
            expected = null;
            message = "No more tokens expected";
        };
    }
}