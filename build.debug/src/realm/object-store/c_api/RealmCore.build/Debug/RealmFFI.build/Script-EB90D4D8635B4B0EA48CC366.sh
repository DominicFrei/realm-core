#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api
  /usr/local/Cellar/cmake/3.19.1/bin/cmake -E cmake_symlink_library /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/Debug/librealm-ffi-dbg.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/Debug/librealm-ffi-dbg.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/Debug/librealm-ffi-dbg.dylib
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api
  /usr/local/Cellar/cmake/3.19.1/bin/cmake -E cmake_symlink_library /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/Release/librealm-ffi.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/Release/librealm-ffi.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/Release/librealm-ffi.dylib
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api
  /usr/local/Cellar/cmake/3.19.1/bin/cmake -E cmake_symlink_library /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/MinSizeRel/librealm-ffi.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/MinSizeRel/librealm-ffi.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/MinSizeRel/librealm-ffi.dylib
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api
  /usr/local/Cellar/cmake/3.19.1/bin/cmake -E cmake_symlink_library /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/RelWithDebInfo/librealm-ffi.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/RelWithDebInfo/librealm-ffi.dylib /Users/dominic.frei/Repositories/RealmBootcamp/build.debug/src/realm/object-store/c_api/RelWithDebInfo/librealm-ffi.dylib
fi

