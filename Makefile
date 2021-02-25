# Makefile syntax
# <target_file> : <dependency1> ...
# <TAB> command to produce target file

# If the dependencies or recipe need to take up more than one line, the line
# must be continued using a backslash.

# The ana.png file breaks since no image can fit inside of it. So I commented that out.

all : Xinkan.lexc \
	phonology.hfst \
	Xinkan_complete.hfst \
	Xinkan_gen.hfst \
	Xinkan_ana.hfst \
	Xinkan_gen.hfstol \
	Xinkan_ana.hfstol \
	Xinkan_lexicon.png
	#ana.png 

Xinkan.lexc : root.lexc TVs.lexc IVs.lexc AlienN.lexc InalienN.lexc VariableN.lexc Adjectives.lexc Adpositions.lexc Particles.lexc Pronominals.lexc Affixes.lexc
	cat root.lexc TVs.lexc IVs.lexc AlienN.lexc InalienN.lexc VariableN.lexc Adjectives.lexc Adpositions.lexc Particles.lexc Pronominals.lexc Affixes.lexc > Xinkan.lexc

phonology.hfst : phonology.twolc
	hfst-twolc phonology.twolc > phonology.hfst

Xinkan_gen.hfst : Xinkan.lexc
	hfst-lexc < Xinkan.lexc > Xinkan_gen.hfst

Xinkan_complete.hfst : Xinkan_gen.hfst phonology.hfst
	hfst-compose-intersect -1 Xinkan_gen.hfst -2 phonology.hfst > Xinkan_complete.hfst

Xinkan_gen.hfstol : Xinkan_complete.hfst
	hfst-fst2fst --optimized-lookup-unweighted -i Xinkan_complete.hfst -o Xinkan_gen.hfstol

Xinkan_ana.hfst : Xinkan_complete.hfst
	hfst-invert -i Xinkan_complete.hfst -o Xinkan_ana.hfst

Xinkan_ana.hfstol : Xinkan_ana.hfst
	hfst-fst2fst --optimized-lookup-unweighted -i Xinkan_ana.hfst -o Xinkan_ana.hfstol

#ana.png : ana.hfstol
#	hfst-fst2txt ana.hfstol | python3 att2dot.py | dot -T png -o ana.png

Xinkan_lexicon.png : Xinkan.lexc
	python3 lexc2dot.py < Xinkan.lexc | dot -T png -o Xinkan_lexicon.png

.PHONY : clean
clean :
	-rm *.hfst *.hfstol Xinkan.lexc *.png

.PHONY : test
test :
	sh tests.sh  # sh is a command to run the argument filename as a shell script (usually bash)
