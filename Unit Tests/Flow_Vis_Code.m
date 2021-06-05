% code to test the VC Model with ground effect
% 15/02/2021
% methodology from E.Branlard and Meyer Forsting 


clc
clear
%close all

%% define some key parameters
load('Test_objects.mat');
LW.Cp_calibration_distance = 0;
environment.freestream_velocity = 15;
Uo_ref = environment.freestream_velocity;
environment.Wind_direction = 0;
ModelSetup = ModelSetup;
ModelSetup.Environment = environment;
ModelSetup.Turbine     = LW;
ModelSetup.Grid_Method.Method = 'polar';
ModelSetup.Wakemodel = 'Bastankah_TI';
ModelSetup.Blockage = 0;
Wake_Summation_Model = ModelSetup.WakeSummation;


D = ModelSetup.Turbine.Diameter;
zh= ModelSetup.Turbine.Hubheight;         %hub height of turbine
zo= environment.surface_roughness; 
xh = [0 0 0 5*D 5*D 5*D 10*D 10*D 10*D];
yh = [-5*D 0 5*D -5*D 0 5*D -5*D 0 5*D];
R = D/2;                  %radius [m]
x =[-2000:20:5000];%[-10*D:D/20:15*D] ; %[0:10:10000]    %x-coordinates in grid
y = [-2000:12:2000]   ;%[-1000:10:1500];      %y-coordinates in grid
z = zh; %[0:zh/10:3*zh];   %z-coordinates in grid
environment.TI_a = 0.1;
ModelSetup.Environment = environment;
environment.surface_roughness = 0.08;

p = population_sort([xh',yh'],ModelSetup);
xh = p(:,1)';
yh = p(:,2)';


%[x_grid,y_grid,z_grid] = meshgrid(x_local,y_local,z_local); % create mesh
[x_grid,y_grid,z_grid] = meshgrid(x,y,z);
[x_grid2,y_grid2,z_grid2,weights] = grid_gen(p,ModelSetup);

%r_grid = sqrt(y_grid.^2 + z_grid.^2); %radial coordinates
ux1 = zeros([size(x_grid)]);      %initialises flow field
ux = zeros([size(x_grid)]);
Uw = zeros([size(x_grid)]);
TI_plus = zeros(size(xh));
Vw = zeros(numel(xh),numel(xh));
Vw(1,1) = Uo_ref;
ux_2= zeros([size(x_grid2)]);
%Uo = zeros([size(x_grid)]);
% 
% for i = 1:numel(z)
%     Uo(:,:,i) = Uo_ref * (z(i)/zh)^0.143 * ones(numel(y),numel(x));
% end
% Uo =  Uo*cosd(environment.Wind_direction);
% initialise flow container
u = Uo_ref * ones([size(x_grid)]); % Uo
% u1 = Uo * ones([size(x_grid)]);

%% VC Elementary model test - here the flow is alligned an axisymmetric

for j = 1:3
    for i = 1: length(xh)
        
        % localise coordinate system
        x_local = x-xh(i);
        y_local = y-yh(i);
        z_local = z-zh;
        
        % locate poaition where we want to take our ct value from
        idz = max(find(z_local<=0));
        idy = max(find(y_local<=0));
        idx = max(find(x_local<=0));
        
        if i ~= 1
            Vw(i,i) = WakeSummation_Selection(Vw,[],i,Vw(1,1),Wake_Summation_Model);
        end
        
        ct = CT_value(ModelSetup.Turbine,Vw(i,i));             % thrust coefficient
        gamma_t(i,j) = Tang_vorticity_strength(Vw(i,i),ct,ModelSetup);   % tangential vortex [m/s]
        fprintf('Turbine %d gamma_t %.5f \n',i,gamma_t(i,j));
        
        %% test bed for the elementary vortex cylindrer programme
        % ux = elementary_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t(i,j),LW,environment,xh(i),yh(i));
         ux = skewed_vortex_cylinder(x_grid,y_grid,z_grid,gamma_t(i,j),ct,ModelSetup.Turbine,ModelSetup.Environment,xh(i),yh(i),1);
         ux2 = skewed_vortex_cylinder(x_grid2,y_grid2,z_grid2,gamma_t(i,j),ct,ModelSetup.Turbine,ModelSetup.Environment,xh(i),yh(i),1);
         %[Uw] = Jensen_Wake_model_VC(x_grid,y_grid,z_grid,u(idy,idx,idz),LW,environment,xh,yh,i);
        %[Uw] = Bastankah_original_wake(x_grid,y_grid,z_grid,u(idy,idx,idz),ModelSetup.Turbine,ModelSetup.Environment,xh,yh,i);
        [Uw2,Vi,~]=Bastankah_TI_wake(x_grid2,y_grid2,z_grid2,Vw(i,i),max(TI_plus(:,i)),ModelSetup.Turbine,ModelSetup.Environment,xh,yh,i,1,weights);
        
        a = Vw(i,i);
        Vw(i,:) = Vi';
        Vw(i,i) = a;
        
        
        [Uw,~,T]=Bastankah_TI_wake(x_grid,y_grid,z_grid,Vw(i,i),max(TI_plus(:,i)),ModelSetup.Turbine,ModelSetup.Environment,xh,yh,i);
        TI_plus(i,:) = real(T');
        
        ux1 = ux1 + ux + real(Uw); %*cosd(environment.Wind_direction);
        ux_2 = ux_2 + ux2 + (Uw2); 
        %u = u + real(Uw); %*cosd(environment.Wind_direction);
        %contour((x_grid(:,:,idz))/R,(y_grid(:,:,idz))/R,u(:,:,idz)/Uo,40,'Fill','on')
    end
u = Uo_ref + ux1;
u2 = Uo_ref + ux_2(:,:,1);
ux1 = zeros([size(x_grid)]);
ux_2= zeros([size(x_grid2)]);
Vw = zeros(numel(xh),numel(xh));
Vw(1,1) = sum(sum(u2(:,:,1).*weights));
%TI = zeros(size(xh));
fprintf('\n')
end
figure
contour((x_grid(:,:,idz))/D,(y_grid(:,:,idz))/D,u(:,:,idz)/Uo_ref,210,'Fill','on')
hold on
plot(xh/D,yh/D,'kx');
contour((x_grid(:,:,idz))/D,(y_grid(:,:,idz))/D,u(:,:,idz)/Uo_ref,40)
xlabel('x/D [-]','fontsize',14,'interpreter','latex')
ylabel('y/D [-]','fontsize',14,'interpreter','latex')
%title('Contour Plot of Vortex Cylinder Model - U_{0} = 16 m/s')
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