-module(first).

-export([logs/1, solve/1]).

logs(0) -> [
            [2,2],
            [0,0],
            [2,0],
            [2,0]
           ];
logs(1) -> [
            [0,0,1,1], %% oo..
            [0,1,2,1], %% o.x.
            [2,0,0,1], %% xoo.
            [1,0,1,2], %% .o.x
            [1,0,1,0], %% .o.o
            [1,1,2,2], %% ..xx
            [2,0,1,1], %% xo..
            [1,2,2,2]  %% .xxx
           ].

solve(Logs) ->
    solve(perms(Logs), []).
solve([], Acc) -> Acc;
solve([P | Permutations], Acc) ->
    Solutions = [{Lower, Upper} || {Lower, Upper} <-
                                       lists:map(
                                         fun (O) -> split(O) end,
                                         orientations(P)),
                                   stable(Lower, transpose(Upper))],
    solve(Permutations, Solutions ++ Acc).

orientations([]) ->
    [[]];
orientations([H|T]) ->
    Os = orientations(T),
    R = lists:reverse(H),
    [[H|O] || O <- Os] ++
        [[R|O] || O <- Os].

stable([],[]) ->
    true;
stable([[]|At],[[]|Bt]) ->
    stable(At, Bt);
stable([[A|As]|At], [[B|Bs]|Bt]) ->
    if
        A + B < 3 -> stable([As|At], [Bs|Bt]);
        true -> false
    end.

split(L) ->
    split(L, [], []).
split([], A, B) ->
    {A, B};
split([A, B | T], AccA, AccB) ->
    split(T, [A|AccA], [B|AccB]).
    
transpose([[]|_]) -> [];
transpose(M) ->
    [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M))].

perms([]) -> [[]];
perms(L)  -> [[H|T] || H <- L, T <- perms(L--[H])].
