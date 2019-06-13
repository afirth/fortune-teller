.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

export GCLOUD_PROJECT := $(shell gcloud config get-value project 2>/dev/null)

# templates = kustomization.yaml
manifest = ./generated/manifest.yaml


#runs kustomize to make one big yaml manifest
.PHONY: all
all: $(templates)
	kustomize build > $(manifest)

.PHONY: install
install: all apply

.PHONY: uninstall
uninstall:
	kubectl delete -f $(manifest)

.PHONY: clean
clean:
	rm $(templates) $(manifest)

#runs kubectl apply on the generated manifest without recompiling
.PHONY: apply
apply: $(templates)
	kubectl apply -f $(manifest)

#runs skaffold
.PHONY: skaffold
skaffold: $(templates) $(targets)
	skaffold run

#calls envsubst to replace things like GCLOUD_PROJECT
$(templates): %.yaml: %.yaml.tmpl
	envsubst < $^ > $@

.PHONY: linkerd-inject
linkerd-inject:
	linkerd inject $(manifest) | kubectl apply -f -

.PHONY: linkerd-uninject
linkerd-uninject:
	linkerd uninject $(manifest) | kubectl apply -f -
