/* interpretador */
:- use_module(library(streampool)).
:- dynamic(objeto/4).

/* comandos interpretados */
criar(Forma, Cor, X, Y, Str) :-
    atomic_list_concat([+, Forma, Cor, X, Y], ' ', Atom),
    atom_string(Atom, Str).

excluir(Forma, Cor, Str) :-
     atomic_list_concat([-, Forma, Cor], ' ', Atom),
     atom_string(Atom, Str).

mover(Forma, Cor, X, Y, Str) :-
    atomic_list_concat([m, Forma, Cor, X, Y], ' ', Atom),
    atom_string(Atom, Str).

/* NLP */
comando_excluir(Forma, Cor) -->
    verbo_excluir, forma(Forma), cor(Cor).

/*os comandos com posições relativas a objetos criados no grid trazem o X e Y já na posição do
novo objeto a ser criado e não na do objeto referenciado*/
comando_criar(Forma, Cor, X, Y) -->
    verbo_criar, forma(Forma), cor(Cor), prep, num(X), num(Y).
comando_criar(Forma, Cor, X, Y) -->
    verbo_criar, forma(Forma), cor(Cor), obi, num(X), num(Y).
comando_criar(Forma, Cor, X, Y) -->
    verbo_criar, forma(Forma), cor(Cor), pos(X,Y).

comando_mover(Forma, Cor, X, Y) -->
    verbo_mover, forma(Forma), cor(Cor), num(X), num(Y).
comando_mover(Forma, Cor, X, Y) -->
    verbo_mover, forma(Forma), cor(Cor), para, num(X), num(Y).
comando_mover(Forma, Cor, X, Y) -->
    verbo_mover, forma(Forma), cor(Cor), pos(X,Y).

verbo_excluir --> [apagar].

verbo_criar --> [criar].
verbo_criar --> [inserir].
verbo_criar --> [desenhar].

verbo_mover --> [mover].
verbo_mover --> [deslocar].

forma(c) --> [circulo].
forma(s) --> [quadrado].

cor(blue) --> [azul].
cor(green) --> [verde].
cor(red) --> [vermelho].
cor(black) --> [preto].
cor(yellow) --> [amarelo].

prep --> [em].
prep --> [na].
ind --> [do].
para --> [para].

obi --> prep, nucleo.
nucleo --> [posicao].

pos(I,J) --> 
    pos_rel(cima), ind, obj(Forma, Cor), ajuste(Forma, Cor, I, J, cima).
pos(I,J) --> 
    pos_rel(baixo), ind, obj(Forma, Cor), ajuste(Forma, Cor, I, J, baixo).
pos(I,J) --> 
    pos_rel(esquerda), ind, obj(Forma, Cor), ajuste(Forma, Cor, I, J, esquerda).
pos(I,J) --> 
    pos_rel(direita), ind, obj(Forma, Cor), ajuste(Forma, Cor, I, J, direita).

pos_rel(cima) --> [acima].
pos_rel(cima) --> [para, cima].
pos_rel(baixo) --> [abaixo].
pos_rel(baixo) --> [para, baixo].
pos_rel(esquerda) --> [para, esquerda].
pos_rel(esquerda) --> [a, esquerda].
pos_rel(direita) --> [para, direita].
pos_rel(direita) --> [a, direita].

ajuste(Forma, Cor, I, J, Rel, _, _) :-
    objeto(Forma, Cor, X, Y),
    rel(I,J,X,Y,Rel).

rel(I,J,X,Y,cima) :- 
    I = X, J is Y - 1.
rel(I,J,X,Y,baixo) :- 
    I = X, J is Y + 1.
rel(I,J,X,Y,esquerda) :- 
    I is X - 1, Y = J.
rel(I,J,X,Y,direita) :- 
    I is X + 1, Y = J.

obj(Forma, Cor) --> forma(Forma), cor(Cor).

num(0) --> ['0'].
num(1) --> ['1'].
num(2) --> ['2'].
num(3) --> ['3'].
num(4) --> ['4'].

interprete(L, Str, continuar) :-
    comando_criar(Forma, Cor, X, Y, L, []),
    criar(Forma, Cor, X, Y, Str),
    assert(objeto(Forma, Cor, X, Y)).

interprete(L, Str, continuar) :-
    comando_excluir(Forma, Cor, L, []),
    excluir(Forma, Cor, Str),
    retractall(objeto(Forma, Cor, _, _)).

interprete(L, Str, continuar) :-
    comando_mover(Forma, Cor, X, Y, L, []),
    mover(Forma, Cor, X, Y, Str),
    retractall(objeto(Forma, Cor, _, _)),
    assert(objeto(Forma, Cor, X, Y)).

interprete([bye], '', parar).
interprete(_, 'Nao entendi oq vc disse. Pode repetir?', incompreensivel).

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

go:-
    interaja(continuar).

/*interface via socket*/
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
    (   ProxCmd == parar
    ->  interaja(parar)
    ;   ( ProxCmd == incompreensivel
        ->  write('  '), write(Str), nl, nl,
                  char_to_server(In, Out)
                  ; write('  Enviado: '), write(Str), nl,
                  format(Out, '~s', Str),
                  flush_output(Out),
                  read_string(In, '\n', '\r', _, Reply),
                  write('  Respost: '), write(Reply), nl, nl,
                  chat_to_server(In, Out)
                 )
        ).

close_connection(In, Out) :-
    close(In,[force(true)]),
    close(Out,[force(true)]).

go_socket :- create_client('localhost',7777).





