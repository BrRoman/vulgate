# Accented Vulgate

## The Text (`vulgate_with_accents.txt`)

Here you have an accented version of the old Vulgate.

• The original text, which has been used for this work, is available [here](http://www.wilbourhall.org/pdfs/vulgate.pdf).

• The accentuation has been performed *magna ex parte* with [Collatinus](http://outils.biblissima.fr/fr/collatinus/) (on Github [here](https://github.com/biblissima/collatinus)).

• The result has been checked with:

- The [Polyglotte of Vigouroux](https://archive.org/details/lasaintebiblepol00vigo) (not always consistent, and containing many typographic mistakes).

- [*A key to the classical pronunciation of Greek, Latin, and Scripture Proper Names*](https://archive.org/details/keytoclassicalpr00walkrich) by John Walker (1807) (not always concordant with the Ecclesiastic accentuation).

## List of proper names of the Vulgate (`vulgate_proper_names.txt`)

You will find here too a list of all proper names of 3 syllables or more in the Vulgate, extracted from the previous text. The goal is to elaborate some rules for the accentuation of latinized hebrew and greeks proper names. These rules are gathered [here](https://github.com/gregorio-project/latin-ecclesiastic-accents/blob/master/doc/accentuation-rules.md).
 

## Yearly cursus (`vulgate_yearly_cursus.txt`)

If you wish to read the Vulgate in one year, here you have a serving suggestion.


Every feedback, idea or correction will be welcome!


## Web interface / EPUB generation

Launching `vulgate.com` will launch a browser pointing to http://localhost:8080, serving a web version of the Vulgate,
automatically generated from [vulgate_with_accents.txt](./vulgate_with_accents.txt).

It will provide a link to get the Vulgate as an epub file, suitable for e-readers.

If one wants to change code, install [MoonScript](moonscript.org), and after editing [.init.moon](./.init.moon),
run following commands:

```sh
moonc .init.moon
./zip vulgata.com init.lua
```
