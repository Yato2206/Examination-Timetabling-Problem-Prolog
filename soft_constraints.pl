:- module(soft_constraints, [
    s1_cost/3
]).

:- use_module(library(clpfd)).
:- use_module(data_loading).

% Penalty for a single pair
pair_penalty(Times, Epoch, I, J, Penalty) :-
    conflict(Epoch, I, J, C),
    I < J,
    nth0(I, Times, Ti),
    nth0(J, Times, Tj),
    Dist #= abs(Ti - Tj),
    proximity_weight(Dist, W),
    Penalty #= C * W.

% Helper predicate the calculates proximity weight based on distance
proximity_weight(Dist, Weight) :-
    Dist #= 0 #<==> B0,
    Dist #= 1 #<==> B1,
    Dist #= 2 #<==> B2,
    Dist #= 3 #<==> B3,
    Dist #= 4 #<==> B4,
    Weight #= 16*B0 + 8*B1 + 4*B2 + 2*B3 + 1*B4.

% Total soft cost
s1_cost(Times, Epoch, Cost) :-
    findall(P,
        ( conflict(Epoch, I, J, C),
          I < J,
          nth0(I, Times, Ti),
          nth0(J, Times, Tj),
          Dist #= abs(Ti - Tj),
          proximity_weight(Dist, W),
          P #= C * W
        ),
        Ps),
    sum(Ps, #=, Cost).