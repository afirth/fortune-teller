.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

export GCLOUD_PROJECT := $(shell gcloud config get-value project 2>/dev/null)

#templates = kustomization.yaml
manifest = ./generated/manifest.yaml

linkerd_args += --proxy-image=gcr.io/linkerd-io/proxy:ver-protocol-error-fix-0
linkerd_args += --proxy-log-level=warn,linkerd2_proxy=info,h2=debug

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
.PHONY: $(templates)
$(templates): %.yaml: %.yaml.tmpl
	envsubst < $^ > $@

.PHONY: linkerd-inject
linkerd-inject:
	linkerd inject $(linkerd_args) $(manifest) > $(manifest).swp \
		&& mv $(manifest).swp $(manifest)

.PHONY: linkerd-uninject
linkerd-uninject:
	linkerd uninject $(linkerd_args) $(manifest) > $(manifest).swp \
		&& mv $(manifest).swp $(manifest)
