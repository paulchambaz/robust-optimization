run:
  python ./tme/exo36.py

watch:
  typst watch paper/rapport.typ

publish:
  mkdir -p GR3_paulchambaz_zelievandermeer
  cp paper/rapport.pdf GR3_paulchambaz_zelievandermeer/GR3_paulchambaz_zelievandermeer.pdf
  mkdir -p GR3_paulchambaz_zelievandermeer/src
  cp src/*.py GR3_paulchambaz_zelievandermeer/src
  cp README.md GR3_paulchambaz_zelievandermeer/
  zip -r GR3_paulchambaz_zelievandermeer.zip GR3_paulchambaz_zelievandermeer
  rm -fr GR3_paulchambaz_zelievandermeer
