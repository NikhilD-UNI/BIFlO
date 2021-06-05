% code to test the VC Model with ground effect
% 15/02/2021
% methodology from E.Branlard and Meyer Forsting 


clc
clear
%close all

%% define some key parameters
load('Test_objects.mat');
environment.freestream_velocity = 7.5;
Uo_ref = environment.freestream_velocity;
environment.Wind_direction = 0;
ModelSetup = ModelSetup;
ModelSetup.Environment = environment;
ModelSetup.Turbine     = LW;
ModelSetup.Grid_Method.Method = 'polar';

% load('WMR_DATA.mat')
% ModelSetup = ModelSetup;
% ModelSetup.Environment = environment;
% ModelSetup.Environment.Wind_direction = -31.4;
% ModelSetup.Environment.freestream_velocity = 8;
% %ModelSetup.Environment.TI_a = 0.059 ;
% ModelSetup.Turbine = SWT_6_154;
% ModelSetup.Wakemodel = 'Bastankah_TI';
% Uo_ref = ModelSetup.Environment.freestream_velocity;

D = ModelSetup.Turbine.Diameter;
zh= ModelSetup.Turbine.Hubheight;         %hub height of turbine
zo= environment.surface_roughness; 
xh = 0%[0,0,0,0,0,0,0,0,0,0,0,0,0,1640,1640,1640,1640,1640,1640,1640,1640,1640,1640,1640,1640] ;%y coordinate of turbine
yh = 0%[0,820,1640,2460,3280,4100,4920,5740,6560,7380,8200,9020,9840,410,1230,2050,2870,3690,4510,5330,6150,6970,7790,8610,9430];
R = D/2;                  %radius [m]
x =[min(xh)-4*D:10:1*D+max(xh)];%[-10*D:D/20:15*D] ; %[0:10:10000]    %x-coordinates in grid
y = [min(yh)-1*D:1:max(yh)+1*D]   ;%[-1000:10:1500];      %y-coordinates in grid
z = zh;%[0:zh/10:3*zh];   %z-coordinates in grid
environment.TI_a = 0.03;
environment.surface_roughness = 0.08;

p = population_sort([xh',yh'],ModelSetup);
xh = p(:,1)';
yh = p(:,2)';


%[x_grid,y_grid,z_grid] = meshgrid(x_local,y_local,z_local); % create mesh
[x_grid,y_grid,z_grid] = meshgrid(x,y,z);

%r_grid = sqrt(y_grid.^2 + z_grid.^2); %radial coordinates
ux1 = zeros([size(x_grid)]);      %initialises flow field
ux = zeros([size(x_grid)]);
Uw = zeros([size(x_grid)]);
TI_plus = zeros(size(xh));

% Uo = zeros([size(x_grid)]);
% for i = 1:numel(z)
%     Uo(:,:,i) = Uo_ref * (z(i)/zh)^0.143 * ones(numel(y),numel(x));
% end
%  Uo =  Uo*cosd(environment.Wind_direction);
 
% initialise flow container
u = Uo_ref * ones([size(x_grid)]); % Uo
%u = Uo .* ones([size(x_grid)]);

%% VC Elementary model test - here the flow is alligned an axisymmetric
for j = 1:4
    for i = 1: length(xh)
        
        % localise coordinate system
        x_local = x-xh(i);
        y_local = y-yh(i);
        z_local = z-zh;
        
        % locate poaition where we want to take our ct value from
        idz = max(find(z_local<=0));
        idy = max(find(y_local<=0));
        idx = max(find(x_local<=-D));
        
        ct = CT_value(ModelSetup.Turbine,u(idy,idx,idz));             % thrust coefficient
        gamma_t(i,j) = Tang_vorticity_strength(u(idy,idx,idz),ct,ModelSetup);   % tangential vortex [m/s]
        fprintf('Turbine %d gamma_t %.5f \n',i,gamma_t(i,j));
        
        %% test bed for the elementary vortex cylindrer programme
        %ux = elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t(i,j),LW,environment,xh(i),yh(i),1);
        ux = skewed_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t(i,j),ct,ModelSetup.Turbine,ModelSetup.Environment,xh(i),yh(i),1);
        %[Uw] = Jensen_Wake_model_VC(x_grid,y_grid,z_grid,u(idy,idx,idz),LW,environment,xh,yh,i);
        [Uw] = Bastankah_original_wake(x_grid,y_grid,z_grid,u(idy,idx,idz),ModelSetup.Turbine,ModelSetup.Environment,xh,yh,i);
        %[Uw,~,T]=Bastankah_TI_wake(x_grid,y_grid,z_grid,u(idy,idx,idz),max(TI_plus(:,i)),ModelSetup.Turbine,ModelSetup.Environment,xh,yh,i);
        %TI_plus(i,:) = T';
        
        ux1 = ux1 + ux + real(Uw); %*cosd(environment.Wind_direction);
        u = u + real(Uw); %*cosd(environment.Wind_direction);
        %contour((x_grid(:,:,idz))/R,(y_grid(:,:,idz))/R,u(:,:,idz)/Uo,40,'Fill','on')
    end
u = Uo_ref + ux1;
ux1 = zeros([size(x_grid)]);
%TI = zeros(size(xh));
fprintf('\n')
end
figure
contour((x_grid(:,:,idz))/D,(y_grid(:,:,idz))/D,u(:,:,idz)/Uo_ref,400,'Fill','on')
hold on
plot(xh/D,yh/D,'kx');
xlabel('x/D [-]')
ylabel('y/D [-]')
title('Contour Plot of Vortex Cylinder Model - U_{0} = 16 m/s')
colormap(turbo)

% figure
% for i = 1: length(z)
% x2(i,:) = x_grid(:,:,i);
% z2(i,:) = z_grid(:,:,i);
% u2(i,:) = u(:,:,i);
% end
% contour(x2/D,z2/D,u2/Uo_ref,80,'Fill','on')
% colormap(turbo)
% xlabel('x/D [-]')
% ylabel('Z/D [-]')