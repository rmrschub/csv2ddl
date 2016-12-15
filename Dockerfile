FROM msoap/shell2http

RUN apk add --no-cache coreutils grep bash curl bc 

ADD dsv2ddl /usr/local/bin
RUN chmod +x /usr/local/bin/dsv2ddl

ADD dsv2dml /usr/local/bin
RUN chmod +x /usr/local/bin/dsv2dml

CMD ["-port=8080", \
     "-shell=/bin/bash", \
     "-include-stderr", \
     "-show-errors", \
     "-form", \
     # CSV related
     "/csv/ddl", "dsv2ddl $v_uri $v_name ,", \
     "/csv/dml", "dsv2dml $v_uri $v_name ,", \
     "/csv/ssv", "curl -s $v_uri | tr ',' ';'", \
     "/csv/tsv", "curl -s $v_uri | tr ',' '\\t'", \
     "/csv/psv", "curl -s $v_uri | tr ',' '|'", \
     # SSV related
     "/ssv/ddl", "dsv2ddl $v_uri $v_name ;", \
     "/ssv/dml", "dsv2dml $v_uri $v_name ;", \
     "/ssv/csv", "curl -s $v_uri | tr ';' ','", \
     "/ssv/tsv", "curl -s $v_uri | tr ';' '\\t'", \
     "/ssv/psv", "curl -s $v_uri | tr ';' '|'", \
     # PSV related
     "/psv/ddl", "dsv2ddl $v_uri $v_name |", \
     "/psv/dml", "dsv2dml $v_uri $v_name |", \
     "/psv/csv", "curl -s $v_uri | tr '|' ','", \
     "/psv/tsv", "curl -s $v_uri | tr '|' '\\t'", \
     "/psv/ssv", "curl -s $v_uri | tr '|' ';'", \
     # TSV related
     "/tsv/ddl", "dsv2ddl $v_uri $v_name '\\t'", \
     "/tsv/dml", "dsv2dml $v_uri $v_name '\\t'", \
     "/tsv/csv", "curl -s $v_uri | tr '\\t' ','", \
     "/tsv/psv", "curl -s $v_uri | tr '\\t' '|'", \
     "/tsv/ssv", "curl -s $v_uri | tr '\\t' ';'", \
     # general DSV
     "/dsv/ddl", "dsv2ddl ${v_uri} ${v_name} ${v_delimiter}", \
     "/dsv/dml", "dsv2dml ${v_uri} ${v_name} ${v_delimiter}" ]