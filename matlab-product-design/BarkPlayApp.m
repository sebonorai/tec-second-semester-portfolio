function BarkPlayApp
% Bark & Play App
% Sebastian Noriega - Equipo 3
% App hecha en MATLAB con:
% - Sólido de revolución
% - Silueta 2D
% - Tabla editable de costos
% - Profit dinámico según demanda
% - Charts
% - Logo / nombre del equipo

%% =========================
% 1) DATOS BASE DEL STEP 4
% =========================
% Si quieres, aquí puedes pegar tus puntos EXACTOS del Step 4.
% Por mientras dejo una silueta funcional tipo juguete/bola.

x = [-2.66,-2.29,-1.62,-0.39,1.11,1.66,2,2.07,-0.39,-0.81,-0.76,-0.45,-0.1,-0.11]; 
y = [0.19,1.41,2.15,2.55,2.15,1.48,1,0.14,0.8,0.62,0.28,0.08,0.29,0.62];

% Asegurar vector fila
x = x(:)';
y = y(:)';

% Interpolación suave para la silueta
xFine = linspace(min(x), max(x), 220);
yFine = interp1(x, y, xFine, 'pchip');

% Parámetros iniciales
defaultDemand = 500;
defaultPrice  = 240;   % del reporte aprox.
defaultWaste  = 5;     % % merma
defaultHoleR  = 0.75;  % radio visual de cavidad

%% =========================
% 2) UI FIGURE
% =========================
fig = uifigure('Name','Bark & Play - Solid of Revolution App',...
    'Position',[50 50 1450 820],...
    'Color',[0.96 0.97 0.99]);

gl = uigridlayout(fig,[12 12]);
gl.RowHeight = {42,42,42,42,42,42,'1x','1x','1x','1x','1x',36};
gl.ColumnWidth = {170,140,140,140,140,140,'1x','1x','1x','1x','1x','1x'};

%% =========================
% 3) ENCABEZADO
% =========================
titleLbl = uilabel(gl,...
    'Text','Bark & Play | Interactive Cost + Demand App',...
    'FontSize',20,...
    'FontWeight','bold');
titleLbl.Layout.Row = 1;
titleLbl.Layout.Column = [1 7];

subLbl = uilabel(gl,...
    'Text','Equipo 3 · Solid of Revolution · Cost Analysis · Profit Simulation');
subLbl.Layout.Row = 2;
subLbl.Layout.Column = [1 6];

logoPanel = uipanel(gl,'Title','Team Logo');
logoPanel.Layout.Row = [1 3];
logoPanel.Layout.Column = [9 12];

logoGrid = uigridlayout(logoPanel,[2 1]);
logoGrid.RowHeight = {'1x',30};

% Si tienes una imagen del logo, guárdala como BarkPlayLogo.png
% en la misma carpeta del script.
if isfile('BarkPlayLogo.png')
    uiimage(logoGrid,'ImageSource','BarkPlayLogo.png');
else
    txt = uitextarea(logoGrid,...
        'Value',{'BARK & PLAY','Play Smart. Bark Happy.'},...
        'Editable','off',...
        'FontSize',18,...
        'FontWeight','bold');
    txt.Layout.Row = 1;
end

%% =========================
% 4) CONTROLES
% =========================
ctrlPanel = uipanel(gl,'Title','Controls');
ctrlPanel.Layout.Row = [3 6];
ctrlPanel.Layout.Column = [1 6];

cgl = uigridlayout(ctrlPanel,[5 4]);
cgl.RowHeight = {30,30,30,30,30};
cgl.ColumnWidth = {150,120,150,'1x'};

uilabel(cgl,'Text','Demand (units):');
demandField = uieditfield(cgl,'numeric','Value',defaultDemand,'Limits',[1 Inf]);

uilabel(cgl,'Text','Sale Price / unit (MXN):');
priceField = uieditfield(cgl,'numeric','Value',defaultPrice,'Limits',[1 Inf]);

uilabel(cgl,'Text','Waste (%):');
wasteField = uieditfield(cgl,'numeric','Value',defaultWaste,'Limits',[0 100]);

uilabel(cgl,'Text','Hole Radius (visual):');
holeField = uieditfield(cgl,'numeric','Value',defaultHoleR,'Limits',[0 2]);

uilabel(cgl,'Text','Demand Slider:');
demandSlider = uislider(cgl,'Limits',[50 5000],'Value',defaultDemand);
demandSlider.Layout.Column = [2 4];

