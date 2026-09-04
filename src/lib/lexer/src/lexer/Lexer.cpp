#include "lexer/Lexer.h"

namespace aondor::lexer
{
    Lexer::Lexer(std::string_view source)
        : _source(source)
    {
    }

    std::vector<Token> Lexer::Tokenize()
    {
        std::vector<Token> tokens;

        while (!IsAtEnd())
        {
            SkipWhiteSpace();

            if (IsAtEnd())
            {
                break;
            }

            const char c = Current();

            if (std::isdigit(static_cast<unsigned char>(c)))
            {
                tokens.push_back(LexNumber());
                continue;
            }

            switch (c)
            {
            case '+':
                tokens.push_back(MakeToken(TokenType::Plus));
                Advance();
                break;
            case '-':
                tokens.push_back(MakeToken(TokenType::Minus));
                Advance();
                break;
            case '*':
                tokens.push_back(MakeToken(TokenType::Star));
                Advance();
                break;
            case '(':
                tokens.push_back(MakeToken(TokenType::LeftParen));
                Advance();
                break;
            case ')':
                tokens.push_back(MakeToken(TokenType::RightParen));
                Advance();
                break;
            case '/':
                {
                    if (Peek() == '/')
                    {
                        SkipSingleLineComment();
                    }
                    else if (Peek() == '*')
                    {
                        SkipMultiLineComment();
                    }
                    else
                    {
                        tokens.push_back(MakeToken(TokenType::Slash));
                        Advance();
                    }

                    break;
                }
            default:
                {
                    throw std::runtime_error(
                        "Invalid character '" +
                        std::string(1, c) +
                        "' at line " +
                        std::to_string(_line) +
                        ", column " +
                        std::to_string(_column)
                    );
                }
            }
        }

        tokens.push_back(
            Token{
                .type = TokenType::EndOfFile,
                .lexeme = "",
                .location = SourceLocation{
                    .line = _line,
                    .column = _column
                }
            }
        );

        return tokens;
    }

    char Lexer::Current() const
    {
        return _source[_position];
    }

    char Lexer::Peek() const
    {
        if (_position + 1 >= _source.size())
        {
            return '\0';
        }

        return _source[_position + 1];
    }

    bool Lexer::IsAtEnd() const
    {
        return _position >= _source.size();
    }

    void Lexer::Advance()
    {
        if (IsAtEnd())
        {
            return;
        }

        if (_source[_position] == '\n')
        {
            ++_line;
            _column = 1;
        }
        else
        {
            ++_column;
        }

        ++_position;
    }

    void Lexer::SkipWhiteSpace()
    {
        while (!IsAtEnd())
        {
            char c = Current();

            if (c == ' ' ||
                c == '\t' ||
                c == '\n' ||
                c == '\r')
            {
                Advance();
                continue;
            }

            break;
        }
    }

    void Lexer::SkipSingleLineComment()
    {
        Advance();
        Advance();

        while (!IsAtEnd() && Current() != '\n')
        {
            Advance();
        }
    }

    void Lexer::SkipMultiLineComment()
    {
        Advance();
        Advance();

        while (!IsAtEnd())
        {
            if (Current() == '*' && Peek() == '/')
            {
                Advance();
                Advance();
                return;
            }

            Advance();
        }

        throw std::runtime_error("Unterminate multi-line comment.");
    }

    Token Lexer::LexNumber()
    {
        const auto startLine = _line;
        const auto startColumn = _column;
        const auto start = _position;

        while (!IsAtEnd() && std::isdigit(Current()))
        {
            Advance();
        }

        bool isDecimal = false;

        if (!IsAtEnd() &&
            Current() == '.' &&
            std::isdigit(Peek()))
        {
            isDecimal = true;

            Advance();

            while (!IsAtEnd() && std::isdigit(Current()))
            {
                Advance();
            }
        }

        return Token{
            .type = isDecimal
                        ? TokenType::DecimalLiteral
                        : TokenType::IntegerLiteral,
            .lexeme = std::string(_source.substr(start, _position - start)),
            .location = SourceLocation{
                startLine,
                startColumn
            }
        };
    }

    Token Lexer::MakeToken(TokenType type) const
    {
        const SourceLocation location{
            .line = _line,
            .column = _column
        };

        return Token{
            .type = type,
            .lexeme = std::string(1, Current()),
            .location = location
        };
    }
}
