HOME ?= `$HOME`
PWD ?= `pwd`

explain: ## Provide the explanation of how to use the Makefile
	### Welcome
	#
	#       _       _    __ _ _
	#    __| | ___ | |_ / _(_) | ___  ___
	#   / _` |/ _ \| __| |_| | |/ _ \/ __|
	#  | (_| | (_) | |_|  _| | |  __/\__ \
	#   \__,_|\___/ \__|_| |_|_|\___||___/

	#
	### Targets
	@cat Makefile* | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: shellcheck-lint
shellcheck-lint: ## Validate the shell scripts
	docker run --rm -v "${PWD}:/mnt" koalaman/shellcheck:stable **.sh
