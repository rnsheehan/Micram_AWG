% MATLAB script for interfacing to the Micram DAC4 AWG
% In my lab the input clock source is a Hittite HMC-T2XXX Signal Generator
% Control code will be of the form of a text-menu based finite state machine
% Primary purpose at this point is the twin pulse test requested by Mr. Odhran Liston
% More functionality can be added at a later date
% R. Sheehan 24 - 6 - 2025

% Seems like you need to add MATLAB files to MATLAB system path
%addpath(genpath('c:/Users/Robert/Programming/MATLAB/Micram_AWG/')); 
%cd('c:/Users/Robert/Programming/MATLAB/Micram_AWG/'); 

% Unclear if I'm allowed to post Micram GmbH MATLAB code on github so I won't
% Add the search path directly
% You may need to change this for your system
addpath(genpath('c:/Users/Robert/Equipment/Equipment_Manuals/Micram/DAC4_1.5/')); 

% In Tyndall Lab C.109 there are two Hittite SG
hit_addr1 = 'GPIB0::15::INSTR'; % HMC-T2100 10MHz - 20GHz 
hit_addr2 = 'GPIB0::29::INSTR'; % HMC-T2270 10MHz - 70GHz1
hit_vendor = 'NI'; 

% Open VISA connection and set parameters for HMC-T2XXX
visObj = visa (hit_vendor, hit_addr2);
fopen (visObj);

%set (visObj, 'Timeout', 10);
%set (visObj, 'EOSMode', 'read');

% equipment status labels
dac4_status = false; % is the dac4 initialised? 
hmc_status = false; % is the HMC-T2XXX output on? 

% Initialise the DAC4 when calling the script for the first time

disp('Does the DAC4 need to be initialised? '); 
disp('Enter 1 to initialise DAC4')
initialise_dac4 = input('Initialise DAC4?'); 

if initialise_dac4 == 1
	clear;
	clear global md;
	clear global fom;
	global md;
	format long;

	%%%%%%%%%
	% Board %
	%%%%%%%%%
	board='dac4board';
	md.(board).ip='192.168.7.2'; % internal IP address beaglebone connection USB

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% path for the folder containing the calibration data %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	md.cal_data_path='C:\Users\Robert\Equipment\Equipment_Manuals\Micram\cal_data';

	%%%%%%%%%%%%%%%%%
	% DAC modules(s) %
	%%%%%%%%%%%%%%%%%%

	% Select which DAC modules should be used.
	% 1         -> Module in socket 1 on master board
	% 2         -> Module in socket 2 on master board
	% 3         -> Module in socket 1 on slave board
	% 4         -> Module in socket 2 on slave board
	% [1 2]     -> Modules in both sockets on master board
	% [1 2 3 4] -> Modules in both sockets on master and slave board
	md.(board).devs=[1];

	%%%%%%%%%%%%%%%%%%%%%%%%%%
	% no configuration below %
	%%%%%%%%%%%%%%%%%%%%%%%%%%

	%addpath([pwd() '\board_functions']);
	%addpath([pwd() '\module_functions']);
	%addpath([pwd() '\dac4_functions']);
	%addpath([pwd() '\common_functions']);

	board_init( board );
	
	dac4_status = true; 
end

% Simple menu allows you to operate the Micram AWG continuously
% Define options for menu
start = 'Options:\n';
option1 = 'Initialise DAC4: Input = 1\n'; % Initialise the DAC4, only needs to be run once
option2 = 'Change Clock Frequency: Input = 2\n'; % change clock frequency, units of GHz
option3 = 'Change Clock Power: Input = 3\n'; % change clock power, units of dBm
option4 = 'Enable Clock Output: Input = 4\n'; % switch clock output on
option5 = 'Disable Clock Output: Input = 5\n'; % switch clock output off
option6 = 'Enable DAC4 Twin Pulse Output: Input = 6\n'; % 
option7 = 'Enable DAC4 Cosine Output: Input = 7\n'; % 
option8 = 'End program: Input = -1\n';
message = 'Input: ';
newline = '\n';
prompt = strcat(newline, start, option2, option3, option4, option5, option6, option7, option8, newline, message);

% some constants for the twin-pulse pattern
Ni = 10; % no. symbols with which twin-pulse pattern is buffered
Nw = 5; % no. symbols needed to form pulse of known deltaT
Nd = 5; % no. symbols needed to form delay between pulses

% set sample rate and the module no. for Micram DAC4
sample_rate = 100e9; % DAC SR in units of Hz
module_no = 1; % assign a value to the DAC4 module

