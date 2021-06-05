function d_m = min_distance_finder(population,ModelSetup)
% This function looks to find the smallest distance of one turbine to
% another
%Inputs
%--------------------------------------------------------------------------
% population - genome string contains [X Y] = [x1,x2,x3 ....xn, y1,y2,y3....yn]
%              For Jensen 1d
%              this is a vector, either 2 by N or N by 2 that contains the
%              x and y coordinates of a given population of turbines. 
%
%Outputs
%--------------------------------------------------------------------------
%d_m - a N by 1 vector containing the minimum distance near of any turbine
%      to the i-th turbine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Wake_Model  = ModelSetup.Wakemodel;

if strcmp(Wake_Model,'Jensen_1D') == 0
    [n.x n.y] = size(population);
    %genome string contains [X Y] = [x1,x2,x3 ....xn, y1,y2,y3....yn]
    xh = population(1:n.y/2);
    yh = population((n.y/2 + 1) : end);
    population = [xh;yh];
    [n.x n.y] = size(population);
    N = n.y;
end

%error handling for
if strcmp(Wake_Model,'Jensen_1D') == 1
    [n.x n.y] = size(population);
    if (n.x == 1 && n.y == 1)
        d_m = 0;
        return
    end
    % Assign size index and reshape population array
    if n.y >= n.x
        N = n.y;
    else
        N = n.x;
        population = population' ;
    end
end

% calculate distances. distance is a N x N matrix with a diagonal
% of zeros (i.e distance of turbine to itself is zero)
distances = dist(population);
distances(1:N+1:end) =[];
distances = reshape(distances,N -1,N);


d_m = zeros(N,1);

%get the distances
for i = 1:N
    d_m(i,1) =  min(distances(:,i));
end

end