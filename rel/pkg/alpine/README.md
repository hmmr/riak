# Packaging Riak for Alpine Linux

Alpine Linux is a minimalistic, Gentoo-inspired, source-based distribution.

Packaging instructions for Alpine cannot be placed in
rel/pkg/alpine/Makefile without bending too many rules and
conventions.

Instead, the aim is to have the APKBUILDs for
[riak as well as for
erlang-22](https://gitlab.alpinelinux.org/hmmr/aports/-/commit/9a4f91c2f5336a492520c0ae774b95f088a09f96)
merged into the official "community" repo.
