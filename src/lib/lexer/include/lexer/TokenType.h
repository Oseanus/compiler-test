#ifndef COMPILERTEST_TOKENTYPE_H
#define COMPILERTEST_TOKENTYPE_H

namespace aondor::lexer
{
    /**
     * An enum that defines the types of tokens for the lexer.
     */
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