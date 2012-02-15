VPATH = functions

base_functions = \
	cdsitepackages \
	cdvirtualenv \
	lssitepackages \
	lsvirtualenvs \
	mkvirtualenv \
	rmvirtualenv \
	virtualenv_sh_init \
	virtualenv_sh_run_global_hook \
	virtualenv_sh_run_hook \
	virtualenv_sh_run_local_hook \
	virtualenv_sh_site_packages_path \
	virtualenv_sh_verify_active_virtualenv \
	virtualenv_sh_verify_workon_home \
	virtualenv_sh_virtualenvs \
	workon

sh_functions   = sh/virtualenv_sh_init_completion

bash_functions = bash/virtualenv_sh_init_completion

zsh_functions  = \
	zsh/virtualenv_sh_init_completion \
	zsh/virtualenv_sh_complete_cdvirtualenv \
	zsh/virtualenv_sh_complete_cdsitepackages \
	zsh/_virtualenv_sh_complete_virtualenvs


all: sh bash zsh

sh: build/virtualenv-sh.sh
build/virtualenv-sh.sh: $(base_functions) $(sh_functions)
	@mkdir -p build
	bin/build-monolithic.sh $^ > build/virtualenv-sh.sh
	@echo

bash: build/virtualenv-sh.bash
build/virtualenv-sh.bash: $(base_functions) $(bash_functions)
	@mkdir -p build
	bin/build-monolithic.sh $^ > build/virtualenv-sh.bash
	@echo

zsh: build/virtualenv-sh.zsh build/virtualenv-sh.zwc
build/virtualenv-sh.zsh build/virtualenv-sh.zwc: $(base_functions) $(zsh_functions)
	@mkdir -p build
	bin/build-monolithic.sh $^ > build/virtualenv-sh.zsh
	bin/compile-all.zsh $^
	@echo


install: all
	cp build/* /usr/local/bin

clean:
	rm -f build/*


test: test-bash test-ksh test-zsh

test-bash: bash
	@echo Testing with $$(which bash)
	cd test; if [ $$(which bash) ]; then bash ./test.sh ../build/virtualenv-sh.bash; else echo "bash is not in the path"; fi

test-ksh: ksh
	@echo Testing with $$(which ksh)
	cd test; if [ $$(which ksh) ]; then ksh ./test.sh ../build/virtualenv-sh.sh; else echo "ksh is not in the path"; fi

test-zsh: zsh
	@echo Testing with $$(which zsh)
	cd test; if [ $$(which zsh) ]; then zsh ./test.sh ../build/virtualenv-sh.zsh; else echo "zsh is not in the path"; fi
