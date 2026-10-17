:- module(optimization, [
    minimize_schedule/3
]).

:- use_module(library(clpfd)).

% Minimize predicate
minimize_schedule(Times1, Times2, TotalCost) :-
    append(Times1, Times2, AllTimes),
    labeling([ffc, min(TotalCost)], [TotalCost|AllTimes]).