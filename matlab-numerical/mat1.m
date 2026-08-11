clear; clc; close all;

f = @(x, y) -y;
x0 = 0;
y0 = 1;
xEnd = 5;
hVals = [1, 0.1, 0.05];
colores = ["#E63946", "#457B9D", "#2A9D8F"];
estilos = ["-", "--", ":"];

figure;
hold on;

for i = 1:length(hVals)
    h = hVals(i);
    x = x0:h:xEnd;
    n = length(x);
    y = zeros(1, n);
    y(1) = y0;

    for j = 1:n-1
        k1 = f(x(j), y(j));
        k2 = f(x(j) + h/2, y(j) + (h/2)*k1);
        y(j+1) = y(j) + h*k2;
    end

    plot(x, y, estilos(i), 'Color', colores(i), 'LineWidth', 2, ...
        'DisplayName', sprintf('Midpoint  h = %.2f', h));
end

% Solucion exacta
xEx = linspace(0, xEnd, 500);
plot(xEx, exp(-xEx), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Exacta: e^{-x}');

xlabel('x', 'FontSize', 13);
ylabel('y', 'FontSize', 13);
title('Método del Punto Medio — Efecto del tamaño de paso', 'FontSize', 14);
legend('Location', 'northeast', 'FontSize', 11);
grid on;
box on;
xlim([0 5]);
ylim([-0.1 1.1]);

% Reflexión — Método del Punto Medio

% El método del punto medio es un solver numérico de segundo orden para ODEs de la forma dy/dx = f(x, y). 
% Requiere una condición inicial y(x₀) = y₀, una función f evaluable en cualquier punto, y un paso h definido por el usuario. 
% Su ventaja sobre Euler es que en lugar de usar la pendiente al inicio del intervalo, primero estima un punto medio con k₁ = f(xₙ, yₙ), 
% y luego evalúa la pendiente ahí con k₂ = f(xₙ + h/2, yₙ + h/2·k₁), usando esa pendiente corregida para avanzar: yₙ₊₁ = yₙ + h·k₂.

% Como se observa en la gráfica, con h = 1 el error es notable desde los primeros pasos, mientras que h = 0.05 casi se superpone con la solución exacta e⁻ˣ. 
% Esto refleja su error global de orden O(h²): reducir h a la mitad reduce el error cuatro veces, logrando buena precisión sin demasiadas iteraciones.
