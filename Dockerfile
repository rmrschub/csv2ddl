FROM msoap/shell2http

RUN apk add --no-cache coreutils grep bash curl bc 

ADD csv2ddl /usr/local/bin
RUN chmod +x /usr/local/bin/csv2ddl

CMD ["-port=8080", \
     "-shell=/bin/bash", \
     "-include-stderr", \
     "-show-errors", \
     "-form", \
     "/csv2ddl", \
     "csv2ddl ${v_fileURI} ${v_tableName} ${v_delimiter}"]
