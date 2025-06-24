function Hittite_Set_Frq(visObj, frqVal)
% set the output frequency of a Hittite HMC-T2XXX Signal Generator
% user must ensure that visa connection to HMC-T2XXX is correctly initialised
% user must ensure that frqVal is within correct bounds for HMC-T2XXX model
% frqVal must have units of GHz
% R. Sheehan 24 - 6 - 2025

% Query HMC-T2XXX frq limits
frqMin = str2double( query (visObj, ':SOUR:FREQ MIN?') ) / 1.0e+9; % read the min frq for HMC-T2XXX
frqMax = str2double( query (visObj, ':SOUR:FREQ MAX?') ) / 1.0e+9; % read the max frq for HMC-T2XXX

units = 'GHz'; % specify what units the frequency output should be

if frqVal >= frqMin && frqVal <= frqMax
	% desired freq value is within range, assign away
	fprintf (visObj, [':SOUR:FREQ ', num2str(frqVal), units]);
else
	% desired freq value is outside of range, default Fout = 1 GHz
	fprintf (visObj, [':SOUR:FREQ ', num2str(1.0), units]);
end

end