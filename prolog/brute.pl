logs(0, [
         [2,2],
         [0,0],
         [2,0],
         [2,0]
         ]).
logs(1, [
         [0,0,1,1], %% oo..
         [0,1,2,1], %% o.x.
         [2,0,0,1], %% xoo.
         [1,0,1,2], %% .o.x
         [1,0,1,0], %% .o.o
         [1,1,2,2], %% ..xx
         [2,0,1,1], %% xo..
         [1,2,2,2]  %% .xxx
        ]).

all_solutions(Ss) :-
    logs(1, Logs),
    bagof(S, one_solution(Logs, S), Ss).

one_solution(Logs, Solution) :-
    shuffle(Logs, Lower, Upper),
    stable(Lower, Upper),
    append(Lower, Upper, Solution).

shuffle(Logs, Lower, Upper) :-
    permutation(Logs, Permutation),
    orientation(Permutation, Oriented),
    split(Oriented, Lower, Upper).

orientation([], []).
orientation([A | As], [A | Oriented]) :-
    orientation(As, Oriented).
orientation([A | As], [Areversed | Oriented]) :-
    reverse(A, Areversed),
    orientation(As, Oriented).

split([], [], []).
split([A,B | Tail], [A|As], [B|Bs]) :-
    split(Tail, As, Bs).

stable(Lower, Upper) :-
    transform(Upper, UpperT),
    compatible(Lower, UpperT).

transform([Row|Rows], Transformed) :-
    cols_as_rows(Row, Cols),
    transform(Rows, Cols, Transformed).
cols_as_rows([], []).
cols_as_rows([A|As], [[A]|Cols]) :-
    cols_as_rows(As, Cols).
transform([], Cols, Cols).
transform([Row|Rows], Cols, Transformed) :-
    add_to_cols(Row, Cols, NewCols),
    transform(Rows, NewCols, Transformed).

add_to_cols([], [], []).
add_to_cols([A | As], [Col | Cols], [[A | Col] | Added]) :-
    add_to_cols(As, Cols, Added).

compatible([],[]).
compatible([[]|At],[[]|Bt]) :-
    compatible(At, Bt).
compatible([[A|As]|At], [[B|Bs]|Bt]) :-
    A + B < 3,
    compatible([As|At], [Bs|Bt]).
