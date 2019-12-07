/**
  Um jogo de aventura ridiculamente simples:
           *---------*
           |calabouço|
           | dragão  | -> dragão mata herói se este não tiver espada.
           |         |
  *--------*----#----*
  | jardim |   hall  |
  | chave  #  espada # -> Saída que requer a chave no jardim.
  |        |  quadro |
  |        |   herói |
  *--------*---------*
  OBJETIVO: Sair vivo do castelo.
**/

:- dynamic(localizacao/2).

localizacao(heroi,hall).
localizacao(objeto(espada),hall).
localizacao(objeto(quadro),hall).
localizacao(objeto(chave),jardim).
localizacao(dragao,calabouco).
 /**
  objeto nesse caso é um functor. Para o prolog, objeto(espada) é uma string só.
  Permite perguntar quais são todos os objetos do local:
    localizacao(objeto(X),hall).
 **/

 porta(hall,leste,saida,fechada).
 porta(hall,oeste,jardim,aberta).
 porta(hall,norte,calabouco,aberta).
 porta(jardim,leste,hall,aberta).
 porta(calabouco,sul,hall,aberta).

descreva(Loc) :-
  findall([Dir,Estado] ,porta(Loc,Dir, _, Estado),ListaPortas),
  write('Portas: '),mostreLista(ListaPortas),nl,
  findall(Obj ,localizacao(objeto(Obj),Loc),ListaObjetos),
  write('Objetos: '),mostreLista(ListaObjetos).

mostreLista([]) :- write('Não há objetos.'), nl.
mostreLista([X]) :- write(X), write('.'), nl.
mostreLista([X,Y]) :- write(X), write(' e '), write(Y), write('.'), nl.
mostreLista([H|T]) :-
  write(H), write(', '),
  mostreLista(T).

va(Dir) :-
  localizacao(heroi,X),
  porta(X,Dir,NovoLocal,aberta),
  assert(localizacao(heroi,NovoLocal)),
  retract(localizacao(heroi,X)),
  write('Agora voce esta em '),write(NovoLocal),write('.').
va(Dir) :-
  localizacao(heroi,X),
  porta(X,Dir,_,fechada),
  write('A porta ao '),write(Dir),write(' em '),write(X),write(' esta fechada.'),nl.
va(Dir) :-
  write('Nao ha como ir para '),write(Dir),write(', pois nao ha porta.').

iniciar :-
  localizacao(heroi,LocAtual),
  write('Voce esta em '), write(LocAtual), write('.'),nl.
