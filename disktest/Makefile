TARGET := randfiletest
CC = gcc
CFLAGS = -Wall -Werror
LDFLAGS = 
LIBS = -lrt
SRCS = $(wildcard   *.c)
OBJS = $(patsubst   %.c,  %.o,  $(SRCS))
all : ${TARGET}
${TARGET} : ${OBJS}
	${CC} ${LDFLAGS} $^ -o $@ ${LIBS}
%.o : %.cpp
	${CC} ${CFLAGS} -c $<
.PHONY: all clean distclean
clean:
	-rm -rf *o ${TARGET} tmp
distclean: clean

tmp:
	mkdir ./tmp

env:
	@echo "SRCS = ${SRCS}" 
	@echo "OBJS = ${OBJS}"

test: tmp ${TARGET}
	./${TARGET} 4096 1000
