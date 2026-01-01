% =========================
% PROJECT METADATA
% =========================

project(name('aura-core')).
project(version('0.1.0')).
project(language(prolog)).
project(entry('src/main.pl')).

% =========================
% RUNTIME (CDN EXECUTOR)
% =========================

runtime(cdn).
runtime(target(wasm)).
runtime(cache(true)).
runtime(parallel(true)).

% =========================
% SOURCES
% =========================

source(app, 'src/**/*.pl').
source(test, 'tests/**/*.pl').
source(data, 'data/**/*.facts').

% =========================
% BUILD TARGETS
% =========================

target(build).
target(test).
target(package).
target(boot).

depends(build, []).
depends(test, [build]).
depends(package, [test]).
depends(boot, [package]).

% =========================
% OUTPUTS
% =========================

output(build, 'out/build/core.logic').
output(test, 'out/test/report.json').
output(package, 'out/pkg/aura.pkg').
output(boot, 'out/run/runtime.state').

% =========================
% BUILD RULES (LOGIC)
% =========================

rule(build) :-
    collect(source(app), Files),
    normalize(Files),
    compile(Files).

rule(test) :-
    collect(source(test), Tests),
    run_tests(Tests).

rule(package) :-
    bundle(output(build), output(test)),
    sign(package).

rule(boot) :-
    load(output(package)),
    init_facts,
    start_inference.

% =========================
% AI / LOGIC INITIALIZATION
% =========================

fact(memory(ephemeral)).
fact(reasoning(backward)).
fact(conflict_resolution(priority)).

init_facts :-
    load(source(data)),
    assert(runtime_ready).

% =========================
% CI / CDN HOOKS
% =========================

on_success :-
    emit('BUILD_OK'),
    upload(output(package)).

on_failure :-
    emit('BUILD_FAILED'),
    halt.
