# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.

using BinaryBuilder
name = "Forge"
version = v"1.0.4"

sources = [
    "https://github.com/arrayfire/forge/archive/v$(version).tar.gz" => "d878b2d5a73fbd10b2f9c6b4f61d6c4417c58756798115a39792756ea4fa0f83",
]

script = """
cd \$WORKSPACE/srcdir/forge-$version/
mkdir build
cd build
cmake ..
make
make install
rm -rf \$WORKSPACE/destdir/bin/{g,h,k}* \$WORKSPACE/destdir/lib/cmake \$WORKSPACE/destdir/logs
ls \$WORKSPACE/destdir/lib
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    "x86_64-apple-darwin14"
]
#platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libforge", :libforge),
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
