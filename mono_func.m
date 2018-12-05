function [R, T, A, ocupacion, saltos_intercapa, tiempo] = funcion_monocromatica(NT,PK,PS,PA);
% FUNCION_MONOCROMATICA Cálculo para una longitud de onda.
%   INPUTS:
%
%     NT: número total de fotones entrantes en el sistema.
%
%     PK: array con las probabilidades de absorción de todas las capas,
%     incluido el sustrato.
%
%     PS: array con las probabilidades de scattering hacia atrás de
%     todas las capas, incluido el sustrato.
%
%     PA: array con las probabilidades de scattering hacia delante de
%     todas las capas, incluido el sustrato.
%
%   OUTPUTS:
%
%     R: array lógico de dimensión NT con valor 'true' en aquellas
%     posiciones que corresponden a fotones reflejados.
%
%     T: array lógico de dimensión NT con valor 'true' en aquellas
%     posiciones que corresponden a fotones transmitidos.
%
%     A: array de dimensión NT que almacena el número de capa donde fue
%     absorbido cada fotón ('0' en caso de no serlo).
%
%     ocupacion: array de la misma dimensión que PK, PS y PS_atras que
%     registra el paso de los fotones por cada capa.
%
%     saltos_intercapa: array de dimensión NT que registra el número de
%     saltos intercapa de cada fotón.
%     
%     tiempo: array de dimensión NT que cuenta el tiempo que pasa el fotón
%     dentro del material hasta que es absorbido, reflejado o transmitido.


NT= 10000;
PK=zeros(100,1);
pPK=[1:100]';
PK(pPK)=0.001;
PS=zeros(100,1);
pPS=[1:100]';
PS(pPS)=0.004;
PA=zeros(100,1);
pPA=[1:100]';
PA(pPA)=0.005;



N = length(PS); % número total de capas incluyendo el sustrato

% Inicialización
R = false(NT,1);
T = false(NT,1);
A = zeros(NT,1);

ocupacion = zeros(N,1);
saltos_intercapa = -ones(NT,1); % lo inicializamos con '-1' para considerar
                                % que los fotones reflejados en la primera 
                                % capa dan '0' saltos
tiempo=zeros(NT,1);                              

for I=1:NT
    % Cada fotón empieza por la primera capa moviéndose hacia la derecha
    J = 1;
    moviendose = true;
    moviendose_hacia_la_derecha = true;
    while moviendose % mientras el fotón siga moviéndose
        ocupacion(J) = ocupacion(J) + 1; % registramos el paso del fotón 
                                         % por la capa J
        saltos_intercapa(I) = saltos_intercapa(I) + 1; % registramos el 
                                                       % salto del fotón a
                                                       % otra capa    
                                                       
        rho = rand; % número aleatorio entre 0 y 1
        if rho<PK(J) % hay absorción
            moviendose = false; % el fotón deja de moverse
            A(I) = J; % el fotón 'I' es absorbido en la capa 'J'
            
        elseif rho<(PK(J)+PS(J)) % hay scattering hacia atrás   
            tiempo(I)=tiempo(I)+2;
            if moviendose_hacia_la_derecha                    
                if isequal(J,1) % el fotón es reflejado en la primera capa
                    moviendose = false; % el fotón deja de moverse
                    R(I) = true; % el fotón 'I' es reflejado
                   
                else
                    moviendose_hacia_la_derecha = false; % invertimos el sentido
                    J = J-1; % retrocedemos una capa
                    
                end                                                                
            else
                moviendose_hacia_la_derecha = true; % invertimos el sentido
                J = J+1; % avanzamos una capa
                
            end    
            
        elseif rho<(PK(J)+PS(J)+PA(J)) %HAY SCATTERING HACIA DELANTE
            tiempo(I)=tiempo(I)+2;
            if moviendose_hacia_la_derecha
                if isequal(J,N) %sufre scattering hacia adelante en la última capa
                    moviendose=false;
                    T(I)=true;
                else
                    J=J+1;
                end
            else 
                if isequal(J,1) % el fotón es reflejado en la primera capa
                    moviendose = false; % el fotón deja de moverse
                    R(I) = true; % el fotón 'I' es reflejado
                else
                    J = J-1;
                end
            end
            
        else % fotón atraviesa    
            tiempo(I)=tiempo(I)+1;
            if moviendose_hacia_la_derecha                
                if isequal(J,N) % el fotón es transmitido en la última capa
                    moviendose = false; % el fotón deja de moverse
                    T(I) = true; % el fotón 'I' es transmitido
                else
                    J = J+1; % avanzamos una capa                    
                end
            else                
                if isequal(J,1) % el fotón es reflejado en la primera capa
                    moviendose = false; % el fotón deja de moverse
                    R(I) = true; % el fotón 'I' es reflejado
                else
                    J = J-1; % retrocedemos una capa
                end
            end
        end        
    end   
 
end
