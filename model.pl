:- module(model, [
    create_exam_times/2,
    h1_constraints/2,
    h2_constraints/2,
    symmetry_breaking/2,
    second_epoch/2
]).

:- use_module(library(clpfd)).
    :- use_module(data_loading).

% Create decision variables for exam times
create_exam_times(Times1, Times2) :-
    num_courses(N),
    length(Times1, N),
    length(Times2, N),
    Times1 ins 1..16,
    Times2 ins 17..28.

% H1 constraint predicate
h1_constraints(Times1, Times2) :-
% Hard constraints for first epoch
    findall((I,J), (conflict(1, I, J, C), C > 0, I < J), Pairs1),
    maplist(no_same_slot(Times1), Pairs1),
% Hard constraints for second epoch
    findall((I,J), (conflict(2, I, J, C), C > 0, I < J), Pairs2),
    maplist(no_same_slot(Times2), Pairs2).

% Helper predicate to enforce no same slot for conflicting exams
no_same_slot(Times, (I,J)) :-
    nth0(I, Times, Ti),
    nth0(J, Times, Tj),
    Ti #\= Tj.

% Symmetry breaking constraints
symmetry_breaking(Times1, Times2) :-
% First exam of first epoch is in the first timeslot
    Times1 = [T0|_],
    T0 #= 1,
% First exam of second epoch should be after the first epoch
    Times2 = [T1|_],
    T1 #>= T0.

% Calculate the window of days between exams of first and second epoch
distance_window(T1, Min, Max) :-
    T1 #=< 5  #<==> B1,
    T1 #>= 6 #/\ T1 #=< 10 #<==> B2,
    T1 #>= 11 #<==> B3,
    Min #= B1*18 + B2*13 + B3*10,
    Max #= B1*23 + B2*20 + B3*18.

% Predicate to check if two exams are the same course in different epochs
second_epoch(I, J) :-
    course_exam_name(1, I, Name),
    course_exam_name(2, J, Name),
    !.

% H2 constraint predicate
h2_constraints(Times1, Times2) :-
    forall(
        second_epoch(I, J),
        (
            nth0(I, Times1, T1),
            nth0(J, Times2, T2),
            T2 #> T1,
            Dist #= T2 - T1,
            distance_window(T1, Min, Max),
            Dist #>= Min,
            Dist #=< Max
        )
    ).

