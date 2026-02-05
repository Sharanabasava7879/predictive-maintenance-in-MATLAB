
% preprocess_data.m

% Step 1: Load dataset
data = readtable('ai4i2020.csv');

% Step 2: Use actual column names based on what MATLAB showed
features = data{:, {'AirTemperature_K_', 'ProcessTemperature_K_', ...
    'RotationalSpeed_rpm_', 'Torque_Nm_', 'ToolWear_min_'}};

labels = data.MachineFailure;  % This is your target variable

% Step 3: Normalize features using z-score
features = zscore(features);

% Step 4: Split into 80% training and 20% testing
cv = cvpartition(size(features, 1), 'HoldOut', 0.2);
X_train = features(training(cv), :);
Y_train = labels(training(cv), :);
X_test  = features(test(cv), :);
Y_test  = labels(test(cv), :);

% Step 5: Save processed data to use in training
save('processed_data.mat', 'X_train', 'Y_train', 'X_test', 'Y_test');
disp('✅ Data preprocessed and saved successfully.');
