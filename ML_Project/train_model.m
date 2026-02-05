% Load dataset
data = readtable('ai4i2020.csv');

% Extract features and labels
features = [ ...
    data.ToolWear_min_, ...
    data.Torque_Nm_, ...
    data.AirTemperature_K_, ...
    data.ProcessTemperature_K_, ...
    data.RotationalSpeed_rpm_ ];

labels = data.MachineFailure;

% Normalize all features
features = zscore(features);

% Split the full dataset (no balancing)
cv = cvpartition(length(labels), 'HoldOut', 0.2);
X_train = features(training(cv), :);
Y_train = labels(training(cv));
X_test  = features(test(cv), :);
Y_test  = labels(test(cv));

% Use class weights to handle imbalance
class0 = sum(Y_train == 0);
class1 = sum(Y_train == 1);
totalSamples = length(Y_train);

w_train = zeros(size(Y_train));
w_train(Y_train == 0) = totalSamples / (2 * class0);
w_train(Y_train == 1) = totalSamples / (2 * class1);

% Train the ensemble model
Mdl = fitcensemble(X_train, Y_train, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 200, ...
    'Learners', templateTree('MaxNumSplits', 10), ...
    'Weights', w_train);

% Predict on test set (~2000 samples)
[Y_pred, scores] = predict(Mdl, X_test);

% Accuracy
accuracy = sum(Y_pred == Y_test) / numel(Y_test) * 100;
fprintf('Model Accuracy: %.2f%%\n', accuracy);

% Confusion matrix (should show ~2000 total now)
confusionchart(Y_test, Y_pred);

% ROC curve
[fpRate, tpRate, ~, AUC] = perfcurve(Y_test, scores(:,2), 1);
figure;
plot(fpRate, tpRate, 'b-', 'LineWidth', 2);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC Curve (AUC = ' num2str(AUC, '%.2f') ')']);
grid on;

% Save for GUI use
save('trained_model.mat', 'Mdl');
save('processed_data.mat', 'X_train', 'Y_train', 'X_test', 'Y_test');
