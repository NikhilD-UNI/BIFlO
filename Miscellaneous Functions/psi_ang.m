function angle = psi_ang(y,z,deg)
% function to determine, in radians, the angle subteneded by the radial
% vector from the cylinder axis to a given point. Psi is zero on the y-
% axis
%
%Input
%--------------------------------------------------------------------------
% y = y point (s)
% z = z point (s)
% deg = optional input for testing. Set to 1 to see angles are in degrees
%                                   Set to 0 to keep to radians
%
%Output
%--------------------------------------------------------------------------
% Angle - array of angles
if nargin < 3
    deg = 0;
end

%Need to find the quadrant of the coordinate point
 len   = size(y);
 n     = prod(len);
 angle = zeros([len]);
 
    for i = 1:n
        if (y(i) == 0) && (z(i) == 0)   % on orign       
            angle(i) = 0;
        elseif (y(i) > 0) && (z(i)>0)   % Quadrant 1
            angle(i) = atan(z(i)/y(i));
            
        elseif (y(i) == 0) && (z(i)>0)  % pi/2
            angle(i) = pi/2;
            
        elseif (y(i) < 0) && (z(i)>=0)  % Quadrant 2
            angle(i) = pi - atan(abs(z(i)/y(i)));
            
        elseif (y(i) < 0) && (z(i)<=0)  % Quadrant 3
            angle(i) = pi + atan(abs(z(i)/y(i)));
            
        elseif (y(i) == 0) && (z(i)<0)  % 3 pi/2
            angle(i) = 3*pi/2;
            
        elseif (y(i) > 0) && (z(i)<=0)  % Quadrant 4
            angle(i) = 2*pi - atan(abs(z(i)/y(i)));
        end
    end 

    if deg
       angle = rad2deg(angle); 
    end
end

