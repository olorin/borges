all: build

.PHONY: all build test

build: dist/setup-config tags
	@/bin/echo -e "CABAL\tbuild"
	cabal build

test: dist/setup-config tags
	@/bin/echo -e "CABAL\ttest"
	cabal test

dist/setup-config: memalpha.cabal 
	cabal configure \
		--enable-tests \
		--disable-benchmarks \
		-v0 2>/dev/null || /bin/echo -e "CABAL\tinstall --only-dependencies" && cabal install --only-dependencies --enable-tests --disable-benchmarks
	@/bin/echo -e "CABAL\tconfigure"
	cabal configure \
		--enable-tests \
		--disable-benchmarks \
		--disable-library-profiling \
		--disable-executable-profiling


# This will match writer-test/writer-test, so we have to strip the directory
# portion off. Annoying, but you can't use two '%' in a pattern rule.
dist/build/%: dist/setup-config tags $(SOURCES)
	@/bin/echo -e "CABAL\tbuild $@"
	cabal build $(notdir $@)

format: $(SOURCES)
	stylish-haskell -i $^

clean:
	@/bin/echo -e "CABAL\tclean"
	-cabal clean >/dev/null
	@/bin/echo -e "RM\ttemporary files"
	-rm -f tags
	-rm -f *.prof
	-rm -f lib/Package.hs

doc:
	cabal haddock

install:
	cabal install
