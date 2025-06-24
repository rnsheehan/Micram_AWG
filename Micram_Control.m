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
option1 = 'Initialise DAC4 Input = 1\n'; % Initialise the DAC4, only needs to be run once
option6 = 'Change Clock Frequency Input = 2\n'; % change clock frequency, units of GHz
option7 = 'Change Clock Power Input = 3\n'; % change clock power, units of dBm
option2 = 'Enable Clock Output Input = 4\n'; % switch clock output on
option3 = 'Disable Clock Output Input = 5\n'; % switch clock output off
option5 = 'Assign Twin Pulse Parameters Input = 6\n'; % 
option8 = 'Perform Optical Power Sweep Input = 7\n'; % 
option4 = 'End program Input = -1\n';
message = 'Input: ';
newline = '\n';
prompt = strcat(newline, start, option1, option6, option7, option2, option3, option5, option8, option4, newline, message);

% Start continuous operation
do = true;
while do
    action = input(prompt);
    if action == -1
        disp('End Program');
        do = false;
    elseif action == 1
        disp('Change temperature to some value within specified Bounds')
        disp(['Low Temperature Bound: ', num2str(Tlimits(1))]);
        disp(['High Temperature Bound: ', num2str(Tlimits(2))]);
        Tset = input('Desired Temperature Value: ');
        CLD1015_Set_TEC_Temp(visObj, Tset)
        disp(['New temperature value: ', num2str(CLD1015_TEC_Qry_Tval(visObj))]);
    elseif action==2
        disp('Switch LDD On')
        CLD1015_Set_LDD_Status(visObj, 1);
        cldStatus = CLD1015_Status(visObj); % update the LDD status
    elseif action == 3
        disp('Switch LDD Off')
        CLD1015_Set_LDD_Status(visObj, 0);
        cldStatus = CLD1015_Status(visObj); % update the LDD status
    elseif action == 4
        disp('Change LDD current to some value within specified Bounds')
        disp('Low Current Bound: 0.0');
        disp(['High Current Bound: ', num2str(Ilimit)]);
        Iset = input('Desired Current Value: ');
        CLD1015_Set_LDD_Curr(visObj, cldStatus, Iset); 
        disp(['New Current Value: ', num2str(CLD1015_LDD_Qry_Ival(visObj))]);
        disp(['New Voltage Value: ', num2str(CLD1015_LDD_Qry_Vval(visObj))]);
    elseif action == 5
        disp('Reset LDD Current to Zero');
        CLD1015_Dialdown_LDD_Curr(visObj, cldStatus); 
    elseif action == 6
        disp('Power Sweep\n');
        Is = input('Input Current Start: ');
        If = input('Input Current End: ');
        Iinc= input('Input Current increment: ');
        % sweep the IV data
        swp_data = CLD1015_LDD_Sweep(visObj, cldStatus, Is, If, Iinc);
        if size(swp_data(1)) > 1 && size(swp_data(2)) > 1
            % make a plot of the IV data
            figure
            plot(swp_data(1), swp_data(2), 'g--o')
            xlabel('Current (mA)')
            ylabel('Voltage (V)')
        end
    elseif action == 7
        if include_power_meter
            % sweep can proceed
            disp('Power Sweep\n');
            Is = input('Input Current Start: ');
            If = input('Input Current End: ');
            Iinc= input('Input Current increment: ');
        else
            disp('Optical power sweep cannot proceed')
            disp('Thorlabs PM100D has not been initialised')
        end
    else
        action = input(prompt); % Takes you back to start of menu
    end
end

% STOP PATTERN:
dac4_pattern_stop( board );

%   Close VISA connection
disp ('Close VISA connection.');
fclose (visObj);
delete (visObj);
disp ('Connection closed successfully.');