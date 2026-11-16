# Changelog

## 0.3.2

First release from this repository, carrying on from upstream's v0.3.0. It
continues Vadim Misbakh-Soloviov's derivative of Weibin Yao's module, with
both histories intact; the derivative stopped in August 2021 and the
original in March 2020.

This replaces 0.3.1, whose archive still carried the upstream test tree:
Test::Base, Spiffy and Module::Install, which are Artistic or GPL and not
the two-clause BSD this repository states.

The derivative is the newer of the two despite what the commit counts
suggest: it carries the fix for `space_in_uri`, a field nginx removed,
which the original does not build without.

Both of them left merge conflicts in the sources, the original as plain
markers and the derivative by commenting the markers and one side out.
They are resolved here, see below.

### Added

- Continuous integration against nginx 1.28, 1.30 and 1.31, statically and
  dynamically, with sanitizers, valgrind, CodeQL and a FreeBSD run.
- `t/00-directives.t` for what the directives accept and refuse, and that
  an unreachable backend fails rather than taking the worker down.
- `LICENSE`. The terms were only ever stated in the README; the file now
  carries them, two-clause BSD, with the copyright holders named.

### Fixed

- Three merge conflicts resolved rather than commented out, in
  `ajp_marshal_into_msgb` and in `ngx_http_ajp_merge_loc_conf`, which is
  the request marshaller and the merge function. Each one was decided on
  what the two sides actually differ in: this derivative sends
  `SCRIPT_URL` and compiles the script for it, upstream has neither, and
  the rest was the same code wrapped differently. The dead side and the
  markers are gone.
- `ajp_msg_peek_uint16` read the first byte twice instead of the second:
  the parenthesis sat around `*buf->pos + 1`, so one was added to the
  value of the high byte. Its only caller masks the result with `0xFF00`
  and so never looked at the low byte, which is why nothing failed.

### Changed

- Sources moved to `src/`.
- `config` no longer runs a feature test that tested nothing (`int a;`) in
  order to reach its real work, and the pre-1.9.11 branch is gone.
- The duplicate `README` and `README.wiki` are gone, and the directives
  are documented here instead of in a copy of upstream's reference.
- The commented-out `ajp_param` entry is gone. It named a field the
  configuration structure does not have and a merge function that was
  never written, so the directive could not have worked; the comment only
  made it look as though it might.
- The directive table in the README now states what each directive takes
  as the code enforces it. Four entries said `on | off` because they
  carry `NGX_CONF_FLAG`, which in nginx means one argument and nothing
  about its value: `ajp_cache` takes a zone or `off`, `ajp_cache_key` a
  key, `ajp_hide_header` and `ajp_pass_header` a header name.
  `ajp_pass` was listed with `limit_except`, which it does not have.
