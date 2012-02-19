VPATH = functions
BUILD = _build
SCRIPTS = scripts

base_functions = \
	autoworkon \
	cdsitepackages \
	cdvirtualenv \
	find_in_parents \
	lssitepackages \
	lsvirtualenvs \
	mkvirtualenv \
	rmvirtualenv \
	virtualenv_sh_add_hook \
	virtualenv_sh_init \
	virtualenv_sh_init_features \
	virtualenv_sh_remove_hook \
	virtualenv_sh_restore_options \
	virtualenv_sh_run_global_hook \
	virtualenv_sh_run_hook \
	virtualenv_sh_run_hook_functions \
	virtualenv_sh_run_local_hook \
	virtualenv_sh_save_options \
	virtualenv_sh_site_packages_path \
	virtualenv_sh_verify_active_virtualenv \
	virtualenv_sh_verify_workon_home \
	virtualenv_sh_virtualenvs \
	workon

bash_functions = \
	bash/_virtualenv_sh_complete_cdvirtualenv \
	bash/_virtualenv_sh_complete_sitepackages \
	bash/_virtualenv_sh_complete_virtualenvs \
	bash/virtualenv_sh_init_features

zsh_functions = \
	zsh/_virtualenv_sh_complete_virtualenvs \
	zsh/virtualenv_sh_add_hook \
	zsh/virtualenv_sh_complete_cdvirtualenv \
	zsh/virtualenv_sh_complete_sitepackages \
	zsh/virtualenv_sh_init_features \
	zsh/virtualenv_sh_remove_hook


all: sh bash zsh

sh: build-prep $(SCRIPTS)/virtualenv-sh.sh
$(SCRIPTS)/virtualenv-sh.sh: $(base_functions)
	rm $(BUILD)/* || true
	cp $^ $(BUILD)
	sh bin/build-monolithic.sh $(BUILD)/* > $(SCRIPTS)/virtualenv-sh.sh
	@echo

bash: build-prep $(SCRIPTS)/virtualenv-sh.bash
$(SCRIPTS)/virtualenv-sh.bash: $(base_functions) $(bash_functions)
	rm $(BUILD)/* || true
	cp $^ $(BUILD)
	sh bin/build-monolithic.sh $(BUILD)/* > $(SCRIPTS)/virtualenv-sh.bash
	@echo

zsh: build-prep $(SCRIPTS)/virtualenv-sh.zsh $(SCRIPTS)/virtualenv-sh.zwc
$(SCRIPTS)/virtualenv-sh.zsh $(SCRIPTS)/virtualenv-sh.zwc: $(base_functions) $(zsh_functions)
	rm $(BUILD)/* || true
	cp $^ $(BUILD)
	sh bin/build-monolithic.sh $(BUILD)/* > $(SCRIPTS)/virtualenv-sh.zsh
	if [ $$(which zsh) ]; then zsh -c "zcompile -U $(SCRIPTS)/virtualenv-sh.zwc $(BUILD)/*"; fi
	@echo

build-prep:
	mkdir -p $(SCRIPTS)
	mkdir -p $(BUILD)


install: install-sh install-bash install-zsh

install-sh: sh
	cp $(SCRIPTS)/virtualenv-sh.sh /usr/local/bin

install-bash: bash
	cp $(SCRIPTS)/virtualenv-sh.bash /usr/local/bin

install-zsh: zsh
	cp $(SCRIPTS)/virtualenv-sh.zsh /usr/local/bin
	if [ -e $(SCRIPTS)/virtualenv-sh.zwc ]; then cp $(SCRIPTS)/virtualenv-sh.zwc /usr/local/bin; fi


clean:
	rm -rf $(BUILD)/* || true
	rm -rf $(SCRIPTS)/* || true


test: test-sh test-bash test-ksh test-zsh

test-sh: sh
	@echo Testing with $$(which sh)
	@cd test; if [ $$(which sh) ]; then sh ./test.sh ../$(SCRIPTS)/virtualenv-sh.sh; else echo "sh is not in the path"; fi
	@echo

test-bash: bash
	@echo Testing with $$(which bash)
	@cd test; if [ $$(which bash) ]; then bash ./test.sh ../$(SCRIPTS)/virtualenv-sh.bash; else echo "bash is not in the path"; fi
	@echo

test-ksh: sh
	@echo Testing with $$(which ksh)
	@cd test; if [ $$(which ksh) ]; then ksh ./test.sh ../$(SCRIPTS)/virtualenv-sh.sh; else echo "ksh is not in the path"; fi
	@echo

# The current version of shunit2 doesn't seem to play well with zsh, but here
# it is.
test-zsh: zsh
	@echo Testing with $$(which zsh)
	@cd test; if [ $$(which zsh) ]; then zsh ./test.sh ../$(SCRIPTS)/virtualenv-sh.zsh; else echo "zsh is not in the path"; fi
	@echo
