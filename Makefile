# The default target
all:: 

CC = cc
RM = rm -rf

EXTRA_CFLAGS = # dynamically added/remoted
CFLAGS = -O2 -std=c99 -pedantic -Wall $(EXTRA_CFLAGS) -Idnscrypt-proxy/src/libevent/include -Idnscrypt-proxy/src/libnacl/build/localhost/include/local -lrt
LDFLAGS = -lm
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

LIB_H = dnscrypt.h udp_request.h edns.h logger.h

LIB_OBJS += dnscrypt.o
LIB_OBJS += udp_request.o
LIB_OBJS += edns.o
LIB_OBJS += logger.o
LIB_OBJS += main.o
LIB_OBJS += rfc1035.o
LIB_OBJS += salsa20_random.o
LIB_OBJS += safe_rw.o
LIB_OBJS += cert.o

LDADD += argparse/argparse.o
LDADD += dnscrypt-proxy/src/libnacl/build/localhost/lib/local/libnacl.a
LDADD += dnscrypt-proxy/src/libevent/.libs/libevent.a

version.h:
	./gen-version.sh > version.h

argparse/argparse.h:
	@git submodule update --init

argparse/argparse.o: argparse/argparse.h
	@make -C argparse argparse.o

dnscrypt-proxy/src/libnacl/build/localhost/lib/local/libnacl.a:
dnscrypt-proxy/src/libevent/.libs/libevent.a:
	@cd dnscrypt-proxy && ./autogen.sh && ./configure && make

$(LIB_OBJS): $(LIB_H)

all:: dnscrypt-wrapper

main.o: version.h

dnscrypt-wrapper: $(LIB_OBJS) $(LDADD)
	$(CC) $(CFLAGS) -o $@ $(LDFLAGS) $^

install: all
	install -p -m 755 dnscrypt-wrapper $(BINDIR)

uninstall:
	$(RM) $(BINDIR)/dnscrypt-wrapper

clean:
	$(RM) dnscrypt-wrapper
	$(RM) $(LIB_OBJS)

clean-all: clean
	cd dnscrypt-proxy; make clean

.PHONY: all install uninstall clean test
