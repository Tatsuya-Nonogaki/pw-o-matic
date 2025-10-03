#!/bin/bash
# 'pw-o-matic', an Optimized Password Generator, generates optimized password strings
# according to the given type of environment flavor and various options. It is also
# designed with ease of use and customization in mind.
# *REQUIREMENTS - apg (Automated Password Generator) (https://github.com/jabenninghoff/apg)
# v1.1.6

show_help () {
    cat <<EOM
Usage: $(basename $0) [-f FLAVOR] [-n NUM_OF_OUTPUT] [-l PW_LENGTH]
  -f: (Optional) Optimization flavor, can be 'linux', 'oracle', 'powershell', 'relax' or
      'simple' mode. Lesser optimization will be done if not specified or the argument
      is out of range.
  -n: (Optional) Number of samples to output, defaults to 3.
  -l: (Optional) Length of each password to generate, MUST be >= 4. By default, the
      script generates variable length passwords in a specific range per FLAVOR. Use
      this option if you want passwords fixed to a certain length.
  -w: (Optional) Script may append cautionary statements to each password when needed.
      Add this option to suppress them.
  Example: $(basename $0) -f linux -n 8
EOM
}

while getopts "f:n:l:wh" opt; do
  case $opt in
    f)
      FLAVOR=${OPTARG,,}
      ;;
    n)
      OUTNUM=$OPTARG
      ;;
    l)
      PWLEN=$OPTARG
      ;;
    w)
      NOWARN=1
      ;;
    h|*)
      show_help
      exit 1
      ;;
  esac
done
shift $(($OPTIND -1))

# Tuning parameters
: ${OUTNUM:=3}                 # default number of output when not specified
OPTIONS="-a 0 -n $OUTNUM -t"   # shared apg options
DEFAULT_LEN='-m 13 -x 16'      # No-Flavor: legth options for apg
DEFAULT_AUX='-M SNCL -E \\'    # No-Flavor: other apg options
RELAX_LEN='-m 9 -x 12'         # Relax-mode: length options for apg
RELAX_AUX='-M NlC'             # Relax-mode: other apg options
SIMPLE_LEN='-m 9 -x 12'        # Simple-mode: length options for apg
SIMPLE_AUX='-M NL'             # Simple-mode: other apg options
LINUX_LEN='-m 13 -x 16'        # Linux: length options for apg
LINUX_AUX='-M SNCL'            # Linux: other apg options
LINUX_SAFE_SYMBOLS='#%+/:=?@_' # Linux: safe symbol characters
ORACLE_LEN='-m 10 -x 14'       # Oracle: legth options for apg
ORACLE_AUX='-M sNCL'           # Oracle: other apg options
ORACLE_SAFE_SYMBOLS='_^'       # Oracle: safe symbol characters
PS_LEN='-m 13 -x 16'           # PowerShell: legth options for apg
PS_AUX='-M SNCL'               # PowerShell: other apg options
PS_SAFE_SYMBOLS='_^-+=.'       # PowerShell: safe symbol characters

if [[ -n "$PWLEN" && (! $PWLEN =~ ^[0-9]+$ || $PWLEN -lt 4) ]]; then
    echo "Invalid LENGTH '$PWLEN': '-l' argument must be >= 4. See '$(basename $0) -h'"
    exit 1
fi

# Generate reliably ALL_SYMBOLS list '!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~'
# which is, ASCII 33-126 excluding alphanumeric characters.
ALL_SYMBOLS=""
for i in $(seq 33 126); do
    ch=$(printf "\\$(printf '%03o' "$i")")
    if [[ ! "$ch" =~ [a-zA-Z0-9] ]]; then
        ALL_SYMBOLS+="$ch"
    fi
done

function escape_char () {
# Escape special characters for safe shell handling
    sed -e 's/\\\$\&\(\)\;\`\|\"/\\&/g' -e "s/'/\\\\'/g"
    #sed 's/[^a-zA-Z 0-9]/\\&/g'    #Alternative way though rough
}

function build_exclude_list () {
# Convert special symbol Include-list to Exclude-list
    local allowed excluded chr
    allowed=$1

    excluded=""
    for (( i=0; i<${#ALL_SYMBOLS}; i++ )); do
      chr="${ALL_SYMBOLS:$i:1}"
      if [[ "$allowed" != *"$chr"* ]]; then
        excluded+="$chr"
      fi
    done

    echo "$excluded" | escape_char
}

function default_flavor_opts () {
    length=${length:=$DEFAULT_LEN}
    echo "No optimization applied"
    OPTIONS+=" $length $DEFAULT_AUX"
}

if [ -n "$PWLEN" ]; then
    length="-m $PWLEN -x $PWLEN"
fi

if [ -n "$FLAVOR" ]; then
    case $FLAVOR in
      linux)
        length=${length:=$LINUX_LEN}
        excludelist=$(build_exclude_list $LINUX_SAFE_SYMBOLS)
        echo "Optimized for linux"
        OPTIONS+=" $length $LINUX_AUX -E $excludelist"
        ;;
      oracle)
        length=${length:=$ORACLE_LEN}
        excludelist=$(build_exclude_list $ORACLE_SAFE_SYMBOLS)
        echo "Optimized for oracle"
        OPTIONS+=" $length $ORACLE_AUX -E $excludelist"
        ;;
      powershell)
        length=${length:=$PS_LEN}
        excludelist=$(build_exclude_list $PS_SAFE_SYMBOLS)
        echo "Optimized for PowerShell"
        OPTIONS+=" $length $PS_AUX -E $excludelist"
        ;;
      relax)
        length=${length:=$RELAX_LEN}
        echo "Optimized for Relax mode"
        OPTIONS+=" $length $RELAX_AUX"
        ;;
      simple)
        length=${length:=$SIMPLE_LEN}
        echo "Optimized for Simple mode"
        OPTIONS+=" $length $SIMPLE_AUX"
        ;;
      *)
        default_flavor_opts
        ;;
    esac
else
    default_flavor_opts
fi

echo "COMMAND : \"apg $OPTIONS\""

# Oracle user password must begin with an alphabetic character to use unquoted
if [ "$FLAVOR" = "oracle" ]; then
    while IFS= read -r line; do
        comment=""
        warn=""
        count=-1
        read pw comment < <(echo $line)

        # If the first character is not an alphabet, sequentially move to the end
        if [[ "$pw" =~ [a-zA-Z] ]]; then
            count=0
            MAX_ROTATIONS=${#pw}
            while [[ ! "${pw:0:1}" =~ [a-zA-Z] && $count -lt $MAX_ROTATIONS ]]; do
                pw="${pw:1}${pw:0:1}"
                ((count++))
            done
        fi

        if [ ! $NOWARN ]; then
            # If apg option includes "pronounceable" and "append pronunciation note" and symbols rotation actually took place,
            if [[ $count -gt 0 && "$OPTIONS" =~ ([[:blank:]]|^)-t([[:blank:]]|$) && ! "$OPTIONS" =~ ([[:blank:]]|^)-a[[:blank:]]+1([[:blank:]]|$) ]]; then
                warn='Pronunciation may not match password.'
            fi

            # If the first character is still not an alphabet,
            if [[ ! "${pw:0:1}" =~ [a-zA-Z] ]]; then
                warn+="${warn:+ }Be careful when using unquoted!"
            fi
        fi
        echo ${pw}${comment:+" $comment"}${warn:+" [$warn]"}
    done < <(apg $OPTIONS)
else
    apg $OPTIONS
fi
