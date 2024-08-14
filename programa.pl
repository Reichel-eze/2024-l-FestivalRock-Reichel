% El Festival del Rock

% Cuestión que partimos de una base de conocimiento con algunos predicados (completamente inversible) predefinidos 
% que modelan la información que fuimos recopilando de los diversos festivales:

% festival(NombreDelFestival, Bandas, Lugar).
% Relaciona el nombre de un festival con la lista de los nombres de bandas que tocan en él y el lugar dónde se realiza.
festival(lollapalooza, [gunsAndRoses, theStrokes, ..., littoNebbia], hipodromoSanIsidro).

% lugar(nombre, capacidad, precioBase).
% Relaciona un lugar con su capacidad y el precio base que se cobran las entradas ahí.
lugar(hipodromoSanIsidro, 85000, 3000).

% banda(nombre, nacionalidad, popularidad).
% Relaciona una banda con su nacionalidad y su popularidad.
banda(gunsAndRoses, eeuu, 69420).

% entradaVendida(NombreDelFestival, TipoDeEntrada).
% Indica la venta de una entrada de cierto tipo para el festival indicado.
% Los tipos de entrada pueden ser alguno de los siguientes: 
%     - campo
%     - plateaNumerada(Fila)
%     - plateaGeneral(Zona).
entradaVendida(lollapalooza, campo).
entradaVendida(lollapalooza, plateaNumerada(1)).
entradaVendida(lollapalooza, plateaGeneral(zona2)).

% plusZona(Lugar, Zona, Recargo)
% Relacion una zona de un lugar con el recargo que le aplica al precio de las plateas generales.
plusZona(hipodromoSanIsidro, zona1, 1500).

% Se pide definir los siguientes predicados:

% 1) Itinerante/1: Se cumple para los festivales que ocurren en más de un lugar, pero con el mismo nombre y 
% las mismas bandas en el mismo orden.
itinerante(Festival) :-                     % si un festival ocurre en mas de un lugar
    festival(Festival,Bandas,UnLugar),
    festival(Festival,Bandas,OtroLugar),
    UnLugar \= OtroLugar.

% 2) careta/1: Decimos que un festival es careta si no tiene campo o si es el personalFest
careta(Festival) :-
    %festival(Festival,_,_),
    %entradaVendida(Festival,TipoDeEntrada),
    %TipoDeEntrada \= campo.
    festival(Festival,_,_),                 % para que sea inversible (y no entre Festival por 1er vez en el not)
    not(entradaVendida(Festival,campo)).    % no tengo ninguna entrada vendida de tipo campo para este festival

careta(personalFest). 

% 3) nacAndPop/1: Un festival es nac&pop si no es careta y todas las bandas que tocan en él son de nacionalidad argentina 
% y tienen popularidad mayor a 1000.
nacAndPop(Festival) :-
    festival(Festival, Bandas, _),
    forall(member(Banda, Bandas), (esArgentina(Banda), tienePopularidadMayorA(Banda,1000))),
    not(careta(Festival)).

esArgentina(Banda) :- banda(Banda,argentina,_).

tienePopularidadMayorA(Banda,PopularidadBase) :- 
    banda(Banda,_,Popularidad),
    Popularidad > PopularidadBase.

nacAndPopPop(Festival) :-
    festival(Festival, Bandas, _),
    forall(member(Banda, Bandas), (banda(Banda, argentina, Popularidad), Popularidad > 1000)),   % esta forma es sin otros predicados auxiliares!!
    not(careta(Festival)).    


% 4) sobrevendido/1: Se cumple para los festivales que vendieron más entradas que la capacidad del lugar donde se realizan.
% Nota: no hace falta contemplar si es un festival itinerante.
sobrevendido(Festival) :-
    festival(Festival, _, Lugar),
    lugar(Lugar, Capacidad, _),
    cantidadDeEntradasVendidas(Festival, Cantidad),     % lo hice con un predicado auxiliar, pero se puede hacer sin el uso del mismo
    Cantidad > Capacidad.

