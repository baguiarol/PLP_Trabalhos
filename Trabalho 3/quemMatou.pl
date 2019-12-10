%pessoas
vitima(chiara).

%lugares em que pietro estava
suspeito(pietro,contagem,segunda).
suspeito(pietro,contagem,terca).
suspeito(pietro,belo_horizonte, quarta).
suspeito(pietro,casa,sexta).

%lugares em que eliza estava
suspeito(eliza,pensao,segunda).
suspeito(eliza,belo_horizonte,terca).
suspeito(eliza,belo_horizonte,quarta).
suspeito(eliza,contagem,quinta).
suspeito(eliza,casa,sexta).

%lugares onde adriano estava
suspeito(adriano, contagem,quarta).
suspeito(adriano, casa, quinta).
suspeito(adriano, casa, sexta).

%lugares onde alfredo estava
suspeito(alfredo, contagem, segunda).
suspeito(alfredo, contagem, terca).
suspeito(alfredo, belo_horizonte, quarta).
suspeito(alfredo, contagem, quinta).
suspeito(alfredo, pensao, sexta).

%lugares onde carol estava
suspeito(carol, belo_horizonte,segunda).
suspeito(carol, belo_horizonte,terca).
suspeito(carol, belo_horizonte,quarta).
suspeito(carol, contagem, quinta).
suspeito(carol, pensao, sexta).

%lugares onde elena estava
suspeito(elena, belo_horizonte, terca).
suspeito(elena, belo_horizonte, quarta).
suspeito(elena, pensao, segunda).
suspeito(elena, pensao, quinta).
suspeito(elena, pensao, sexta).

%lugares onde henrico estava
suspeito(henrico, pensao, segunda).
suspeito(henrico,belo_horizonte, terca).
suspeito(henrico, pensao, quarta).

%lugares onde maria estava
suspeito(maria, contagem, terca).
suspeito(maria, contagem, quarta).
suspeito(maria, contagem, quinta).
suspeito(maria, pensao,segunda).
suspeito(maria, pensao, sexta).




%relacao amizade
amiga(chiara,eliza).


%%relaçoes namorados

%motivo do crime pode ser ciumes
casais(chiara, pietro).
casais(chiara, alfredo).

casais(pietro,carol).
casais(pietro,chiara).

casais(alfredo, elena).
casais(alfredo, chiara).

casais(elena,henrico).
casais(elena,alfredo).

casais(henrico,maria).
casais(henrico, elena).

casais(maria, adriano).
casais(maria, henrico).

casais(adriano,carol).
casais(adriano, maria).
%motivo deve ser dinheiro

condicoes(pietro,pobre).
condicoes(alfredo,pobre).
condicoes(elena,rica).
condicoes(eliza,pobre).
condicoes(henrico,rico).
condicoes(maria,pobre).
condicoes(adriano,rico).
condicoes(carol,rica).


%o motivo do crime pode ser insanidade
psicotico(adriano).
psicotico(maria).

%pessoas e lugares nos dias
%chiara foi morta na quinta ou sexta na pensao onde morava
% um dos suspeitos era da pensao

%armas do crime, chiara foi morta por
%instrumento semelhante a um bastao
%
%


%disturbios psicotico

psicopata(adriano).
psicopata(maria).

%o assassino entrou na casa com a chave roubada de
% chiara
roubochave(X) :- 
    suspeito(X,contagem, segunda),
    X \= eliza.
roubochave(X) :- 
    suspeito(X,belo_horizonte, terca),
    X \= eliza.

%pegaram a arma na quinta em belo_horizonte 
%ou quarta em contagem
%o martelo que foi roubado da caixa de 
%ferramentas da pensão
%na quarta ou quinta-feira.

pegouArmaPerna(X) :- 
    suspeito(X, belo_horizonte, quinta),
    X\= pietro.
pegouArmaPerna(X) :- 
    suspeito(X, contagem, quarta),
    X\= pietro.

pegouArmaMartelo(X) :- suspeito(X,pensao, quarta).
pegouArmaMartelo(X) :- suspeito(X,pensao, quinta).


possivelArma(X):- pegouArmaPerna(X).
possivelArma(X):- pegouArmaMartelo(X).

% estava na pensao dia quinta ou sexta


estavanapensao(X) :- suspeito(X, pensao, sexta).
estavanapensao(X) :- suspeito(X, pensao, quinta).

%motivo do crime
% pegou a arma? 
% roubou a chave? estava pensao no dia?
% eh psicopata?
%ciumes(chiara,X) :- casais(X,Y).


%Quem matou Chiara e por quê?

possivelAssassino(X) :-
    possivelArma(X),
    pegouArmaMartelo(X),
    estavanapensao(X),
    roubochave(X).


%se foi por dinheiro    
assassinoCondicoes(X) :-
    condicoes(X,pobre),
    possivelAssassino(X).

assassino1(X) :- 
    assassinoCondicoes(X),
    write(X), write(" matou Chiara por dinheiro").

%se foi por insanidade
assassinoPsicopata(X) :-
    psicopata(X),
    possivelAssassino(X).

assassino2(X) :- 
    assassinoPsicopata(X),
    write(X), write(" matou Chiara por insanidade").

%se foi por ciume

ciumesChiara(Y):-
    casais(chiara, X),
    casais(X, Y).

assassinoCiumento(X):-
    possivelAssassino(X),
    ciumesChiara(X).

assassino3(X) :- 
    assassinoCiumento(X),
    write(X), write(" matou Chiara por ciumes").


