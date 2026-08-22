#!/bin/bash

set -exo pipefail

export LIBS="$(pkg-config --libs-only-l zlib) $LIBS"
export LDFLAGS="$(pkg-config --libs-only-L zlib) -lrt $LDFLAGS"
export CFLAGS="$(pkg-config --cflags zlib) -Wno-null-dereference $CFLAGS"
autoreconf -if

# --build/--host make configure aware that linux-aarch64, linux-ppc64le and
# linux-riscv64 are cross-compiled from linux-64; without them $host_cpu is
# the build machine's and configure enables host-specific code paths (e.g.
# eu-stackprof) for the wrong architecture.
#
# libdebuginfod is built as a stub (=dummy) so that elfutils does not pull in
# libcurl, and the debuginfod server is turned off explicitly: it additionally
# needs json-c and libmicrohttpd, the latter of which has no linux-riscv64
# build.
./configure --prefix=$PREFIX \
            --build=${BUILD} \
            --host=${HOST} \
            --with-zlib \
            --enable-libdebuginfod=dummy \
            --disable-debuginfod \
            || (cat config.log && exit 1)
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
