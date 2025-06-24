function nsymbd = Micram_Get_Twin_Pulse_Delay_Symbols(cr, deltaTd)

% cr is the clock rate needed to generate the twin-pulses whose width is deltaTw
% deltaTw is the time duration of the non-zero pulse
% deltaTd is the desired time delay between pulses

% Using the actual clock rate and the desired time delay between twin-pulses
% compute the number of symbols needed to ensure the time-delay, this is nsymbd
% nsymbd output rounded to the nearest integer
% R. Sheehan 24 - 6 - 2025

% the manner in which nsymbd is computed means that the minimum default delay will actually be deltaTw
% it should be possible to change this constraint in the future if needed
% R. Sheehan 24 - 6 - 2025

val = round( (2.0 * cr * deltaTd)/1.0e+3 ); 

if val > 4
	nsymbd = val; % val is a reasonable value for nsymbd
else
	nsymbd = 5; % val is not a reasonable value, nsymbd must default to 5
end

end