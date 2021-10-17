%Turbine properties for the SWT-6.0-154m turbine and the Vestas and their
%respective farms
%
%WMR locations - Wind Farm Wakes from SAR and Doppler Radar, [Tobias Ahsbahs 1,* , Nicolai Gayle Nygaard 2, Alexander Newcombe 2 and Merete Badger 1]
%
clear
%clc

%% Westermost Rough layout
xcoord1 = [1140*ones(1,6)].*[0:1:5]; 
ycoord =  [950*ones(1,7)].*[0:1:6];
xcoord2 = [1140*ones(1,5)].*[0 1 2 4 5]; 
xcoord3 = [1140*ones(1,4)].*[0 1 4 5];

Population_WMH_xy = [xcoord1 xcoord2 xcoord2 xcoord3 xcoord3 xcoord2 xcoord1 ycoord(1)*ones(1,6) ycoord(2)*ones(1,5) ycoord(3)*ones(1,5) ycoord(4)*ones(1,4) ycoord(5)*ones(1,4) ycoord(6)*ones(1,5) ycoord(7)*ones(1,6)];
nvar = length(Population_WMH_xy);

%the below angle is the angle below 270 deg which the farm "face is
%considered to be orientated about. You can correct wind angle by this or
%change the config.
Farm_orientation_offset = 90 - 58.56; %[deg]

xh = Population_WMH_xy(1:nvar/2);
yh = Population_WMH_xy(nvar/2 + 1:nvar);

rotated_config = rotatez(Farm_orientation_offset,1) * [xh;yh];

Population_WMH_true = [rotated_config(1,:) rotated_config(2,:)];

%% Turbine data in Westermost Rough
SWT_6_154 = Turbine;
SWT_6_154.Hubheight = 102;
SWT_6_154.Diameter  = 154;
SWT_6_154.u_cut_out = 25;
SWT_6_154.u_cut_in  = 4;

SWT_6_154.Cp_calibration_distance = 2.5*SWT_6_154.Diameter;
% https://www.thewindpower.net/turbine_en_807_siemens_swt-6.0-154.php
SWT_6_154.Rated_Power= 6e6;            
SWT_6_154.Rated_Power_speed = 13; 

Speeds = 4:0.5:25;
Power = [220 320 440 575 721 945 1173 1485 1796 2157 2517 2940 3360 3930 4485 5160 5792 5960 6000 6000*ones(1,24) ]*(10^3) ;

SWT_6_154.Power = [Speeds', Power'];

% load Ct values into the programme
% file:///C:/Users/nikhi/Downloads/MScThesis_TUDelft_OttelienBossuyt.pdf
% ct curve from a scaled 10MW turbine;
speed = [4:1:25];
ct = [0.9066 0.78 0.76 0.7633 0.7633 0.7666 0.71 0.6133 0.4566 0.34133 0.27 0.22 0.18 0.1466 0.128 0.1066 0.0933 0.08 0.0733 0.0666 0.0533 0.05];

SWT_6_154.Ct = [speed',ct'];

%% environment data from WMR 2016 - 2017
height = 100;
wind_speed = xlsread('C:\Users\nikhi\Documents\University\Aeronautics\FYP\Wind Farm Data\LiDAR_Data_WMR_2016-2017.xlsx','AE2:AE11363');
wind_directions = xlsread('C:\Users\nikhi\Documents\University\Aeronautics\FYP\Wind Farm Data\LiDAR_Data_WMR_2016-2017.xlsx','AI2:AI11363');
wind_speed_sd  =  xlsread('C:\Users\nikhi\Documents\University\Aeronautics\FYP\Wind Farm Data\LiDAR_Data_WMR_2016-2017.xlsx','AF2:AF11363');

TI = wind_speed_sd./wind_speed ;

idx = find(isnan(wind_speed) == 0);

wind_speed = wind_speed(idx);
wind_directions = wind_directions(idx) + 4;
TI              = TI(idx);

