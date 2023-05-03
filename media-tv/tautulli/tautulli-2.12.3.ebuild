# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10,11} )
PYTHON_REQ_USE='sqlite(+)'

inherit python-single-r1 systemd

DESCRIPTION="A python based web application for monitoring your Plex Media Server."
HOMEPAGE="https://tautulli.com"
MY_PV="${PV/_beta/-beta}"
MY_PN="Tautulli"
MY_P="${MY_PN}-${MY_PV}"
SRC_URI="https://github.com/${MY_PN}/${MY_PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="bindist mirror strip test"

DEPEND="
	${PYTHON_DEPS}
"

RDEPEND="
	acct-user/tautulli
	acct-group/tautulli
	media-tv/plex-media-server
	dev-python/pyopenssl
	${DEPEND}
"

S="${WORKDIR}/${MY_P}"

src_install() {
	dodoc API.md CHANGELOG.md CONTRIBUTING.md README.md
	newinitd "${FILESDIR}/${PN}.init" ${PN}
	newconfd "${FILESDIR}/${PN}.conf" ${PN}

	keepdir /var/lib/${PN}
	insinto "/var/lib/${PN}"
	doins -r contrib data lib plexpy pylintrc PlexPy.py Tautulli.py || die
	fowners -R ${PN}:${PN} /var/lib/${PN}

	insinto /etc/${PN}
	fowners -R ${PN}:${PN} /etc/${PN}
	dodir "/etc/${PN}"
	dosym "${EPREFIX}/var/lib/${PN}/config.ini" "/etc/${PN}/config.ini"

	systemd_dounit  "${FILESDIR}/${PN}.service"
	systemd_newunit "${FILESDIR}/${PN}.service" "${PN}@.service"
}

pkg_postinst() {
	elog "Tautulli is now installed but requires the config.ini file"
	elog "be generated in /etc/${_SHORTNAME}/${_APPNAME}"
	elog "To create the initial config.ini interactively run"
	elog "python /var/lib/${PN}/Tautulli.py then ctrl+c"
	elog "before starting the system service"
	elog "you will then be able to access tautulli at"
	elog "http://<ip>:8181/"
}

# Adds the precompiled tautulli libraries to the revdep-rebuild's mask list
# so it doesn't try to rebuild libraries that can't be rebuilt.
_mask_tautulli_libraries_revdep() {
	dodir /etc/revdep-rebuild/

	# Bug: 659702. The upstream plex binary installs its precompiled package to /usr/lib.
	# Due to profile 17.1 splitting /usr/lib and /usr/lib64, we can no longer rely
	# on the implicit symlink automatically satisfying our revdep requirement when we use $(get_libdir).
	# Thus we will match upstream's directory automatically. If upstream switches their location,
	# then so should we.
	echo "SEARCH_DIRS_MASK=\"${EPREFIX}/usr/lib/tautulli\"" > "${ED}"/etc/revdep-rebuild/80tautulli
}
