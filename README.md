# SFML + ImGUI C++ MacOS Template

## Prerequisites

1) Git
2) VSCode
3) Homebrew
4) Make
5) clang-format

## Setup

Install SFML :

```bash
brew install sfml
```

Get path installation :

```bash
brew info sfml
```

Edit Makefile and change SFML_PATH and change .vscode/c_cpp_properties.json and change the includePath.

Build with Cmd+Shift+B

Run with Fn+F5

## clang-format

Installation :

```bash
brew install clang-format
```

And run this command in the root directory of this projet :

```bash
clang-format -style=llvm -dump-config > .clang-format
```

## Install ImGUI

Get *.h and *.cpp (except imgui_demo.cpp) from this repo : https://github.com/SFML/imgui-sfml (branch 2.6.x) and copy to src/imgui folder.

Get *.h and *.cpp from this repo : https://github.com/SFML/imgui-sfml (branch 2.6.x) and copy to src/imgui folder.

Add `#include "imconfig-SFML.h"` after pragma preprocessing in `imconfig.h` file.

## Makefile inspiration

Cf. [Ultimate Makefile](https://medium.com/@caglayandokme/the-ultimate-makefile-for-c-projects-part-1-applications-76709d8ceda9)
