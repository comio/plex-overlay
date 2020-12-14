# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="Tautulli user"
ACCT_USER_ID=636
ACCT_USER_HOME=/opt/tautulli
ACCT_USER_GROUPS=( tautulli )

acct-user_add_deps
