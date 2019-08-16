# LLVM
Set up a modern C++ toolchain on Ubuntu 18.04.

## Toolchain
Uninstall old toolchain.

```sh
sudo update-alternatives --remove-all cc
sudo update-alternatives --remove-all c++
sudo rm -f /etc/ld.so.conf.d/llvm.conf
sudo rm -f /etc/ld.so.conf.d/tbb.conf
sudo ldconfig
rm -rf /opt/llvm
```

Install new toolchain.

```sh
rm -rf /opt/llvm; mkdir /opt/llvm
wget https://prereleases.llvm.org/9.0.0/rc1/clang+llvm-9.0.0-rc1-x86_64-linux-gnu-ubuntu-18.04.tar.xz
tar xf clang+llvm-9.0.0-rc1-x86_64-linux-gnu-ubuntu-18.04.tar.xz -C /opt/llvm --strip-components 1
sudo update-alternatives --install /usr/bin/cc cc /opt/llvm/bin/clang 100
sudo update-alternatives --install /usr/bin/c++ c++ /opt/llvm/bin/clang++ 100

sudo tee /etc/ld.so.conf.d/llvm.conf <<'EOF'
/opt/llvm/lib
/opt/llvm/lib/clang/9.0.0/lib/linux
EOF

sudo ldconfig
```

## TBB
Check out source code.

```sh
git clone -b tbb_2019 --depth 1 https://github.com/01org/tbb tbb
```

Apply this patch if you want to remove the version number suffix from libraries.

```diff
diff --git i/build/Makefile.tbb w/build/Makefile.tbb
index 63ee6eb..ea965cf 100644
--- i/build/Makefile.tbb
+++ w/build/Makefile.tbb
@@ -102,10 +102,6 @@ $(TBB.DLL): BUILDING_LIBRARY = $(TBB.DLL)
 $(TBB.DLL): $(TBB.OBJ) $(TBB.RES) tbbvars.sh $(TBB_NO_VERSION.DLL)
        $(LIB_LINK_CMD) $(LIB_OUTPUT_KEY)$(TBB.DLL) $(TBB.OBJ) $(TBB.RES) $(LIB_LINK_LIBS) $(LIB_LINK_FLAGS)
 
-ifneq (,$(TBB_NO_VERSION.DLL))
-$(TBB_NO_VERSION.DLL):
-       echo "INPUT ($(TBB.DLL))" > $(TBB_NO_VERSION.DLL)
-endif
 
 #clean:
 #      $(RM) *.$(OBJ) *.$(DLL) *.res *.map *.ilk *.pdb *.exp *.manifest *.tmp *.d core core.*[0-9][0-9] *.ver
diff --git i/build/Makefile.tbbmalloc w/build/Makefile.tbbmalloc
index 421e95c..5037bfa 100644
--- i/build/Makefile.tbbmalloc
+++ w/build/Makefile.tbbmalloc
@@ -98,15 +98,6 @@ $(MALLOCPROXY.DLL): $(PROXY.OBJ) $(MALLOCPROXY_NO_VERSION.DLL) $(MALLOC.DLL) $(M
        $(LIB_LINK_CMD) $(LIB_OUTPUT_KEY)$(MALLOCPROXY.DLL) $(PROXY.OBJ) $(MALLOC.RES) $(LIB_LINK_LIBS) $(LINK_MALLOC.LIB) $(PROXY_LINK_FLAGS)
 endif
 
-ifneq (,$(MALLOC_NO_VERSION.DLL))
-$(MALLOC_NO_VERSION.DLL):
-       echo "INPUT ($(MALLOC.DLL))" > $(MALLOC_NO_VERSION.DLL)
-endif
-
-ifneq (,$(MALLOCPROXY_NO_VERSION.DLL))
-$(MALLOCPROXY_NO_VERSION.DLL):
-       echo "INPUT ($(MALLOCPROXY.DLL))" > $(MALLOCPROXY_NO_VERSION.DLL)
-endif
 
 malloc: $(MALLOC.DLL) $(MALLOCPROXY.DLL)

diff --git i/build/linux.inc w/build/linux.inc
index 4d59aaa..e94f18d 100644
--- i/build/linux.inc
+++ w/build/linux.inc
@@ -111,20 +111,20 @@ endif
 TBB.LST = $(tbb_root)/src/tbb/$(def_prefix)-tbb-export.lst
 TBB.DEF = $(TBB.LST:.lst=.def)
 
-TBB.DLL = $(TBB_NO_VERSION.DLL).$(SONAME_SUFFIX)
+TBB.DLL = $(TBB_NO_VERSION.DLL)
 TBB.LIB = $(TBB.DLL)
 TBB_NO_VERSION.DLL=libtbb$(CPF_SUFFIX)$(DEBUG_SUFFIX).$(DLL)
 LINK_TBB.LIB = $(TBB_NO_VERSION.DLL)
 
 MALLOC_NO_VERSION.DLL = libtbbmalloc$(DEBUG_SUFFIX).$(MALLOC_DLL)
 MALLOC.DEF = $(MALLOC_ROOT)/$(def_prefix)-tbbmalloc-export.def
-MALLOC.DLL = $(MALLOC_NO_VERSION.DLL).$(SONAME_SUFFIX)
+MALLOC.DLL = $(MALLOC_NO_VERSION.DLL)
 MALLOC.LIB = $(MALLOC_NO_VERSION.DLL)
 LINK_MALLOC.LIB = $(MALLOC_NO_VERSION.DLL)
 
 MALLOCPROXY_NO_VERSION.DLL = libtbbmalloc_proxy$(DEBUG_SUFFIX).$(DLL)
 MALLOCPROXY.DEF = $(MALLOC_ROOT)/$(def_prefix)-proxy-export.def
-MALLOCPROXY.DLL = $(MALLOCPROXY_NO_VERSION.DLL).$(SONAME_SUFFIX)
+MALLOCPROXY.DLL = $(MALLOCPROXY_NO_VERSION.DLL)
 MALLOCPROXY.LIB = $(MALLOCPROXY_NO_VERSION.DLL)
 LINK_MALLOCPROXY.LIB = $(MALLOCPROXY.LIB)
 
```

Install TBB.

```sh
pushd tbb
rm -rf build/*_release
AR="llvm-ar" RANLIB="llvm-ranlib" CC="clang" CXX="clang++" LDFLAGS="-fuse-ld=ld -Wl,-S" \
make compiler=clang arch=intel64 stdver=c++17 cfg=release
cp -R build/*_release/libtbb*.so* /opt/llvm/lib/
cp -R include/tbb /opt/llvm/include/c++/v1/
chmod 0644 /opt/llvm/lib/libtbb*.so*
popd
```

## Parallel STL
Install Parallel STL headers.

```sh
git clone --depth 1 https://git.llvm.org/git/pstl
cp -R pstl/include/pstl /opt/llvm/include/c++/v1/
cp -R pstl/test/support/stdlib /opt/llvm/include/c++/v1/pstl/

tee /opt/llvm/include/c++/v1/pstl/stdlib/__pstl_config_site <<'EOF'
#pragma once
#define _PSTL_PAR_BACKEND_TBB 1
EOF

sudo tee /etc/ld.so.conf.d/ldd.conf <<'EOF'
/opt/llvm/lib
EOF

sudo ldconfig
```
