f = @(x) x.^3 - 13*x - 12;


x0 = 4.5;
x1 = 5.5;
x2 = 5;

n = 50;
for i = 1:n

h0 = x1-x0;
h1 = x2-x1;

d0 = (f(x1) - f(x0))/h0;
d1 = (f(x2) - f(x1))/h1;

a = (d1-d0)/(h1+h0);
b = a*h1+d1;
c = f(x2);

x3n = x2 - (2*c/(b - sqrt(b.^2 - 4*a*c)));

x3p = x2 - (2*c/(b + sqrt(b.^2 - 4*a*c)));

fprintf('Raiz positiva: %f, evaluacion; %f \n' , x3p, f(x3p))
fprintf('Raiz Negativa: %f,  evaluacion; %f \n' , x3n, f(x3n))

if abs(f(x3p)) < abs(f(x3n))
    x3 = x3p;
else
    x3 = x3n;
end

x0 = x1;
x1 = x2;
x2 = x3;

if abs(x3 - x2) < 1e-6
    fprintf('Raiz Final: %f \n' , x3)
    break
end

fprintf('Raiz Actualizada: %f \n' , x3)

end