clear;

%-----------------------------------------------------

Normalizar=1; 
SeparacionGrid=1;
MultiplicadorCargasPositivas=1;
MultiplicadorCargasNegativas=1;
SeparacionLineas=16;
TotalCargasPositivas=50;
TotalCargasNegativas=50;
LongitudLineaPositiva=10;
LongitudLineaNegativa=5;
NumeroParticulasPruebaPos=5;
NumeroParticulasPruebaNeg=5;

%-----------------------------------------------------

x= -max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]):SeparacionGrid:max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]); %coordenadas X para donde medir campo electrico
y= -max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]):SeparacionGrid:max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]); %coordenadas Y para donde medir campo electrico
[X,Y] = meshgrid(x,y);
k = 8.99e9;
qp = MultiplicadorCargasPositivas*1e-9;
qn = MultiplicadorCargasNegativas*1e-9;
E=0;
masa=1e-12;
PotencialElectrico=0;

Ex=zeros(size(X)); %preasignando espacio
Ey=zeros(size(Y)); %preasignando espacio

qpy=-LongitudLineaPositiva/2:(LongitudLineaPositiva/TotalCargasPositivas):LongitudLineaPositiva/2; %coordenadas Y de cargas positivas
qny=-LongitudLineaNegativa/2:(LongitudLineaNegativa/TotalCargasNegativas):LongitudLineaNegativa/2; %coordenadas Y de cargas negativas

figure %setup de grafica
hold on
title('Campo eléctrico de cargas lineales')
xlabel('x')
ylabel('y')
axis equal
grid on
line([-SeparacionLineas/2 -SeparacionLineas/2], [-max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]) max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])],'Color','y')
line([SeparacionLineas/2 SeparacionLineas/2], [-max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]) max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])],'Color','y')
line([-SeparacionLineas/2 SeparacionLineas/2], [-max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]) -max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])],'Color','y')
line([-SeparacionLineas/2 SeparacionLineas/2], [max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas]) max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])],'Color','y')

q1=zeros(2,numel(qpy)); %preasignando espacio
for i= 1:max(2,numel(qpy)) %creando matriz de coordenadas para las cargas positivas
    q1(1,i)=-SeparacionLineas/2; 
    q1(2,i)=qpy(i);
    plot(q1(1,i), q1(2,i), 'ro', 'MarkerFaceColor','r') %graficando puntos positivos en rojo
end

q2=zeros(2,numel(qny)); %preasignando espacio
for i= 1:max(2,numel(qny)) %creando matriz de coordenadas para las cargas negativas
    q2(1,i)=SeparacionLineas/2;
    q2(2,i)=qny(i);
    plot(q2(1,i), q2(2,i), 'bo', 'MarkerFaceColor','b') %graficando puntos negativos en azul
end

ParticulaPruebaPosicionXPos = randi([-SeparacionLineas/4, SeparacionLineas/4], 1, NumeroParticulasPruebaPos);
ParticulaPruebaPosicionXNeg = randi([-SeparacionLineas/4, SeparacionLineas/4], 1, NumeroParticulasPruebaNeg);
ParticulaPruebaPosicionYPos = randi([-max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])/2, max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])/2], 1, NumeroParticulasPruebaPos);
ParticulaPruebaPosicionYNeg = randi([-max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])/2, max([LongitudLineaPositiva,LongitudLineaNegativa,SeparacionLineas])/2], 1, NumeroParticulasPruebaNeg);
ParticulaPruebaCargaPos = randi([1, 10], 1, NumeroParticulasPruebaPos)*1e-13;
ParticulaPruebaCargaNeg = randi([-10, -1], 1, NumeroParticulasPruebaNeg)*1e-13;
ParticulaPruebaMasaPos = randi([27, 32], 1, NumeroParticulasPruebaPos)*masa;
ParticulaPruebaMasaNeg = randi([27, 32], 1, NumeroParticulasPruebaNeg)*masa;
VelocidadInicialPruebaXPos = rand(1, NumeroParticulasPruebaPos)*1e-9;
VelocidadInicialPruebaXNeg = rand(1, NumeroParticulasPruebaNeg)*1e-9;
VelocidadInicialPruebaYPos = rand(1, NumeroParticulasPruebaPos)*1e-9;
VelocidadInicialPruebaYNeg = rand(1, NumeroParticulasPruebaNeg)*1e-9;

