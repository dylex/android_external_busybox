/* vi: set sw=4 ts=4: */
/*
 * Android/bionic glue.
 *
 * Copyright (C) 2010 by Dylan Simon <dylan@dylex.net>
 *
 * Licensed under GPLv2, see file LICENSE in this tarball for details.
 */

#include <stdlib.h>
#include "libbb.h"

/* declared in stdlib.h */
int clearenv()
{
	environ = NULL;
	return 0;
}

/* bionic/stubs.c:ttyname not implemented anyway */
int ttyname_r(int fd, char *name, size_t namesize)
{
	char *t = ttyname(fd);
	if (!t)
		return -1;
	strncpy(name, ttyname(fd), namesize);
	return 0;
}

/* no /etc/shells anyway */
char *getusershell() { return NULL; }
void setusershell() {}
void endusershell() {}

/* not used anyway */
int addmntent(FILE *fp, const struct mntent *mnt)
{
	errno = ENOENT;
	return 1;
}

/* declared in grp.h, but not necessary */
int setpwent() { return 0; }
void setgrent() {}
void endgrent() {}
