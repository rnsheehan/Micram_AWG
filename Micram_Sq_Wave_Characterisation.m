% script for configuring the Micram DAC4 AWG with Square Wave Pulses
% need this script because of comms issues with the HMC-T2XXX
% HMC-T2XXX controls clock rate for AWG
% clock rate value will have to be entered manually in this script for
% output to be configured correctly
% Want to see what the pulse width is for purely square waves as function
% of Clock frequency
% R. Sheehan 26 - 6 - 2025

% Unclear if I'm allowed to post Micram GmbH MATLAB code on github so I won't
% Add the search path directly
% You may need to change this for your system
addpath(genpath('c:/Users/Robert/Equipment/Equipment_Manuals/Micram/DAC4_1.5/'));

% instantiate the DAC4 board object
global md;

% some constants for the twin-pulse pattern
Ntot = 256; % total number of symbols in a line
Nw = 5; % no. symbols needed to form pulse of known deltaT
Nd = Nw; % no. symbols needed to form delay between pulses
Ns = Nd + Nw; % total no. symbols in single square segment
NNs = round(Ntot / Ns); % no. segments that can fit in a line

% set sample rate and the module no. for Micram DAC4
sample_rate = 100e9; % DAC SR in units of Hz
module_no = 1; % assign a value to the DAC4 module

disp('Enable DAC4 Twin Pulse Output');

% start inputting some values
% deltaTw is the width of the pulse that you want to excite the laser
%deltaTw = input('Input the required pulse width in units of pico-second: ');

% deltaTd is the length of the delay that you want between the pulses
%deltaTd = input('Input the required time-delay between pulses in units of pico-second: ');

% owing to the manner in which the pattern is sent to the DAC4
% it is not actually a requirement that deltaTd > deltaTw

% compute the clock-rate needed to generate the pulse of width deltaTw
%crghz = Micram_Get_Twin_Pulse_Clock_Rate(Nw, deltaTw);
crghz = 10 ; % As CR is set manually this has no bearing on the actual DAC4 device
fprintf('Desired Clock Frequency: %0.3f GHz\n',crghz);

% compute the number of symbols needed to generate the delay of width deltaTd
% remember that the clock-rate must now be kept constant to ensure pulses of width deltaTw
% the manner in which Nd is computed means that the minimum default delay will actually be deltaTw
% it should be possible to change this constraint in the future if needed
% R. Sheehan 24 - 6 - 2025
%Nd = Micram_Get_Twin_Pulse_Delay_Symbols(crghz, deltaTd); 
fprintf('Number of symbols in the delay %d\n',Nd);
fprintf('Number of symbols in the segments %d\n',Ns);
fprintf('Number of segments in the line %d\n',NNs);

% assign the square wave pulse pattern
% pattern takes the form of a line of length 256 symbols, repeated 2048 times
% line will take the form [ 0 for Nd symbols (delay), 63 for Nw symbols (pulse),...., zero padding ]
% zero padding is added on at the end of the line by DAC4 to make sure the line length is 256 symbols
% the contents of line can be changed as needed
pulse = 63 * ones(1, Nw); % pulse of known duration and max output voltage
delay = zeros(1, Nd); % delay of known duration
segment = [delay pulse]; 
line = []; 
for i=1:NNs
    line = horzcat(line, segment); 
end
fprintf('Number of symbols in the line %d\n',size(line));

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

% STOP PATTERN:
%dac4_pattern_stop( board );  % you can enter this command from the MATLAB
%CLI