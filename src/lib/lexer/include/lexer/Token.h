#ifndef COMPILERTEST_TOKEN_H
#define COMPILERTEST_TOKEN_H

#include <string>

#include "TokenType.h"
#include "SourceLocation.h"

namespace aondor::lexer
{
    /**
     * Represents a token recognized by the lexer.
     */
    struct Token
    {
        /**
         * Type of the token (e.g. identifier, keyword, operator).
         */
        TokenType type;

        /**
         * Original text from the source code.
         */
        std::string lexeme;

        /**
         * Position of the token in the source code.
         */
        SourceLocation location;
    };
}

#endif //COMPILERTEST_TOKEN_H