PruebaPlot1=plot(ParticulaPruebaPosicionXPos, ParticulaPruebaPosicionYPos, 'go', 'MarkerFaceColor','g');
PruebaPlot1Base=plot(ParticulaPruebaPosicionXPos, ParticulaPruebaPosicionYPos, 'go', 'MarkerFaceColor','g');
PruebaPlot2=plot(ParticulaPruebaPosicionXNeg, ParticulaPruebaPosicionYNeg, 'mo', 'MarkerFaceColor','m');
PruebaPlot2Base=plot(ParticulaPruebaPosicionXNeg, ParticulaPruebaPosicionYNeg, 'mo', 'MarkerFaceColor','m');

TempNumeroParticulasPruebaPos=NumeroParticulasPruebaPos;
TempNumeroParticulasPruebaNeg=NumeroParticulasPruebaNeg;

for i = 1:numel(X)
    for j=1:max(2,numel(qpy)) %para todas las cargas positivas
        r1=[X(i)-q1(1,j),Y(i)-q1(2,j)]; %distancia en X de punto de calculo a carga positiva numero j, distancia en Y del punto de calculo a carga positiva numero j
        R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
        TempE=(k.*(qp).*r1)/R1.^3; %Contribución de carga positiva J al campo electrico total del punto I
        E=E+TempE; %Sumación
    end
    for j=1:max(2,numel(qny)) %para todas las cargas negativas
        r1=[X(i)-q2(1,j),Y(i)-q2(2,j)]; %distancia en X de punto de calculo a carga negativa numero j, distancia en Y del punto de calculo a carga negativa numero j
        R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
        TempE=(k.*(-qn).*r1)/R1.^3; %Contribución de carga negativa J al campo electrico total del punto I
        E=E+TempE; %Sumación
    end
    Ex(i)=E(1); %guardando vector X del campo 
    Ey(i)=E(2); %guardando vector Y del campo 
    E=0; %reset a zero para calcular el siguiente punto
end

if (Normalizar==1)
    magnitud = sqrt(Ex.^2 + Ey.^2); 
    quiver(X, Y, Ex./magnitud, Ey./magnitud, 'c'); %dividiendo por su magnitud para solo tener la dirección
else
    quiver(X, Y, Ex, Ey, 'c');
end

TempParticulaPruebaPosicionXPos=ParticulaPruebaPosicionXPos;
TempParticulaPruebaPosicionXNeg=ParticulaPruebaPosicionXNeg;
TempParticulaPruebaPosicionYPos=ParticulaPruebaPosicionYPos;
TempParticulaPruebaPosicionYNeg=ParticulaPruebaPosicionYNeg;

%-----------------------------------------------------

for n=1:NumeroParticulasPruebaPos
    TempVelocidadPruebaXPos=VelocidadInicialPruebaXPos(n);
    TempVelocidadPruebaYPos=VelocidadInicialPruebaYPos(n);
