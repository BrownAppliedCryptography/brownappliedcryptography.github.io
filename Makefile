.PHONY: build

build:
	goo build site.yaml
	touch build/.nojekyll

serve: build
	goo serve site.yaml 5000 --nobuild

update: build
	git add -A
	git commit -m "update website"
	