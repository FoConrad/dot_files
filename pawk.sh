################# TODO #####################
# Allow inclusion of new line literals in the command strings....
# (hint, remove the -e flag from echo and add newlines separately)
############################################
_pyp() {
  # This function is indirectly called from pyp, pyp3 with python version
  # supplied
  local python_v="$1"; shift

  local delim=""
  # Get delimiter if present
  if [ "$1" = "-d" ]; then
    delim="'$2'" # Add quotes to help python
    shift; shift
  elif [[ "$1" =~ "-d." ]]; then
    # This gets from variable $1, a substring from index 2, of length 1 (i.e.
    # gets the third character). For when argument passed like -d'|' as seen
    # in cut, for instance.
    delim="'${1:2:1}'"
    shift
  fi

  # Redirect all input into a file, because why not. This could be fed as
  # sys.stdin, but at that point this just seems cleaner
  local input_file="$(mktemp)"
  while read line; do
    printf '%s\n' "$line" >> $input_file
  done

  # We will also write the python to a file, because 'python -c "..."' is such
  # a head ache for non trivial programs
  local pyfile="$(mktemp)"

  # Open file for reading, no need to pass as argument because we made the name
  echo -e "rfil = open('${input_file}', 'r')" >> $pyfile

  # Indent level increases for 'enum' mode (enumerate)
  local indent=""
  local mode="enum"
  if [[ "$1" = "raw" ]]; then
    shift
    indent=""
    mode="raw"
  else
    indent="    "
    mode="enum"
    if [ "$1" = "enum" ]; then
      shift
    fi
  fi

  # Now there are three sections for 'enum':
  #   1) Pre loop code, which needs to be delimited by PRE and PRE_END
  #   2) The loop code which starts after 'mode' param unless PRE and PRE_END
  #      are provide. Loop code is ended with END, or will end on its own
  #   3) Final, post-loop section. Only present when END is passed and includes
  #      all lines after.
  if [[ "$1" = "PRE" ]]; then
    shift
    for line in "$@"; do
      shift
      if [ "$line" = "PRE_END" ]; then
        break
      fi
      echo -e "${line}\n" >> $pyfile
    done
  fi

  # Enum mode now has to start enumeration. The variables are ind for index and
  # 'item' for current line. Unfortunately no great ways to tell reader this
  # unless they read the code
  if [[ "$mode" == "enum" ]]; then 
    echo -e 'for ind, item in enumerate(rfil):' >> $pyfile
    echo -e "${indent}_pieces_=item.split(${delim})" >> $pyfile
  fi

  for line in "$@"; do
    shift
    if [ "$line" = "END" ]; then
      break
    fi
    local inter_line="$(echo $line | sed -E 's/\$([0-9]+)/_pieces_[\1]/g')"
    echo -e "${indent}${inter_line}\n" >> $pyfile
  done

  # Final section
  for line in "$@"; do
    echo -e "${line}\n" >> $pyfile
  done

  # Run and check for error
  $python_v $pyfile
  if [ $? -ne 0 ]; then
    echo "Something went wrong... Here is your source.."
    cat $pyfile
  fi
}
pyp() { _pyp "python" "$@" }
pyp3() { _pyp "python3" "$@" }
