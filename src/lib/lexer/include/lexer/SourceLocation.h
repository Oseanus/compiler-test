#ifndef COMPILERTEST_SOURCELOCATION_H
#define COMPILERTEST_SOURCELOCATION_H

#include <cstddef>

namespace aondor::lexer
{
    /**
     * Defines the location of a token in the source code.
     */
    struct SourceLocation
    {
        size_t line{1};
        size_t column{1};
    };
}

#endif //COMPILERTEST_SOURCELOCATION_H