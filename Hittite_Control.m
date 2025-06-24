% Script for interfacing to Hittite HMC-T2XXX Signal Generators
% Set the operating frequency
% Set the operating power
% Turn the output On / Off
% R. Sheehan 19 - 6 - 2025

% In Tyndall Lab C.109 there are two Hittite SG
hit_addr1 = 'GPIB0::15::INSTR'; % HMC-T2100 10MHz - 20GHz 
hit_addr2 = 'GPIB0::29::INSTR'; % HMC-T2270 10MHz - 70GHz
hit_vendor = 'NI'; 

% Open VISA connection and set parameters for HMC-T2XXX
visObj = visa (hit_vendor, hit_addr1);
fopen (visObj);

%set (visObj, 'Timeout', 10);
%set (visObj, 'EOSMode', 'read');

% Attempt to make a query of the device
units = 'GHz'; % specify what units the frequency output should be
fset = 7; % specify the output frequency in units of GHz
fprintf (visObj, [':SOUR:FREQ ', num2str(fset), units]);
v = query (visObj, ':SOUR:FREQ?') ; % Read the output frequency
vghz = str2double(v)/1.0e+9; 
fprintf('Current Frequency: %s\n',v);
fprintf('Current Frequency: %0.3f GHz\n',vghz);

% Turn on the output
fprintf (visObj, ':OUTP ON');
v = query (visObj, ':OUTP?') ; % Determine the status of the output
fprintf('Output Status: %s\n',v);

% Insert a fixed delay
pause('on'); 
pause(20); 

% Turn off the output
fprintf (visObj, ':OUTP OFF');
v = query (visObj, ':OUTP?') ; % Determine the status of the output
fprintf('Output Status: %s\n',v);

%   Close VISA connection
disp ('Close VISA connection.');
fclose (visObj);
delete (visObj);
disp ('Connection closed successfully.');