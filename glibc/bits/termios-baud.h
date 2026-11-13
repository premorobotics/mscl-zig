/* Baud rates for builds that target a glibc older than 2.42. */
#if __GLIBC__ == 2 && __GLIBC_MINOR__ < 42
#define B0 0000000
#define B50 0000001
#define B75 0000002
#define B110 0000003
#define B134 0000004
#define B150 0000005
#define B200 0000006
#define B300 0000007
#define B600 0000010
#define B1200 0000011
#define B1800 0000012
#define B2400 0000013
#define B4800 0000014
#define B9600 0000015
#define B19200 0000016
#define B38400 0000017
#ifdef __USE_MISC
#define EXTA B19200
#define EXTB B38400
#endif
#define B57600 __B57600
#define B115200 __B115200
#define B230400 __B230400
#define B460800 __B460800
#define B500000 __B500000
#define B576000 __B576000
#define B921600 __B921600
#define B1000000 __B1000000
#define B1152000 __B1152000
#define B1500000 __B1500000
#define B2000000 __B2000000
#define B2500000 __B2500000
#define B3000000 __B3000000
#define B3500000 __B3500000
#define B4000000 __B4000000
#define __MAX_BAUD B4000000
#else
#include_next <bits/termios-baud.h>
#endif
