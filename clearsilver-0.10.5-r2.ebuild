# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Please note: apache, java and mono support disabled for now.
# Fill a bug if you need it.
#
# dju@gentoo.org, 4th July 2005
# anthony@durity.com, 16th October 2011
#
# http://devmanual.gentoo.org/ebuild-writing/index.html
#

inherit eutils perl-app multilib autotools

DESCRIPTION="Clearsilver is a fast, powerful, and language-neutral HTML template system."
HOMEPAGE="http://www.clearsilver.net/"
SRC_URI="http://www.clearsilver.net/downloads/${P}.tar.gz"

LICENSE="CS-1.0"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 ~sparc x86 ~x86-fbsd"
IUSE="gettext ruby perl python zlib"

DEPEND="gettext? ( sys-devel/gettext )
	ruby? ( dev-lang/ruby )
	python? ( dev-lang/python )
	perl? ( dev-lang/perl )
	zlib? ( sys-libs/zlib )"

DOCS="README INSTALL"

if use python ; then
	DOCS="${DOCS} README.python"
fi

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-perl_installdir.patch
	use zlib && epatch "${FILESDIR}"/${P}-libz.patch
	epatch "${FILESDIR}"/${P}-libdir.patch
	epatch "${FILESDIR}"/${P}-ruby_install.rb.patch
	epatch "${FILESDIR}"/${P}-ruby_neo.rb.patch
	epatch "${FILESDIR}"/${P}-ruby_neo_cs.c.patch
	epatch "${FILESDIR}"/${P}-ruby_neo_util.c.patch
	sed -i -e "s:GENTOO_LIBDIR:$(get_libdir):" configure.in
	eautoreconf || die "eautoreconf failed"

	# Fix for Gentoo/Freebsd
	[[ "${ARCH}" == FreeBSD ]] && touch ${S}/features.h ${S}/cgi/features.h
}

src_compile() {
	econf \
		$(use_enable gettext) \
		$(use_enable ruby) \
		$(use_enable perl) \
		$(use_with perl perl /usr/bin/perl) \
		$(use_enable python) \
		$(use_with python python /usr/bin/python) \
		$(use_enable zlib compression) \
		"--disable-apache" \
		"--disable-java" \
		"--disable-csharp" \
		|| die "./configure failed"

	emake || die "emake failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc ${DOCS} || die "dodoc failed"

	if use perl ; then
		fixlocalpod || die "fixlocalpod failed"
	fi
}
