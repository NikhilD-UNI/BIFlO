function [population_sorted,I,idx_front_row] = population_sort(population,ModelSetup)
% Function to sort and hence index the population by position in array.
% sorting will be done in ascending order of the x coordinate of the
% population. The catesian coordinate system is alligned to the wind
% direction, in such a way that the x axis is defined as positive in the
% same direction as the wind direction
%
%inputs
%--------------------------------------------------------------------------
% population = coordinate points of the turbine [X , Y]
%
% ModelSetup = ModelSetup Class
%
%outputs
%--------------------------------------------------------------------------
% population_sorted = sorted population list in same format [X , Y] but
%                     listed in order of ascending x values. coordinate
%                     position of turbines will be the same as in
%                     population
%
% I                 = Index transformation array from the row sort
%                     algorithm
%
% idx_front_row     = Returns the indexes of the turbines that are 
%                     considered to be in the front row 
%--------------------------------------------------------------------------

%store yaw angle
if nargin == 1
yaw = 0;
D   = 200 ;
else
yaw = ModelSetup.Environment.Wind_direction;
D   = ModelSetup.Turbine.Diameter;
end
%find how many turbines
[nTurb,~] = size(population);

%rotate our axis system to be alligned with the yaw direction.
population_rotated = zeros([size(population)]);
for i = 1:nTurb
    c = rotatez(yaw,1) * [population(i,1) ; population(i,2)];
    population_rotated(i,1) = c(1) ;
    population_rotated(i,2) = c(2) ;
end
%now sort the populatio in terms of ascending x coordinates
[population_sorted_rotated, I] = sortrows(population_rotated,1);
population_sorted = [population(I,1),population(I,2)];

%% Find the front row turbines
% Now find the indexes of the turbine that constitute the front row. 
% This algorithim works by looking at boundry expansion  

if nTurb == 1
    idx_front_row = 1;
    return
end

% localise the sorted and roted population system
population_rotated_local = population_sorted_rotated - population_sorted_rotated(1,:);
x = population_rotated_local(:,1);
y = population_rotated_local(:,2);

% find turbine numbers on boundary
k = boundary(x,y);

% analyse boundary expansion
MAX = [0 0] ;
MIN = [0 0] ;
idx_front_row = 1;
count = 2;

try
    sign = (y(k(2))  >= 0);
catch
    Idx_front_row = 1;
    return
end

if sign
    %need to check that the boundary expansion doesn't register from the
    %wrong end. The boundary function can throw placements incorrectly.
    sign2 = (y(k(end-1))  >= 0);
    if (sign2 == sign) && (x(k(end-1)) <  x(k(2)))
        k = flip(k);
    end
else
    k = flip(k);
end

% if all(y(2:end) >= 0)
%     k = flip(k);
% end

for i = 1: length(k)-1
    if y(k(i+1)) >= 0
        
        if (y(k(i+1))-MAX(2)) >= D
            idx_front_row(count) = k(i+1);
            MAX = [x(k(i+1)) y(k(i+1))];
            count = count+1;
            continue
        elseif (y(k(i+1))-MAX(2)) >= D/2 && abs((x(k(i+1))-MAX(1))) >= 5*D
            idx_front_row(count) = k(i+1);
            MAX = [x(k(i+1)) y(k(i+1))];
            count = count+1;
            continue
        end
    else
        
    end
end

for i = 1: length(k)-1
    if y(k(end-i)) <= 0
        
        if (MIN(2)-y(k(end-i))) >= D
            idx_front_row(count) = k(end-i);
            MIN = [x(k(end-i)) y(k(end-i))];
            count = count+1;
            continue
        elseif (MIN(2) - y(k(end-i))) >= D/2 && abs((x(k(end-i))-MIN(1))) >= 5*D
            idx_front_row(count) = k(end-i);
            MIN = [x(k(end-i)) y(k(end-i))];
            count = count+1;
            continue
        end
    else
        
    end
end


end