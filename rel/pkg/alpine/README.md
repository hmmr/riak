# Packaging Riak for Alpine Linux

Alpine Linux is a minimalistic, Gentoo-inspired distribution.

Packaging instructions for Alpine cannot be placed in
rel/pkg/alpine/Makefile without bending too many rules and
conventions.

Instead, TI Tokyo builds and publishes riak apk packages in its own
repository at https://files-source.tiot.jp/alpine/v3.x. To make it available locally,
users are encouraged to:

1. Add this entry to /etc/apk/repositories:

```
http://files-source.tiot.jp/alpine/v3.xx/main
```
where _xx_ is the latest version of alpine linux release (currently 18).

2. Download the public key from
https://files.tiot.jp/alpine/alpine@tiot.jp.rsa.pub and add it
to /etc/apk/keys.

With this done, riak, riak-cs and riak-ts will become available via
regular `apk add`. To install a particular version, do `apk add
riak=3.2.0.25-r0`, where the fourth element of the version indicates
the OTP version with which it was built.
