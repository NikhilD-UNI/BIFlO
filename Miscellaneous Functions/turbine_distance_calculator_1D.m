function [d] = turbine_distance_calculator_1D(turbine_coordinate)
%function gives the distance between itself and the other turbines in the
%input variable turbine coordinate
%coordinates inputed will be with reference to the global coordinate
%refernce frame
 n = length(turbine_coordinate);
 d = zeros(1,n);
 d = turbine_coordinate(:) - turbine_coordinate(1) ;
end