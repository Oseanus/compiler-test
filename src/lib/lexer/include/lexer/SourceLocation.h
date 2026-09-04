#ifndef COMPILERTEST_SOURCELOCATION_H
#define COMPILERTEST_SOURCELOCATION_H

#include <cstddef>

namespace aondor::lexer
{
    struct SourceLocation
    {
        size_t line{1};
        size_t column{1};
    };
}

#endif //COMPILERTEST_SOURCELOCATION_H