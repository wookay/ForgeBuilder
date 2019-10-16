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
cat <<EOF > CMakeLists.txt.patch
--- forge-1.0.4-original/CMakeLists.txt	2019-10-16 17:52:20.000000000 +0900
+++ forge-1.0.4/CMakeLists.txt	2019-10-16 17:49:43.000000000 +0900
@@ -179,3 +179,13 @@
     pkgcfg_lib_FontConfigPkg_freetype
     pkgcfg_lib_FontConfigPkg_fontconfig
 )
+
+EXTERNALPROJECT_ADD(
+  freetype
+  # URL http://download.savannah.gnu.org/releases/freetype/freetype-2.7.1.tar.gz
+  URL \\\${CMAKE_SOURCE_DIR}/vendor/freetype-2.7.1.tar.gz
+  PATCH_COMMAND \\\${CMAKE_SOURCE_DIR}/patches/patch-manager.sh freetype
+  CONFIGURE_COMMAND ./configure --prefix=\\\${CMAKE_BINARY_DIR} --disable-shared --enable-static --without-png
+  INSTALL_COMMAND make install && ln -s \\\${CMAKE_BINARY_DIR}/include/freetype2 \\\${CMAKE_BINARY_DIR}/include/freetype2/freetype
+  BUILD_IN_SOURCE 1
+)
EOF
patch -p1 -i CMakeLists.txt.patch
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=\$prefix -DBUILD_EXAMPLES_CUDA=OFF -DBUILD_EXAMPLES_OPENCL=OFF ..
make
make install
rm -rf \$WORKSPACE/destdir/bin/{g,h,k}* \$WORKSPACE/destdir/lib/cmake \$WORKSPACE/destdir/logs
ls \$WORKSPACE/destdir/lib
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    MacOS(:x86_64)
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
