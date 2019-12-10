:- use_module(library(streampool)).

/* interpretador */
/* o :- dymanic Informa ao intérprete que a definição 
do (s) predicado (s) pode mudar durante a execução (usando assert/1 e ou retrair/1 ).*/

:- dynamic(ultimoId/1).
:- dynamic(objeto/5).

/* comandos interpretados */
proximoId(Id) :-
    ultimoId(Ultimo),
    Id is Ultimo + 1,
    retractall(ultimoId(_)),  
    assert(ultimoId(Id)). 

/*rectractall remove na base de dados*/
/*assert adiciona na base de dados*/

/* criar/desenhar*/
criar(Forma, Cor, X, Y, Str) :- 
    proximoId(Id),
    atom_number(AId, Id),
    atomic_list_concat([+, AId, Forma, Cor, X, Y], ' ', Atom),
    write(Atom),
    assert(objeto(Forma, Cor, X, Y, Id)),
    atom_string(Atom, Str).

/*mover/deslocar*/
mover(Forma, Cor, X, Y, Str) :-
    atomic_list_concat([m, Forma, Cor, X, Y], ' ', Atom),
    write(Atom),
    atom_string(Atom, Str).

moverId(Id,X, Y, Str) :-
    atomic_list_concat([m, Id, X, Y] , ' ', Atom),
    write(Atom),
    atom_string(Atom, Str).

/*apagar*/

apagar(Forma, Cor, Str) :-
    atomic_list_concat([-, Forma, Cor], ' ', Atom),
    write(Atom),
    atom_string(Atom, Str).

apagarId(Id, Str) :-
    atomic_list_concat([-,Id], ' ', Atom),
    write(Atom),
    atom_string(Atom, Str).



/* NLP */

/*comandos desenhar,criar,inserir */

/*desenhar,criar,inserir circulo verde em 1 1 */
comando_criar(Forma, Cor, X, Y) --> 
    verbo_criar, forma(Forma), cor(Cor), prep, num(X), num(Y).
/*desenhar,criar,inserir circulo verde na posicao 1 1 */
comando_criar(Forma, Cor, X, Y) --> 
    verbo_criar, forma(Forma), cor(Cor), prep, prep, num(X), num(Y).

/*desenhar,criar,inserir circulo verde abaixo do circulo azul*/
comando_criar(Forma, Cor, X, Y) --> 
    verbo_criar, forma(Forma), cor(Cor), prep, posicao(X,Y).

comando_criar(Forma, Cor, X, Y) --> 
    verbo_criar, forma(Forma), cor(Cor), posicao(X,Y).


/*comandos mover,deslocar */

/*mover circulo azul 1 1*/
comando_mover(Forma, Cor, X, Y) -->
    verbo_mover, forma(Forma), cor(Cor), num(X),num(Y).
/*mover circulo azul para 1 1*/
comando_mover(Forma, Cor, X, Y) -->
    verbo_mover, forma(Forma), cor(Cor), prep, num(X), num(Y).

/*mover circulo azul acima do circulo verde*/
comando_mover(Forma, Cor, X, Y) -->
    verbo_mover, forma(Forma), cor(Cor),prep, posicao(X,Y).

/*mover 1 para baixo do 2*/
comando_moverId(Id, X, Y) -->
    verbo_mover, id(Id), prep, posicao(X,Y).

comando_moverId(Id, X, Y) -->
    verbo_mover, id(Id), prep, num(X), num(Y).


/*comandos apagar, remover */
/*apagar, remover circulo azul*/
comando_apagar(Forma, Cor) -->  
    verbo_apagar, forma(Forma), cor(Cor).

comando_apagarId(Id) -->  
    verbo_apagar, id(Id).



verbo_criar --> [criar].
verbo_criar -->[desenhar].
verbo_criar -->[inserir].


verbo_apagar --> [apagar].
verbo_apagar --> [remover].

verbo_mover --> [mover].
verbo_mover --> [deslocar].


prep --> [em].
prep -->[posicao].
prep --> [na].
prep --> [do].
prep --> [de].
prep --> [para].
prep --> [aa].

forma(c) --> [circulo].
forma(s) --> [quadrado].

cor(blue) --> [azul].
cor(black) --> [preto].
cor(red) --> [vermelho].
cor(green) --> [verde].


num(0) --> ['0'].
num(1) --> ['1'].
num(2) --> ['2'].
num(3) --> ['3'].
num(4) --> ['4'].
num(5) --> ['5'].
num(6) --> ['6'].
num(7) --> ['7'].
num(8) --> ['8'].
num(9) --> ['9'].



id(0) --> ['0'].
id(1) --> ['1'].
id(2) --> ['2'].
id(3) --> ['3'].
id(4) --> ['4'].
id(5) --> ['5'].
id(6) --> ['6'].
id(7) --> ['7'].
id(8) --> ['8'].
id(9) --> ['9'].


/* para mover*/

