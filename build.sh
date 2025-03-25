#!/bin/sh

inputFileName='index.tex'
outputFileName='dolgozat.pdf'

startDir="$( pwd )"
selfDir="$( dirname -- "$( realpath "$0" )" )"

baseName="$( echo "${inputFileName}" | sed 's/\.[^.]*$//' )"

cd "$selfDir"
mkdir -p build
rm -Rf build/*
cp -R ./src/. ./build

cd "${selfDir}/build"
command="pdflatex --shell-escape -interaction=nonstopmode --synctex=1 '${inputFileName}'"
eval "${command}"
bibtex "${baseName}"
eval "${command}"
eval "${command}"

cd "$selfDir"
rm -f ./*.out ./*.dvi
mkdir -p out
cp -f "build/${baseName}.pdf" "out/${outputFileName}"
synctexOutputFileName="$( printf '%s' "$outputFileName" | sed -E 's/\.pdf$//' ).synctex.gz"
gzip -dc "build/${baseName}.synctex.gz" | sed -E 's/\/build\/.\/(\w+).(cls|tex)$/\/src\/\1.\2/' | gzip > "out/${synctexOutputFileName}"

cd "$startDir"
