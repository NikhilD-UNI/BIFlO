function COE = Cost_Model_WMR(x,ModelSetup,Farm_orientation_offset)
    capex = 2.58e6 ;     %[£/MW] 
    N = numel(x(1,:))/2; %number of turbines
    RP = ModelSetup.Turbine.Rated_Power/1e6;
    Tot_cost = capex*RP*N;
    E = AEP(x,ModelSetup,Farm_orientation_offset)/(365*24);
    COE= -Tot_cost/(E);
    
end