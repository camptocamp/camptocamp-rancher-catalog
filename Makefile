include templates.mk

all: $(TEMPLATES)

template-dir-%:
	mkdir -p templates/$*

templates/%/config.yml: template-dir-%
	git remote add $(REMOTE_BASE)$* $(GIT_URL_BASE)$*
	touch $@

templates/%/docker-compose.yml:
	make templates/$(firstword $(subst /, ,$*))/config.yml
	git subtree add -P templates/$* $(REMOTE_BASE)$(firstword $(subst /, ,$*)) $(lastword $(subst /, ,$*))

$(TEMPLATES): %: templates/%/config.yml
	make $(addprefix templates/$*/, $(addsuffix /docker-compose.yml, $(shell git ls-remote --tags $(REMOTE_BASE)$*|grep -v -E '\^\{\}$$'|cut -d'/' -f3)))
