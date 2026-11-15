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

37 of them, read out of the module's own command tables, so this is the
whole set and the contexts are the ones the code enforces. Most follow
nginx's own proxy directives of the same name; the ones particular to AJP
are described below the table.

|Directive|Context|Takes|
|---|---|---|
|`ajp_buffer_size`|http, server, location|1 argument|
|`ajp_buffers`|http, server, location|2 arguments|
|`ajp_busy_buffers_size`|http, server, location|1 argument|
|`ajp_cache`|http, server, location|on | off|
|`ajp_cache_key`|http, server, location|on | off|
|`ajp_cache_lock`|http, server, location|on | off|
|`ajp_cache_lock_timeout`|http, server, location|1 argument|
|`ajp_cache_methods`|http, server, location|1 or more arguments|
|`ajp_cache_min_uses`|http, server, location|1 argument|
|`ajp_cache_path`|http|2 or more arguments|
|`ajp_cache_use_stale`|http, server, location|1 or more arguments|
|`ajp_cache_valid`|http, server, location|1 or more arguments|
|`ajp_connect_timeout`|http, server, location|1 argument|
|`ajp_header_packet_buffer_size`|http, server, location|1 argument|
|`ajp_hide_header`|http, server, location|on | off|
|`ajp_ignore_client_abort`|http, server, location|on | off|
|`ajp_ignore_headers`|http, server, location|1 or more arguments|
|`ajp_intercept_errors`|http, server, location|on | off|
|`ajp_keep_conn`|http, server, location|on | off|
|`ajp_max_data_packet_size`|http, server, location|1 argument|
|`ajp_max_temp_file_size`|http, server, location|1 argument|
|`ajp_next_upstream`|http, server, location|1 or more arguments|
|`ajp_pass`|location, if|1 or 2 arguments|
|`ajp_pass_header`|http, server, location|on | off|
|`ajp_pass_request_body`|http, server, location|on | off|
|`ajp_pass_request_headers`|http, server, location|on | off|
|`ajp_read_timeout`|http, server, location|1 argument|
|`ajp_script_url`|http, server, location|1 argument|
|`ajp_secret`|location, if|1 argument|
|`ajp_send_lowat`|http, server, location|1 argument|
|`ajp_send_timeout`|http, server, location|1 argument|
|`ajp_store`|http, server, location|1 argument|
|`ajp_store_access`|http, server, location|1 to 3 arguments|
|`ajp_temp_file_write_size`|http, server, location|1 argument|
|`ajp_temp_path`|http, server, location|1 to 4 arguments|
|`ajp_upstream_fail_timeout`|http, server, location|1 argument|
|`ajp_upstream_max_fails`|http, server, location|1 argument|

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
