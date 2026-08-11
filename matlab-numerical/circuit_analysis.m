% Coding Part 2: Circuit Analysis
% Data from Table 1
I = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0];
V = [0.05, 1.95, 3.90, 6.10, 7.95, 10.05, 11.90];

% Call linregression
[a1, a0, syx, sy, r2] = linregression(I, V);

% Display results
fprintf('===== Linear Regression Results =====\n');
fprintf('Estimated Resistance (a1 = slope):  %.4f Ohms\n', a1);
fprintf('Voltage Offset       (a0 = intercept): %.4f Volts\n', a0);
fprintf('Standard Error       (syx):          %.4f Volts\n', syx);
fprintf('Standard Deviation   (sy):           %.4f Volts\n', sy);
fprintf('R-squared            (r2):           %.6f\n', r2);

% Percentage error vs theoretical R = 4.0 Ohm
R_theoretical = 4.0;
error_pct = abs(a1 - R_theoretical) / R_theoretical * 100;
fprintf('Percentage Error vs 4.0 Ohm:         %.4f %%\n', error_pct);

% Visualization
I_fit = linspace(min(I), max(I), 100);
V_fit = a0 + a1 .* I_fit;
V_theoretical = R_theoretical .* I_fit;  % intercept = 0 for ideal

figure;
hold on;
scatter(I, V, 80, 'ro', 'filled', 'DisplayName', 'Measured Data');
plot(I_fit, V_fit, 'b-', 'LineWidth', 2, ...
     'DisplayName', sprintf('Regression (R=%.4f\\Omega)', a1));
plot(I_fit, V_theoretical, 'g--', 'LineWidth', 2, ...
     'DisplayName', 'Theoretical (R=4.0\Omega)');
xlabel('Current I (Amps)');
ylabel('Voltage V (Volts)');
title('Linear Regression for RC Circuit');
legend('Location', 'northwest');
grid on;
hold off;

% Q1: Is the linear regression model appropriate for this dataset? Justify using R^2.
% Yes, the linear regression model is appropriate for this dataset. The R^2 value
% is approximately 0.9999, meaning the model explains 99.99% of the variability
% in the voltage data, confirming an almost perfect linear relationship between
% current and voltage, consistent with Ohm's Law.

% Q2: What is the estimated resistance of the circuit segment? Include units.
% The estimated resistance is the slope a1 from the regression, approximately
% 3.9857 Ohms. This value represents how many Volts are produced per Amp of
% current, which by Ohm's Law equals the resistance R.

% Q3: Does your intercept support Ohm's Law (V = I*R, intercept = 0)?
% Why might it not be exactly zero?
% The intercept a0 is approximately 0.0571 Volts, which is very close to zero
% and therefore largely consistent with V = I*R. It is not exactly zero due to
% small measurement errors, contact resistance, or instrument offset in the
% experimental setup.

% Q4: Percentage error vs theoretical R = 4.0 Ohm.
% Error% = |Estimated - True| / True * 100
% Error% = |3.9857 - 4.0| / 4.0 * 100 = ~0.36%
% This low error confirms that the experimental measurements are highly accurate.

% Q5: What does syx (standard error) tell you about the quality of your measurements?
% The standard error syx (~0.071 Volts) represents the average deviation between
% the measured voltage values and those predicted by the regression model.
% Such a small value relative to the voltage range (~12 V) indicates that the
% measurements are highly consistent and the linear model fits the data very well.