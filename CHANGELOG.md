# Changelog

## 0.3.1

First release from this repository, carrying on from upstream's v0.3.0. It
continues Vadim Misbakh-Soloviov's derivative of Weibin Yao's module, with
both histories intact; the derivative stopped in August 2021 and the
original in March 2020.

The derivative is the newer of the two despite what the commit counts
suggest: it carries the fix for `space_in_uri`, a field nginx removed, and
has the merge conflict markers the original still has in its sources
resolved.

### Added

- Continuous integration against nginx 1.28, 1.30 and 1.31, statically and
  dynamically, with sanitizers, valgrind, CodeQL and a FreeBSD run.
- `t/00-directives.t` for what the directives accept and refuse, and that
  an unreachable backend fails rather than taking the worker down.
- `LICENSE`. The terms were only ever stated in the README; the file now
  carries them, two-clause BSD, with the copyright holders named.

### Changed

- Sources moved to `src/`.
- `config` no longer runs a feature test that tested nothing (`int a;`) in
  order to reach its real work, and the pre-1.9.11 branch is gone.
- The duplicate `README` and `README.wiki` are gone; `README.markdown` is
  kept as `README.upstream.md` for the full directive reference.
