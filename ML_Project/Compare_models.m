% Load and prepare the data
data = readtable('ai4i2020.csv');

features = [ ...
    data.ToolWear_min_, ...
    data.Torque_Nm_, ...
    data.AirTemperature_K_, ...
    data.ProcessTemperature_K_, ...
    data.RotationalSpeed_rpm_ ];

labels = data.MachineFailure;

% Split into training/testing sets
cv = cvpartition(height(data), 'HoldOut', 0.2);
X_train = features(training(cv), :);
Y_train = labels(training(cv));
X_test = features(test(cv), :);
Y_test = labels(test(cv));

% Fix class imbalance using weights
classCounts = groupcounts(Y_train);
classWeights = [1, classCounts(1)/classCounts(2)];
weights = classWeights(Y_train + 1);  % Apply to train only

% 1. Decision Tree
tree = fitctree(X_train, Y_train, 'Weights', weights);
pred_tree = predict(tree, X_test);
acc_tree = sum(pred_tree == Y_test) / numel(Y_test) * 100;

% 2. k-NN (k=5)
knn = fitcknn(X_train, Y_train, 'NumNeighbors', 5, 'Distance', 'euclidean');
pred_knn = predict(knn, X_test);
acc_knn = sum(pred_knn == Y_test) / numel(Y_test) * 100;

% 3. SVM
svm = fitcsvm(X_train, Y_train, 'KernelFunction', 'rbf', ...
    'ClassNames', [0 1], 'Weights', weights);
pred_svm = predict(svm, X_test);
acc_svm = sum(pred_svm == Y_test) / numel(Y_test) * 100;

% 4. Ensemble (Bagged Trees)
ens = fitcensemble(X_train, Y_train, 'Method', 'Bag', ...
    'ClassNames', [0 1], 'Weights', weights);
pred_ens = predict(ens, X_test);
acc_ens = sum(pred_ens == Y_test) / numel(Y_test) * 100;

% Display accuracies
fprintf('\nModel Accuracies:\n');
fprintf('Decision Tree:     %.2f%%\n', acc_tree);
fprintf('k-NN:              %.2f%%\n', acc_knn);
fprintf('SVM:               %.2f%%\n', acc_svm);
fprintf('Ensemble (Bagged): %.2f%%\n', acc_ens);

% Plot confusion matrix for each
figure;
subplot(2,2,1); confusionchart(Y_test, pred_tree); title('Decision Tree');
subplot(2,2,2); confusionchart(Y_test, pred_knn); title('k-NN');
subplot(2,2,3); confusionchart(Y_test, pred_svm); title('SVM');
subplot(2,2,4); confusionchart(Y_test, pred_ens); title('Ensemble');
