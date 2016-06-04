(TeX-add-style-hook "latex_article"
 (lambda ()
    (TeX-add-symbols
     '("sym" 1)
     '("graph" 3)
     '("Figtext" 1)
     "Starnote")
    (TeX-run-style-hooks
     "caption"
     "labelsep=endash"
     "labelfont=bf"
     "setspace"
     "calc"
     "siunitx"
     "multirow"
     "tabularx"
     "longtable"
     "threeparttablex"
     "threeparttable"
     "booktabs"
     "array"
     "lmodern"
     "afterpage"
     "pdflscape"
     "amssymb"
     "amsmath"
     "geometry"
     "xcolor"
     ""
     "graphicx"
     "dvips"
     "inputenc"
     "utf8"
     "latex2e"
     "art12"
     "article"
     "a4paper"
     "12pt")))

