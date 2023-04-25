# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="Firmware for Hauppauge and WinTV tuners"
HOMEPAGE="http://www.hauppauge.com/site/support/linux.html"
UBUNTU_RELEASE="jammy"
SRC_URI="https://launchpad.net/~b-rad/+archive/ubuntu/kernel+mediatree+hauppauge/+files/${PN}_${PV}+${UBUNTU_RELEASE}.tar.gz"

LICENSE="Hauppauge-Firmware"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

S="${WORKDIR}/${P}+${UBUNTU_RELEASE}"

src_install() {
	insinto /lib/firmware
	doins "${S}"/install/0/*.fw
}
