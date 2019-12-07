:- use_module(library(streampool)).

/* interpretador */
:- dynamic(ultimoId/1).

/* comandos interpretados */
proximoId(Id) :-
    ultimoId(Ultimo),
    Id is Ultimo + 1,
    retractall(ultimoId(_)),
    assert(ultimoId(Id)).

/* criar/desenhar*/
criar(Forma, Cor, X, Y, Str) :- 
    proximoId(Id),
    atom_number(AId, Id),
    atomic_list_concat([+, AId, Forma, Cor, X, Y], ' ', Atom),
    write(Atom),
    atom_string(Atom, Str).

/*mover/deslocar*/
mover(Forma, Cor, X, Y, Str) :-
    atomic_list_concat(['m', Forma, Cor, X, Y], ' ', Atom),
    write(Atom),
    atom_string(Atom, Str).

/*apagar*/

/*apagar(AId, Str) :-
    atomic_list_concat([-, AId], ' ', Atom),
    write(Atom),
    atom_string(Atom, Str).

*/

/* NLP */

/*comandos desenhar*/
comando_criar(Forma, Cor, X, Y) --> 
    verbo_criar, forma(Forma), cor(Cor), prep, num(X), num(Y).

/*comandos criar */
comando_criar(Forma, Cor, X, Y) --> 
    verbo_criar, forma(Forma), cor(Cor), prep, prep, num(X), num(Y).

/*
comando_mover(Forma, Cor, X, Y) -->
    verbo_mover, forma(Forma), cor(Cor), 


comando_apagar(AId) --> verbo_apagar, id(AId).*/


verbo_criar --> [criar].
verbo_criar -->[desenhar].
verbo_criar -->[inserir].


verbo_apagar --> [apagar].

verbo_mover --> [mover].
verbo_mover --> [deslocar].


prep --> [em].
prep -->[posicao].

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

interprete(L, Str, continuar) :-
    comando_criar(Forma, Cor, X, Y, L, []),
    criar(Forma, Cor, X, Y, Str).
/*
interprete(L, Str, continuar) :-
    comando_mover(Forma, Cor, X, Y, L, []),
    criar(Forma, Cor, X, Y, Str).

interprete(L, Str, continuar) :-
    comando_apagar(Id,L, []),
    apagar(Id, Str).
*/

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