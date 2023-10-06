
%%%-------------------------------------------------------------------
%%% @author Lee Barney
%%% @copyright 2023 Lee Barney licensed under the <a>
%%%        rel="license"
%%%        href="http://creativecommons.org/licenses/by/4.0/"
%%%        target="_blank">
%%%        Creative Commons Attribution 4.0 International License</a>
%%%
%%% Project - CSE 382
%%%
%%% @doc
%%% These solutions are not intended to be ideal solutions. Instead,
%%% they are solutions that you can compare against yours to see
%%% other options and to come up with even better solutions.
%%%
%%% You can find the unit tests to be passed near the bottom of this 
%%% file, just before the speed tests.
%%% @end
%%% Created : 10 May 2023 by Lee Barney <barney.cit@gmail.com>
%%%-------------------------------------------------------------------

-module(tasks).

%%%===================================================================
%%% Public API functions
%%%===================================================================
-export([c_foldl/3,c_foldr/3,c_unfold/3,generate_primes/1,generate_primesS/1,inc_if_prime/1]).

%%
%% An implementation of the fold right functor pattern.
%%
%% Parameters - 1)A list of any type of elements that is to be folded into 1 value
%%              2)An initial value to which is merged the elements of the list
%%				3)A lambda function used to merge the accumulator and each element of the list
%% Value - A single value of some type
%% Complexity - O(n*u) where u is the complexity of the fold-func lambda function
%%
% Make sure the list is full
c_foldr(List, _, _) when is_list(List) =:= false -> not_list;
c_foldr([], Accum, _) -> Accum;
c_foldr(List,Accum,Fold_fun) ->
	% Take the last item in the list and use a function to append it to a new list
	Last = lists:last(List),
	Rest = lists:droplast(List),
	c_foldr(Rest, Fold_fun(Accum, Last), Fold_fun).

%%
%% An implementation of the fold left functor pattern.
%%
%% Parameters - 1)A list of any type of elements that is to be folded into 1 value
%%              2)An initial value to which is merged the elements of the list
%%				3)A lambda function used to merge the accumulator and each element of the list
%% Value - A single value of some type
%% Complexity - O(n*u) where u is the complexity of the fold-func lambda function
%%
c_foldl(List, _, _) when not is_list(List) -> not_list; 
c_foldl([], Accum, _) -> Accum;
c_foldl([H|T],Accum,Fold_fun) ->
	c_foldl(T, Fold_fun(Accum, H), Fold_fun).

%%
%% A naive implementation of the unfold functor pattern. This version is 
%%   very limited and should not be used in production.
%%
%% Parameters - 1)The number of items to be generated
%%              2)The current state of the unfold-process
%%				3)A lambda function to apply to the state that generates the next state and count
%% Value - A list of elements of the same type as the initial state
%% Complexity - O(n*u) where u is the complexity of the unfold-func lambda
%%
c_unfold(Value,_,_) when not is_integer(Value) -> not_number; 
c_unfold(0,_,_) -> [];
c_unfold(Count,State,Unfold_fun) ->
	{A, B} = Unfold_fun(Count, State),
	[B] ++ c_unfold(A, B, Unfold_fun).



%%%-------------------------------------------------------------------
%%% @doc
%%% Generate a list of primes. All primes greater than 2 and
%%% 3 are of the form 6n plus or minus 1. An indicator, n, is 
%%% incremented from 1 to the specified limit. Each of these n's
%%% represents a value for 6n. Some of these values have no primes
%%% at plus or minus 1, others have one, and some have two.
%%%
%%%
%%% Parameters - 1)The number of values of n to check for primes.
%%% Value - A list prime numbers including 2 and 3.
%%% Complexity - O(n!)
%%% @end
%%%-------------------------------------------------------------------

% This is just a simple factorial function
factorial(1) -> 1;
factorial(Num)->
	Num * factorial(Num - 1).

% Uses Wilson's theorem to test primality
% 'rem' is the modulo function in erlang
% Don't worry if you don't fully understand it because we didn't either #blackmagic
is_prime(Num)->
	(factorial(Num - 1) + 1) rem Num =:= 0.

% This will take a number (Limit) and it will prepend
generate_canidates(0)-> [];
generate_canidates(Limit)->
	[(6 * Limit) + 1] ++ [(6 * Limit) - 1] ++ generate_canidates(Limit - 1).
	

generate_primes(Value) when not is_integer(Value) -> not_number; 
generate_primes(0) -> [];
% Generate canidates and keep primes then finally append 3 and 2 to the result
generate_primes(Limit)->
	[Num || Num <- generate_canidates(Limit), is_prime(Num)] ++ [3, 2].


% Teacher Solution
generate_primesS(0)->[];
generate_primesS(Limit)->
	case c_unfold(Limit,1,fun(Count,_State) -> 
						Lesser = 6*Count-1,
						Greater = 6*Count+1,
						{Count-1,inc_if_prime(Greater)++inc_if_prime(Lesser)}
					 end) of
		not_number -> not_number;
		Result_list -> lists:flatten(Result_list)++[3,2]
	end.

%Helper function. Include if prime, don't include if not prime.
inc_if_prime(N)->
	case (factorial(N-1) rem N) == N-1 of
		true -> [N];
		_ -> []
	end.

% %Helper function. Calculate factorial
% factorial(N)->
% 	c_foldl(lists:seq(1,N),1,fun(Accum,X) -> Accum * X end).



%%% Only include the eunit testing library and functions
%%% in the compiled code if testing is 
%%% being done.
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
 
c_unfold_test_()->
	[?_assertEqual([A*2 || A<-lists:seq(1,50)],c_unfold(50,0,fun(Count,State)-> {Count-1,State+2} end)),%happy path, generating even numbers
	 %nasty thoughts start here
	 ?_assertEqual(not_number,c_unfold(nil,bob,fun(X)-> X end)),
	 ?_assertEqual(not_number,c_unfold({hello,world},sue,fun(_X)-> true end))
	].

c_foldl_test_()->
	[?_assertEqual("hello there you are amazing ", c_foldl([hello,there,you,are,amazing],
															"",
															fun(Accum,Atom)-> Accum++atom_to_list(Atom)++" " end)),%happy path
	 ?_assertEqual(21,c_foldl([1,2,3,4,5,6],0,fun(Accum,X) -> Accum+X end)),%another happy path
	 %nasty thoughts start here
	 ?_assertMatch([],c_foldl([],[],fun(Accum,X)->Accum+X end)),
	 ?_assertEqual(not_list,c_foldl(hello,[],fun(Accum,X)->Accum+X end))
	].


c_foldr_test_()->
	[?_assertEqual("amazing are you there hello ", c_foldr([hello,there,you,are,amazing],
															"",
															fun(Accum,Atom)-> Accum++atom_to_list(Atom)++" " end)),%happy path
	 ?_assertEqual(21,c_foldr([1,2,3,4,5,6],0,fun(Accum,X) -> Accum+X end)),%another happy path
	 %nasty thoughts start here
	 ?_assertMatch([],c_foldr([],[],fun(Accum,X)->Accum+X end)),
	 ?_assertEqual(not_list,c_foldr(hello,[],fun(Accum,X)->Accum+X end))
	].


generate_primes_test_()->
	[?_assertEqual([13,11,7,5,3,2],generate_primes(2)),%happy path
	 %nasty thoughts start here
	 ?_assertEqual([61,59,53,47,43,41,37,31,29,23,19,17,13,11,7,5,3,2],
	 				generate_primes(10)),
	 ?_assertEqual([],generate_primes(0)),
	 ?_assertEqual(not_number,generate_primes(sue))
	].
-endif.



	