QtProjectTemplate
=================

[![Test status](https://travis-ci.org/koturn/QtProjectTemplate.png)](https://travis-ci.org/koturn/QtProjectTemplate "Travis CI | koturn/QtProjectTemplate")
[![Test status](https://ci.appveyor.com/api/projects/status/2dk4wgtp9nqhof38?svg=true)](https://ci.appveyor.com/project/koturn/qtprojecttemplate "AppVeyor | koturn/QtProjectTemplate")


Template [Qt](https://www.qt.io/ "Qt") project with [CMake](https://cmake.org/ "CMake").


## Build

If your build environment is Windows or Mac OS, please set the `QTDIR` environment variable beforehand.

```shell
$ mkdir build
$ cd build
$ cmake .. -DCMAKE_BUILD_TYPE=Release
$ cmake --build .
```


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE "LICENSE").
