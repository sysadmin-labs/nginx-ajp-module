# The directives parse, and the ones that are wrong are refused.
#
# There is no AJP backend here, so nothing is proxied: AJP is a binary
# protocol and a stand-in for it has to be written before the proxying
# itself can be tested.  What is asked here is what nginx accepts, which
# is the part that breaks when the module is built against a newer nginx.

use Test::Nginx::Socket 'no_plan';

repeat_each(1);
run_tests();

__DATA__

=== TEST 1: ajp_pass with an upstream block
--- http_config
    upstream tomcat {
        server 127.0.0.1:8009;
    }
--- config
    location /t {
        ajp_pass tomcat;
    }
    location /ok { return 200 "ok\n"; }
--- request
GET /ok
--- response_body
ok



=== TEST 2: ajp_pass with an address
--- config
    location /t {
        ajp_pass 127.0.0.1:8009;
    }
    location /ok { return 200 "ok\n"; }
--- request
GET /ok
--- response_body
ok



=== TEST 3: the buffer, timeout and header directives
--- http_config
    upstream tomcat { server 127.0.0.1:8009; }
--- config
    location /t {
        ajp_pass                       tomcat;
        ajp_buffer_size                8k;
        ajp_buffers                    8 16k;
        ajp_busy_buffers_size          32k;
        ajp_header_packet_buffer_size  8k;
        ajp_max_data_packet_size       8k;
        ajp_connect_timeout            5s;
        ajp_read_timeout               30s;
        ajp_keep_conn                  on;
        ajp_ignore_client_abort        off;
        ajp_intercept_errors           on;
        ajp_pass_request_body          on;
        ajp_pass_request_headers       on;
        ajp_hide_header                X-Powered-By;
        ajp_script_url                 /index.jsp;
        ajp_pass_header                X-Accel-Redirect;
        ajp_next_upstream              error timeout http_500;
    }
    location /ok { return 200 "ok\n"; }
--- request
GET /ok
--- response_body
ok



=== TEST 4: the cache directives
--- http_config
    upstream tomcat { server 127.0.0.1:8009; }
    ajp_cache_path /tmp/ajp-test-cache levels=1:2 keys_zone=ajptest:1m;
--- config
    location /t {
        ajp_pass              tomcat;
        ajp_cache             ajptest;
        ajp_cache_key         "$scheme$request_method$host$request_uri";
        ajp_cache_valid       200 1m;
        ajp_cache_methods     GET HEAD;
        ajp_cache_min_uses    2;
        ajp_cache_use_stale   error timeout;
        ajp_cache_lock        on;
        ajp_cache_lock_timeout 3s;
    }
    location /ok { return 200 "ok\n"; }
--- request
GET /ok
--- response_body
ok



=== TEST 5: a secret can be given as the second argument
--- http_config
    upstream tomcat { server 127.0.0.1:8009; }
--- config
    location /t {
        ajp_pass tomcat secretword;
    }
    location /ok { return 200 "ok\n"; }
--- request
GET /ok
--- response_body
ok



=== TEST 6: two ajp_pass in one location are refused
--- http_config
    upstream tomcat { server 127.0.0.1:8009; }
--- config
    location /t {
        ajp_pass tomcat;
        ajp_pass tomcat;
    }
--- must_die
--- error_log
is duplicate



=== TEST 7: ajp_buffers with a count of one is refused
--- http_config
    upstream tomcat { server 127.0.0.1:8009; }
--- config
    location /t {
        ajp_pass     tomcat;
        ajp_buffers  1 4k;
    }
--- must_die



=== TEST 8: a request to a location without a backend fails, it does not crash
--- config
    location /t {
        ajp_pass 127.0.0.1:1;
        ajp_connect_timeout 1s;
    }
--- request
GET /t
--- error_code: 502
