%% CALCULO Y SIMULACION DE LA DESACELERACION POR FRENADO MAGNETICO
%  Reporte final - Reto F1014B (Modelacion computacional de sistemas
%  electromagneticos)
%
%  Este codigo reune las tres simulaciones del reto en un solo programa
%  ejecutable, con sus respectivas animaciones:
%
%    SIMULACION 1 - Campo magnetico de un cable y de una espira por la
%                   Ley de Biot-Savart (Avance 1).
%    SIMULACION 2 - Caida de un iman (dipolo) sobre un anillo de corriente
%                   fija, integrada con Runge-Kutta de 4to orden (Avance 2).
%                   Incluye animacion 2D del campo y animacion 3D del iman.
%    SIMULACION 3 - FEM y corriente inducidas en una espira por el iman
%                   que cae por su eje; circuito RL resuelto con Euler
%                   (Avance 3). Incluye animacion 3D con FEM e I en vivo.
%    CASO C       - Extension del Avance 3: tubo de muchas espiras donde
%                   la induccion conjunta SI frena al iman visiblemente
%                   (modelo de la torre de caida, ley de Lenz). Incluye
%                   animacion 3D con vectores v, F y B_ind.

clear; close all; clc;


%% SIMULACION 1 - CAMPOS MAGNETICOS BASICOS (BIOT-SAVART)

%  Campo de un cable rectilineo (formula analitica) y de una espira
%  circular (integracion numerica de Biot-Savart). Se grafican los
%  vectores de campo en 3D y el mapa de magnitud del cable.

%% Parametros
I_s1  = 5;            % [A]     corriente
mu0   = 4*pi*1e-7;    % [T*m/A] permeabilidad del vacio
R_s1  = 1;            % [m]     radio de la espira
n_s1  = 100;          % numero de segmentos de la espira

%  Cable rectilineo (formula analitica)
[y, z, x] = meshgrid(-1:0.2:1, -1:0.2:1, -1:0.2:1);
d = sqrt(y.^2 + z.^2);          % distancia perpendicular al cable
B = (mu0*I_s1) ./ (2*pi*d);     % magnitud del campo (B = mu0 I / 2 pi d)
B(d < 1e-6) = 0;
By = -B .* (z./d);
Bz =  B .* (y./d);
Bx = zeros(size(x));

Bmag = sqrt(Bx.^2 + By.^2 + Bz.^2);
Bmag(Bmag == 0) = 1;
Bxn = Bx ./ Bmag;  Byn = By ./ Bmag;  Bzn = Bz ./ Bmag;

figure('Name','Sim 1 - Cable'); hold on;
x_cable = linspace(-1, 1, 100);
plot3(x_cable, zeros(size(x_cable)), zeros(size(x_cable)), 'b', 'LineWidth', 4);
quiver3(x(:), y(:), z(:), Bxn(:), Byn(:), Bzn(:), 2, 'r');
axis equal; grid on;
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Campo magnetico generado por una linea de corriente');
view(35, 25);

figure('Name','Sim 1 - Magnitud cable');
contourf(y(:,:,1), z(:,:,1), sqrt(By(:,:,1).^2 + Bz(:,:,1).^2), 20);
colorbar; axis equal;
xlabel('y (m)'); ylabel('z (m)');
title('Magnitud del campo B - cable');

%  Espira circular (integracion numerica)
[x, y, z] = meshgrid(-2:0.4:2, -2:0.4:2, -2:0.4:2);
phi = linspace(0, 2*pi, n_s1+1);
x_e = R_s1*cos(phi);
y_e = R_s1*sin(phi);
z_e = zeros(size(phi));

Bx = zeros(size(x));  By = zeros(size(x));  Bz = zeros(size(x));
for ii = 1:size(x,1)
    for jj = 1:size(x,2)
        for ll = 1:size(x,3)
            Bt = [0,0,0];
            for k = 1:n_s1
                ds    = [x_e(k+1)-x_e(k), y_e(k+1)-y_e(k), 0];
                r_vec = [x(ii,jj,ll)-x_e(k), y(ii,jj,ll)-y_e(k), z(ii,jj,ll)-z_e(k)];
                r_mag = norm(r_vec);
                if r_mag > 1e-6
                    dB = (mu0*I_s1)/(4*pi) * cross(ds, r_vec) / r_mag^3;
                    Bt = Bt + dB;
                end
            end
            Bx(ii,jj,ll) = Bt(1);
            By(ii,jj,ll) = Bt(2);
            Bz(ii,jj,ll) = Bt(3);
        end
    end
end

Bmag = sqrt(Bx.^2 + By.^2 + Bz.^2);
Bmag(Bmag == 0) = 1;
Bxn = Bx ./ Bmag;  Byn = By ./ Bmag;  Bzn = Bz ./ Bmag;

figure('Name','Sim 1 - Espira'); hold on;
plot3(x_e, y_e, z_e, 'b', 'LineWidth', 3);
quiver3(x(:), y(:), z(:), Bxn(:), Byn(:), Bzn(:), 2, 'r');
axis equal; grid on;
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Campo magnetico generado por una espira circular');
view(35, 25);

fprintf('=== SIMULACION 1 completada (campo de cable y espira) ===\n');


%% SIMULACION 2 - CAIDA DEL IMAN SOBRE EL ANILLO (RK4)

%  El iman (dipolo) cae sobre un anillo con corriente FIJA. La fuerza
%  magnetica se calcula analitica y numericamente (diferencias finitas)
%  y la trayectoria se integra con RK4. Despues de las graficas estaticas
%  se incluyen una animacion 2D del mapa del campo y una animacion 3D
%  del iman cilindrico cayendo sobre el anillo.

