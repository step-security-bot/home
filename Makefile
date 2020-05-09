# Makefile for home

# Variables
EMACS =
ifndef EMACS
EMACS = "emacs"
endif

DOTEMACS = ~/.config/emacs
DOTGNUS = ~/.config/gnus
DOTNIXPKGS = ~/.config/nixpkgs
ETCNIXOS = /etc/nixos
SYNCDIR = /home/vincent/sync/nixos
PUBLISH_FOLDER = ~/desktop/sites/beta.sbr.pm
SRCWWW = ~/src/www

# Targets
.PHONY: all
all: switch emacs-dump

.PHONY: update
update:
	nix-channel --update

.PHONY: pull
pull:
	(cd overlays/emacs-overlay && git checkout master && git pull --rebase)

.PHONY: emacs-dump
emacs-dump:
	emacs --batch -q -l ~/.config/emacs/dump.el

# home-manager setup
.PHONY: assets
assets:
	mkdir -p assets
	cp -Rv $(SYNCDIR)/* assets/
	chown -R vincent:users assets || true

.PHONY: build
build: assets setup
	@if test $(USER) = root;\
	then\
		nixos-rebuild build;\
	else\
		home-manager build;\
	fi

.PHONY: dry-build
dry-build: assets setup
	@if test $(USER) = root;\
	then\
		nixos-rebuild dry-build;\
	fi

.PHONY: switch
switch: assets setup
	@if test $(USER) = root;\
	then\
		nixos-rebuild switch;\
	else\
		home-manager switch;\
	fi

install-hooks:
	if [ -e .git ]; then nix-shell -p git --run 'git config core.hooksPath .githooks'; fi

# Cleaning
.PHONY: clean
clean:
	@if test $(USER) = root;\
	then\
		nix-env --profile /nix/var/nix/profiles/system --delete-generations 15d;\
	else\
		unlink result || true;\
	fi

.PHONY: clean-www
clean-www:
	-rm -rvf *.elc
	-rm -rv ~/.org-timestamps/*

# Documentation build and publishing
.PHONY: update-docs
update-docs:
	@echo "Updating docs references…"
	$(EMACS) --batch --directory $(DOTEMACS)/lisp/ \
		--load lib/lisp/docs.el \
		--funcall update-docs

.PHONY: build-www
build-www: $(SRCWWW)/publish-common.el lib/lisp/publish.el update-docs
	@echo "Publishing... with current Emacs configurations."
	${EMACS} --batch --directory $(DOTEMACS)/lisp/ \
		--load $(SRCWWW)/publish-common.el --load lib/lisp/publish.el \
		--funcall org-publish-all

$(SRCWWW)/Makefile: $(SRCWWW)
$(SRCWWW)/publish-common.el: $(SRCWWW)

$(SRCWWW):
	test -d $(SRCWWW) || git clone git@git.sr.ht:~vdemeester/www.git $(SRCWWW)

# Setup and doctor
.PHONY: doctor
doctor:
	@echo "Validate the environment"
	@readlink $(DOTEMACS) || $(error $(DOTEMACS) is not correctly linked, you may need to run setup)
	@readlink $(DOTNIXPKGS) || $(error $(DOTNIXPKGS) is not correctly linked, you may need to run setup)

.PHONY: setup
setup: $(DOTEMACS) $(DOTGNUS) $(DOTNIXPKGS) $(ETCNIXOS) $(SYNCDIR)

$(DOTEMACS):
	@echo "Link $(DOTEMACS) to $(CURDIR)/tools/emacs"
	@ln -s $(CURDIR)/tools/emacs $(DOTEMACS)

$(DOTGNUS):
	@echo "Link $(DOTGNUs) to $(CURDIR)/tools/gnus"
	@ln -s $(CURDIR)/tools/gnus $(DOTGNUS)

$(DOTNIXPKGS):
	@echo "Link $(DOTNIXPKGS) to $(CURDIR)"
	@ln -s $(CURDIR) $(DOTNIXPKGS)

$(ETCNIXOS):
	@if test $(USER) = root;\
	then\
		echo "Link $(ETCNIXOS) $(CURDIR)";\
		ln -s $(CURDIR) $(ETCNIXOS);\
	fi

$(SYNCDIR):
	$(error $(SYNCDIR) is not present, you need to configure syncthing before running this command)
