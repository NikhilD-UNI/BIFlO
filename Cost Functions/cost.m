function fval = cost(x,ModelSetup,Farm_orientation_offset)
n = numel(x(1,:))/2;
C = n*(2/3 + 1/3*exp(-0.00174*n^2));
E = -AEP(x,ModelSetup,Farm_orientation_offset);
fval = C/(E/1e6);

end