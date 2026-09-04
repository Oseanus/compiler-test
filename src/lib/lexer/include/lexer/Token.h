#ifndef COMPILERTEST_TOKEN_H
#define COMPILERTEST_TOKEN_H

#include <string>

#include "TokenType.h"
#include "SourceLocation.h"

namespace aondor::lexer
{
    struct Token
    {
        TokenType type;
        std::string lexeme;
        SourceLocation location;
    };
}

#endif //COMPILERTEST_TOKEN_H