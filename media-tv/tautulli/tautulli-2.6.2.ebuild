# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3_8 )
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
RESTRICT="bindist strip test"

DEPEND="
	${PYTHON_DEPS}
	acct-user/tautulli
	acct-group/tautulli
"

RDEPEND="
	media-tv/plex-media-server
	dev-python/pyopenssl
	${DEPEND}
"

S="${WORKDIR}/${MY_P}"

src_install() {
	dodoc API.md CHANGELOG.md CONTRIBUTING.md README.md
        newinitd "${FILESDIR}/${PN}.init" ${PN}

	keepdir /var/lib/${PN}
        fowners -R ${PN}:${PN} /var/lib/${PN}

        insinto /etc/${PN}
        insopts -m0660 -o ${PN} -g ${PN}

	insinto "/var/lib/${PN}"
	doins -r contrib data lib plexpy pylintrc PlexPy.py Tautulli.py || die

	dodir "/etc/${PN}"
	dosym "${EPREFIX}/var/lib/${PN}/config.ini" "/etc/${PN}/config.ini"

	systemd_dounit  "${FILESDIR}/${PN}.service"
	systemd_newunit "${FILESDIR}/${PN}.service" "${PN}@.service"
}
