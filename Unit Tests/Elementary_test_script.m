% code to test the VC Model
%10/02/2021

clear
clc
close all

%% define some key parameters
load('Test_objects.mat');
environment.freestream_velocity = 13;
Uo = environment.freestream_velocity;
D = LW.Diameter;
R = D/2;                  %radius [m]
x = [-2.5*D:D/40:3*D] ;   %x-coordinates
r = 0:D/40:1*D ;          %radial coordinates
n_r = length(r);          %number of radial points
n_x = length(x);          %number of x points
ux = zeros(n_r,n_x);      %initialises flow field
[x_grid,r_grid] = meshgrid(x,r); % create mesh


%% VC Elementary model test - here the flow is alligned an axisymmetric
for j = 1:4

u = Uo + ux;                           % initial velocity 
ct = CT_value(LW,u(1,1));             % thrust coefficient
gamma_t = -u(1,1)*(1 - sqrt(1-ct));   % tangential vortex [m/s]

%alligned flow - x velocity
k_2 = (4*r_grid*R)./((R+r_grid).^2 + x_grid.^2);  %eliptical parameter
k0_2 = (4*r_grid*R)./((R+r_grid).^2);

term_1 = (R - r_grid + abs(R-r_grid))./(2*abs(R-r_grid)) ;
term_1(r_grid == R) = 1/2;           %accounts for singularity at sheet

term_2 = (x_grid.*sqrt(k_2))./(2*pi*sqrt(r_grid*R)) ;
[K,~] = ellipke(k_2);                %complete eliptical integral of the second kind

%     for i = 1:n_r
%         PI(i,1:n_x) = ellipticPi(k_2(i,61),k_2(i,:));
%     end

 PI = ellipticPi(k0_2,k_2);
    
PI(r_grid==R) = 0;                    
ux = gamma_t/2 * (term_1 + term_2.*(K + ((R-r_grid)./(R+r_grid)).*PI));
ux(1,:) = gamma_t/2 * (1+x_grid(1,:)./sqrt(R^2 + x_grid(1,:).^2));

end


contour(x_grid/R,r_grid/R,u/Uo,30,'Fill','on')
hold on
contour(x_grid/R,-r_grid/R,u/Uo,30,'Fill','on')
xlabel('x/R [-]')
ylabel('r/R [-]')
title('Contour Plot of Vortex Cylinder Model - U_{0} = 14 m/s')
%note you need to finish off the itteration and convergence step inorder to
%make sure the ct is now consistent