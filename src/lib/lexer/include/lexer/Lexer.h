#ifndef COMPILERTEST_LEXER_H
#define COMPILERTEST_LEXER_H

#include <string_view>
#include <vector>
#include <stdexcept>

#include "Token.h"

namespace aondor::lexer
{
    class Lexer
    {
    public:
        explicit Lexer(std::string_view source);

        std::vector<Token> Tokenize();

    private:
        std::string_view _source;
        std::size_t _position{0};

        std::size_t _line{1};
        std::size_t _column{1};

        [[nodiscard]] char Current() const;

        [[nodiscard]] char Peek() const;

        [[nodiscard]] bool IsAtEnd() const;

        void Advance();

        void SkipWhiteSpace();

        void SkipSingleLineComment();

        void SkipMultiLineComment();

        [[nodiscard]] Token LexNumber();

        [[nodiscard]] Token MakeToken(TokenType type) const;
    };
}

#endif //COMPILERTEST_LEXER_H