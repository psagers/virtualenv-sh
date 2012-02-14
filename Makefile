VPATH = functions

base_functions = cdsitepackages \
				 cdvirtualenv \
				 lssitepackages \
				 lsvirtualenvs \
				 mkvirtualenv \
				 rmvirtualenv \
				 virtualenv-sh-init \
				 virtualenv-sh-run-global-hook \
				 virtualenv-sh-run-hook \
				 virtualenv-sh-run-local-hook \
				 virtualenv-sh-site-packages-path \
				 virtualenv-sh-verify-active-virtualenv \
				 virtualenv-sh-verify-workon-home \
				 virtualenv-sh-virtualenvs \
				 workon

sh_functions   = sh/virtualenv-sh-init-completion

bash_functions = bash/virtualenv-sh-init-completion

zsh_functions  = zsh/virtualenv-sh-init-completion


sh: $(base_functions) $(sh_functions)
	@mkdir -p build
	@bin/build-monolithic.sh $^ > build/virtualenv-sh.sh

bash: $(base_functions) $(bash_functions)
	@mkdir -p build
	@bin/build-monolithic.sh $^ > build/virtualenv-sh.bash

zsh: $(base_functions) $(zsh_functions)
	@mkdir -p build
	@bin/build-monolithic.sh $^ > build/virtualenv-sh.zsh
	@bin/compile-all.zsh $^
