% Create new Simulink model
modelName = 'SplitPhase_SPS_NoScope';
new_system(modelName);
open_system(modelName);

% Add AC Voltage Source (Specialized Power Systems)
add_block('powerlib/Power Sources/AC Voltage Source', ...
    [modelName '/AC Source'], ...
    'Position', [50 100 130 150]);

% Add Split Phase Induction Motor (Specialized Power Systems)
add_block('powerlib/Machines/Split Phase Induction Motor', ...
    [modelName '/Split Phase Motor'], ...
    'Position', [200 80 350 180]);

% Add Machine Measurement Demux
add_block('powerlib/Measurements/Machine Measurement Demux', ...
    [modelName '/Meas Demux'], ...
    'Position', [370 100 450 200]);

% Add Display Blocks (Speed, Current, Torque)
add_block('simulink/Sinks/Display', [modelName '/Speed Display'], ...
    'Position', [500 80 550 100]);
add_block('simulink/Sinks/Display', [modelName '/Current Display'], ...
    'Position', [500 130 550 150]);
add_block('simulink/Sinks/Display', [modelName '/Torque Display'], ...
    'Position', [500 180 550 200]);

% Add To Workspace Blocks
add_block('simulink/Sinks/To Workspace', [modelName '/Speed Out'], ...
    'VariableName', 'motor_speed', ...
    'SaveFormat', 'StructureWithTime', ...
    'Position', [600 80 650 100]);

add_block('simulink/Sinks/To Workspace', [modelName '/Current Out'], ...
    'VariableName', 'motor_current', ...
    'SaveFormat', 'StructureWithTime', ...
    'Position', [600 130 650 150]);

add_block('simulink/Sinks/To Workspace', [modelName '/Torque Out'], ...
    'VariableName', 'motor_torque', ...
    'SaveFormat', 'StructureWithTime', ...
    'Position', [600 180 650 200]);

% Add Powergui block
add_block('powerlib/Powergui', [modelName '/Powergui'], ...
    'Position', [50 250 150 280]);

% Connect blocks
add_line(modelName, 'AC Source/1', 'Split Phase Motor/1');
add_line(modelName, 'AC Source/2', 'Split Phase Motor/2');
add_line(modelName, 'Split Phase Motor/1', 'Meas Demux/1');

add_line(modelName, 'Meas Demux/1', 'Speed Display/1');
add_line(modelName, 'Meas Demux/1', 'Speed Out/1');

add_line(modelName, 'Meas Demux/2', 'Current Display/1');
add_line(modelName, 'Meas Demux/2', 'Current Out/1');

add_line(modelName, 'Meas Demux/3', 'Torque Display/1');
add_line(modelName, 'Meas Demux/3', 'Torque Out/1');

% Set simulation configuration
set_param(modelName, 'Solver', 'ode23tb');
set_param(modelName, 'StopTime', '2');

% Done
open_system(modelName);
disp('✅ Simulink SPS model created. Click RUN to simulate.');
