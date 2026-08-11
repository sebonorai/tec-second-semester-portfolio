function [a1, a0, syx, sy, r2] = linregression(x, y)
    n = length(x);
    
    sum_x  = sum(x);
    sum_y  = sum(y);
    sum_xy = sum(x .* y);
    sum_x2 = sum(x .^ 2);
    
    % Slope (β1) - Eq. 3
    a1 = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x^2);
    
    % Intercept (β0) - Eq. 4
    x_bar = sum_x / n;
    y_bar = sum_y / n;
    a0 = y_bar - a1 * x_bar;
    
    % Predicted values
    y_hat = a0 + a1 .* x;
    
    % R-squared - Eq. 5
    SS_res = sum((y - y_hat).^2);
    SS_tot = sum((y - y_bar).^2);
    r2 = 1 - SS_res / SS_tot;
    
    % Standard error of estimate - Eq. 6
    syx = sqrt(SS_res / (n - 2));
    
    % Standard deviation of y - Eq. 7
    sy = sqrt(SS_tot / (n - 1));
end