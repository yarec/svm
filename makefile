
scripts= common.sh \
		 git.sh \
		 scsh.sh \
		 install-main.sh

install.sh: $(foreach x, $(scripts), shell/funcs/$(x))
	@cat $^ > $@
