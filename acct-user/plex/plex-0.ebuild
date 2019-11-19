# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="System-wide Plex services user"
ACCT_USER_ID=113
ACCT_USER_GROUPS=( plex video )
ACCT_USER_HOME=/var/lib/plexmediaserver
ACCT_USER_SHELL=/bin/sh

acct-user_add_deps
