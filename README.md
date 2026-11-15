# nginx-ajp-module

[![Build][build-test-badge]][build-test-link]
[![Lint][lint-badge]][lint-link]
[![CodeQL][codeql-badge]][codeql-link]
[![A/UBSan][sanitizers-badge]][sanitizers-link]
[![Valgrind][valgrind-badge]][valgrind-link]
[![FreeBSD][freebsd-badge]][freebsd-link]

[build-test-badge]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/build-test.yml/badge.svg
[build-test-link]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/build-test.yml
[lint-badge]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/lint.yml/badge.svg
[lint-link]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/lint.yml
[codeql-badge]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/codeql.yml/badge.svg
[codeql-link]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/codeql.yml
[sanitizers-badge]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/sanitizers.yml/badge.svg
[sanitizers-link]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/sanitizers.yml
[valgrind-badge]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/valgrind.yml/badge.svg
[valgrind-link]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/valgrind.yml
[freebsd-badge]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/freebsd.yml/badge.svg
[freebsd-link]: https://github.com/sysadmin-labs/nginx-ajp-module/actions/workflows/freebsd.yml

Proxy to a backend over AJP, the binary protocol Tomcat and Jetty speak on
their connector port, instead of putting HTTP in front of it.

AJP carries the request in a compact binary form with the common headers
as single bytes, and it keeps the connection, so there is less to parse and
fewer handshakes than with `proxy_pass` to an HTTP connector.

## Where this comes from

Weibin Yao wrote this module. His repository stopped in March 2020, and the
derivative the FreeBSD port built from, Vadim Misbakh-Soloviov's, stopped
in August 2021 — so the port has been building from a fork of a dead
project. This continues the derivative, which is the newer of the two
despite the commit counts: it carries the fix for `space_in_uri`, a field
nginx removed, and it has the merge conflict markers the original still has
in its sources resolved.

Both histories are here. The original is where the code comes from, the
derivative is where it was last touched.

Nothing in the module itself needed changing so far. What is new is the
scaffolding: a build against the releases the ports ship, the sanitizers,
valgrind, CodeQL and a FreeBSD run. There is no reload gate yet, and
`ci/README.md` says why.

## Requirements

nginx 1.28 or newer. Nothing beyond what nginx itself needs.

## Building

```sh
./configure --add-module=/path/to/nginx-ajp-module
```

As a loadable module, `--add-dynamic-module=` and then

```nginx
load_module modules/ngx_http_ajp_module.so;
```

## Quick start

```nginx
upstream tomcat {
    server 127.0.0.1:8009;
    keepalive 16;
}

server {
    location / {
        ajp_keep_conn on;
        ajp_pass      tomcat;
    }
}
```

The port is Tomcat's AJP connector, 8009 by default, not 8080. Modern
Tomcat binds it to localhost and requires a secret; give that secret as
the second argument to `ajp_pass`.

## Directives

The full set, with what each one takes, is in `README.upstream.md`. They
follow nginx's own proxy directives closely: `ajp_pass`,
`ajp_connect_timeout`, `ajp_read_timeout`, `ajp_buffer_size`,
`ajp_buffers`, `ajp_busy_buffers_size`, `ajp_hide_header`,
`ajp_pass_header`, `ajp_next_upstream`, `ajp_intercept_errors`, the
`ajp_cache*` family, and a few of its own:

### ajp\_pass

|Syntax |`ajp_pass address \| upstream [secret]`|
|-------|---|
|Default|none|
|Context|location, limit\_except|

The backend, and optionally the secret its connector requires.

### ajp\_keep\_conn

|Syntax |`ajp_keep_conn on \| off`|
|-------|---|
|Default|`off`|
|Context|http, server, location|

Keep the AJP connection open after the response. Needed for `keepalive`
in the upstream block to do anything.

### ajp\_header\_packet\_buffer\_size

|Syntax |`ajp_header_packet_buffer_size size`|
|-------|---|
|Default|`8k`|
|Context|http, server, location|

The buffer the request header packet is built in. AJP caps a packet at
8 KB, so this cannot usefully be larger, and a request whose headers do
not fit is refused.

### ajp\_max\_data\_packet\_size

|Syntax |`ajp_max_data_packet_size size`|
|-------|---|
|Default|`8k`|
|Context|http, server, location|

The largest body chunk sent in one packet, between 8 KB and 64 KB.

### ajp\_script\_url

|Syntax |`ajp_script_url uri`|
|-------|---|
|Default|none|
|Context|http, server, location|

Sent to the backend as the `SCRIPT_URL` attribute. May contain variables.

## Testing

```sh
ci/build.sh 1.30.6 /tmp/nginx-test
TEST_NGINX_BINARY=/tmp/nginx-test/sbin/nginx prove -r t/
```

The suite does not proxy anything: AJP is binary, and a stand-in for a
Tomcat connector has to be written before that can be tested. What it asks
is what nginx accepts — which is the part that breaks when the module meets
a newer nginx — that the wrong configurations are refused, and that a
request to an unreachable backend fails rather than taking the worker down.

## License

BSD 2-Clause. See `LICENSE`.
