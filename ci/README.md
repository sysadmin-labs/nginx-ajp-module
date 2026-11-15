# What is here, and what is missing

`build.sh`, `apt-get.sh` and `fetch-verify.sh` are the same in every module
repository here.

**There is no reload gate yet.** A reload test has to ask the module a
question only it can answer; for this module that means an AJP backend to
proxy to, and AJP is a binary protocol, so the backend has to be written
before the gate can exist. Until then the reload workflow is absent rather
than present and passing on something it does not check.
