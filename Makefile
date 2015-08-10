PACKAGES=compiler-libs.common,ppx_tools
FLAGS=-thread -safe-string -short-paths -package $(PACKAGES)

ppx_type: ppx_type.ml
	ocamlfind ocamlopt $(FLAGS) -linkpkg ppx_type.ml -o ppx_type

test: test.ml ppx_type
	ocamlfind ocamlopt $(FLAGS) -dsource -ppx ./ppx_type test.ml -o test.out 2> test.err

.PHONY: clean
clean:
	rm -rf *.{cmi,cmx,o,err,out,mltyped} ppx_type
