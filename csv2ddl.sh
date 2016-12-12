#!/usr/local/Cellar/bash/4.4.5/bin/bash
# Generate a SQL DDL for a given CSV file.
# Make sure to use Bash 4.+
# Based on https://gist.github.com/randerzander/0d2537b1970ba94648bb

set -eu

# Script arguments
FILE=$1
TABLE_NAME=$2
HEADER_LINE_NUM=${3:-1}
PK_COLUMN_NUM=${4:-1}
DELIM=${5:-';'}

# Sample size settings
MARGIN_OF_ERROR="0.05"
Z_SCORE="1.645"
PRIOR="0.5"
POPULATION_SIZE=
SAMPLE_SIZE=

# SQL datatype regexes
BOOLEAN='^(?i:true|false)$'
INTEGER='^[-+]?[0-9]+$'
FLOAT='^[-+]?[0-9]*\.[0-9]*$'
DATE='^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$'
TIME='^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$'
DATETIME='^[0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]$'
TEXT='^[[:alnum:][:space:]]*$'
# TODO(resc28): VARCHAR(n)
# TODO(resc28): INTERVAL
# TODO(resc28): ARRAY
# TODO(resc28): MULTISET
# TODO(resc28): XML


#######################################
# Cleanup line terminators
# Globals:
#   none
# Arguments:
#   CSV filepath
# Returns:
#   cleaned file content
#######################################
# TODO(resc28): take care for CRLF, CR, LF, etc
function lineTerminatorCleanup () {
  tr -s '\r' '\n' < $1 
}


#######################################
# Sample rows from the CSV table
# Assumes hypergeometric distribution
# Globals:
#   POPULATION_SIZE
#   SAMPLE_SIZE_FLOAT
#   SAMPLE_SIZE
#   PRIOR
#   Z_SCORE
#   MARGIN_OF_ERROR
#   HEADER_LINE_NUM
# Arguments:
#   none
# Returns:
#   none
#######################################
function getSampleRows () {
  POPULATION_SIZE=$((`cat $1 | wc -l`-1))
  
  SAMPLE_SIZE_FLOAT=`echo "(($PRIOR*(1-$PRIOR))*$POPULATION_SIZE*($Z_SCORE)^2)/( (($PRIOR*(1-$PRIOR))*($Z_SCORE)^2) + ($POPULATION_SIZE-1)*($MARGIN_OF_ERROR)^2 )" | bc -l`  
  SAMPLE_SIZE=`echo "($SAMPLE_SIZE_FLOAT+0.5)/1" | bc`
  
  sed "${HEADER_LINE_NUM}d" $1 | gshuf --random-source=/dev/urandom | head -n $SAMPLE_SIZE 
}

#######################################
# Guess SQL datatype for nth column
# Globals:
#   SAMPLE_SIZE
#   PRIOR
#   MARGIN_OF_ERROR
#   SAMPLE_ROWS
# Arguments:
#   column number
# Returns:
#   SQL datatype
#######################################
function guessColumnType () {
  CELLS=`mktemp`
  cat $SAMPLE_ROWS | awk -F "\"*$DELIM\"*" '{print $'$1'}' > $CELLS
  
  target=`echo "($SAMPLE_SIZE*$PRIOR)-($SAMPLE_SIZE*$MARGIN_OF_ERROR)" | bc -l`
  declare -A TYPE_HISTOGRAM
  TYPE_HISTOGRAM=(
    ["BOOLEAN"]=`cat $CELLS | grep -Eo "${BOOLEAN}" | wc -l | ( read hits; echo "$hits/$target" | bc  )`
    ["INTEGER"]=`cat $CELLS | grep -Eo "${INTEGER}" | wc -l | ( read hits; echo "$hits/$target" | bc )`
    ["FLOAT"]=`cat $CELLS | grep -Eo "${FLOAT}" | wc -l | ( read hits; echo "$hits/$target" | bc )`
    ["DATE"]=`cat $CELLS | grep -Eo "${DATE}" | wc -l | ( read hits; echo "$hits/$target" | bc )`
    ["TIME"]=`cat $CELLS | grep -Eo "${TIME}" | wc -l | ( read hits;echo "$hits/$target" | bc )`
    ["DATETIME"]=`cat $CELLS | grep -Eo "${DATETIME}" | wc -l | ( read hits; echo "$hits/$target" | bc )`
  )
 
  TYPE_INFO=`for k in "${!TYPE_HISTOGRAM[@]}"
  do
    echo $k' : '${TYPE_HISTOGRAM["$k"]}
  done |
  sort -rn -k3 | 
  head -n 1 `
  
  IFS=' : ' read -r -a TYPE <<< "$TYPE_INFO"
    
  if [ "${TYPE[1]}" != "1" ]; then
    echo "TEXT"
  else
    echo "${TYPE[0]}"
  fi
}

#######################################
# Generate SQL DDL for CSV
# Globals:
#   $TMP
#   $DELIM
#   $TABLE_NAME
#   $HEADER_LINE_NUM
#   $PK_COLUMN_NUM
# Arguments:
#   $TMP
#   $DELIM
#   $TABLE_NAME
#   $HEADER_LINE_NUM
#   $PK_COLUMN_NUM
# Returns:
#   DDL file
#######################################
function writeDDL () {
  HEADERS=`sed "${4}q;d" $1 | tr -d '\n'`
  IFS=$2 read -a array <<< "$HEADERS"
  LAST_COL=${array[$[${#array[@]}-1]]}
  
  echo 'CREATE TABLE '$3' (' > $3.ddl
  COUNTER=1
  for element in "${array[@]}"
  do
    COLUMN_TYPE=`guessColumnType $COUNTER`
    
    if [ "$element" != "$LAST_COL" ]; then
      if [ "$COUNTER" = "$5" ]; then
        echo "  ${element// /_} ${COLUMN_TYPE} NOT NULL PRIMARY KEY," >> $3.ddl
      else
        echo "  ${element// /_} ${COLUMN_TYPE}," >> $3.ddl
      fi
    else
      if [ "$COUNTER" = "$5" ]; then
        echo "  ${element// /_} ${COLUMN_TYPE} NOT NULL PRIMARY KEY" >> $3.ddl
      else
        echo "  ${element// /_} ${COLUMN_TYPE}" >> $3.ddl
      fi
    fi
    let COUNTER=COUNTER+1
  done
  echo ")" >> $3.ddl
}


TMP=`mktemp`
SAMPLE_ROWS=`mktemp`

lineTerminatorCleanup $FILE > $TMP
getSampleRows $TMP > $SAMPLE_ROWS
writeDDL $TMP $DELIM $TABLE_NAME $HEADER_LINE_NUM $PK_COLUMN_NUM


# cleanup
rm $TMP
rm $SAMPLE_ROWS