updateBtn = uibutton(cgl,'push','Text','Update App','ButtonPushedFcn',@(~,~)updateAll());
updateBtn.Layout.Row = 5;
updateBtn.Layout.Column = [1 2];

resetBtn = uibutton(cgl,'push','Text','Reset','ButtonPushedFcn',@(~,~)resetApp());
resetBtn.Layout.Row = 5;
resetBtn.Layout.Column = [3 4];

%% =========================
% 5) KPIs
% =========================
kpiPanel = uipanel(gl,'Title','KPIs');
kpiPanel.Layout.Row = [1 2];
kpiPanel.Layout.Column = [7 8];

kgl = uigridlayout(kpiPanel,[4 2]);
kgl.RowHeight = {30,30,30,30};
kgl.ColumnWidth = {140,'1x'};

uilabel(kgl,'Text','Volume (cm^3):','FontWeight','bold');
volLbl = uilabel(kgl,'Text','-');

uilabel(kgl,'Text','Unit Cost (MXN):','FontWeight','bold');
unitCostLbl = uilabel(kgl,'Text','-');

uilabel(kgl,'Text','Revenue (MXN):','FontWeight','bold');
revLbl = uilabel(kgl,'Text','-');

uilabel(kgl,'Text','Profit (MXN):','FontWeight','bold');
profitLbl = uilabel(kgl,'Text','-','FontWeight','bold');

%% =========================
% 6) TABLA DE COSTOS EDITABLE
% =========================
costPanel = uipanel(gl,'Title','Editable Cost Table');
costPanel.Layout.Row = [3 6];
costPanel.Layout.Column = [7 8];

baseCostData = {
    'Material',    18;
    'Labor',       20;
    'Energy',       8;
    'Finishing',   10;
    'Packaging',   12;
    'Transport',    6;
};

costTable = uitable(costPanel,...
    'Data',baseCostData,...
    'ColumnName',{'Concept','Cost MXN / unit'},...
    'ColumnEditable',[false true],...
    'Position',[10 10 250 220]);

%% =========================
% 7) AXES
% =========================
ax2D = uiaxes(gl);
ax2D.Layout.Row = [7 9];
ax2D.Layout.Column = [1 4];
title(ax2D,'2D Silhouette');
xlabel(ax2D,'x');
ylabel(ax2D,'radius y');
grid(ax2D,'on');

ax3D = uiaxes(gl);
ax3D.Layout.Row = [7 10];
ax3D.Layout.Column = [5 8];
title(ax3D,'Solid of Revolution');
xlabel(ax3D,'X');
ylabel(ax3D,'Y');
zlabel(ax3D,'Z');
grid(ax3D,'on');
view(ax3D,3);

axBar = uiaxes(gl);
axBar.Layout.Row = [7 9];
axBar.Layout.Column = [9 12];
title(axBar,'Cost Breakdown');
ylabel(axBar,'MXN');
grid(axBar,'on');

axProfit = uiaxes(gl);
axProfit.Layout.Row = [10 11];
axProfit.Layout.Column = [1 6];
title(axProfit,'Profit vs Demand');
xlabel(axProfit,'Demand');
ylabel(axProfit,'Profit (MXN)');
grid(axProfit,'on');

axUnits = uiaxes(gl);
axUnits.Layout.Row = [10 11];
axUnits.Layout.Column = [7 12];
title(axUnits,'Revenue vs Cost');
ylabel(axUnits,'MXN');
grid(axUnits,'on');

footer = uilabel(gl,...
    'Text','Tip: si quieres usar tu Step 4 exacto, solo reemplaza los vectores x y y al inicio del archivo.',...
    'HorizontalAlignment','center');
footer.Layout.Row = 12;
footer.Layout.Column = [1 12];

%% =========================
% 8) CALLBACKS
% =========================
demandSlider.ValueChangedFcn = @(src,evt) syncDemand();
demandField.ValueChangedFcn  = @(src,evt) syncSlider();

