#!/usr/bin/env bash
# ============================================================
#  AspirantOS - command-line compile check (Git Bash / Linux)
#  Same steps as tools/build.cmd:
#  javac --release 21 -> build/cli, then build/AspirantOS.war
#  Usage:  bash tools/build.sh   (from the project folder)
# ============================================================
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
: "${CATALINA_HOME:?CATALINA_HOME is not set (Tomcat 11 folder)}"
SRC="$ROOT/src/main/java"
WEB="$ROOT/src/main/webapp"
OUT="$ROOT/build/cli"     # build/classes belongs to Eclipse
WAR="$ROOT/build/AspirantOS.war"

# Windows java tools need ';' as classpath separator, Linux needs ':'
SEP=":"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    SEP=";"
    # Windows javac does not understand /d/... paths: use D:/... instead
    ROOT="$(cygpath -m "$ROOT")"; SRC="$ROOT/src/main/java"; WEB="$ROOT/src/main/webapp"
    OUT="$ROOT/build/cli"; WAR="$ROOT/build/AspirantOS.war"
    CATALINA_HOME="$(cygpath -m "$CATALINA_HOME")"
    ;;
esac

rm -rf "$OUT" "$WAR"
mkdir -p "$OUT/classes"

find "$SRC" -name "*.java" > "$OUT/sources.txt" 2>/dev/null || true
if [ -s "$OUT/sources.txt" ]; then
  javac --release 21 -encoding UTF-8 -Xlint:unchecked -d "$OUT/classes" \
        -cp "$CATALINA_HOME/lib/*${SEP}$WEB/WEB-INF/lib/*" @"$OUT/sources.txt"
fi

mkdir -p "$OUT/web"
cp -r "$WEB/." "$OUT/web/"
mkdir -p "$OUT/web/WEB-INF/classes"
cp -r "$OUT/classes/." "$OUT/web/WEB-INF/classes/"

jar --create --file "$WAR" -C "$OUT/web" .
echo "BUILD OK: $WAR"
