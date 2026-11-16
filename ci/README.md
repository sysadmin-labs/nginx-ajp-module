# What is here, and what is missing

`build.sh`, `apt-get.sh` and `fetch-verify.sh` are the same in every module
repository here.

**There is no reload gate yet.** A reload test has to ask the module a
question only it can answer; for this module that means an AJP backend to
proxy to, and AJP is a binary protocol, so the backend has to be written
before the gate can exist. Until then the reload workflow is absent rather
than present and passing on something it does not check.

**And `t/` barely reaches the module.** Every request in the suite goes to
a location with `return 200`, except the one that asks for a 502 from an
unreachable backend. `src/ngx_http_ajp.c` and `src/ngx_http_ajp_msg.c`,
which are the protocol, execute in none of them: valgrind and the
sanitizers run green over code they never enter. The same AJP backend is
what would change that, so this is one piece of work and not two. Worth
knowing when reading the badges: they say the module builds clean and
parses what it should, not that its protocol handling has been measured.
