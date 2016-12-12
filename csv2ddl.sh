#!/usr/local/Cellar/bash/4.4.5/bin/bash
#
# Generate a SQL DDL for a given CSV _arg_fileuri.
# Based on https://gist.github.com/randerzander/0d2537b1970ba94648bb
# Make sure to use Bash 4.+
#
# ARG_POSITIONAL_SINGLE([fileUri],[specify the file],[])
# ARG_POSITIONAL_SINGLE([tableName],[specify the table name],[])
# ARG_OPTIONAL_SINGLE([headerLine],[l],[specify the header line],[1])
# ARG_OPTIONAL_SINGLE([pkColumn],[p],[specify the primary key column],[1])
# ARG_OPTIONAL_SINGLE([delimiter],[d],[specify the delimiter character],[';'])
# ARG_HELP([The general script's help msg])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.2.2 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, know your rights: https://github.com/matejak/argbash

die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_headerline="1"
_arg_pkcolumn="1"
_arg_delimiter=';'

# THE PRINT HELP FUNCION
print_help ()
{
	echo "The general script's help msg"
	printf 'Usage: %s [-l|--headerLine <arg>] [-p|--pkColumn <arg>] [-d|--delimiter <arg>] [-h|--help] <fileUri> <tableName>\n' "$0"
	printf "\t%s\n" "<fileUri>: specify the file"
	printf "\t%s\n" "<tableName>: specify the table name"
	printf "\t%s\n" "-l,--headerLine: specify the header line (default: '"1"')"
	printf "\t%s\n" "-p,--pkColumn: specify the primary key column (default: '"1"')"
	printf "\t%s\n" "-d,--delimiter: specify the delimiter character (default: '';'')"
	printf "\t%s\n" "-h,--help: Prints help"
}

# THE PARSING ITSELF
while test $# -gt 0
do
	_key="$1"
	case "$_key" in
		-l|--headerLine|--headerLine=*)
			_val="${_key##--headerLine=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_headerline="$_val"
			;;
		-p|--pkColumn|--pkColumn=*)
			_val="${_key##--pkColumn=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_pkcolumn="$_val"
			;;
		-d|--delimiter|--delimiter=*)
			_val="${_key##--delimiter=}"
			if test "$_val" = "$_key"
			then
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_val="$2"
				shift
			fi
			_arg_delimiter="$_val"
			;;
		-h|--help)
			print_help
			exit 0
			;;
		*)
			_positionals+=("$1")
			;;
	esac
	shift
done

_positional_names=('_arg_fileuri' '_arg_tablename' )
test ${#_positionals[@]} -lt 2 && _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 2, but got only ${#_positionals[@]}." 1
test ${#_positionals[@]} -gt 2 && _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 2, but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
	eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1
done

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash


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
#   CSV _arg_fileuripath
# Returns:
#   cleaned _arg_fileuri content
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
#   _arg_headerline
# Arguments:
#   none
# Returns:
#   none
#######################################
function getSampleRows () {
  POPULATION_SIZE=$((`cat $1 | wc -l`-1))
  
  SAMPLE_SIZE_FLOAT=`echo "(($PRIOR*(1-$PRIOR))*$POPULATION_SIZE*($Z_SCORE)^2)/( (($PRIOR*(1-$PRIOR))*($Z_SCORE)^2) + ($POPULATION_SIZE-1)*($MARGIN_OF_ERROR)^2 )" | bc -l`  
  SAMPLE_SIZE=`echo "($SAMPLE_SIZE_FLOAT+0.5)/1" | bc`
  
  sed "${_arg_headerline}d" $1 | gshuf --random-source=/dev/urandom | head -n $SAMPLE_SIZE 
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
  cat $SAMPLE_ROWS | awk -F "\"*$_arg_delimiter\"*" '{print $'$1'}' > $CELLS
  
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
#   $_arg_delimiter
#   $_arg_tablename
#   $_arg_headerline
#   $_arg_pkcolumn
# Arguments:
#   $TMP
#   $_arg_delimiter
#   $_arg_tablename
#   $_arg_headerline
#   $_arg_pkcolumn
# Returns:
#   DDL _arg_fileuri
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

lineTerminatorCleanup $_arg_fileuri > $TMP
getSampleRows $TMP > $SAMPLE_ROWS
writeDDL $TMP $_arg_delimiter $_arg_tablename $_arg_headerline $_arg_pkcolumn


# cleanup
rm $TMP
rm $SAMPLE_ROWS

# ] <-- needed because of Argbash