cantidadDeEntradasVendidas(Festival, Cantidad) :-
    festival(Festival,_,_),
    findall(Entrada, entradaVendida(Festival, Entrada), Entradas),
    length(Entradas, Cantidad).
    
% 5) recaudaciónTotal/2: Relaciona un festival con el total recaudado con la venta de entradas. 
% Cada tipo de entrada se vende a un precio diferente:
%  - El precio del campo es el precio base del lugar donde se realiza el festival.
%  - La platea general es el precio base del lugar más el plus que se p aplica a la zona. 
%  - Las plateas numeradas salen el triple del precio base para las filas de atrás (>10) y 6 veces el
%  precio base para las 10 primeras filas. 
% Nota: no hace falta contemplar si es un festival itinerante.

recaudacionTotal(Festival, TotalRecaudado) :-
    festival(Festival, _, Lugar),
    findall(Precio, (entradaVendida(Festival,Entrada), precioEntrada(Entrada, Lugar, Precio)), Precios),
    sum_list(Precios, TotalRecaudado).

% USO DE POLIMORFISMO PARA EL precioEntrada

precioEntrada(campo, Lugar, PrecioBase) :- lugar(Lugar, _, PrecioBase). 

precioEntrada(plateaGeneral(Zona), Lugar, Precio) :-
    lugar(Lugar, _, PrecioBase),
    plusZona(Lugar, Zona, PrecioZona),
    Precio is PrecioBase + PrecioZona.

%precioEntrada(plateaNumerada(Fila), Lugar, PrecioFila) :- 
%    Fila > 10,
%    lugar(Lugar, _, PrecioBase),
%    PrecioFila is 3 * PrecioBase.

%precioEntrada(plateaNumerada(Fila), Lugar, PrecioFila) :- 
%    Fila =< 10,
%    lugar(Lugar, _, PrecioBase),
%    PrecioFila is 6 * PrecioBase.

precioEntrada(plateaNumerada(Fila), Lugar, PrecioFila) :-
    multiplicadorSegunFila(Fila, Multiplicador),
    lugar(Lugar, _, PrecioBase),
    PrecioFila is Multiplicador * PrecioBase.

multiplicadorSegunFila(Fila, 3) :- Fila > 10.
multiplicadorSegunFila(Fila, 6) :- Fila =< 10.
    
%precioSegunFila(Fila, Lugar, PrecioFila).    
%precioSegunFila(Fila, Lugar, PrecioFila) :- 
%    lugar(Lugar,_,PrecioBase),
%    Fila > 10, 
%    PrecioFila is 3 * PrecioBase.

%precioSegunFila(Fila, Lugar, PrecioFila) :- 
%    lugar(Lugar,_,PrecioBase),
%    Fila =< 10, 
%    PrecioFila is 6 * PrecioBase.ma

% 6) delMismoPalo/2: Relaciona dos bandas si tocaron juntas en algún recital o si una de ellas tocó con una banda del mismo palo 
% que la otra, pero más popular.   

% RECURSIVIDAD!!!

delMismoPalo(UnaBanda, OtraBanda) :- tocoCon(UnaBanda, OtraBanda).  % CASO BASE (tocar con una banda)

delMismoPalo(UnaBanda, OtraBanda) :-                                % CASO RECURSIVO (tocar con una banda tercera)
    tocoCon(UnaBanda, TercerBanda),                                 % "una de las bandas, toco con una tercer banda"                   
    esMasPopularQue(TercerBanda, OtraBanda),                        % "esta tercer banda, es mas popular que otra banda"
    delMismoPalo(TercerBanda, OtraBanda).                           % "la tercer banda y la otra banda son del mismo palo"

tocoCon(UnaBanda, OtraBanda) :-
    festival(_, Bandas, _),     % algun festival con Bandas
    member(UnaBanda, Bandas),
    member(OtraBanda, Bandas),
    UnaBanda \= OtraBanda.

esMasPopularQue(TercerBanda, OtraBanda) :-
    banda(TercerBanda, _, PopularidadTercerBanda),
    banda(OtraBanda, _, PopularidadOtraBanda),
    PopularidadTercerBanda > PopularidadOtraBanda.




