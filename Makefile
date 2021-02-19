# Makefile syntax
# <target_file> : <dependency1> ...
# <TAB> command to produce target file

# If the dependencies or recipe need to take up more than one line, the line
# must be continued using a backslash.

# The ana.png file breaks since no image can fit inside of it. So I commented that out.

all : verbs.lexc \
	nouns.lexc \
	lexicon.lexc \
	phon.hfst \
	complete.hfst \
	gen.hfstol \
	ana.hfstol \
	lexicon.png
	#ana.png 

Verbs.hfst : Verbs.lexc
	hfst-lexc Verbs.lexc > Verbs.hfst

Vphon.hfst : Vphon.twolc
	hfst-twolc Vphon.twolc > Vphon.hfst

Vcomplete.hfst : Verbs.hfst Vphon.hfst
	hfst-compose-intersect -1 Verbs.hfst -2 Vphon.hfst > Vcomplete.hfst

Nouns.hfst : Nouns.lexc
	hfst-lexc Nouns.lexc > Nouns.hfst

Nphon.hfst : Nphon.twolc
	hfst-twolc Nphon.twolc > Nphon.hfst

Ncomplete.hfst : Nouns.hfst Nphon.hfst
	hfst-compose-intersect -1 Nouns.hfst -2 Nphon.hfst > Ncomplete.hfst

verbs.lexc : Verbs_template.lexc SIV.lexc TV.lexc AIV.lexc IAIV.lexc
	cat Verbs_template.lexc SIV.lexc TV.lexc AIV.lexc IAIV.lexc > verbs.lexc

nouns.lexc : Nouns_template.lexc Alien_nouns.lexc Inalien_nouns.lexc
	cat Nouns_template.lexc Alien_nouns.lexc Inalien_nouns.lexc > nouns.lexc

lexicon.lexc : Root.lexc verbs.lexc nouns.lexc Particles.lexc PrefixAgr.lexc SuffixAgr.lexc
	cat Root.lexc Particles.lexc PrefixAgr.lexc verbs.lexc nouns.lexc SuffixAgr.lexc > lexicon.lexc

phon.hfst : phon.twolc
	hfst-twolc phon.twolc > phon.hfst

gen.hfst : lexicon.lexc
	hfst-lexc < lexicon.lexc > gen.hfst

complete.hfst : gen.hfst phon.hfst
	hfst-compose-intersect -1 gen.hfst -2 phon.hfst > complete.hfst

gen.hfstol : complete.hfst
	hfst-fst2fst --optimized-lookup-unweighted -i complete.hfst -o gen.hfstol

ana.hfst : complete.hfst
	hfst-invert -i complete.hfst -o ana.hfst

ana.hfstol : ana.hfst
	hfst-fst2fst --optimized-lookup-unweighted -i ana.hfst -o ana.hfstol

#ana.png : ana.hfstol
#	hfst-fst2txt ana.hfstol | python3 att2dot.py | dot -T png -o ana.png

lexicon.png : lexicon.lexc
	python3 lexc2dot.py < lexicon.lexc | dot -T png -o lexicon.png

.PHONY : clean
clean :
	-rm *.hfst *.hfstol lexicon.lexc *.png

.PHONY : test
test :
	sh tests.sh  # sh is a command to run the argument filename as a shell script (usually bash)
