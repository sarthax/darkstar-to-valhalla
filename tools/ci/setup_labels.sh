#!/bin/bash
# One-time: create the pipeline labels on valhalla. Review, then run manually (needs `gh auth login`).
set -e
R=sarthax/darkstar-to-valhalla
mk() { gh label create "$1" --repo "$R" --color "$2" --description "$3" --force; }
mk ready            0e8a16 "Spec complete; a worker may pick this up"
mk in-progress      fbca04 "A worker is building this"
mk needs-local-test 1d76db "PR ready for Claude Code local test + integration"
mk tested-ok        0e8a16 "Passed local test; ready to merge --no-ff"
mk failed           d93f0b "Failed local test; see PR comments"
mk needs-id-lookup  5319e7 "Contains TODO(ID needs Claude lookup)"
