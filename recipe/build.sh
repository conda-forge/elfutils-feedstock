#!/bin/bash

set -exo pipefail

export LIBS="$(pkg-config --libs-only-l zlib) $LIBS"
export LDFLAGS="$(pkg-config --libs-only-L zlib) -lrt $LDFLAGS"
export CFLAGS="$(pkg-config --cflags zlib) -Wno-null-dereference $CFLAGS"
autoreconf -if
./configure --prefix=$PREFIX --with-zlib --enable-libdebuginfod=dummy || (cat config.log && exit 1)
make -j${CPU_COUNT} srcfiles_no_Werror=1

# Unfortunately some tests fail, so we can't run "make check" here.
# This is probably due to this package being a very sensitive package.
# I believe this happens because it is not ready to be packaged into
# an environment such as conda where it will run in different OSes,
# environments, etc.
#
# For example, when running the tests on my personal machine, using
# the docker image provided by condaforge, 8 tests failed, while in
# CircleCI, 4 tests failed.

make install
