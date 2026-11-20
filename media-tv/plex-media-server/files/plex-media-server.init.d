#!/sbin/openrc-run

start() {
	ebegin "Starting Plex Media Server"
	start-stop-daemon -S -m -p "${PLEX_PIDFILE}" -1 "${PLEX_OUTLOG}" -2 "${PLEX_ERRLOG}" --quiet -u ${PLEX_USER} -N -5 -b --exec "${PLEX_SCRIPT}"
	eend $?
}

stop() {
	ebegin "Stopping Plex Media Server"
	start-stop-daemon --stop --retry SIGTERM/10 --pidfile "${PLEX_PIDFILE}"
	eend $?
}
