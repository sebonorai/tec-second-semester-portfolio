function [i_val,t_val] = cRunKut(f_i,t_val,i_val,n,h)
for i = 1:n
    k1 = f_i(t_val(i), i_val(i));
    k2 = f_i(t_val(i) + 0.5*h, i_val(i) + 0.5*k1*h);
    k3 = f_i(t_val(i) + 0.5*h, i_val(i) + 0.5*k2*h);      
    k4 = f_i(t_val(i)+h, i_val(i)+k3*h);

    i_val(i+1) = i_val(i)+(h/6)*(k1+2*k2+2*k3+k4);
    t_val(i+1) = t_val(i)+h;
end
end

f_i = @(t,i) (10*2*pi*cos(2*pi*t))/1000 - i/(1000*0.001);
f_vc = @(t,vc) (10*sin(2*pi*t)-vc)/(1000*0.001); 
t_in = 0;
i_in = 0;
vc_in = 0;
t_final = 20;
for h = 0.01
    n = (t_final - t_in) / h;

    t_val = zeros(1,n+1);
    i_val = zeros(1,n+1);
    vc_val = zeros(1,n+1);
    t_val(1) = t_in;
    i_val(1) = i_in;
    vc_val(1) = vc_in;

    [i_val,t_val] = cRunKut(f_i,t_val,i_val,n,h);
    [vc_val,t_val] = cRunKut(f_vc,t_val,vc_val,n,h);

end

figure(1)
plot(t_val,i_val)
figure(2)
plot(t_val,vc_val)