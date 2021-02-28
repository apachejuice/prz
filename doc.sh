#!/usr/bin/env bash
PKG_NAME="prz"
PKG_VER="1.0"
if [ -z "$2" ]; then
    SRCDIR="src"
else
    SRCDIR="$2"
fi

TIMEOUT=0.1

command -v valadoc > /dev/null 2>&1 || {
    echo -e >&2 "\033[0;31mERROR: 'valadoc' not installed, unable to generate documentation"
    exit 1
}

EXCLUDE_COUNT=$((0))

function exclude_sources () {
    if [ -f "doc_exclude" ]; then
        echo "Excluding sources..."
        EXCLUDES=$(cat "doc_exclude")
        for I in $EXCLUDES; do
            EXCLUDE_COUNT=$((EXCLUDE_COUNT + 1))
            SOURCES=${"$SOURCES"//$I/""}
        done
    else
        echo "No exclusion list found."
    fi
}

OUTPUT_DIR="doc"

function get_output_dir () {
    if (( "$#" > 0  )); then
        OUTPUT_DIR="$1"
    fi
}

echo "Found valadoc at $(which valadoc)..."
sleep $TIMEOUT
echo "Enumerating sources..."
sleep $TIMEOUT
SOURCES=$(find "$SRCDIR/" -type f \( -name "*.vala" -o -name "*.vapi" \) -printf "\"%p\" ")
exclude_sources
get_output_dir
echo "Using output directory '$OUTPUT_DIR'."

COUNT=$((0))
for S in $SOURCES; do
    echo ".. $S"
    sleep $TIMEOUT
    COUNT=$(($COUNT + 1))
done

sleep $TIMEOUT
echo "Found $COUNT source files, $EXCLUDE_COUNT excluded"

sleep $TIMEOUT
VALADOC_COMMAND="valadoc --directory doc $SOURCES \
--pkg gee-0.8 --pkg gio-2.0 --pkg linux --package-name $PKG_NAME-$PKG_VER \
--package-version $PKG_VER --force --verbose"

echo "Generating documentation..."
TMP_FILE=$(mktemp "/tmp/docgen-XXXXXX.sh")
exec 3>"$TMP_FILE"
echo $VALADOC_COMMAND >&3
bash $TMP_FILE
rm $TMP_FILE
