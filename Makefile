include templates.mk

all: $(TEMPLATES)

template-dir-%:
	mkdir -p templates/$*

templates/%/.init: template-dir-%
	git remote get-url $(REMOTE_BASE)$* || git remote add $(REMOTE_BASE)$* $(GIT_URL_BASE)$*
	touch $@

templates/%/docker-compose.yml:
	make templates/$(firstword $(subst /, ,$*))/.init
	git subtree add -P templates/$* $(REMOTE_BASE)$(firstword $(subst /, ,$*)) $(lastword $(subst /, ,$*))

$(TEMPLATES): %: templates/%/.init
	make $(addprefix templates/$*/, $(addsuffix /docker-compose.yml, $(shell git ls-remote --tags $(REMOTE_BASE)$*|grep -v -E '\^\{\}$$'|cut -d'/' -f3)))
