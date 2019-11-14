#include <iostream>
int main()
{
  int result = 0;
  for (int i = 0; i < 20; ++i)
    result += i;
  std::cout << "result=" << result << std::endl;
  return 0;
}
