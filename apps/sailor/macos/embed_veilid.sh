#!/bin/bash
DYLIB_SRC="/Users/orbit/.pub-cache/git/veilid-df7254aea1f0345c57a03cbb905babe87b0e936a/target/lipo-darwin/libveilid_flutter.dylib"
FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "$FRAMEWORKS_DIR"
cp "$DYLIB_SRC" "$FRAMEWORKS_DIR/libveilid_flutter.dylib"
codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" "$FRAMEWORKS_DIR/libveilid_flutter.dylib" 2>/dev/null || codesign --force --sign - "$FRAMEWORKS_DIR/libveilid_flutter.dylib"
