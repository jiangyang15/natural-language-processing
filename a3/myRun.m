% myRun.m

% This script is to test trained phonemes HMM on test data, to get the
% accuracy of trained model. The script does the following things:

% 1. Load all phones and mfcc file for all test utterance
% 2. Apply HMM model to calculate likelihood
% 3. Find the most likely phoneme and compare with the correct result.

dir_test    = '/u/cs401/speechdata/Testing';
dir_hmm     = './hmm';
dir_bnt    = '/u/cs401/A3_ASR/code/FullBNT-1.0.7';

phn_files = dir([dir_test, filesep, '*.phn']);
mfcc_files = dir([dir_test, filesep, '*.mfcc']);
N = length(phn_files);

correct = 0;
total = 0;

for i=1:N
    phn_file = phn_files(i).name;
    mfcc_file = mfcc_files(i).name;
    
    mfcc_data = dlmread(strcat(dir_test, filesep, mfcc_file));
    mfcc_N = size(mfcc_data, 1);
    
    phn_data = textread([dir_test, filesep, phn_file], '%s', 'delimiter', '\n');
    phn_N = length(phn_data);
    
    total = total + phn_N;

    for j=1:phn_N
        phn_lines  = strsplit(phn_data{j}, ' ');
        phn_start = str2num(phn_lines{1});
        phn_start = (phn_start / 128) + 1;
        phn_end   = str2num(phn_lines{2});
        phn_end   = min(phn_end / 128, mfcc_N);
        phoneme       = phn_lines{3};
        if strcmp(phoneme, 'h#')
            phoneme = 'sil';
        end
            
        mfcc_range = mfcc_data(phn_start:phn_end, :);
        trained_hmms = dir([dir_hmm, filesep]);
        trained_hmms = trained_hmms(3:end); % Skip . and ..
        N_hmms = length(trained_hmms);
        
        max_prob = -Inf;
        found_phn = '';
        
        for k=1:N_hmms
            curr_hmm_name = trained_hmms(k).name;
            load([dir_hmm, filesep, curr_hmm_name], 'HMM', '-mat');
            
            data = mfcc_range';
            addpath(genpath(dir_bnt));
            cur_prob = loglikHMM(HMM, data);
            rmpath(genpath(dir_bnt));

            if cur_prob > max_prob
                max_prob  = cur_prob;
                found_phn = curr_hmm_name(5:end);
            end
        end
        if strcmp(phoneme, found_phn)
            correct = correct + 1;
        end
    end
end
disp('Accuracy:')
disp(correct / total)