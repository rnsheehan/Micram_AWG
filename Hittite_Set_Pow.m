function Hittite_Set_Pow(visObj, powVal)
% set the output power of a Hittite HMC-T2XXX Signal Generator
% user must ensure that visa connection to HMC-T2XXX is correctly initialised
% user must ensure that powVal is within correct bounds for HMC-T2XXX model
% powVal must have units of dBm
% R. Sheehan 24 - 6 - 2025

% Query HMC-T2XXX power limits
powMin = str2double( query (visObj, ':SOUR:POW MIN?') ); % read the min power for HMC-T2XXX
powMax = str2double( query (visObj, ':SOUR:POW MAX?') ); % read the max power for HMC-T2XXX

units = 'dBm'; % specify what units the power output should be, for HMC-T2XXX only dBm is acceptable for power units

if powVal >= powMin && powVal <= powMax
	% desired power value is within range, assign away
	fprintf (visObj, [':SOUR:POW ', num2str(powVal), units]); 
else
	% desired power value is outside of range, default Pout = 0 dBm
	fprintf (visObj, [':SOUR:POW ', num2str(0), units]);
end

end