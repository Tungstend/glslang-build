git clone https://github.com/KhronosGroup/SPIRV-Cross.git
git clone https://github.com/KhronosGroup/glslang.git

chmod -R 777 SPIRV-Cross
chmod -R 777 glslang

wget https://dl.google.com/android/repository/android-ndk-r27b-linux.zip
unzip -q android-ndk-r27b-linux.zip
export ANDROID_NDK_HOME=$PWD/android-ndk-r27b
STRIP_PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"

cd SPIRV-Cross
cmake -B $PWD/build -G "Unix Makefiles" \
-DCMAKE_INSTALL_PREFIX="$PWD/install/$ABI" \
-DANDROID_ABI=$ABI \
-DCMAKE_BUILD_TYPE=Release \
-DANDROID_STL=c++_static \
-DANDROID_PLATFORM=android-21 \
-DCMAKE_SYSTEM_NAME=Android \
-DANDROID_TOOLCHAIN=clang \
-DANDROID_ARM_MODE=arm \
-DCMAKE_MAKE_PROGRAM=$ANDROID_NDK_HOME/prebuilt/linux-x86_64/bin/make \
-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
-DSPIRV_CROSS_SHARED=ON \
-DSPIRV_CROSS_CLI=OFF

cd build
make -j4 install

cd ../install/$ABI/lib
find . -type f \( -name "*.a" -o -name "*.so" \) -exec "$STRIP_PATH" {} \;

cd ../../../..

cd glslang
./update_glslang_sources.py

cmake -B $PWD/build -G "Unix Makefiles" \
-DCMAKE_INSTALL_PREFIX="$PWD/install/$ABI" \
-DANDROID_ABI=$ABI \
-DCMAKE_BUILD_TYPE=Release \
-DANDROID_STL=c++_static \
-DANDROID_PLATFORM=android-21 \
-DCMAKE_SYSTEM_NAME=Android \
-DANDROID_TOOLCHAIN=clang \
-DANDROID_ARM_MODE=arm \
-DCMAKE_MAKE_PROGRAM=$ANDROID_NDK_HOME/prebuilt/linux-x86_64/bin/make \
-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake

cd build
make -j4 install

cd ../install/$ABI/lib
find . -type f \( -name "*.a" -o -name "*.so" \) -exec "$STRIP_PATH" --strip-unneeded {} \;