for t=1:0.02:50
    for j=1:max(2,numel(qpy)) %para todas las cargas positivas
        r1=[TempParticulaPruebaPosicionXPos(n)-q1(1,j),TempParticulaPruebaPosicionYPos(n)-q1(2,j)]; %distancia en X de punto de calculo a carga positiva numero j, distancia en Y del punto de calculo a carga positiva numero j
        R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
        TempE=(k.*(qp).*r1)/R1.^3; %Contribución de carga positiva J al campo electrico total del punto I
        E=E+TempE; %Sumación
    end
    for j=1:max(2,numel(qny)) %para todas las cargas negativas
        r1=[TempParticulaPruebaPosicionXPos(n)-q2(1,j),TempParticulaPruebaPosicionYPos(n)-q2(2,j)]; %distancia en X de punto de calculo a carga negativa numero j, distancia en Y del punto de calculo a carga negativa numero j
        R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
        TempE=(k.*(-qn).*r1)/R1.^3; %Contribución de carga negativa J al campo electrico total del punto I
        E=E+TempE; %Sumación
    end
    Acceleracion=ParticulaPruebaCargaPos(n)*E/ParticulaPruebaMasaPos(n);
    Desplacamiento(1)=(1/2)*Acceleracion(1)*(t).^2;
    Desplacamiento(2)=(1/2)*Acceleracion(2)*(t).^2;
    line([TempParticulaPruebaPosicionXPos(n) TempParticulaPruebaPosicionXPos(n)+TempVelocidadPruebaXPos+Desplacamiento(1)], [TempParticulaPruebaPosicionYPos(n) TempParticulaPruebaPosicionYPos(n)+TempVelocidadPruebaYPos+Desplacamiento(2)],'Color','g')
    TempParticulaPruebaPosicionXPos(n)=TempParticulaPruebaPosicionXPos(n)+TempVelocidadPruebaXPos+Desplacamiento(1);
    TempParticulaPruebaPosicionYPos(n)=TempParticulaPruebaPosicionYPos(n)+TempVelocidadPruebaYPos+Desplacamiento(2);
    TempVelocidadPruebaXPos=TempVelocidadPruebaXPos+Acceleracion(1);
    TempVelocidadPruebaYPos=TempVelocidadPruebaYPos+Acceleracion(2);
    E=0;
    if TempParticulaPruebaPosicionXPos(n)>=SeparacionLineas/2
       TempParticulaPruebaPosicionXPos(n)=SeparacionLineas/2;
       plot(TempParticulaPruebaPosicionXPos(n), TempParticulaPruebaPosicionYPos(n), 'go', 'MarkerFaceColor','g');
       set(PruebaPlot1, 'XData', TempParticulaPruebaPosicionXPos(n), 'YData', TempParticulaPruebaPosicionYPos(n)); % Update position
       drawnow; % Force update
       break;
    else
       set(PruebaPlot1, 'XData', TempParticulaPruebaPosicionXPos(n), 'YData', TempParticulaPruebaPosicionYPos(n)); % Update position
       drawnow; % Force update
    end
end
end

%-----------------------------------------------------

for n=1:NumeroParticulasPruebaNeg
    TempVelocidadPruebaXNeg=VelocidadInicialPruebaXNeg(n);
    TempVelocidadPruebaYNeg=VelocidadInicialPruebaYNeg(n);
    for t=1:0.02:50
        for j=1:max(2,numel(qpy)) %para todas las cargas Negitivas
            r1=[TempParticulaPruebaPosicionXNeg(n)-q1(1,j),TempParticulaPruebaPosicionYNeg(n)-q1(2,j)]; %distancia en X de punto de calculo a carga positiva numero j, distancia en Y del punto de calculo a carga positiva numero j
            R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
            TempE=(k.*(qp).*r1)/R1.^3; %Contribución de carga positiva J al campo electrico total del punto I
            E=E+TempE; %Sumación
        end
        for j=1:max(2,numel(qny)) %para todas las cargas negativas
            r1=[TempParticulaPruebaPosicionXNeg(n)-q2(1,j),TempParticulaPruebaPosicionYNeg(n)-q2(2,j)]; %distancia en X de punto de calculo a carga negativa numero j, distancia en Y del punto de calculo a carga negativa numero j
            R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
            TempE=(k.*(-qn).*r1)/R1.^3; %Contribución de carga negativa J al campo electrico total del punto I
            E=E+TempE; %Sumación
        end
        Acceleracion=ParticulaPruebaCargaNeg(n)*E/ParticulaPruebaMasaNeg(n);
        Desplacamiento(1)=(1/2)*Acceleracion(1)*(t).^2;
        Desplacamiento(2)=(1/2)*Acceleracion(2)*(t).^2;
        line([TempParticulaPruebaPosicionXNeg(n) TempParticulaPruebaPosicionXNeg(n)+TempVelocidadPruebaXNeg+Desplacamiento(1)], [TempParticulaPruebaPosicionYNeg(n) TempParticulaPruebaPosicionYNeg(n)+TempVelocidadPruebaYNeg+Desplacamiento(2)],'Color','m')
        TempParticulaPruebaPosicionXNeg(n)=TempParticulaPruebaPosicionXNeg(n)+TempVelocidadPruebaXNeg+Desplacamiento(1);
        TempParticulaPruebaPosicionYNeg(n)=TempParticulaPruebaPosicionYNeg(n)+TempVelocidadPruebaYNeg+Desplacamiento(2);
        TempVelocidadPruebaXNeg=TempVelocidadPruebaXNeg+Acceleracion(1);
        TempVelocidadPruebaYNeg=TempVelocidadPruebaYNeg+Acceleracion(2);
        E=0;
        if TempParticulaPruebaPosicionXNeg(n)<=-SeparacionLineas/2
            TempParticulaPruebaPosicionXNeg(n)=-SeparacionLineas/2;
            plot(TempParticulaPruebaPosicionXNeg(n), TempParticulaPruebaPosicionYNeg(n), 'mo', 'MarkerFaceColor','m');
            set(PruebaPlot2, 'XData', TempParticulaPruebaPosicionXNeg(n), 'YData', TempParticulaPruebaPosicionYNeg(n)); % Update position
            drawnow; % Force update
            break;
        else
            set(PruebaPlot2, 'XData', TempParticulaPruebaPosicionXNeg(n), 'YData', TempParticulaPruebaPosicionYNeg(n)); % Update position
            drawnow; % Force update
        end
    end
