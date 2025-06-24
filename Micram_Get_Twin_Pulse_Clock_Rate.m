function cr = Micram_Get_Twin_Pulse_Clock_Rate(nsymb, deltaT)

% compute the clock rate required to setup the Odhran Liston twin pulse
% nsymb is the number of symbols needed to make the pulse, integer value
% deltaT is the time width of the pulse, expressed in units of ps
% cr is the desired clock rate in units of GHz
% R. Sheehan 24 - 6 - 2025

% this is an empirical approximation that relates the HMC-T2XXX output frequency with the desired pulse width
% it can be shown from data that for the DAC4
% PW[GHz] ~ ( 2 CR[GHz] ) / nsymb

% i.e. HMC-T2XXX operating with output frequency CR[GHz] will produce square pulses of width PW[GHz]
% nsymb is the number of symbols needed to create the square pulse, this is quite technical and 
% is related to how the pattern is loaded into the DAC4 using the method dac4_pattern_load_raw.m

% time in units of ps is related to frequency in units of GHz via T[ps] = 1e+3/F[GHz]
% using this conversion you can relate deltaT[ps] to HMC-T2XXX CR[GHz]

cr = (1.0e+3 * nsymb) / (2.0 * deltaT); 

end