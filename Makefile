PROG = pl0c
OBJS = pl0c.o  # Ensure this includes the object files you want to link

CC ?= cc
CFLAGS ?= -g -O2
LDFLAGS ?=

PREFIX ?= /usr/local
MANDIR ?= ${PREFIX}/man

BOOTSTRAP = bootstrap
STAGE2 = stage2

all: final

bootstrap: ${OBJS}
	${CC} ${LDFLAGS} -o ${BOOTSTRAP} ${OBJS}

stage2: bootstrap ${OBJS}  # Add ${OBJS} in case more object files are needed
	./${BOOTSTRAP} < pl0c.pl0 | ${CC} ${CFLAGS} -o ${STAGE2} -x c -

stage3: stage2
	./${STAGE2} < pl0c.pl0 | ${CC} ${CFLAGS} -o ${PROG} -x c -

final: stage3
	cmp -s ${STAGE2} ${PROG}

nobootstrap:
	${PROG} < pl0c.pl0 | ${CC} ${CFLAGS} -o ${PROG} -x c -

genbootstrap: final
	./${PROG} < pl0c.pl0 | clang-format > pl0c.c

install:
	install -d ${PREFIX}/bin
	install -d ${MANDIR}/man1
	install -c -s -m 755 ${PROG} ${PREFIX}/bin
	install -c -m 444 ${PROG}.1 ${MANDIR}/man1

test:
	cd tests && ./test.sh

clean:
	rm -f ${PROG} ${BOOTSTRAP} ${STAGE2} ${OBJS} *.core
