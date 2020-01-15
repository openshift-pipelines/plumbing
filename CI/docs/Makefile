images :=  $(subst diagrams,images,$(patsubst %.plantuml,%.png,$(wildcard diagrams/*.plantuml)))

all: $(images)

clean:
	@rm -vf $(images)
.PHONY: clean all

images/%.png: diagrams/%.plantuml
	@echo "Generating $@"
	@plantuml $< -o ../images/
