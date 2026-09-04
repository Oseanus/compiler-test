#ifndef COMPILERTEST_LEXER_H
#define COMPILERTEST_LEXER_H

#include <string_view>
#include <vector>
#include <stdexcept>

#include "Token.h"

namespace aondor::lexer
{
    /**
     * @brief Lexical analyzer for the AonDor source code.
     *
     * Fragments the input text into a sequence of tokens, for a parser
     * to work with.
     */
    class Lexer
    {
    public:
        /**
         * @brief Creates a @c Lexer object for the input source code.
         * @param source A @c string_view that is the source code.
         */
        explicit Lexer(std::string_view source);

        /**
         * @brief Conducts the lexical analysis.
         *
         * Reads the whole source code and fragments it to a sequence of tokens.
         *
         * @return A list all recognized tokens.
         */
        std::vector<Token> Tokenize();

    private:
        /// The source code to be analyzed.
        std::string_view _source;

        /// The current position in the source code, starting with 0.
        std::size_t _position{0};

        /// The current line number, starting with 1.
        std::size_t _line{1};

        /// The current column number, starting with 1.
        std::size_t _column{1};

        /**
         * @brief Returns the current character.
         *
         * @return The character behind the current position.
         */
        [[nodiscard]] char Current() const;

        [[nodiscard]] char Peek() const;

        /**
         * @brief Checks if the end of the source code is reached.
         *
         * @return true, if the end is reached.
         */
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