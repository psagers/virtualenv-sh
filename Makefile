VPATH = functions

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

sh: build/virtualenv-sh.sh
build/virtualenv-sh.sh: $(base_functions)
	@mkdir -p build/sh
	cp $^ build/sh
	sh bin/build-monolithic.sh build/sh/* > build/virtualenv-sh.sh
	@rm -r build/sh
	@echo

bash: build/virtualenv-sh.bash
build/virtualenv-sh.bash: $(base_functions) $(bash_functions)
	@mkdir -p build/bash
	cp $^ build/bash
	sh bin/build-monolithic.sh build/bash/* > build/virtualenv-sh.bash
	@rm -r build/bash
	@echo

zsh: build/virtualenv-sh.zsh build/virtualenv-sh.zwc
build/virtualenv-sh.zsh build/virtualenv-sh.zwc: $(base_functions) $(zsh_functions)
	@mkdir -p build/zsh
	cp $^ build/zsh
	sh bin/build-monolithic.sh build/zsh/* > build/virtualenv-sh.zsh
	if [ $$(which zsh) ]; then zsh bin/compile-all.zsh build/zsh/*; fi
	@rm -r build/zsh
	@echo


install: install-sh install-bash install-zsh

install-sh: sh
	cp build/virtualenv-sh.sh /usr/local/bin

install-bash: bash
	cp build/virtualenv-sh.bash /usr/local/bin

install-zsh: zsh
	cp build/virtualenv-sh.zsh /usr/local/bin
	if [ -e build/virtualenv-sh.zwc ]; then cp build/virtualenv-sh.zwc /usr/local/bin; fi


clean:
	rm -rf build/*


test: test-sh test-bash test-ksh test-zsh

test-sh: sh
	@echo Testing with $$(which sh)
	@cd test; if [ $$(which sh) ]; then sh ./test.sh ../build/virtualenv-sh.sh; else echo "sh is not in the path"; fi
	@echo

test-bash: bash
	@echo Testing with $$(which bash)
	@cd test; if [ $$(which bash) ]; then bash ./test.sh ../build/virtualenv-sh.bash; else echo "bash is not in the path"; fi
	@echo

test-ksh: sh
	@echo Testing with $$(which ksh)
	@cd test; if [ $$(which ksh) ]; then ksh ./test.sh ../build/virtualenv-sh.sh; else echo "ksh is not in the path"; fi
	@echo

# The current version of shunit2 doesn't seem to play well with zsh, but here
# it is.
test-zsh: zsh
	@echo Testing with $$(which zsh)
	@cd test; if [ $$(which zsh) ]; then zsh ./test.sh ../build/virtualenv-sh.zsh; else echo "zsh is not in the path"; fi
	@echo
