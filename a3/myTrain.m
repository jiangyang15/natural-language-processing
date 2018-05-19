% myTrain.m

% This is the script to train all phones found in train folder, independent
% of different speakers. The script do the following things

% 1. Prepare a struct to hold all phones matrix
% 2. Invoke HMM trainer to train the data for each phones
% 3. Write model to file

dir_train   = '/u/cs401/speechdata/Testing';
bnt_path    = '/u/cs401/A3_ASR/code/FullBNT-1.0.7';
output_file = './hmm';

M           = 8;
Q           = 3;
initType    = 'kmeans';
max_iter    = 15;

speakers = dir([dir_train, filesep]);
speakers = speakers(3:end);
N = length(speakers);

% Prepare a struct to feed into HMM trainer
% The struct is:
% phoneme_struct.(phoneme) = cell(N, mfcc_data)

phoneme_struct = struct();

for i=1:N
    speaker = speakers(i).name;
    dir_speaker = [dir_train, filesep, speaker];
    
    sounds = dir([dir_speaker, filesep, '*.mfcc']);
    phones = dir([dir_speaker, filesep, '*.phn']);
    sounds_N = length(sounds);
    
    for j=1:sounds_N
        mfcc = load([dir_speaker, filesep, sounds(j).name]);
        mfcc_N = size(mfcc, 1);
        phn = textread([dir_speaker, filesep, phones(j).name], '%s', 'delimiter', '\n');
        phn_N = length(phn);
        for k=1:phn_N
            phn_lines  = strsplit(phn{k}, ' ');
            phn_start = str2num(phn_lines{1});
            phn_start = (phn_start / 128) + 1;
            phn_end   = str2num(phn_lines{2});
            phn_end   = min(phn_end / 128, mfcc_N);
            
            phoneme       = phn_lines{3};
            if strcmp(phoneme, 'h#')
                phoneme = 'sil';
            end
            
            mfcc_range = mfcc(phn_start:phn_end, :);
            if ~isfield(phoneme_struct, phoneme)
                phoneme_struct.(phoneme) = cell(0);
            end
            num_phn_sequences = length(phoneme_struct.(phoneme));
            phoneme_struct.(phoneme){num_phn_sequences + 1} = mfcc_range';
        end
    end
end

% Invoke HMM trainer to train the data
addpath(genpath(bnt_path));

phn_train = fields(phoneme_struct);
phn_N = length(phn_train);
for i_phn=1:phn_N
    phn = phn_train{i_phn};
    data = phoneme_struct.(phn);
    
    HMM = initHMM(data, M, Q, initType);
    [HMM, LL] = trainHMM(HMM, data, max_iter);
    
    % Save model to file for future use
    save([output_file, filesep, 'hmm_', phn], 'HMM', '-mat');
end

rmpath(genpath(bnt_path));