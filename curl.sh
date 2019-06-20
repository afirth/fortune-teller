#!/usr/bin/env bash
set -eux -o pipefail

grpcurl -v fortune-teller.tree.outstandingwombat.com:443 build.stack.fortune.FortuneTeller/Predict
# grpcurl -v -insecure fortune-teller.tree.outstandingwombat.com:443 build.stack.fortune.FortuneTeller/Predict
