:- module(main, [main/0]).

:- use_module(library(clpfd)).
:- use_module(data_loading).
:- use_module(model).
:- use_module(soft_constraints).
:- use_module(optimization).
:- use_module(output).

main :-
    load_deetc,
    create_exam_times(Times1, Times2),
    symmetry_breaking(Times1, Times2),
    h1_constraints(Times1, Times2),
    h2_constraints(Times1, Times2),
    s1_cost(Times1, 1, Cost1),
    s1_cost(Times2, 2, Cost2),
    TotalCost #= Cost1 + Cost2,
    minimize_schedule(Times1, Times2, TotalCost),
    write_all_programme_csvs(Times1, Times2),
    write_combined_csv('deetc_timetable.csv', Times1, Times2),
    format("Total penalty: ~w~n", [TotalCost]),
    !.