updateAll();

    function syncDemand()
        demandField.Value = round(demandSlider.Value);
        updateAll();
    end

    function syncSlider()
        demandSlider.Value = demandField.Value;
        updateAll();
    end

    function resetApp()
        demandField.Value = defaultDemand;
        demandSlider.Value = defaultDemand;
        priceField.Value = defaultPrice;
        wasteField.Value = defaultWaste;
        holeField.Value = defaultHoleR;
        costTable.Data = baseCostData;
        updateAll();
    end

    function updateAll()
        % Leer inputs
        demand = demandField.Value;
        salePrice = priceField.Value;
        wastePct = wasteField.Value / 100;
        holeR = holeField.Value;

        % Leer tabla
        tdata = costTable.Data;
        costValues = cell2mat(tdata(:,2));
        baseUnitCost = sum(costValues);

        % =========================
        % A) VOLUMEN POR SOLIDO DE REVOLUCION
        % =========================
        % V = pi * integral( y^2 dx )
        volume_cm3 = pi * trapz(xFine, yFine.^2);

        % costo ajustado por volumen (factor visual/escalado)
        % Esto hace que el costo de material reaccione a la geometría.
        materialBase = costValues(1);
        materialAdjusted = materialBase * (volume_cm3 / 120);

        otherCosts = sum(costValues(2:end));
        unitCost = materialAdjusted + otherCosts;
        unitCost = unitCost * (1 + wastePct);

        % =========================
        % B) REVENUE / COST / PROFIT
        % =========================
        totalRevenue = salePrice * demand;
        totalCost = unitCost * demand;
        totalProfit = totalRevenue - totalCost;

        % =========================
        % C) SILUETA 2D
        % =========================
        cla(ax2D);
        plot(ax2D, xFine, yFine, 'LineWidth', 2);
        hold(ax2D,'on');
        plot(ax2D, xFine, -yFine, 'LineWidth', 2);
        xline(ax2D,0,'--');
        title(ax2D,'2D Silhouette of Dog Toy');
        axis(ax2D,'equal');
        hold(ax2D,'off');

        % =========================
        % D) SOLIDO DE REVOLUCION 3D
        % =========================
        theta = linspace(0,2*pi,80);
        [X,TH] = meshgrid(xFine,theta);
        R = repmat(yFine,length(theta),1);
        Y = R .* cos(TH);
        Z = R .* sin(TH);

        cla(ax3D);
        surf(ax3D, X, Y, Z, ...
            'EdgeColor','none', ...
            'FaceAlpha',0.9);
        hold(ax3D,'on');

        % cavidad visual
        [xs,ys,zs] = sphere(40);
        surf(ax3D, ...
            -0.2 + holeR*xs, ...
             0.0 + holeR*ys, ...
             0.0 + holeR*zs, ...
            'EdgeColor','none', ...
            'FaceAlpha',0.55);

        title(ax3D,'Solid of Revolution + Treat Cavity');
        axis(ax3D,'equal');
        camlight(ax3D,'headlight');
        lighting(ax3D,'gouraud');
        hold(ax3D,'off');

        % =========================
        % E) COST BREAKDOWN CHART
        % =========================
        cla(axBar);
        costNames = string(tdata(:,1));
        bar(axBar, categorical(costNames), [materialAdjusted; costValues(2:end)]);
        title(axBar,'Editable Cost Breakdown');
        ylabel(axBar,'MXN / unit');

        % =========================
        % F) PROFIT VS DEMAND
        % =========================
        demVec = 50:50:5000;
        profitVec = (salePrice - unitCost) .* demVec;

        cla(axProfit);
        plot(axProfit, demVec, profitVec, 'LineWidth', 2);
        hold(axProfit,'on');
        scatter(axProfit, demand, totalProfit, 70, 'filled');
        title(axProfit,'Profit vs Demand');
        xlabel(axProfit,'Demand (units)');
        ylabel(axProfit,'Profit (MXN)');
        hold(axProfit,'off');

        % =========================
        % G) REVENUE VS COST
        % =========================
        cla(axUnits);
        bar(axUnits, categorical({'Revenue','Total Cost','Profit'}), ...
            [totalRevenue totalCost totalProfit]);
        title(axUnits,'Financial Summary');

        % =========================
        % H) KPIs
        % =========================
        volLbl.Text = sprintf('%.2f', volume_cm3);
        unitCostLbl.Text = sprintf('$%.2f', unitCost);
        revLbl.Text = sprintf('$%.2f', totalRevenue);
        profitLbl.Text = sprintf('$%.2f', totalProfit);

        % color profit
        if totalProfit >= 0
            profitLbl.FontColor = [0 0.5 0];
        else
            profitLbl.FontColor = [0.8 0 0];
        end
    end
end
