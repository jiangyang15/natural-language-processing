function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses
SE = 0;
IE = 0;
DE = 0;
num_words = 0;
hypothesis_lines = textread(hypothesis, '%s', 'delimiter', '\n');
N = length(hypothesis_lines);
for n = 1:N
    ref_file = textread([annotation_dir, filesep, 'unkn_', int2str(n), '.txt'], '%s', 'delimiter', '\n');
    ref_split = strsplit(ref_file{1},' ');
    ref_sentence = ref_split(3:end);
    num_words = num_words + length(ref_sentence);
    hypothesis_line = hypothesis_lines{n};
    hypothesis_split = strsplit(hypothesis_line, ' ');
    hypothesis_sentence = hypothesis_split(3:end);
    [new_se, new_ie, new_de] = leven(hypothesis_sentence, ref_sentence);
    SE = SE + new_se;
    IE = IE + new_ie;
    DE = DE + new_de;
    disp('-----')
    disp(strcat('ref:', strjoin(ref_sentence,' ')));
    disp(strcat('hypo:', strjoin(hypothesis_sentence,' ')));
    fprintf('se %f, ie %f, de %f \n', new_se/length(ref_sentence), new_ie/length(ref_sentence), new_de/length(ref_sentence));
end
SE = SE / num_words;
IE = IE / num_words;
DE = DE / num_words;
LEV_DIST = SE + IE + DE;
end

function [se, ie, de] = leven(hypothesis_sentence, ref_sentence)

n = length(hypothesis_sentence);
m = length(ref_sentence);
R = zeros(n+1, m+1);
B = zeros(n+1, m+1);

R(1, :) = Inf;
R(:, 1) = Inf;
R(1, 1) = 0;

for i = 2:n+1
    for j = 2:m+1
        sub = R(i-1,j-1)+1;
        if strcmp(ref_sentence{j-1}, hypothesis_sentence{i-1})
            sub = sub - 1;
        end
        insert = R(i, j-1) + 1;
        delete = R(i-1, j) + 1;
        min_number = min(sub, min(insert, delete));
        R(i, j) = min_number;
        if (min_number == sub) && strcmp(ref_sentence{j-1}, hypothesis_sentence{i-1})
            B(i, j) = 0;
        elseif (min_number == sub)
            B(i, j) = 1;
        elseif (min_number == insert)
            B(i, j) = 2;
        elseif (min_number == delete)
            B(i, j) = 3;
        end
    end
end
se = 0;
ie = 0;
de = 0;
i = n+1;
j = m+1;

while (i ~= 1) || (j ~= 1)
    if (B(i, j) == 0)
        i = i - 1;
        j = j - 1;
    elseif (B(i, j) == 1)
        i = i - 1;
        j = j - 1;
        se = se + 1;
    elseif (B(i, j) == 2)
        j = j - 1;
        ie = ie + 1;
    elseif (B(i, j) == 3)
        i = i - 1;
        de = de + 1;
    end
end

de = de + j - 1;
ie = ie + i - 1;
tmp = de;
de = ie;
ie = tmp;
end

