#ifndef COMPILERTEST_TOKENTYPE_H
#define COMPILERTEST_TOKENTYPE_H

namespace aondor::lexer
{
    enum class TokenType
    {
        IntegerLiteral,
        DecimalLiteral,

        Plus,
        Minus,
        Star,
        Slash,

        LeftParen,
        RightParen,

        EndOfFile,

        Invalid
    };
}

#endif //COMPILERTEST_TOKENTYPE_H