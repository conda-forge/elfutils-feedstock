#!/bin/bash
export LIBS="$(pkg-config --libs-only-l zlib) $LIBS"
export LDFLAGS="$(pkg-config --libs-only-L zlib) -lrt $LDFLAGS"
# tests introspect debug information in some of the binaries built.  Build with -g and strip at install
export CFLAGS="$(pkg-config --cflags zlib) -Wno-unused-but-set-variable -Wno-unused-variable -Wno-null-dereference $CFLAGS -g"
# tests don't work with NDEBUG
export CPPFLAGS="${CPPFLAGS/-DNDEBUG/}"
autoreconf --install --force
mkdir build && cd build
../configure --prefix=$PREFIX --mandir=$PREFIX/man --enable-test-rpath --with-zlib --enable-libdebuginfod=dummy || (cat config.log && exit 1)
make -j${CPU_COUNT}

make check -j${CPU_COUNT} || (cat tests/test-suite.log && exit 1)

make install-strip
