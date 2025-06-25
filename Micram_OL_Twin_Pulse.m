% script for configuring the Micram DAC4 AWG with Odhran Liston Twin-Pulse
% need this script because of comms issues with the HMC-T2XXX
% HMC-T2XXX controls clock rate for AWG
% clock rate value will have to be entered manually in this script for
% output to be configured correctly
% Micram_Control.m is much nicer because it talks to DAC4 and HMC-T2XXX
% simultaneously
% R. Sheehan 25 - 6 - 2025

% Unclear if I'm allowed to post Micram GmbH MATLAB code on github so I won't
% Add the search path directly
% You may need to change this for your system
addpath(genpath('c:/Users/Robert/Equipment/Equipment_Manuals/Micram/DAC4_1.5/'));

% instantiate the DAC4 board object
global md;

% some constants for the twin-pulse pattern
Ni = 10; % no. symbols with which twin-pulse pattern is buffered
Nw = 5; % no. symbols needed to form pulse of known deltaT
Nd = 5; % no. symbols needed to form delay between pulses

% set sample rate and the module no. for Micram DAC4
sample_rate = 100e9; % DAC SR in units of Hz
module_no = 1; % assign a value to the DAC4 module

disp('Enable DAC4 Twin Pulse Output');

% start inputting some values
% deltaTw is the width of the pulse that you want to excite the laser
deltaTw = input('Input the required pulse width in units of pico-second: ');

% deltaTd is the length of the delay that you want between the pulses
deltaTd = input('Input the required time-delay between pulses in units of pico-second: ');

% owing to the manner in which the pattern is sent to the DAC4
% it is not actually a requirement that deltaTd > deltaTw

% compute the clock-rate needed to generate the pulse of width deltaTw
crghz = Micram_Get_Twin_Pulse_Clock_Rate(Nw, deltaTw);
fprintf('Desired Clock Frequency: %0.3f GHz\n',crghz);

% compute the number of symbols needed to generate the delay of width deltaTd
% remember that the clock-rate must now be kept constant to ensure pulses of width deltaTw
% the manner in which Nd is computed means that the minimum default delay will actually be deltaTw
% it should be possible to change this constraint in the future if needed
% R. Sheehan 24 - 6 - 2025
Nd = Micram_Get_Twin_Pulse_Delay_Symbols(crghz, deltaTd); 
fprintf('Number of symbols in the delay %d\n',Nd);

% Compute the size of the buffer
buf_2 = 256 - 2*Nw - Nd; 
if mod(buf_2, 2) == 0
    Ni = buf_2 / 2; % buf_2 is even
else
    Ni = (buf_2-1) / 2; % buf_2 is odd, change it to nearest even
end
fprintf('Number of symbols in the buffer %d\n',Ni);

% force the script to pause while you change the clock frequency to the
% desired rate
xx = input('Have you updated the clock frequency? ');

% assign the twin-pulse pattern
% pattern takes the form of a line of length 256 symbols, repeated 2048 times
% line will take the form [ 0 for Ni symbols (buffer), 63 for Nw symbols (first pulse), 0 for Nd symbols (delay), 63 for Nw symbols (second pulse), 0 for Ni symbols (buffer), zero padding ]
% zero padding is added on at the end of the line by DAC4 to make sure the line length is 256 symbols
% the contents of line can be changed as needed
buffer = zeros(1, Ni); % fixed buffer of zeroes to go at start and end of line
pulse = 63 * ones(1, Nw); % pulse of known duration and max output voltage
delay = zeros(1, Nd); % delay of known duration
line = [buffer pulse delay pulse buffer];

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