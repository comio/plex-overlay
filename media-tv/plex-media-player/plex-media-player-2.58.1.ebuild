# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils xdg cmake-utils

DESCRIPTION="Next generation Plex Desktop/Embedded Client"
HOMEPAGE="http://plex.tv/"

# To change on every release bump:
COMMIT="ae73e074"
WEB_CLIENT_BUILD_ID="183-045db5be50e175"
WEB_CLIENT_DESKTOP_VERSION="4.29.2-e50e175"
WEB_CLIENT_TV_VERSION="4.29.6-045db5b"

MY_PV="${PV}-${COMMIT}"
MY_P="${PN}-${MY_PV}"

RESTRICT="mirror download? ( network-sandbox )"

SRC_URI="
	https://github.com/plexinc/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	!download? (
		https://artifacts.plex.tv/web-client-pmp/${WEB_CLIENT_BUILD_ID}/buildid.cmake -> buildid-${WEB_CLIENT_BUILD_ID}.cmake
		https://artifacts.plex.tv/web-client-pmp/${WEB_CLIENT_BUILD_ID}/web-client-tv-${WEB_CLIENT_TV_VERSION}.tar.xz
		desktop? (
			https://artifacts.plex.tv/web-client-pmp/${WEB_CLIENT_BUILD_ID}/web-client-desktop-${WEB_CLIENT_DESKTOP_VERSION}.tar.xz
		)
	)
"

LICENSE="GPL-2 Plex"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cec +desktop download joystick lirc X"

QT_VERSION=5.11.2
DEPEND="
	>=dev-qt/qtcore-${QT_VERSION}
	>=dev-qt/qtnetwork-${QT_VERSION}
	>=dev-qt/qtxml-${QT_VERSION}
	>=dev-qt/qtwebchannel-${QT_VERSION}[qml]
	>=dev-qt/qtwebengine-${QT_VERSION}
	>=dev-qt/qtdeclarative-${QT_VERSION}
	>=dev-qt/qtquickcontrols-${QT_VERSION}
	>=dev-qt/qtx11extras-${QT_VERSION}
	>=dev-qt/qtdbus-${QT_VERSION}
	media-video/mpv[libmpv]
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXrandr

	|| (
		media-video/ffmpeg[openssl]
		media-video/ffmpeg[gnutls]
		media-video/ffmpeg[securetransport]
	)

	cec? (
		>=dev-libs/libcec-2.2.0
	)

	joystick? (
		media-libs/libsdl2
		virtual/libiconv
	)
	X? (
		x11-misc/xdg-utils
	)
"

RDEPEND="
	${DEPEND}

	lirc? (
		app-misc/lirc
	)
"

PATCHES=(
	"${FILESDIR}/iconv-fix.patch"
	"${FILESDIR}/git-revision.patch"
	"${FILESDIR}/dont_copy_qtwebengine_devtools_resources_pak_file.patch"
	"${FILESDIR}/fix-video-qt5_14.patch"
)

S="${WORKDIR}/${MY_P}"
DEPENDENCIES_DIR="${S}/dependencies"

CMAKE_IN_SOURCE_BUILD=1

src_prepare() {
	sed -i -e '/^  install(FILES ${QTROOT}\/resources\/qtwebengine_devtools_resources.pak DESTINATION resources)$/d' src/CMakeLists.txt || die

	cmake-utils_src_prepare

	if use download && has network-sandbox $FEATURES; then
		eerror "You must disable 'network-sandbox' feature in order to use 'download' flag" && die
	elif ! use download; then
		# Avoid to download during the build process
		mkdir -p "${DEPENDENCIES_DIR}"
		cp "${DISTDIR}/buildid-${WEB_CLIENT_BUILD_ID}.cmake" "${DEPENDENCIES_DIR}"
		# Desktop client
		if use desktop; then
			cp "${DISTDIR}/web-client-desktop-${WEB_CLIENT_DESKTOP_VERSION}.tar.xz" "${DEPENDENCIES_DIR}"
			sha1sum -b "${DISTDIR}/web-client-desktop-${WEB_CLIENT_DESKTOP_VERSION}.tar.xz" > "${DEPENDENCIES_DIR}/web-client-desktop-${WEB_CLIENT_DESKTOP_VERSION}.tar.xz.sha1"
			mkdir -p "${DEPENDENCIES_DIR}/universal-web-client-desktop/${WEB_CLIENT_BUILD_ID}"
			mv "${WORKDIR}/web-client-desktop-${WEB_CLIENT_DESKTOP_VERSION}" "${DEPENDENCIES_DIR}/universal-web-client-desktop/${WEB_CLIENT_BUILD_ID}"
		fi
		# Full screen TV client
		cp "${DISTDIR}/web-client-tv-${WEB_CLIENT_TV_VERSION}.tar.xz" "${DEPENDENCIES_DIR}"
		sha1sum -b "${DISTDIR}/web-client-tv-${WEB_CLIENT_TV_VERSION}.tar.xz" > "${DEPENDENCIES_DIR}/web-client-tv-${WEB_CLIENT_TV_VERSION}.tar.xz.sha1"
		mkdir -p "${DEPENDENCIES_DIR}/universal-web-client-tv/${WEB_CLIENT_BUILD_ID}"
		mv "${WORKDIR}/web-client-tv-${WEB_CLIENT_TV_VERSION}" "${DEPENDENCIES_DIR}/universal-web-client-tv/${WEB_CLIENT_BUILD_ID}"
	fi
	eapply_user
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_CEC=$(usex cec)
		-DENABLE_SDL2=$(usex joystick)
		-DENABLE_LIRC=$(usex lirc)
		-DLINUX_X11POWER=$(usex X)
		-DQTROOT="${EPREFIX}/usr/share/qt5"
		-DWEB_CLIENT_DISABLE_DESKTOP=$(usex desktop "OFF" "ON")
	)

	export BUILD_NUMBER="${BUILD}"
	export GIT_REVISION="${COMMIT}"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	wm="$PN-tv" make_session_desktop "Plex Media Player (TV Layout)" "plexmediaplayer" "--tv" "--fullscreen"
	if use desktop; then
		wm="$PN-desktop" make_session_desktop "Plex Media Player" "plexmediaplayer" "--desktop" "--fullscreen"
	fi
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