end

%-----------------------------------------------------

PotencialElectricoX=zeros(size(X)); %preasignando espacio
PotencialElectricoY=zeros(size(Y)); %preasignando espacio

for i = 1:numel(X)
    for j=1:max(2,numel(qpy)) %para todas las cargas positivas
        r1=[X(i)-q1(1,j),Y(i)-q1(2,j)]; %distancia en X de punto de calculo a carga positiva numero j, distancia en Y del punto de calculo a carga positiva numero j
        R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
        TempPotencialElectrico=(k.*(qp)./R1); %Contribución de carga positiva J al campo electrico total del punto I
        PotencialElectrico=PotencialElectrico+TempPotencialElectrico; %Sumación
    end
    for j=1:max(2,numel(qny)) %para todas las cargas positivas
        r1=[X(i)-q2(1,j),Y(i)-q2(2,j)]; %distancia en X de punto de calculo a carga positiva numero j, distancia en Y del punto de calculo a carga positiva numero j
        R1=norm(r1); %teorema de Pitágoras para longitud de la hipotenusa del triangulo de los numeros anteriores
        TempPotencialElectrico=(k.*(qn)./R1); %Contribución de carga positiva J al campo electrico total del punto I
        PotencialElectrico=PotencialElectrico+TempPotencialElectrico; %Sumación
    end
    PotencialElectricoX(i)=PotencialElectrico(1); %guardando vector X del campo 
    PotencialElectrico=0; %reset a zero para calcular el siguiente punto
end

figure %setup de grafica
hold on
title('Potencial eléctrico de cargas lineales')
xlabel('x')
ylabel('y')
axis equal
grid on

contourf(X, Y, PotencialElectricoX);

%-----------------------------------------------------

figure
hold on
title('Campo eléctrico de cargas lineales')
xlabel('x')
ylabel('y')
axis equal
grid on

q1=zeros(2,numel(qpy)); %preasignando espacio
for i= 1:max(2,numel(qpy)) %creando matriz de coordenadas para las cargas positivas
    q1(1,i)=-SeparacionLineas/2; 
    q1(2,i)=qpy(i);
    plot(q1(1,i), q1(2,i), 'ro', 'MarkerFaceColor','r') %graficando puntos positivos en rojo
end

q2=zeros(2,numel(qny)); %preasignando espacio
for i= 1:max(2,numel(qny)) %creando matriz de coordenadas para las cargas negativas
    q2(1,i)=SeparacionLineas/2;
    q2(2,i)=qny(i);
    plot(q2(1,i), q2(2,i), 'bo', 'MarkerFaceColor','b') %graficando puntos negativos en azul
end

streamslice(X, Y, Ex, Ey);