cwd = $(shell pwd)
emacs ?= emacs
emacsflags = --batch
version = $(shell date +%s)
tar_version = $(version).0
package := discover-my-major-$(tar_version).tar
pkg := discover-my-major-pkg.el
sources := $(filter-out %-pkg.el, $(wildcard *.el))

all: package

package : $(package)
$(package) : $(sources) $(pkg)
	rm -fv *.tar
	rm -rfv discover-my-major-*/
	mkdir -vp discover-my-major-$(tar_version)
	cp -vf $(sources) $(pkg) discover-my-major-$(tar_version)
	tar cvf $(package) discover-my-major-$(tar_version)
	rm -rvf discover-my-major-$(tar_version)
	rm -f $(pkg)

install : package
	$(emacs) $(emacsflags) -l package \
	-f package-initialize  --eval '(package-install-file "$(cwd)/$(shell ls -t *.tar | head -1)")'

$(pkg) : $(sources)
	rm -f $(pkg)
	echo \(define-package \"discover-my-major\" \"$(version)\" \"Discover key bindings and their meaning for the current Emacs major mode\" \'\(\(makey \"0.2\"\)\)\) > $(pkg)
