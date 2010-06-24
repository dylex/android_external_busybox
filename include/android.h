/* vi: set sw=4 ts=4: */
/*
   Copyright 2010, Dylan Simon

   Licensed under the GPL v2 or later, see the file LICENSE in this tarball.
*/

#ifndef BB_ANDROID_H
#define BB_ANDROID_H 1

/* for dirname, basename */
#include <libgen.h>

#define killpg_busybox(P, S) kill(-(P), S)

#define setmntent fopen
#define endmntent fclose

/* defined in bionic/utmp.c */
void endutent(void);

/* defined in bionic/mktemp.c */
char *mkdtemp(char *);

/* defined in bionic/stubs.c */
char *ttyname(int);

/* added to SYSCALLS.TXT:
int    stime(time_t *) 25
int    swapon(const char *, int)       87
int    swapoff(const char *)   115
*/
int              stime (time_t *);
int              swapon (const char *, int);
int              swapoff (const char *);

/* local definition in libbb/xfuncs_printf.c */
int fdprintf(int fd, const char *format, ...);

/* local definitions in libbb/android.c */
int ttyname_r(int, char *, size_t);

char *getusershell(void);
void setusershell(void);
void endusershell(void);

struct mntent;
struct __sFILE;
int addmntent(struct __sFILE *, const struct mntent *);
struct mntent *getmntent_r(struct __sFILE *fp, struct mntent *mnt, char *buf, int buflen);

/* bionic's vfork is rather broken; for now a terrible bandaid: */
#define vfork fork

#endif
