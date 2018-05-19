%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = 'engLM.mat';
fn_LMF       = 'freLM.mat';
lm_type      = '';
delta        = 0.5;
numSentences = 1000;

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
AMFE1k = align_ibm1( trainDir, numSentences, 20, 'am.mat');
AMFE10k = align_ibm1( trainDir, numSentences*10, 20, 'am10k.mat');
AMFE15k = align_ibm1( trainDir, numSentences*15, 20, 'am15k.mat');
AMFE30k = align_ibm1( trainDir, numSentences*30, 20, 'am30k.mat');

AMFE = {AMFE1k, AMFE10k, AMFE15k, AMFE30k};
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  
reference1 = cell(25, 0);
num = 1;
lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e', '%s','delimiter','\n');
for l=1:length(lines)
    sentence = preprocess(lines{l}, 'e');
    reference1{num} = sentence;
    num = num + 1;
end

reference2 = cell(25, 0);
num = 1;
lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e', '%s','delimiter','\n');
for l=1:length(lines)
    sentence = preprocess(lines{l}, 'e');
    reference2{num} = sentence;
    num = num + 1;
end

testingFrench = cell(25, 0);
num = 1;
lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f', '%s','delimiter','\n');
for l=1:length(lines)
    testingFrench{num} = preprocess(lines{l}, 'f');
    num = num + 1;
end
    
for i=1:4
    AMFETest = AMFE{i};
    score = zeros(length(testingFrench), 3);
    for l=1:length(testingFrench)
        translation = decode2( testingFrench{l}, LME, AMFETest, lm_type)
        score(l,1) = BLEU({reference1{l}, reference2{l}}, translation, 1);
        score(l,2) = BLEU({reference1{l}, reference2{l}}, translation, 2);
        score(l,3) = BLEU({reference1{l}, reference2{l}}, translation, 3);
    end
    score
end

[status, result] = unix('')