# Contributor: Carlo Landmeter <clandmeter@gmail.com>
# Contributor: blattersturm <peachypies@protonmail.ch>
# Maintainer:
pkgname=mono
pkgver=5.12.0.226
pkgrel=0
pkgdesc="Free implementation of the .NET platform including runtime and compiler"
url="http://www.mono-project.com/"
arch="x86_64 x86"
license="GPL"
depends_dev="zlib-dev libgdiplus-dev"
makedepends="$depends_dev python2 linux-headers paxmark autoconf automake libtool cmake"
subpackages="$pkgname-dev $pkgname-doc $pkgname-lang"
source="http://download.mono-project.com/sources/mono/mono-${pkgver/_/~}.tar.bz2"
builddir="$srcdir/$pkgname-$pkgver"

prepare() {
	default_prepare
	cd "$builddir"

	# Remove hardcoded lib directory from the config.
	sed -i 's|$mono_libdir/||g' data/config.in

	# We need to do this so it don't get killed in the build proces when
	# MPROTECT and RANDMMAP is enable.
	sed -i '/exec "/ i\paxmark mr "$(readlink -f "$MONO_EXECUTABLE")"' \
		runtime/mono-wrapper.in
}

build() {
	cd "$builddir"

	# Based on Fedora and SUSE package.
	export CFLAGS="$CFLAGS -fno-strict-aliasing"

	# Set the minimum arch for x86 to prevent atomic linker errors.
	[ "$CARCH" = "x86" ] && export CFLAGS="$CFLAGS -march=i586 -mtune=generic"

	# Run autogen to fix supplied configure linker issues with make install.
	./autogen.sh \
		--build=$CBUILD \
		--host=$CHOST \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--localstatedir=/var \
		--enable-parallel-mark \
		--enable-minimal=attach,debug,profiler,simd,ssa,perfcounters,desktop_loader,shared_perfcounters,remoting \
		--disable-rpath \
		--disable-boehm \
		--with-x=no \
		--with-libgc=none \
		--with-mcs-docs=no \
		--with-sigaltstack=no \
		--with-ikvm-native=no \
		--with-profile2=no \
		--with-profile3=no \
		--with-profile4=no \
		--with-profile4_x=yes \

	make -j$(nproc)
}

package() {
	cd "$builddir"

	make -j1 DESTDIR="$pkgdir" install
	paxmark mr "$pkgdir"/usr/bin/mono-sgen

	cd "$pkgdir"

	# Remove .la files.
	rm ./usr/lib/*.la

	# Remove Windows-only stuff.
	rm -r ./usr/lib/mono/*/Mono.Security.Win32*
	rm ./usr/lib/libMonoSupportW.*
}

sha512sums="f4ab3066c9a3545ace0c4af50ddbe58cf5d9ffe4895cc546669f329b91988fcfebab91a070ea46b27536040823a3bbc1bd7e5552a49769988e8271d52662c583  mono-5.12.0.226.tar.bz2"

