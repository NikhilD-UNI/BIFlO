function h = rotatez(ang,dim)
%rotation matrix about the z axis
%inputs
%--------------------------------------------------------------------------
%ang - the angle which you would like to rotate a 3d object about the z
%      axis. This is a clockwise rotation
%dim - if value set to one, output will be a 2D rotational matrix.I
%outputs
%--------------------------------------------------------------------------
% h - rotation matrix

if nargin == 1
    h = [ cosd(ang) -sind(ang) 0; sind(ang) cosd(ang) 0; 0 0 1];
elseif nargin == 2
    if dim == 1
        h = [ cosd(ang) -sind(ang); sind(ang) cosd(ang)];
    elseif dim == 0
        h = [ cosd(ang) -sind(ang) 0; sind(ang) cosd(ang) 0; 0 0 1];
    else
        warning('the dimension for your rotation matrix has been assigned a flag other than 0 or 1. The default condition will be set to 1')
        h = [ cosd(ang) -sind(ang); sind(ang) cosd(ang)];
    end
end
end