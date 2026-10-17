:- module(output, [
    write_all_programme_csvs/2,
    write_combined_csv/3
]).

:- use_module(data_loading).

% Write the csv files for all programmes
write_all_programme_csvs(Times1, Times2) :-
    all_programmes(Programmes),
    forall(
        member(P, Programmes),
        write_programme_csv(P, Times1, Times2)
    ).

% Helper predicate to write programme specific CSV files
write_programme_csv(Programme, Times1, Times2) :-
    atomic_list_concat([Programme, '_timetable.csv'], File),
    open(File, write, Stream),
    format(Stream, "programme,epoch,course,semester,year,day~n", []),
    write_epoch_programme_csv(Stream, Programme, 1, Times1),
    write_epoch_programme_csv(Stream, Programme, 2, Times2),
    close(Stream).

% Helper predicate to write epoch data for a specific programme
write_epoch_programme_csv(Stream, Programme, Epoch, Times) :-
    forall(
        nth0(I, Times, Day),
        (
            ( course_exam_name(Epoch, I, Name),
            programme_course(Programme, Name, Semester, Year)
            -> ( Semester = 0 -> SemesterStr = '-' ; SemesterStr = Semester ),
            format(Stream, "~w,~w,~w,~w,~w,~w~n", [Programme, Epoch, Name, SemesterStr, Year, Day])
            ; true
            )
        )
    ).

% Helper predicate to collect all programmes
all_programmes(Programmes) :-
    setof(P, C^S^Y^programme_course(P, C, S, Y), Programmes).

% Write a single combined CSV for all programmes
write_combined_csv(File, Times1, Times2) :-
    open(File, write, Stream),
    format(Stream, "programme,epoch,course,semester,year,day~n", []),
    write_combined_epoch_csv(Stream, 1, Times1),
    write_combined_epoch_csv(Stream, 2, Times2),
    close(Stream).

% Helper to write a specific epoch for all programme_course entries
write_combined_epoch_csv(Stream, Epoch, Times) :-
    forall(
        nth0(I, Times, Day),
        (
            course_exam_name(Epoch, I, Name),
            programme_course(Programme, Name, Semester, Year) ->
                ( Semester = 0 -> SemStr = '-' ; SemStr = Semester ),
                format(Stream, "~w,~w,~w,~w,~w,~w~n",
                       [Programme, Epoch, Name, SemStr, Year, Day])
        ; true
        )
    ).