% Start continuous operation
do = true;
while do
    action = input(prompt);
    if action == -1
        disp('End Program');
        do = false;
    %elseif action == 1
    %    disp('Initialise DAC4');
    %    run("setup_dac4.m"); % call the script to initialise the DAC4
	%	dac4_status = true; 
    elseif action==2
        disp('Change Clock Frequency');
		freq = input('Input Desired Clock Frequency in units of GHz: '); % input desired frequency in units of GHz
		Hittite_Set_Frq(visObj, freq); 
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
        disp('Enable DAC4 Twin Pulse Output');
				
		if hmc_status == false
			fprintf (visObj, ':OUTP ON'); 
		end
		
		% deltaTw is the width of the pulse that you want to excite the laser
		deltaTw = input('Input the required pulse width in units of pico-second: ');
		
		% deltaTd is the length of the delay that you want between the pulses
		deltaTd = input('Input the required time-delay between pulses in units of pico-second: ');
		
		% owing to the manner in which the pattern is sent to the DAC4
		% it is not actually a requirement that deltaTd > deltaTw
		
		% compute the clock-rate needed to generate the pulse of width deltaTw
		frqVal = Micram_Get_Twin_Pulse_Clock_Rate(Nw, deltaTw); 
		Hittite_Set_Frq(visObj, frqVal); 
		crhz, crghz = Hittite_Get_Freq(visObj); % read the actual clock rate
		fprintf('Current Clock Frequency: %0.3f GHz\n',crghz);
		
		% compute the number of symbols needed to generate the delay of width deltaTd
		% remember that the clock-rate must now be kept constant to ensure pulses of width deltaTw
		% the manner in which Nd is computed means that the minimum default delay will actually be deltaTw
		% it should be possible to change this constraint in the future if needed
		% R. Sheehan 24 - 6 - 2025
		Nd = Micram_Get_Twin_Pulse_Delay_Symbols(crghz, deltaTd); 
		
		% assign the twin-pulse pattern
		% pattern takes the form of a line of length 256 symbols, repeated 2048 times
		% line will take the form [ 0 for Ni symbols (buffer), 63 for Nw symbols (first pulse), 0 for Nd symbols (delay), 63 for Nw symbols (second pulse), 0 for Ni symbols (buffer), zero padding ]
		% zero padding is added on at the end of the line by DAC4 to make sure the line length is 256 symbols
		% the contents of line can be changed as needed
		buffer = zeros(1, Ni); % fixed buffer of zeroes to go at start and end of line
		pulse = 63 * ones(1, Nw); % pulse of known duration and max output voltage
		delay = zeros(1, Nd); % delay of known duration
		line = [buffer pulse delay pulse buffer];
		
		% setup DAC4 for operation
		if dac4_status == true
			% set sample rate
			dac4_set_samplerate( board, md.(board).devs, sample_rate)
			dac4_swing_set( board, md.(board).devs, 500);
			
			% set trigger output freq
			dac4_syncoutput_mode_set( board, module_no, 'DIV4'); % divide output frq by 4
			
			% load the line pattern into the DAC4 memory
			dac4_pattern_load_raw( board, md.(board).devs, line); 
			
			% start outputting the pattern
			% pattern should continue until you tell the code to stop
			dac4_pattern_start( board );			
		end
	elseif action == 7
        disp('Enable DAC4 Cosine Output');
		
		if hmc_status == false
			fprintf (visObj, ':OUTP ON'); 
		end
		
		% Tell the computer the frequency that you want to output
		frqVal = input('Input the required output frequency in units of GHz: ');
		clock_rate = 4.0 * frqVal; % change the clock-freq to the correct value because output from DAC4 is clock-rate / 4
		Hittite_Set_Frq(visObj, clock_rate); % adjust the clock-rate
		crhz, crghz = Hittite_Get_Freq(visObj); % read the actual clock rate
		fprintf('Current Clock Frequency: %0.3f GHz\n',crghz);
		
		no_cosine_cycles_p = 3;
		pat_length_m = floor( no_cosine_cycles_p*(sample_rate/crhz) ); 
		fprintf('Fout = %f\n',frqVal);
		fprintf('No. Cosine Cycles P = %d\n',no_cosine_cycles_p);
		fprintf('Pattern Length M = %d\n',pat_length_m);
		
		% setup DAC4 for operation
		if dac4_status == true
			% set sample rate
			dac4_set_samplerate( board, md.(board).devs, sample_rate)
			dac4_swing_set( board, md.(board).devs, 500);
			
			% set trigger output freq
			dac4_syncoutput_mode_set( board, module_no, 'DIV4'); % divide output frq by 4
			
			% load the line pattern into the DAC4 memory
			dac4_pattern_load_raw( board, md.(board).devs, line); 
			
			% start outputting the pattern
			% pattern should continue until you tell the code to stop
			dac4_pattern_load(board, module_no, pattern_cosine(pat_length_m, no_cosine_cycles_p) );		
		end		
    else
        action = input(prompt); % Takes you back to start of menu
    end
end

% STOP PATTERN:
if dac4_status == true
	dac4_pattern_stop( board );
	dac4_status = false; 
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