pos(acima) -->[acima, do].
pos(acima) -->[acima, de].

pos(abaixo) --> [abaixo, de].
pos(abaixo) --> [abaixo, do].
pos(abaixo) --> [baixo, do].
pos(abaixo) --> [baixo, de].

pos(esquerda) --> [esquerda, do].
pos(esquerda) --> [esquerda, de].

pos(direita) --> [direita, do].
pos(direita) --> [direita, de].

/*
pos(acima) --> [para, acima, de].
pos(baixo) --> [para, baixo,do].
pos(esquerda) --> [a, esquerda,de].
pos(esquerda) --> [a, esquerda,do].
pos(direita) --> [a, direita,de].
pos(direita) --> [a, direita,do].
*/


ajuste(Forma, Cor, A, B, Rel, _, _) :- objeto(Forma, Cor, X, Y, _),relacao(A,B,X,Y, Rel).

ajusteId(Id, A, B, Rel, _, _) :- objeto(_,_, X, Y, Id),relacao(A,B,X,Y, Rel).

relacao(A,B,X,Y,esquerda) :- A = X, B is Y - 1.
relacao(A,B,X,Y,direita) :- A = X, B is Y + 1.
relacao(A,B,X,Y,acima) :- A is X - 1, Y = B.
relacao(A,B,X,Y,abaixo) :-  A is X + 1, Y = B.

posicao(A,B) --> pos(acima), forma(Forma), cor(Cor), ajuste(Forma, Cor, A, B, acima).
posicao(A,B) -->  pos(abaixo), forma(Forma), cor(Cor), ajuste(Forma, Cor, A, B, abaixo).
posicao(A,B) --> pos(esquerda), forma(Forma), cor(Cor), ajuste(Forma, Cor, A, B, esquerda).
posicao(A,B) --> pos(direita), forma(Forma), cor(Cor), ajuste(Forma, Cor, A, B, direita).


posicao(A,B) --> pos(acima), id(Id), ajusteId(Id, A, B, acima).
posicao(A,B) --> pos(abaixo), id(Id), ajusteId(Id, A, B, abaixo).
posicao(A,B) --> pos(esquerda), id(Id), ajusteId(Id, A, B, esquerda).
posicao(A,B) --> pos(direita),  id(Id), ajusteId(Id, A, B, direita).


/* interpretes pra a comunicao com socket do python*/

/*interprete para criar*/
interprete(L, Str, continuar) :-
    comando_criar(Forma, Cor, X, Y, L, []),
    criar(Forma, Cor, X, Y, Str).

/*interprete para mover*/
interprete(L, Str, continuar) :-
    comando_mover(Forma, Cor, X, Y, L, []),
    mover(Forma, Cor, X, Y, Str).

interprete(L, Str, continuar) :-
    comando_moverId(Id, X, Y, L, []),
    moverId(Id, X, Y, Str).

/*interprete para apagar*/
interprete(L, Str, continuar) :-
    comando_apagarId(Id,L, []),
    apagarId(Id, Str).

interprete(L, Str, continuar) :-
    comando_apagar(Forma, Cor,L, []),
    apagar(Forma, Cor, Str).


interprete([bye], '', parar).

interprete(_, 'Nao entendi o que vc disse. Pode repetir?', imcompreensivel).

estado_inicial :-
    retractall(ultimoId(_)),
    assert(ultimoId(0)).

/* interface via teclado */

prompt(L) :-
    write('>> '),
    read_line_to_codes(user_input, Cs),
    atom_codes(A, Cs),
    atomic_list_concat(L, ' ', A).

interaja(parar) :-
    write('Tchau!'), nl.

interaja(_) :-
    prompt(L),
    interprete(L, Str, ProxCmd),
    write(Str), nl,
    interaja(ProxCmd).
go :-
    estado_inicial,
    interaja(continuar).



/* interface via socket */
create_client(Host, Port) :-
    setup_call_catcher_cleanup(tcp_socket(Socket),
                               tcp_connect(Socket, Host:Port),
                               exception(_),
                               tcp_close_socket(Socket)),
    setup_call_cleanup(tcp_open_socket(Socket, In, Out),
                        chat_to_server(In, Out),
                        close_connection(In, Out)).

chat_to_server(In, Out) :-
    prompt(L),
    interprete(L, Str, ProxCmd),
    ( ProxCmd == parar
    -> interaja(parar)
    ; ( ProxCmd == imcompreensivel
    -> write(' '), write(Str), nl, nl,
    chat_to_server(In, Out)
    ; write(' Enviado: '), write(Str), nl,
    format(Out, '~s', Str),
    flush_output(Out),
    read_string(In, '\n', '\r', _, Reply),
    write(' Respost: '), write(Reply), nl, nl,
    chat_to_server(In, Out)
    )
    ).
close_connection(In, Out) :-
    close(In, [force(true)]),
    close(Out, [force(true)]).
go_socket :-
    estado_inicial,
    create_client('localhost', 7777).