wind_direction_intervals = 10;
wind_speed_intervals     = 1;

wind_direction_bins = [0:wind_direction_intervals:(360-wind_direction_intervals)];
%wind_speed_bins     = [1.75,4:wind_speed_intervals:25,25.5+(floor(max(wind_speed)+1)-25.5)/2];
wind_speed_bins      = [1:wind_speed_intervals:25,25.5+(floor(max(wind_speed)+1)-25.5)/2];

dataStore = zeros(length(wind_direction_bins),length(wind_speed_bins));
TI_data_store = zeros(length(wind_direction_bins),2);

for i = 1: numel(wind_speed)
    
%     [idx_dir1, idx_dir2] = idx_find(wind_directions(i),wind_direction_bins);
    idx_dir = find(wind_direction_bins == round(wind_directions(i),-1));
    
%     [idx_speed1, idx_speed2] = idx_find(wind_speed(i),wind_speed_bins);
    idx_speed = find(wind_speed_bins == round(wind_speed(i)));
    
%     if wind_speed(i) <= 3.5
%         idx_speed = 1;
%     end
    if wind_directions(i) <= (wind_direction_intervals/2)
        idx_dir = 1;
    end
    if wind_speed(i) >= 25.5
        idx_speed = numel(wind_speed_bins);
    end
     if wind_directions(i) >= (360 - wind_direction_intervals/2)
        idx_dir = 1;
    end
    
    
    dataStore(idx_dir,idx_speed) = dataStore(idx_dir,idx_speed) + 1;
    if or(wind_speed_bins(idx_speed) <= SWT_6_154.u_cut_out , wind_speed_bins(idx_speed) >= SWT_6_154.u_cut_in)
        TI_data_store(idx_dir,1) = TI_data_store(idx_dir,1) + TI(i);
        TI_data_store(idx_dir,2) = TI_data_store(idx_dir,2) + 1;
    end
end

TI_dir = TI_data_store(:,1)./TI_data_store(:,2);

Mean_Wind_Speed = sum(sum(dataStore).*wind_speed_bins)/sum(sum(dataStore));

v_bar = mean_power_producing_velocity(SWT_6_154,wind_speed_bins,dataStore,[]);
v_bar_global = mean_power_producing_velocity(SWT_6_154,wind_speed_bins,sum(dataStore),[]);

Mean_wind_direction = sum(sum(dataStore').*wind_direction_bins/(sum(sum(dataStore))));


environment = environment;
environment.surface_roughness = 0.001; %[m]
environment.wind_rose.Direction = wind_direction_bins;
environment.wind_rose.Speeds = wind_speed_bins;
environment = configure_wind_rose_table(environment);
environment = wind_rose_data_assign(environment,dataStore,TI_dir);
environment = wind_rose_data_processing(environment);
%environment = wind_rose_data_processing_probability_averaging(environment,SWT_6_154.u_cut_in,SWT_6_154.u_cut_out);
environment = wind_rose_data_power_average_register(environment,v_bar);
environment.wind_rose.GlobalSummary.Mean_Speed_Power_Producing = v_bar_global;
environment.wind_rose.GlobalSummary.Mean_direction = Mean_wind_direction;
environment.wind_rose.GlobalSummary.Mean_TI_a      = mean(TI_dir);

save('WMR_DATA', 'SWT_6_154', 'Population_WMH_true' , 'Population_WMH_xy' , 'Farm_orientation_offset','environment')



function [idx1,idx2] = idx_find(value,array)
%searches for the value in array and returns the indexes of the array which
%bound that value
n = length(array);
n_val = length(value);

for j = 1:n_val
    for i = 1:n-1
        if value(j) <array(i+1) && value(j) >array(i)
            idx1(j) =i;
            idx2(j) =i+1;
            break
        end
        if value(j) == array(i)
            idx1(j) =i;
            idx2(j) =i;
            break
        end
    end
end
end

function wind_rose(wind_direction,wind_speed)
%WIND_ROSE Plot a wind rose
%   this plots a wind rose
figure
pax = polaraxes;
% polarhistogram(deg2rad(wind_direction(wind_speed<5)),deg2rad(0:10:360),'Normalization','probability','FaceColor','blue','displayname','0 - 5 m/s');
% hold on
% polarhistogram(deg2rad(wind_direction(wind_speed<10)),deg2rad(0:10:360),'Normalization','probability','FaceColor','green','displayname','5 - 10 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<15)),deg2rad(0:10:360),'Normalization','probability','FaceColor','yellow','displayname','10 - 15 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<20)),deg2rad(0:10:360),'Normalization','probability','FaceColor','red','displayname','15 - 20 m/s');
polarhistogram(deg2rad(wind_direction(wind_speed<30)),deg2rad(0:10:360),'Normalization','probability','displayname','> 25 m/s')

