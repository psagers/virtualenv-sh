VPATH = functions

base_functions = \
	cdsitepackages \
	cdvirtualenv \
	lssitepackages \
	lsvirtualenvs \
	mkvirtualenv \
	rmvirtualenv \
	virtualenv_sh_add_hook \
	virtualenv_sh_init \
	virtualenv_sh_init_shell \
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
	bash/virtualenv_sh_init_shell

zsh_functions = \
	zsh/_virtualenv_sh_complete_virtualenvs \
	zsh/virtualenv_sh_add_hook \
	zsh/virtualenv_sh_complete_cdvirtualenv \
	zsh/virtualenv_sh_complete_sitepackages \
	zsh/virtualenv_sh_init_shell \
	zsh/virtualenv_sh_remove_hook


all: sh bash zsh

sh: build/virtualenv-sh.sh
build/virtualenv-sh.sh: $(base_functions)
	@mkdir -p build/sh
	cp $^ build/sh
	bin/build-monolithic.sh build/sh/* > build/virtualenv-sh.sh
	@rm -r build/sh
	@echo

bash: build/virtualenv-sh.bash
build/virtualenv-sh.bash: $(base_functions) $(bash_functions)
	@mkdir -p build/bash
	cp $^ build/bash
	bin/build-monolithic.sh build/bash/* > build/virtualenv-sh.bash
	@rm -r build/bash
	@echo

zsh: build/virtualenv-sh.zsh build/virtualenv-sh.zwc
build/virtualenv-sh.zsh build/virtualenv-sh.zwc: $(base_functions) $(zsh_functions)
	@mkdir -p build/zsh
	cp $^ build/zsh
	bin/build-monolithic.sh build/zsh/* > build/virtualenv-sh.zsh
	bin/compile-all.zsh build/zsh/*
	@rm -r build/zsh
	@echo

install: all
	cp build/* /usr/local/bin

clean:
	rm -rf build/*


test: test-bash test-ksh test-zsh

test-bash: bash
	@echo Testing with $$(which bash)
	@cd test; if [ $$(which bash) ]; then bash ./test.sh ../build/virtualenv-sh.bash; else echo "bash is not in the path"; fi

test-ksh: sh
	@echo Testing with $$(which ksh)
	@cd test; if [ $$(which ksh) ]; then ksh ./test.sh ../build/virtualenv-sh.sh; else echo "ksh is not in the path"; fi

test-zsh: zsh
	@echo Testing with $$(which zsh)
	@cd test; if [ $$(which zsh) ]; then zsh ./test.sh ../build/virtualenv-sh.zsh; else echo "zsh is not in the path"; fi