%% Parametros del anillo y del iman

I_av2     = 1.5e4;     % [A] corriente del anillo (los de la presentacion / AvanceFinal.m)
a_av2     = 0.35;      % [m] radio del anillo
mu_mag    = 50;        % [A*m^2] momento dipolar del iman
m_iman    = 0.05;      % [kg] masa del iman (50 g)
g         = 9.81;      % [m/s^2] gravedad

% Condiciones iniciales
z0_av2 = 2;            % [m]   posicion inicial sobre el eje
v0_av2 = -4;           % [m/s] velocidad inicial

% Parametros numericos
dt_av2    = 1e-4;      % [s] paso de tiempo
t_max_av2 = 8;         % [s] tiempo maximo
z_min_av2 = -3;        % [m] altura de corte

N_av2     = round(t_max_av2/dt_av2) + 1;
t_av2     = zeros(1, N_av2);
z_av2     = zeros(1, N_av2);
v_av2     = zeros(1, N_av2);
Fmag_av2  = zeros(1, N_av2);   % fuerza magnetica numerica (diferencias finitas)
Ftot_av2  = zeros(1, N_av2);   % fuerza total
Fana_av2  = zeros(1, N_av2);   % fuerza magnetica analitica

z_av2(1) = z0_av2;
v_av2(1) = v0_av2;

% Constante de la fuerza magnetica analitica:
%   F_mag(z) = 3 mu_mag mu0 I a^2 z / [2 (z^2+a^2)^(5/2)]
K_force = 3 * mu_mag * mu0 * I_av2 * a_av2^2 / 2;

i = 1;
while i < N_av2 && z_av2(i) > z_min_av2
    z_n = z_av2(i);
    v_n = v_av2(i);

    % RK4
    F_mag_1 = K_force * z_n / (z_n^2 + a_av2^2)^(5/2);
    k1_z = v_n;          k1_v = -g + F_mag_1/m_iman;

    z_m1 = z_n + 0.5*dt_av2*k1_z;   v_m1 = v_n + 0.5*dt_av2*k1_v;
    F_mag_2 = K_force * z_m1 / (z_m1^2 + a_av2^2)^(5/2);
    k2_z = v_m1;         k2_v = -g + F_mag_2/m_iman;

    z_m2 = z_n + 0.5*dt_av2*k2_z;   v_m2 = v_n + 0.5*dt_av2*k2_v;
    F_mag_3 = K_force * z_m2 / (z_m2^2 + a_av2^2)^(5/2);
    k3_z = v_m2;         k3_v = -g + F_mag_3/m_iman;

    z_f  = z_n + dt_av2*k3_z;       v_f  = v_n + dt_av2*k3_v;
    F_mag_4 = K_force * z_f / (z_f^2 + a_av2^2)^(5/2);
    k4_z = v_f;          k4_v = -g + F_mag_4/m_iman;

    z_av2(i+1) = z_n + (dt_av2/6)*(k1_z + 2*k2_z + 2*k3_z + k4_z);
    v_av2(i+1) = v_n + (dt_av2/6)*(k1_v + 2*k2_v + 2*k3_v + k4_v);
    t_av2(i+1) = t_av2(i) + dt_av2;

    % Fuerza numerica (diferencias finitas) para validacion
    z_aux = z_n + v_n*dt_av2;
    B_n   = mu0 * I_av2 * a_av2^2 / (2 * (z_n^2   + a_av2^2)^(3/2));
    B_aux = mu0 * I_av2 * a_av2^2 / (2 * (z_aux^2 + a_av2^2)^(3/2));
    if abs(z_aux - z_n) > 1e-12
        dBdz = (B_aux - B_n) / (z_aux - z_n);
    else
        dBdz = 0;
    end
    F_mag_num = -mu_mag * dBdz;

    F_mag_ana = K_force * z_n / (z_n^2 + a_av2^2)^(5/2);
    F_total   = -m_iman*g + F_mag_ana;

    Fmag_av2(i) = F_mag_num;
    Fana_av2(i) = F_mag_ana;
    Ftot_av2(i) = F_total;

    i = i + 1;
end

% Recortar al numero real de pasos
N_av2_real = i - 1;
t_av2    = t_av2(1:N_av2_real);
z_av2    = z_av2(1:N_av2_real);
v_av2    = v_av2(1:N_av2_real);
Fmag_av2 = Fmag_av2(1:N_av2_real);
Ftot_av2 = Ftot_av2(1:N_av2_real);
Fana_av2 = Fana_av2(1:N_av2_real);

% Caida libre de referencia
z_free = z0_av2 + v0_av2*t_av2 - 0.5*g*t_av2.^2;

%  Graficas estaticas
figure('Name','Sim 2 - Fig 1 Posicion vs tiempo','Position',[100 100 750 500]);
hold on;
plot(t_av2, z_av2,  'r-',  'LineWidth', 2.5, 'DisplayName','Caida con frenado magnetico');
plot(t_av2, z_free, 'b--', 'LineWidth', 2,   'DisplayName','Caida libre (sin frenado)');
yline(0, 'k-.', 'LineWidth', 1.5, 'DisplayName','Plano del anillo (z = 0)');
hold off; grid on;
xlabel('Tiempo (s)'); ylabel('Posicion z (m)');
title('Fig 1: Posicion del iman vs tiempo');
legend('Location','southwest'); set(gca,'FontSize',11);