% polarhistogram(deg2rad(wind_direction(wind_speed<25)),deg2rad(0:10:360),'Normalization','probability','displayname','24 - 25 m/s')
% 
% hold on
% polarhistogram(deg2rad(wind_direction(wind_speed<24)),deg2rad(0:10:360),'Normalization','probability','displayname','23 - 24 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<23)),deg2rad(0:10:360),'Normalization','probability','displayname','22 - 23 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<22)),deg2rad(0:10:360),'Normalization','probability','displayname','21 - 22 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<21)),deg2rad(0:10:360),'Normalization','probability','displayname','20 - 21 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<20)),deg2rad(0:10:360),'Normalization','probability','displayname','19 - 20 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<19)),deg2rad(0:10:360),'Normalization','probability','displayname','18 - 19 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<18)),deg2rad(0:10:360),'Normalization','probability','displayname','17 - 18 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<17)),deg2rad(0:10:360),'Normalization','probability','displayname','16 - 17 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<16)),deg2rad(0:10:360),'Normalization','probability','displayname','15 - 16 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<15)),deg2rad(0:10:360),'Normalization','probability','displayname','14 - 15 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<14)),deg2rad(0:10:360),'Normalization','probability','displayname','13 - 14 m/s');


% polarhistogram(deg2rad(wind_direction(wind_speed<13)),deg2rad(0:10:360),'Normalization','probability','displayname','12 - 13 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<12)),deg2rad(0:10:360),'Normalization','probability','displayname','11 - 12 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<11)),deg2rad(0:10:360),'Normalization','probability','displayname','10 - 11 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<10)),deg2rad(0:10:360),'Normalization','probability','displayname','9 - 10 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<9)),deg2rad(0:10:360),'Normalization','probability','displayname','8 - 9 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<8)),deg2rad(0:10:360),'Normalization','probability','displayname','7 - 8 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<7)),deg2rad(0:10:360),'Normalization','probability','displayname','6 - 7 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<6)),deg2rad(0:10:360),'Normalization','probability','displayname','5 - 6 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<5)),deg2rad(0:10:360),'Normalization','probability','displayname','4 - 5 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<4)),deg2rad(0:10:360),'Normalization','probability','displayname','0 - 4 m/s');

% polarplot(deg2rad(wind_direction(wind_speed<25)),deg2rad(0:10:360),'Normalization','count','displayname','20 - 25 m/s')
% hold on
% polarplot(deg2rad(wind_direction(wind_speed<20)),deg2rad(0:10:360),'Normalization','count','FaceColor','red','displayname','15 - 20 m/s');
% polarplot(deg2rad(wind_direction(wind_speed<15)),deg2rad(0:10:360),'Normalization','count','FaceColor','yellow','displayname','10 - 15 m/s');
% polarplot(deg2rad(wind_direction(wind_speed<10)),deg2rad(0:10:360),'Normalization','count','FaceColor','green','displayname','5 - 10 m/s');
% polarplot(deg2rad(wind_direction(wind_speed<5)),deg2rad(0:10:360),'Normalization','count','FaceColor','blue','displayname','0 - 5 m/s');


