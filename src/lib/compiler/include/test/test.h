#ifndef MYPROJECT_TEST_H
#define MYPROJECT_TEST_H

#include <iostream>

namespace Sample::Test
{
    class Test
    {
    public:
        Test() = default;
        ~Test() = default;

        static void Print();
    };
}

#endif //MYPROJECT_TEST_H