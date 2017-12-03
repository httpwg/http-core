Building on Cygwin

For some reason, the configure script assumes the existence of "lex". This is
not true for default Cygwin installations. The workaround is to edit "Makefile"
as below:

  <       ${CC} -o $@ ${DEBUG} ${OBJS} -ll
  ---
  >       ${CC} -o $@ ${DEBUG} ${OBJS} -lfl


to use "flex" instead.