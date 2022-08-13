# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit readme.gentoo-r1 systemd unpacker pax-utils

COMMIT="738907df3"
_APPNAME="plexmediaserver"
_USERNAME="plex"
_SHORTNAME="${_USERNAME}"
_FULL_VERSION="${PV}-${COMMIT}"

URI="https://downloads.plex.tv/plex-media-server-new"

DESCRIPTION="Free media library that is intended for use with a plex client"
HOMEPAGE="https://www.plex.tv/"
SRC_URI="
	amd64? ( ${URI}/${_FULL_VERSION}/debian/plexmediaserver_${_FULL_VERSION}_amd64.deb )
	x86? ( ${URI}/${_FULL_VERSION}/debian/plexmediaserver_${_FULL_VERSION}_i386.deb )"
S="${WORKDIR}"

LICENSE="Plex"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="mirror bindist"

DEPEND="
	acct-group/plex
	acct-user/plex"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/plexmediaserver.service.amd64.patch" )

QA_DESKTOP_FILE="usr/share/applications/plexmediamanager.desktop"
QA_PREBUILT="*"
QA_MULTILIB_PATHS=(
	"usr/lib/plexmediaserver/lib/.*"
	"usr/lib/plexmediaserver/Resources/Python/lib/python2.7/.*"
	"usr/lib/plexmediaserver/Resources/Python/lib/python2.7/lib-dynload/_hashlib.so"
)

BINS_TO_PAX_MARK=(
	"${ED}/usr/lib/plexmediaserver/Plex Script Host"
	"${ED}/usr/lib/plexmediaserver/Plex Media Scanner"
)

src_install() {
	# Remove Debian specific files
	rm -r "usr/share/doc" || die

	# Copy main files over to image and preserve permissions so it is portable
	cp -rp usr/ "${ED}" || die

	# Make sure the logging directory is created
	keepdir /var/log/pms
	fowners plex:plex /var/log/pms

	# Create default library folder with correct permissions
	keepdir /var/lib/plexmediaserver
	fowners plex:plex /var/lib/plexmediaserver

	# Install the OpenRC init/conf files
	newinitd "${FILESDIR}/${PN}.init.d" ${PN}
	newconfd "${FILESDIR}/${PN}.conf.d" ${PN}

	# Install systemd service file
	systemd_newunit "${ED}"/usr/lib/plexmediaserver/lib/plexmediaserver.service "${PN}.service"

	# Add pax markings to some binaries so that they work on hardened setup
	for f in "${BINS_TO_PAX_MARK[@]}"; do
		pax-mark m "${f}"
	done

	# Adds the precompiled plex libraries to the revdep-rebuild's mask list
	# so it doesn't try to rebuild libraries that can't be rebuilt.
	insinto /etc/revdep-rebuild
	doins "${FILESDIR}"/80plexmediaserver

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
