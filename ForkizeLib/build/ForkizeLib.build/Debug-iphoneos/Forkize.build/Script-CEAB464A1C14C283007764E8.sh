#!/bin/sh
# define output folder environment variable
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# Step 1. Build Device and Simulator versions
#xcodebuild -target Forkize ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
xcodebuild -target Forkize -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO VALID_ARCHS="i386 x86_64"  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Step 2. Create universal binary file using lipo
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/libForkize.a" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/libForkize.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/libForkize.a"

# Last touch. copy the header files. Just for convenience
#cp "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include/${PRODUCT_NAME}/Forkize.h" "${UNIVERSAL_OUTPUTFOLDER}/"

cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include/Forkize/Forkize.h" "${UNIVERSAL_OUTPUTFOLDER}/"
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include/Forkize/UserProfile.h" "${UNIVERSAL_OUTPUTFOLDER}/"

