function [c ceq] = nonlinconstraint(x,D,ModelSetup)
if any((min_distance_finder(x,ModelSetup))-5*D <=0)
    c =  0.1;
    ceq = [];
else
     c = -0.1 ;
    ceq = [];
end
end