pax.ThetaDir = 'clockwise';
pax.ThetaZeroLocation = 'top';
pax.TickLabelInterpreter= 'latex';
pax.Units= 'normalized';
legend('Show')
title('Wind Rose')
end

function wind_rose2(wind_direction,wind_speed)
%WIND_ROSE Plot a wind rose
%   this plots a wind rose
figure
pax = polaraxes;
% polarhistogram(deg2rad(wind_direction(wind_speed<5)),deg2rad(0:10:360),'Normalization','probability','FaceColor','blue','displayname','0 - 5 m/s');
% hold on
% polarhistogram(deg2rad(wind_direction(wind_speed<10)),deg2rad(0:10:360),'Normalization','probability','FaceColor','green','displayname','5 - 10 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<15)),deg2rad(0:10:360),'Normalization','probability','FaceColor','yellow','displayname','10 - 15 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<20)),deg2rad(0:10:360),'Normalization','probability','FaceColor','red','displayname','15 - 20 m/s');

polarhistogram(deg2rad(wind_direction(wind_speed<30)),deg2rad(0:10:360),'Normalization','count','displayname','> 25 m/s')
hold on
polarhistogram(deg2rad(wind_direction(wind_speed<25)),deg2rad(0:10:360),'Normalization','count','displayname','20 - 25 m/s')
polarhistogram(deg2rad(wind_direction(wind_speed<20)),deg2rad(0:10:360),'Normalization','count','displayname','15 - 20 m/s');
polarhistogram(deg2rad(wind_direction(wind_speed<15)),deg2rad(0:10:360),'Normalization','count','displayname','10 - 15 m/s');
polarhistogram(deg2rad(wind_direction(wind_speed<10)),deg2rad(0:10:360),'Normalization','count','displayname','4  - 10 m/s');
polarhistogram(deg2rad(wind_direction(wind_speed<4)),deg2rad(0:10:360),'Normalization','count','displayname','0  - 4 m/s');
%polarhistogram(deg2rad(wind_direction(wind_speed<10)),deg2rad(0:10:360),'Normalization','count','displayname','4  - 10 m/s');
% hold on
% polarhistogram(deg2rad(wind_direction(wind_speed<15)),deg2rad(0:10:360),'Normalization','count','displayname','10 - 15 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<20)),deg2rad(0:10:360),'Normalization','count','displayname','15 - 20 m/s');
% polarhistogram(deg2rad(wind_direction(wind_speed<25)),deg2rad(0:10:360),'Normalization','count','displayname','20 - 25 m/s')
% polarhistogram(deg2rad(wind_direction(wind_speed<30)),deg2rad(0:10:360),'Normalization','count','displayname','> 25 m/s')

% polarplot(deg2rad(wind_direction(wind_speed<25)),deg2rad(0:10:360),'Normalization','count','displayname','20 - 25 m/s')
% hold on
% polarplot(deg2rad(wind_direction(wind_speed<20)),deg2rad(0:10:360),'Normalization','count','FaceColor','red','displayname','15 - 20 m/s');
% polarplot(deg2rad(wind_direction(wind_speed<15)),deg2rad(0:10:360),'Normalization','count','FaceColor','yellow','displayname','10 - 15 m/s');
% polarplot(deg2rad(wind_direction(wind_speed<10)),deg2rad(0:10:360),'Normalization','count','FaceColor','green','displayname','5 - 10 m/s');
% polarplot(deg2rad(wind_direction(wind_speed<5)),deg2rad(0:10:360),'Normalization','count','FaceColor','blue','displayname','0 - 5 m/s');


pax.ThetaDir = 'clockwise';
pax.ThetaZeroLocation = 'top';
pax.TickLabelInterpreter= 'latex';
pax.Units= 'normalized';
legend('Show')
title('Wind Rose')
end