#!/usr/bin/env bash
set -eux -o pipefail

grpcurl -plaintext fortune-teller.tree.outstandingwombat.com:80 build.stack.fortune.FortuneTeller/Predict
