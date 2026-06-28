#!/bin/sh
set -e

unset LD_LIBRARY_PATH GI_TYPELIB_PATH GIO_EXTRA_MODULES GTK_PATH

inputFileName='index.tex'
outputFileName='dolgozat.pdf'

startDir="$( pwd )"
selfDir="$( dirname -- "$( realpath "$0" )" )"

baseName="$( echo "${inputFileName}" | sed 's/\.[^.]*$//' )"

cd "$selfDir"
PATH="${selfDir}/bin:${PATH}"
export PATH

mkdir -p build
rm -Rf build/*
cp -R ./src/. ./build

cd "${selfDir}/build"

pdflatex --shell-escape -interaction=nonstopmode --synctex=1 "$inputFileName"
if command -v biber > /dev/null 2>&1; then
    biber "${baseName}"
else
    printf '%s\n' 'WARNING: a biber parancs nem elérhető, az irodalomjegyzék feldolgozása kimarad.' >&2
fi
pdflatex --shell-escape -interaction=nonstopmode --synctex=1 "$inputFileName"
pdflatex --shell-escape -interaction=nonstopmode --synctex=1 "$inputFileName"

cd "$selfDir"
rm -f ./*.out ./*.dvi
mkdir -p out
cp -f "build/${baseName}.pdf" "out/${outputFileName}"
synctexOutputFileName="$( printf '%s' "$outputFileName" | sed -E 's/\.pdf$//' ).synctex.gz"
gzip -dc "build/${baseName}.synctex.gz" | sed -E 's/\/build\/.\/(\w+).(cls|tex)$/\/src\/\1.\2/' | gzip > "out/${synctexOutputFileName}"

cd "$startDir"
