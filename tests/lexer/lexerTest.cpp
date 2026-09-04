#include <gtest/gtest.h>

#include "lexer/Lexer.h"
#include "lexer/TokenType.h"

namespace aondor::lexer::test
{
    // Helper function
    static std::vector<Token> Tokenize(std::string_view source)
    {
        Lexer lexer(source);
        return lexer.Tokenize();
    }

    TEST(LexerTests, RecognizesIntegerLiteral)
    {
        const auto tokens = Tokenize("123");

        ASSERT_EQ(tokens.size(), 2);

        EXPECT_EQ(tokens[0].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[0].lexeme, "123");

        // EXPECT_EQ(tokens[1].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, RecognizesDecimalLiteral)
    {
        const auto tokens = Tokenize("3.14");

        ASSERT_EQ(tokens.size(), 2);

        EXPECT_EQ(tokens[0].type, TokenType::DecimalLiteral);
        EXPECT_EQ(tokens[0].lexeme, "3.14");

        EXPECT_EQ(tokens[1].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, RecognizesPlusOperator)
    {
        const auto tokens = Tokenize("1+2");

        ASSERT_EQ(tokens.size(), 4);

        EXPECT_EQ(tokens[0].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[1].type, TokenType::Plus);
        EXPECT_EQ(tokens[2].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[3].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, RecognizesArithmeticOperators)
    {
        const auto tokens = Tokenize("+ - * /");

        ASSERT_EQ(tokens.size(), 5);

        EXPECT_EQ(tokens[0].type, TokenType::Plus);
        EXPECT_EQ(tokens[1].type, TokenType::Minus);
        EXPECT_EQ(tokens[2].type, TokenType::Star);
        EXPECT_EQ(tokens[3].type, TokenType::Slash);
        EXPECT_EQ(tokens[4].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, RecognizesParentheses)
    {
        const auto tokens = Tokenize("(1)");

        ASSERT_EQ(tokens.size(), 4);

        EXPECT_EQ(tokens[0].type, TokenType::LeftParen);
        EXPECT_EQ(tokens[1].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[2].type, TokenType::RightParen);
        EXPECT_EQ(tokens[3].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, IgnoresWhitespace)
    {
        const auto tokens = Tokenize(" 1 \t + \n 2 ");

        ASSERT_EQ(tokens.size(), 4);

        EXPECT_EQ(tokens[0].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[1].type, TokenType::Plus);
        EXPECT_EQ(tokens[2].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[3].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, IgnoresSingleLineComment)
    {
        const auto tokens = Tokenize(
                "5 // Comment\n"
                "6"
            );

        ASSERT_EQ(tokens.size(), 3);

        EXPECT_EQ(tokens[0].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[0].lexeme, "5");

        EXPECT_EQ(tokens[1].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[1].lexeme, "6");

        EXPECT_EQ(tokens[2].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, IgnoresMultiLineComment)
    {
        const auto tokens = Tokenize(
            "5\n"
            "/* Comment */"
            "6"
        );

        ASSERT_EQ(tokens.size(), 3);

        EXPECT_EQ(tokens[0].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[1].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[2].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, TokenizesComplexExpression)
    {
        const auto tokens = Tokenize("(1 + 2) * 3.5");

        ASSERT_EQ(tokens.size(), 8);

        EXPECT_EQ(tokens[0].type, TokenType::LeftParen);
        EXPECT_EQ(tokens[1].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[2].type, TokenType::Plus);
        EXPECT_EQ(tokens[3].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[4].type, TokenType::RightParen);
        EXPECT_EQ(tokens[5].type, TokenType::Star);
        EXPECT_EQ(tokens[6].type, TokenType::DecimalLiteral);
        EXPECT_EQ(tokens[7].type, TokenType::EndOfFile);
    }

    TEST(LexerTests, StoresCorrectSourceLocation)
    {
        const auto tokens = Tokenize(
            "\n"
            "\n"
            "123"
        );

        ASSERT_GE(tokens.size(), 1);

        EXPECT_EQ(tokens[0].location.line, 3u);
        EXPECT_EQ(tokens[0].location.column, 1u);
    }

    TEST(LexerTests, ThrowsForInvalidCharacter)
    {
        EXPECT_THROW(
            Tokenize("1 + @"),
            std::runtime_error
        );
    }

    TEST(LexerTests, SpecificationExample)
    {
        const auto tokens = Tokenize(
            "// Monthly revenue\n"
            "1000 + 250"
        );

        ASSERT_EQ(tokens.size(), 4);

        EXPECT_EQ(tokens[0].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[0].lexeme, "1000");

        EXPECT_EQ(tokens[1].type, TokenType::Plus);

        EXPECT_EQ(tokens[2].type, TokenType::IntegerLiteral);
        EXPECT_EQ(tokens[2].lexeme, "250");

        EXPECT_EQ(tokens[3].type, TokenType::EndOfFile);
    }
}