figure('Name','Sim 2 - Fig 2 Fuerza total vs posicion','Position',[100 100 750 500]);
hold on;
plot(z_av2, Ftot_av2, 'b-', 'LineWidth', 2);
xline(0, 'k-.', 'LineWidth', 1.5);
yline(0, 'k-',  'LineWidth', 0.5);
yline(-m_iman*g, 'k:', 'LineWidth', 1.2);
hold off; grid on;
xlabel('Posicion z (m)'); ylabel('Fuerza total sobre el iman (N)');
title('Fig 2: Fuerza total vs posicion');
legend({'Fuerza total','Plano del anillo','','Solo gravedad'},'Location','best');
set(gca,'FontSize',11);

figure('Name','Sim 2 - Fig 3 Fuerza total vs tiempo','Position',[100 100 750 500]);
hold on;
plot(t_av2, Ftot_av2, 'b-', 'LineWidth', 2);
yline(-m_iman*g, 'k--', 'LineWidth', 1.5);
yline(0, 'k-', 'LineWidth', 0.5);
hold off; grid on;
xlabel('Tiempo (s)'); ylabel('Fuerza total sobre el iman (N)');
title('Fig 3: Fuerza total vs tiempo');
legend({'Fuerza total','Solo gravedad (-mg)'},'Location','best');
set(gca,'FontSize',11);

figure('Name','Sim 2 - Fig 4 Validacion','Position',[100 100 750 500]);
hold on;
plot(z_av2, Fmag_av2, 'b-',  'LineWidth', 2.8, 'DisplayName','Fuerza magnetica numerica');
plot(z_av2, Fana_av2, 'r--', 'LineWidth', 1.8, 'DisplayName','Fuerza magnetica analitica');
xline(0, 'k-.', 'LineWidth', 1.5, 'DisplayName','Plano del anillo');
yline(0, 'k-',  'LineWidth', 0.5, 'HandleVisibility','off');
hold off; grid on;
xlabel('Posicion z (m)'); ylabel('Fuerza magnetica F_{mag} (N)');
title('Fig 4: Validacion - Fuerza magnetica numerica vs analitica');
legend('Location','best'); set(gca,'FontSize',11);

fprintf('\n=== SIMULACION 2 - RESUMEN ===\n');
fprintf(' Pasos simulados:        %d\n', N_av2_real);
fprintf(' Velocidad en z = 0:     %.3f m/s\n', interp1(z_av2, v_av2, 0, 'linear'));
fprintf(' Velocidad caida libre:  %.3f m/s\n', -sqrt(2*g*z0_av2 + v0_av2^2));
fprintf(' max|F_num - F_ana|:     %.3e N\n', max(abs(Fmag_av2 - Fana_av2)));


%  Animacion 2D - mapa del campo del anillo + iman cayendo
%  Construye el mapa del campo en el plano xz por Biot-Savart numerico
%  y reproduce la caida del iman como un marcador magenta sobre el campo.

x_grid = linspace(-3, 3, 50);
z_grid = linspace(-3, 5, 70);
[Xg, Zg] = meshgrid(x_grid, z_grid);

n_seg = 80;
phi   = linspace(0, 2*pi, n_seg+1);
x_an  = a_av2*cos(phi);
y_an  = a_av2*sin(phi);
z_an  = zeros(size(phi));

Bx_map = zeros(size(Xg));
Bz_map = zeros(size(Xg));
for ii = 1:size(Xg,1)
    for jj = 1:size(Xg,2)
        B = [0,0,0];
        for k = 1:n_seg
            ds  = [x_an(k+1)-x_an(k), y_an(k+1)-y_an(k), 0];
            r_v = [Xg(ii,jj)-x_an(k), -y_an(k), Zg(ii,jj)-z_an(k)];
            rm  = norm(r_v);
            if rm > 1e-6
                dB = (mu0*I_av2)/(4*pi) * cross(ds, r_v) / rm^3;
                B  = B + dB;
            end
        end
        Bx_map(ii,jj) = B(1);
        Bz_map(ii,jj) = B(3);
    end
end
B_map = sqrt(Bx_map.^2 + Bz_map.^2);

figure('Name','Sim 2 - Animacion 2D del campo','Position',[200 50 800 750]);
contourf(Xg, Zg, log10(B_map + 1e-12), 25, 'LineStyle','none');
colormap(jet);
hold on;
streamslice(Xg, Zg, Bx_map, Bz_map, 2, 'arrows');
plot([-a_av2 a_av2], [0 0], 'ko', 'MarkerSize',12, 'MarkerFaceColor','k');
yline(0, 'k--', 'LineWidth',1.2);
axis equal; axis([-3 3 -3 5]);
xlabel('x (m)'); ylabel('z (m)');
cb = colorbar; cb.Label.String = 'log_{10}|B| (T)';

iman_2d = plot(0, z_av2(1), 'mo', 'MarkerSize',16, 'MarkerFaceColor','m', ...
               'LineWidth',2);

n_frames_2d  = 200;
step_anim_2d = max(1, round(N_av2_real/n_frames_2d));

for k = 1:step_anim_2d:N_av2_real
    set(iman_2d, 'YData', z_av2(k));
    title(sprintf('Animacion 2D - t = %.2f s | z = %.2f m | v = %.2f m/s', ...
                  t_av2(k), z_av2(k), v_av2(k)));
    drawnow;
    pause(0.02);
end
hold off;


%  Animacion 3D - iman cilindrico cayendo sobre el anillo
%  Vista 3D del iman como cilindro (S azul arriba / N rojo abajo) cayendo
%  sobre el anillo, con un panel lateral mostrando v(t) en vivo y la
%  caida libre de referencia (linea punteada).

fig_av2_3d = figure('Name','Sim 2 - Animacion 3D','Position',[80 40 1400 760]);

