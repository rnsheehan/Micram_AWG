function res = Hittite_Get_Frq(visObj)
% get the output frequency of a Hittite HMC-T2XXX Signal Generator
% user must ensure that visa connection to HMC-T2XXX is correctly initialised
% res is array with frq value in units of Hz and GHz respectively
% R. Sheehan 24 - 6 - 2025

v = query (visObj, ':SOUR:FREQ?') ; % Read the output frequency
vhz = str2double(v); % output frq in units of Hz
vghz = vhz/1.0e+9; % output frq in units of GHz

res = [vhz, vghz]; 

end