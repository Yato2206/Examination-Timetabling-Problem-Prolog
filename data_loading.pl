:- module(data_loading, [
    load_deetc/0,
    course_exam_name/3,
    conflict/4,
    num_courses/1,
    programme_course/4
]).

:- use_module(library(readutil)).
:- dynamic course_exam_name/3.
:- dynamic conflict/4.
:- dynamic num_courses/1.
:- dynamic programme_course/4.

% Load the courses names from a deetc0910_EPOCH.names file. 
% If true, file was loaded successfully.
load_courses_names(Epoch, File) :-
    retractall(course_exam_name(Epoch, _, _)),
    read_file_to_string(File, Content, []),
    split_string(Content, "\n", "\r", Lines),
    load_names_lines(Epoch, 0, Lines).

% Helper predicate to load names line by line
load_names_lines(_, _, []).
load_names_lines(Epoch, I, [""|Rest]) :-      % skip empty lines
    load_names_lines(Epoch, I, Rest).
load_names_lines(Epoch, I, [Name|Rest]) :-
    Name \= "",
    assertz(course_exam_name(Epoch, I, Name)),
    I1 is I + 1,
    load_names_lines(Epoch, I1, Rest).

% Load the number of courses from a deetc0910_EPOCH.crs file.
% If true, file was loaded successfully.
load_number_of_courses(File) :-
    retractall(num_courses(_)),
    read_file_to_string(File, Content, []),
    split_string(Content, "\n", "\r", Lines),
    length(Lines, N),
    assertz(num_courses(N)).

% Load the conflict matrix from a deetc0910_EPOCH.cm file.
% If true, file was loaded successfully.
load_conflict_matrix(Epoch, File) :-
    read_file_to_string(File, Content, []),
    split_string(Content, "\n", "\r", Rows),
    load_conflict_matrix_rows(Epoch, 0, Rows).

% Helper predicate to load conflict matrix row by row
load_conflict_matrix_rows(_, _, []).
load_conflict_matrix_rows(Epoch, I, [Row|Rest]) :-
    ( Row = "" -> I1 = I
    ; split_row(Row, Numbers),
      load_conflict_cells(Epoch, I, 0, Numbers),
      I1 is I + 1
    ),
    load_conflict_matrix_rows(Epoch, I1, Rest).

% Helper predicate to split a row into numbers
split_row(Row, Numbers) :-
    split_string(Row, " \t", " \t", Parts),
    maplist(number_string, Numbers, Parts).

% Helper predicate to load conflict cells in a row
load_conflict_cells(_, _, _, []).
load_conflict_cells(Epoch, I, J, [N|Rest]) :-
    ( N > 0 -> assertz(conflict(Epoch, I, J, N)) ; true ),
    J1 is J + 1,
    load_conflict_cells(Epoch, I, J1, Rest).

% Load programme courses data
% Returns true if the programme data was loaded successfully
load_programme(Programme, File) :-
    read_file_to_string(File, Content, []),
    split_string(Content, "\n", "\r", Lines),
    forall(
        member(Line, Lines),
        ( Line \= "" ->
            split_string(Line, ",", " ", Parts),
            ( Parts = [Name, SemesterStr, YearStr] ->
                number_string(Semester, SemesterStr),
                number_string(Year, YearStr)
            ),
            assertz(programme_course(Programme, Name, Semester, Year))
        ; true )
    ).

load_programmes :-
    load_programme(leetc,  'leetc.names'),
    load_programme(leic, 'leic.names'),
    load_programme(lercm,  'lercm.names'),
    load_programme(meet, 'meet.names'),
    load_programme(meic,  'meic.names').

% Load all data files
% If true, all data was loaded successfully
load_deetc :-
    load_courses_names(1, 'deetc0910_1stEpoch.names'),
    load_number_of_courses('deetc0910_1stEpoch.crs'),
    load_conflict_matrix(1, 'deetc0910_1stEpoch.cm'),
    load_courses_names(2, 'deetc0910_2ndEpoch.names'),
    load_number_of_courses('deetc0910_2ndEpoch.crs'),
    load_conflict_matrix(2, 'deetc0910_2ndEpoch.cm'),
    load_programmes.