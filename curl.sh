#!/usr/bin/env bash
set -eux -o pipefail

grpcurl -insecure fortune-teller.tree.outstandingwombat.com:443 build.stack.fortune.FortuneTeller/Predict
