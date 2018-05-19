% gmmClassfiy.m

% This script is used to test all unknown utterance, to identify the 
% correct speaker. The script did the following things:

% 1. For all the test utterance, load mfcc data
% 2. Based on mfcc data, calculate all likelihood on all trained speakers.
% 3. Find the top 5 potential speakers and write to file.

test_folder = '/u/cs401/speechdata/Testing';


S = size(gmms, 2);
file_names = dir(test_folder);

for i = 1:length(file_names)
    filename = file_names(i).name;
    if findstr(filename, 'mfcc')
        dot_idx = strfind(filename, '.');
        output_filename = strcat(filename(1:dot_idx), 'lik');
        data = dlmread(strcat(test_folder, filename));
        disp('testing ');
        disp(filename);
        T = size(data, 1);
        D = size(data, 2);
        l = zeros(1, S);
        for j = 1:S
            % Preparation
            M = size(gmms(j).cov, 3);
            cov = zeros(M, D);
            for m=1:M
                cov(m,:) = diag(gmms(j).cov(:,:,m));
            end
            % Calculate log likelihood
            p = calculate_p(gmms(j).weights, gmms(j).means', cov, data);
            l(j) = sum(log(sum(p, 1)), 2);
        end
        % Sort on the result to find top five
        [like, idx] = sort(l);
        idx = fliplr(idx);
        % Write result to file
        fp = fopen(strcat('part2_results/', output_filename), 'w');
        for k = 1:5
            fprintf(fp, '%s ', gmms(idx(k)).name);
        end
        fclose(fp);
    end
end
        