ax3d_av2 = subplot(1,2,1);
xlim(ax3d_av2, [-1 1]);
ylim(ax3d_av2, [-1 1]);
zlim(ax3d_av2, [z_min_av2 - 0.3, z0_av2 + 0.3]);
daspect(ax3d_av2, [1 1 1]);
xlabel(ax3d_av2, 'x (m)'); ylabel(ax3d_av2, 'y (m)'); zlabel(ax3d_av2, 'z (m)');
grid(ax3d_av2, 'on');
view(ax3d_av2, -40, 14);
hold(ax3d_av2, 'on');

ax_v_av2 = subplot(1,2,2);
v_libre_av2 = v0_av2 - g * t_av2;
plot(ax_v_av2, t_av2, v_av2,       'b-',  'LineWidth', 2.4); hold(ax_v_av2, 'on');
plot(ax_v_av2, t_av2, v_libre_av2, 'k--', 'LineWidth', 1.2);
yline(ax_v_av2, 0, 'k:', 'LineWidth', 0.6);
v_mark_av2 = plot(ax_v_av2, t_av2(1), v_av2(1), 'o', 'MarkerSize', 11, ...
                  'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
grid(ax_v_av2, 'on');
xlabel(ax_v_av2, 'Tiempo (s)'); ylabel(ax_v_av2, 'Velocidad v (m/s)');
title(ax_v_av2, 'Velocidad: con frenado (azul) vs caida libre (negra)');
legend(ax_v_av2, {'Con anillo (frenado)','Caida libre',''}, 'Location','southwest');
set(ax_v_av2, 'FontSize', 11);

theta_ring     = linspace(0, 2*pi, 80);
n_frames_av2   = 200;
step_av2_3d    = max(1, round(N_av2_real/n_frames_av2));

for kk = 1:step_av2_3d:N_av2_real
    set(0, 'CurrentFigure', fig_av2_3d);
    cla(ax3d_av2);
    set(fig_av2_3d, 'CurrentAxes', ax3d_av2);

    plot3([0 0],[0 0],[z_min_av2 z0_av2], 'k:', 'LineWidth', 0.6);

    plot3(a_av2*cos(theta_ring), a_av2*sin(theta_ring), zeros(size(theta_ring)), ...
          'Color', [0.85 0.65 0.13], 'LineWidth', 5);
    text(a_av2 + 0.1, 0, 0.05, 'I', 'Color', 'r', 'FontSize', 13, ...
         'FontWeight', 'bold');

    drawMagnet(z_av2(kk), 0.13, 0.30);

    quiver3(0, 0, z_av2(kk), 0, 0, -0.5, 'm', 'LineWidth', 2.2, ...
            'MaxHeadSize', 0.5);

    camlight(ax3d_av2, 'headlight');

    title(ax3d_av2, sprintf('Sim 2 - corriente FIJA | t=%.2fs   z=%.2fm   v=%.2fm/s', ...
                            t_av2(kk), z_av2(kk), v_av2(kk)));

    set(v_mark_av2, 'XData', t_av2(kk), 'YData', v_av2(kk));

    drawnow;
    pause(0.025);
end


%% SIMULACION 3 - FEM Y CORRIENTE INDUCIDAS EN LA ESPIRA (FARADAY + RL)

%  El iman cae en MRUA (su retroceso por induccion es despreciable para
%  una sola espira). Se calcula la FEM por Faraday + regla de la cadena
%  y la corriente del circuito RL por Euler explicito. Despues de la
%  grafica estatica se incluye una animacion 3D donde el anillo cambia
%  de color en vivo segun la corriente inducida.

%% Parametros fisicos, geometricos y electricos

m_z = 10;            % [A*m^2] momento dipolar
R   = 0.05;          % [m]   radio de la espira (5 cm)
R_e = 0.5;           % [ohm] resistencia
L_e = 1e-4;          % [H]   inductancia

z0 = 0.15;           % [m]   altura inicial
v0 = 0;              % [m/s] velocidad inicial

dt    = 1e-5;        % [s]
t_max = 0.4;         % [s]
z_fin = -0.15;       % [m]

%  Cinematica MRUA
N     = round(t_max/dt) + 1;
t_vec = (0:N-1) * dt;
z_vec = z0 + v0*t_vec - 0.5*g*t_vec.^2;
v_vec = v0 - g*t_vec;

idx_fin = find(z_vec <= z_fin, 1, 'first');
if ~isempty(idx_fin)
    t_vec = t_vec(1:idx_fin);
    z_vec = z_vec(1:idx_fin);
    v_vec = v_vec(1:idx_fin);
end
N = length(t_vec);

%  FEM inducida (Faraday + regla de la cadena)
v_caida = abs(v_vec);
emf_vec = (3 * mu0 * m_z * R^2 .* z_vec) ./ ...
          (2 * (R^2 + z_vec.^2).^(5/2)) .* v_caida;

%  Corriente en el circuito RL (Euler)
I_vec = zeros(1, N);
for k = 1:N-1
    I_vec(k+1) = I_vec(k) + (dt/L_e) * (emf_vec(k) - R_e*I_vec(k));
end

%  Graficas en funcion de z (eje X invertido)
figure('Name','Sim 3 - FEM y corriente vs posicion','Position',[100 80 1000 650]);

subplot(2,1,1);
plot(z_vec, emf_vec, 'r-', 'LineWidth', 2); hold on;
xline(0, 'k--', 'Centro de la Espira', ...
      'LabelOrientation','horizontal','LabelVerticalAlignment','middle','LineWidth',1.2);
yline(0, 'k:', 'LineWidth', 0.5); hold off; grid on;
ylabel('FEM Inducida (V)');
title('Evolucion de la FEM y Corriente segun la posicion del Iman');
set(gca, 'XDir', 'reverse', 'FontSize', 11);
xlim([-0.15 0.15]); ylim([-5e-3 5e-3]);

subplot(2,1,2);
plot(z_vec, I_vec, 'b-', 'LineWidth', 2); hold on;
xline(0, 'k--', 'Centro de la Espira', ...
      'LabelOrientation','horizontal','LabelVerticalAlignment','middle','LineWidth',1.2);
yline(0, 'k:', 'LineWidth', 0.5); hold off; grid on;
xlabel('Posicion del iman z (m)'); ylabel('Corriente Inducida (A)');
set(gca, 'XDir', 'reverse', 'FontSize', 11);
xlim([-0.15 0.15]); ylim([-0.01 0.01]);

[emf_max, idx_emf] = max(abs(emf_vec));
[I_max_3,   idx_I  ] = max(abs(I_vec));
tau = L_e / R_e;

fprintf('\n=== SIMULACION 3 - RESUMEN ===\n');
fprintf(' tau = L/R_e = %.2e s,  dt/tau = %.3f (estable si < 2)\n', tau, dt/tau);
fprintf(' |FEM|_max = %.3e V  en z = %.4f m\n', emf_max, z_vec(idx_emf));
fprintf(' |I|_max   = %.3e A  en z = %.4f m\n', I_max_3, z_vec(idx_I));


%  Animacion 3D - induccion en la espira (FEM e I en vivo)
%  Vista 3D del iman cilindrico cayendo sobre el anillo unico. El anillo
%  cambia de color segun |I| instantanea, y dos paneles laterales muestran
%  FEM(z) y I(z) con marcador amarillo en vivo.

I_max_av3 = max(abs(I_vec));

fig_av3 = figure('Name','Sim 3 - Animacion 3D induccion','Position',[100 50 1400 760]);

ax3d_av3 = subplot(2,3,[1 4]);
xlim(ax3d_av3, [-0.10 0.10]);
ylim(ax3d_av3, [-0.10 0.10]);
zlim(ax3d_av3, [-0.18 0.20]);
daspect(ax3d_av3, [1 1 1]);
xlabel(ax3d_av3, 'x (m)'); ylabel(ax3d_av3, 'y (m)'); zlabel(ax3d_av3, 'z (m)');
grid(ax3d_av3, 'on');
view(ax3d_av3, -45, 14);
hold(ax3d_av3, 'on');

ax_emf_av3 = subplot(2,3,[2 3]);
plot(ax_emf_av3, z_vec, emf_vec*1000, 'r-', 'LineWidth', 2);
hold(ax_emf_av3, 'on');
xline(ax_emf_av3, 0, 'k--', 'Centro de la Espira', ...
      'LabelOrientation','horizontal','LabelVerticalAlignment','middle','LineWidth', 1.0);
yline(ax_emf_av3, 0, 'k:', 'LineWidth', 0.5);
emf_mark = plot(ax_emf_av3, z_vec(1), emf_vec(1)*1000, 'o', ...
                'MarkerSize', 11, 'MarkerFaceColor', 'y', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
set(ax_emf_av3, 'XDir', 'reverse');
xlim(ax_emf_av3, [-0.15 0.15]); ylim(ax_emf_av3, [-5 5]);
grid(ax_emf_av3, 'on');
xlabel(ax_emf_av3, 'Posicion z del iman (m)');
ylabel(ax_emf_av3, 'FEM (mV)');
title(ax_emf_av3, 'FEM inducida en vivo');
set(ax_emf_av3, 'FontSize', 11);

ax_I_av3 = subplot(2,3,[5 6]);
plot(ax_I_av3, z_vec, I_vec*1000, 'b-', 'LineWidth', 2);
hold(ax_I_av3, 'on');
xline(ax_I_av3, 0, 'k--', 'Centro de la Espira', ...
      'LabelOrientation','horizontal','LabelVerticalAlignment','middle','LineWidth', 1.0);
yline(ax_I_av3, 0, 'k:', 'LineWidth', 0.5);
I_mark = plot(ax_I_av3, z_vec(1), I_vec(1)*1000, 'o', ...
              'MarkerSize', 11, 'MarkerFaceColor', 'y', ...
              'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
set(ax_I_av3, 'XDir', 'reverse');
xlim(ax_I_av3, [-0.15 0.15]); ylim(ax_I_av3, [-10 10]);
grid(ax_I_av3, 'on');
xlabel(ax_I_av3, 'Posicion z del iman (m)');
ylabel(ax_I_av3, 'Corriente inducida (mA)');
title(ax_I_av3, 'Corriente inducida en vivo');
set(ax_I_av3, 'FontSize', 11);

theta_ring_av3 = linspace(0, 2*pi, 80);
n_frames_av3   = 150;
step_av3       = max(1, round(N/n_frames_av3));

for kk = 1:step_av3:N
    set(0, 'CurrentFigure', fig_av3);
    cla(ax3d_av3);
    set(fig_av3, 'CurrentAxes', ax3d_av3);

    plot3([0 0],[0 0],[-0.18 0.20], 'k:', 'LineWidth', 0.6);

    %  Anillo coloreado por |I| instantanea
    amp      = min(abs(I_vec(kk))/max(I_max_av3, eps), 1);
    ring_col = [0.6 + 0.4*amp, 0.5 - 0.45*amp, 0.3 - 0.25*amp];
    ring_lw  = 3.0 + 4.0*amp;
    plot3(R*cos(theta_ring_av3), R*sin(theta_ring_av3), ...
          zeros(size(theta_ring_av3)), 'Color', ring_col, 'LineWidth', ring_lw);

    drawMagnet(z_vec(kk), 0.012, 0.025);

    quiver3(0, 0, z_vec(kk), 0, 0, -0.035, 'm', 'LineWidth', 2, ...
            'MaxHeadSize', 0.5);

    camlight(ax3d_av3, 'headlight');

    title(ax3d_av3, sprintf( ...
        'Sim 3 - induccion | t=%.3fs   z=%.3fm   v=%.2fm/s | I=%.2fmA', ...
        t_vec(kk), z_vec(kk), v_vec(kk), I_vec(kk)*1000));

    set(emf_mark, 'XData', z_vec(kk), 'YData', emf_vec(kk)*1000);
    set(I_mark,   'XData', z_vec(kk), 'YData', I_vec(kk)*1000);

    drawnow;
    pause(0.025);
end


%% CASO C - TUBO DE ESPIRAS (FRENADO POR INDUCCION, LEY DE LENZ)

%  Apilando muchas espiras, la suma de fuerzas de retroceso SI frena al
%  iman: es el modelo realista del reto (torre de caida). Sistema acoplado
%  de N+2 ODEs integrado con RK4. Demuestra la velocidad terminal.
%  Incluye animacion 3D con vectores v, F y B_ind en vivo.

%%  Parametros del tubo

m_z_C   = 50;          % [A*m^2] momento dipolar
m_im_C  = 0.05;        % [kg]    masa del iman
R_C     = 0.04;        % [m]     radio del tubo
R_e_C   = 0.001;       % [ohm]   resistencia por espira
L_C     = 1e-6;        % [H]     inductancia por espira
N_C     = 50;          % numero de espiras
sp_C    = 0.005;       % [m]     separacion entre espiras
z_rings_C  = -(0:N_C-1) * sp_C;
z_top_C    = z_rings_C(1);
z_bottom_C = z_rings_C(end);

z0_C = 0.30; v0_C = 0; dt_C = 2e-4; t_max_C = 2;
z_fin_C = z_bottom_C - 0.03;

N_steps_C = round(t_max_C/dt_C) + 1;
t_C = zeros(1, N_steps_C);
z_C = zeros(1, N_steps_C);
v_C = zeros(1, N_steps_C);
I_C = zeros(N_C, N_steps_C);

y_C = zeros(N_C+2, 1);
y_C(1) = z0_C;  y_C(2) = v0_C;
t_C(1) = 0;     z_C(1) = y_C(1);   v_C(1) = y_C(2);

n_eff_C = 1;
for kk = 1:N_steps_C-1
    k1 = derivs_tubo(y_C,              z_rings_C, R_C, R_e_C, L_C, mu0, m_z_C, m_im_C, g);
    k2 = derivs_tubo(y_C + 0.5*dt_C*k1, z_rings_C, R_C, R_e_C, L_C, mu0, m_z_C, m_im_C, g);
    k3 = derivs_tubo(y_C + 0.5*dt_C*k2, z_rings_C, R_C, R_e_C, L_C, mu0, m_z_C, m_im_C, g);
    k4 = derivs_tubo(y_C +     dt_C*k3, z_rings_C, R_C, R_e_C, L_C, mu0, m_z_C, m_im_C, g);
    y_C = y_C + (dt_C/6) * (k1 + 2*k2 + 2*k3 + k4);
    t_C(kk+1)   = kk * dt_C;
    z_C(kk+1)   = y_C(1);
    v_C(kk+1)   = y_C(2);
    I_C(:,kk+1) = y_C(3:end);
    n_eff_C = kk + 1;
    if y_C(1) <= z_fin_C, break; end
end
t_C = t_C(1:n_eff_C);  z_C = z_C(1:n_eff_C);
v_C = v_C(1:n_eff_C);  I_C = I_C(:,1:n_eff_C);

v_libre_C = -g * t_C;

% Fuerza magnetica neta sobre el iman en cada instante
F_mag_hist = zeros(1, n_eff_C);
for kk = 1:n_eff_C
    d_k   = z_C(kk) - z_rings_C(:);
    den52 = (R_C^2 + d_k.^2).^(5/2);
    F_k   = 3*mu0*m_z_C*R_C^2 .* d_k .* I_C(:,kk) ./ (2*den52);
    F_mag_hist(kk) = sum(F_k);
end
F_neta_C = F_mag_hist - m_im_C * g;
peso     = m_im_C * g;

%  Graficas estaticas
figure('Name','Caso C - Velocidad con tubo','Position',[100 100 850 500]);
plot(t_C, v_C, 'b-', 'LineWidth', 2.4); hold on;
plot(t_C, v_libre_C, 'k--', 'LineWidth', 1.2);
yline(0, 'k:', 'LineWidth', 0.6); hold off; grid on;
xlabel('Tiempo (s)'); ylabel('Velocidad v (m/s)');
title('Caso C: Velocidad con tubo (frenado Lenz) vs caida libre');
legend({'Con tubo (frenado)','Caida libre'},'Location','southwest');
set(gca,'FontSize',11);

figure('Name','Caso C - Fuerzas sobre el iman','Position',[120 70 850 500]);
plot(t_C, F_mag_hist, 'Color',[0.95 0.55 0.05], 'LineWidth', 2.4); hold on;
plot(t_C, F_neta_C,   'b-', 'LineWidth', 2.4);
yline(0, 'k:', 'LineWidth', 0.8);
yline(-peso, 'k--', sprintf('-m\\cdotg = -%.3f N', peso), ...
      'LineWidth', 1.2, 'LabelHorizontalAlignment','left');
hold off; grid on;
xlabel('Tiempo (s)'); ylabel('Fuerza (N)');
title('Caso C: Fuerza magnetica (Lenz) y fuerza neta sobre el iman');
legend({'F_{mag} (induccion en el tubo)','F_{neta} = F_{mag} - m\cdotg'},'Location','best');
set(gca,'FontSize',11);

fprintf('\n=== CASO C - Tubo de %d espiras (frenado por induccion) ===\n', N_C);
fprintf(' Velocidad final con frenado: %.3f m/s\n', v_C(end));
fprintf(' Velocidad sin frenado:       %.3f m/s\n', v_libre_C(end));
if abs(v_C(end)) > 1e-3
    fprintf(' Reduccion %.1fx por induccion (Lenz).\n', abs(v_libre_C(end)/v_C(end)));
end


%  Animacion 3D - tubo con vectores v, F y B_ind
%  Vista 3D del tubo entero con el iman cilindrico cayendo. Las espiras
%  cambian de color segun su |I_k|, y se dibujan tres vectores en vivo:
%  velocidad v (azul), fuerza magnetica F (naranja) y campo inducido
%  B_ind (verde) en la espira de mayor corriente.

v_max_C   = max(abs(v_C));
F_max_C   = max(abs(F_mag_hist));
v_scale   = 0.05 / max(v_max_C, eps);
F_scale   = 0.05 / max(F_max_C, eps);
B_arrow_L = 0.025;
I_max_C   = max(abs(I_C(:)));

fig_C = figure('Name','Caso C - Animacion 3D tubo (Lenz)','Position',[100 50 1400 760]);

ax3d_C = subplot(1,2,1);
xlim(ax3d_C, [-1.6*R_C, 1.6*R_C]);
ylim(ax3d_C, [-1.6*R_C, 1.6*R_C]);
zlim(ax3d_C, [z_bottom_C - 0.05, z0_C + 0.05]);
pbaspect(ax3d_C, [1 1 3.5]);
xlabel(ax3d_C, 'x (m)'); ylabel(ax3d_C, 'y (m)'); zlabel(ax3d_C, 'z (m)');
grid(ax3d_C, 'on');
view(ax3d_C, -40, 14);
hold(ax3d_C, 'on');

ax_v_C = subplot(1,2,2);
plot(ax_v_C, t_C, v_C,        'b-',  'LineWidth', 2.4); hold(ax_v_C, 'on');
plot(ax_v_C, t_C, v_libre_C,  'k--', 'LineWidth', 1.2);
yline(ax_v_C, 0, 'k:', 'LineWidth', 0.6);
v_mark_C = plot(ax_v_C, t_C(1), v_C(1), 'o', 'MarkerSize', 11, ...
                'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
grid(ax_v_C, 'on');
xlabel(ax_v_C, 'Tiempo (s)'); ylabel(ax_v_C, 'Velocidad v (m/s)');
title(ax_v_C, 'Velocidad: con tubo (azul) vs caida libre (negra)');
legend(ax_v_C, {'Con tubo (frenado)','Caida libre',''}, 'Location','southwest');
set(ax_v_C, 'FontSize', 11);

n_frames_C = 150;
step_C = max(1, round(n_eff_C/n_frames_C));

for kk = 1:step_C:n_eff_C
    set(0, 'CurrentFigure', fig_C);
    cla(ax3d_C);
    set(fig_C, 'CurrentAxes', ax3d_C);

    plot3([0 0],[0 0],[z_bottom_C - 0.05, z0_C + 0.05], 'k:', 'LineWidth', 0.6);

    %  Planos rojos: entrada y salida del tubo
    patch([-2*R_C 2*R_C 2*R_C -2*R_C], ...
          [-2*R_C -2*R_C 2*R_C 2*R_C], ...
          [z_top_C z_top_C z_top_C z_top_C], ...
          [1 0.4 0.4], 'FaceAlpha', 0.18, 'EdgeColor', 'none');
    patch([-2*R_C 2*R_C 2*R_C -2*R_C], ...
          [-2*R_C -2*R_C 2*R_C 2*R_C], ...
          [z_bottom_C z_bottom_C z_bottom_C z_bottom_C], ...
          [1 0.4 0.4], 'FaceAlpha', 0.18, 'EdgeColor', 'none');

    drawTube(z_rings_C, R_C, I_C(:,kk), I_max_C);
    drawMagnet(z_C(kk), 0.015, 0.030);

    %  Vector velocidad (azul)
    v_len = v_C(kk) * v_scale;
    quiver3(-0.025, 0, z_C(kk), 0, 0, v_len, 0, ...
            'Color', [0.10 0.45 0.95], 'LineWidth', 2.8, 'MaxHeadSize', 0.6);
    text(-0.045, 0, z_C(kk) + v_len/2, 'v', ...
         'Color', [0.10 0.45 0.95], 'FontWeight','bold', 'FontSize', 13);

    %  Vector fuerza magnetica (naranja)
    F_len = F_mag_hist(kk) * F_scale;
    quiver3(0.025, 0, z_C(kk), 0, 0, F_len, 0, ...
            'Color', [0.95 0.55 0.05], 'LineWidth', 2.8, 'MaxHeadSize', 0.6);
    text(0.045, 0, z_C(kk) + F_len/2, 'F', ...
         'Color', [0.95 0.55 0.05], 'FontWeight','bold', 'FontSize', 13);

    %  Vector campo inducido B_ind en la espira de mayor |I| (verde)
    [I_peak, idx_peak] = max(abs(I_C(:,kk)));
    if I_peak > 0.001 * I_max_C
        sgn_B = sign(I_C(idx_peak, kk));
        quiver3(0, 0, z_rings_C(idx_peak), 0, 0, sgn_B*B_arrow_L, 0, ...
                'Color', [0.05 0.65 0.20], 'LineWidth', 2.5, 'MaxHeadSize', 0.7);
        text(0.025, 0, z_rings_C(idx_peak) + sgn_B*B_arrow_L/2, ...
             'B_{ind}', 'Color', [0.05 0.65 0.20], ...
             'FontWeight','bold', 'FontSize', 11);
    end

    %  Momento dipolar m del iman (magenta)
    quiver3(0, 0, z_C(kk), 0, 0, -0.025, 0, ...
            'Color', 'm', 'LineWidth', 1.8, 'MaxHeadSize', 0.5);

    camlight(ax3d_C, 'headlight');

    if z_C(kk) > z_top_C
        fase = 'CAIDA LIBRE';
    elseif z_C(kk) > z_bottom_C
        fase = 'EN EL TUBO (Lenz frena)';
    else
        fase = 'SALIO DEL TUBO';
    end
    title(ax3d_C, sprintf( ...
        '[%s] t=%.2fs z=%.3fm v=%.2fm/s F=%.2fN', ...
        fase, t_C(kk), z_C(kk), v_C(kk), F_mag_hist(kk)));

    set(v_mark_C, 'XData', t_C(kk), 'YData', v_C(kk));

    drawnow;
    pause(0.03);
end

fprintf('\n=== TODAS LAS SIMULACIONES COMPLETADAS ===\n');


%% FUNCIONES LOCALES

function dy = derivs_tubo(y, z_rings, R, R_e, L, mu0, m_z, m_im, g)
%DERIVS_TUBO  Derivadas del sistema acoplado tubo + iman (Caso C).
%   y = [ z ; v ; I_1 ; ... ; I_N ]  (columna N+2)
    z = y(1);
    v = y(2);
    I = y(3:end);
    z_rings = z_rings(:);
    d_k = z - z_rings;
    den52 = (R^2 + d_k.^2).^(5/2);
    eps_k = -3*mu0*m_z*R^2 .* d_k .* v ./ (2*den52);
    F_k   =  3*mu0*m_z*R^2 .* d_k .* I ./ (2*den52);
    dy        = zeros(size(y));
    dy(1)     = v;
    dy(2)     = -g + sum(F_k)/m_im;
    dy(3:end) = (eps_k - R_e*I) / L;
end


function drawTube(z_rings, R, I_now, I_max)
%DRAWTUBE  Dibuja las espiras del tubo coloreadas por |I_k| instantanea.
%   Version vectorizada: agrupa las espiras en tres bandas de intensidad
%   y las dibuja con UNA sola llamada a plot3 por banda.
    theta = linspace(0, 2*pi, 30);
    n_th  = length(theta);
    n_r   = length(z_rings);

    cx = R*cos(theta);
    cy = R*sin(theta);
    Xm = repmat(cx(:), 1, n_r);
    Ym = repmat(cy(:), 1, n_r);
    Zm = repmat(z_rings(:)', n_th, 1);

    if I_max <= 0, I_max = 1; end
    amp = min(abs(I_now(:))/I_max, 1);

    bin_low = amp < 0.20;
    bin_mid = amp >= 0.20 & amp < 0.60;
    bin_hi  = amp >= 0.60;

    if any(bin_low)
        plot3(Xm(:,bin_low), Ym(:,bin_low), Zm(:,bin_low), ...
              'Color', [0.65 0.55 0.40], 'LineWidth', 1.5);
    end
    if any(bin_mid)
        plot3(Xm(:,bin_mid), Ym(:,bin_mid), Zm(:,bin_mid), ...
              'Color', [0.95 0.55 0.25], 'LineWidth', 2.6);
    end
    if any(bin_hi)
        plot3(Xm(:,bin_hi), Ym(:,bin_hi), Zm(:,bin_hi), ...
              'Color', [0.90 0.15 0.15], 'LineWidth', 3.6);
    end
end


function drawMagnet(zc, r, h)
%DRAWMAGNET  Dibuja un iman cilindrico solido centrado en (0,0,zc).
%   Polo SUR arriba (azul), polo NORTE abajo (rojo). El momento dipolar
%   m apunta de S hacia N, es decir hacia -z (hacia abajo).
    theta   = linspace(0, 2*pi, 30);
    z_top   = zc + h/2;
    z_eq_hi = zc + h/6;
    z_eq_lo = zc - h/6;
    z_bot   = zc - h/2;

    Zs = repmat([z_top; z_eq_hi], 1, length(theta));
    Xs = [r*cos(theta); r*cos(theta)];
    Ys = [r*sin(theta); r*sin(theta)];
    surf(Xs, Ys, Zs, 'FaceColor', [0.15 0.30 0.85], ...
         'EdgeColor', 'none', 'FaceLighting', 'gouraud');

    Zb = repmat([z_eq_hi; z_eq_lo], 1, length(theta));
    Xb = [r*cos(theta); r*cos(theta)];
    Yb = [r*sin(theta); r*sin(theta)];
    surf(Xb, Yb, Zb, 'FaceColor', [0.55 0.55 0.55], ...
         'EdgeColor', 'none', 'FaceLighting', 'gouraud');

    Zn = repmat([z_eq_lo; z_bot], 1, length(theta));
    Xn = [r*cos(theta); r*cos(theta)];
    Yn = [r*sin(theta); r*sin(theta)];
    surf(Xn, Yn, Zn, 'FaceColor', [0.85 0.15 0.15], ...
         'EdgeColor', 'none', 'FaceLighting', 'gouraud');

    fill3(r*cos(theta), r*sin(theta), z_top*ones(size(theta)), ...
          [0.15 0.30 0.85], 'EdgeColor', 'none');
    fill3(r*cos(theta), r*sin(theta), z_bot*ones(size(theta)), ...
          [0.85 0.15 0.15], 'EdgeColor', 'none');

    text(0, 0, z_top + 0.03, 'S', 'Color', 'w', ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
    text(0, 0, z_bot - 0.03, 'N', 'Color', 'w', ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
end
