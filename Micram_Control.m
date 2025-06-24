% MATLAB script for interfacing to the Micram DAC4 AWG
% In my lab the input clock source is a Hittite HMC-T2XXX Signal Generator
% Control code will be of the form of a text-menu based finite state machine
% Primary purpose at this point is the twin pulse test requested by Mr. Odhran Liston
% More functionality can be added at a later date
% R. Sheehan 24 - 6 - 2025

% Unclear if I'm allowed to post Micram GmbH MATLAB code on github so I won't
% Add the search path directly
% You may need to change this for your system
addpath(genpath('c:/Users/Robert/Equipment/Equipment_Manuals/Micram/DAC4_1.5/')); 

% In Tyndall Lab C.109 there are two Hittite SG
hit_addr1 = 'GPIB0::15::INSTR'; % HMC-T2100 10MHz - 20GHz 
hit_addr2 = 'GPIB0::29::INSTR'; % HMC-T2270 10MHz - 70GHz
hit_vendor = 'NI'; 

% Open VISA connection and set parameters for HMC-T2XXX
visObj = visa (hit_vendor, hit_addr2);
fopen (visObj);

%set (visObj, 'Timeout', 10);
%set (visObj, 'EOSMode', 'read');

% Simple menu allows you to operate the Micram AWG continuously
% Define options for menu
start = 'Options:\n';
option1 = 'Initialise DAC4: Input = 1\n'; % Initialise the DAC4, only needs to be run once
option2 = 'Change Clock Frequency: Input = 2\n'; % change clock frequency, units of GHz
option3 = 'Change Clock Power: Input = 3\n'; % change clock power, units of dBm
option4 = 'Enable Clock Output: Input = 4\n'; % switch clock output on
option5 = 'Disable Clock Output: Input = 5\n'; % switch clock output off
option6 = 'Assign Twin Pulse Parameters: Input = 6\n'; % 
option7 = 'Enable DAC4 Twin Pulse Output: Input = 7\n'; % 
option8 = 'End program: Input = -1\n';
message = 'Input: ';
newline = '\n';
prompt = strcat(newline, start, option1, option2, option3, option4, option5, option6, option7, option8, newline, message);

% equipment status labels
dac4_init = false; % is the dac4 initialised? 
hmc_status = false; % is the HMC-T2XXX output on? 

% Start continuous operation
do = true;
while do
    action = input(prompt);
    if action == -1
        disp('End Program');
        do = false;
    elseif action == 1
        disp('Initialise DAC4');
        run("setup_dac4.m"); % call the script to initialise the DAC4
		dac4_init = true; 
    elseif action==2
        disp('Change Clock Frequency');
		freq = input('Input Desired Clock Frequency in units of GHz: '); % input desired frequency in units of GHz
		Hittite_Set_Frq(visObj, frqVal); 
    elseif action == 3
        disp('Change Clock Power');
		power = input('Input Desired Clock Power in units of dBm: '); % input desired power in units of dBm
		Hittite_Set_Pow(visObj, power); 
    elseif action == 4
        disp('Enable Clock Output');
		fprintf (visObj, ':OUTP ON');
		hmc_status = true; 
    elseif action == 5
        disp('Disable Clock Output');
		fprintf (visObj, ':OUTP OFF');
		hmc_status = false; 
    elseif action == 6
        disp('Assign Twin Pulse Parameters');
    elseif action == 7
        disp('Enable DAC4 Twin Pulse Output');
		if hmc_status == false
			fprintf (visObj, ':OUTP ON'); 
		end
    else
        action = input(prompt); % Takes you back to start of menu
    end
end

% STOP PATTERN:
if dac4_init == true
	dac4_pattern_stop( board );
	dac4_init = false; 
end

%   Close VISA connection
% turn off the output if you haven't already done so
disp ('Close VISA connection.');
if hmc_status == true
	fprintf (visObj, ':OUTP OFF'); 
end
fclose (visObj);
delete (visObj);
disp ('Connection closed successfully.');