function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture
gmms = [];
folder_names = dir(dir_train);
for i = 1:length(folder_names)
    file_info = folder_names(i);
    if file_info.isdir == 1
        folder_name = file_info.name;
        if strcmp(folder_name, '.') || strcmp(folder_name, '..')
            continue;
        end
        new_struct = struct();
        new_struct.name = folder_name;
        data = [];
        file_names = dir(strcat(dir_train,folder_name));
        for j = 1:length(file_names)
            if findstr(file_names(j).name, 'mfcc')
                m = dlmread(strcat(dir_train, folder_name, '/', file_names(j).name));
                data = [data ; m];
            end
        end
        [weights, means, cov] = trainSpeaker(data, max_iter, epsilon, M);
        new_struct.weights = weights;
        new_struct.means = means;
        new_struct.cov = cov;
        gmms = [gmms new_struct];
        disp(strcat('finished', folder_name));
    end
end
end

function [weights, means, cov_ret] = trainSpeaker(data, max_iter, epsilon, M )

T = size(data, 1);
D = size(data, 2);

weights = ones(1, M) * 1/M;
% m by d
means = data(ceil(rand(1, M) * T), :);
cov = ones(M, D);
prev = -Inf;

% For each iteration
for i = 1:max_iter
    % Compute likelihood
    p = calculate_p(weights, means, cov, data);
    log_likelihood = sum(log(sum(p, 1)), 2);
    for t = 1:T
        sum_p = sum(p(:, t));
        p(:, t) = p(:, t) / sum_p;
    end
    
    % Update result
    for m = 1:M
        tmp_sum = sum(p(m, :));
        weights(m) = tmp_sum / T;
        t_sum = zeros(1, 14);
        for t = 1:T
            t_sum = t_sum + p(m, t) * data(t, :);
        end
        means(m, :) = t_sum / tmp_sum;
        tt_sum = zeros(1, 14);
        for t = 1:T
            tt_sum = tt_sum + p(m, t) * (data(t, :).^2);
        end
        cov(m, :) = tt_sum / tmp_sum - means(m, :).^2;
    end
    
    % Calculate improvement
    improvement = log_likelihood - prev;
    if improvement < epsilon
        break;
    end
    prev = log_likelihood;
end

means = means';
cov_ret = zeros(14, 14, M);
for m = 1:M
    cov_ret(:,:, m) = diag(cov(m,:));
end

end
                



