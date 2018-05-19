function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end
  
  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = cell(numSentences, 0);
  fre = cell(numSentences, 0);
  DD = dir( [ mydir, filesep, '*', 'e'] );
  num = 1;
  for iFile=1:length(DD)
    lines = textread([mydir, filesep, DD(iFile).name], '%s','delimiter','\n');
    for i=1:length(lines)
        eng{num} = strsplit(' ', preprocess(lines{i}, 'e'));
        num = num + 1;
        if (num > numSentences)
            break;
        end
    end
    if (num > numSentences)
        break;
    end
  end
  
  DD = dir( [ mydir, filesep, '*', 'f'] );
  num = 1;
  for iFile=1:length(DD)
    lines = textread([mydir, filesep, DD(iFile).name], '%s','delimiter','\n');
    for i=1:length(lines)
        fre{num} = strsplit(' ', preprocess(lines{i}, 'f'));
        num = num + 1;
        if (num > numSentences)
            break;
        end
    end
    if (num > numSentences)
        break;
    end
  end

  % TODO: your code goes here.
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = struct(); % AM.(english_word).(foreign_word)
    engToFreMap = struct();

    for l=1:length(eng)
        sec = unique(eng{l});
        for w=1:length(sec)
            eword = sec{w};
            if (~isfield(engToFreMap, eword))
                engToFreMap.(eword) = {};
            end
            engToFreMap.(eword) = unique([engToFreMap.(eword), fre{l}]);
        end
    end
    words = fieldnames(engToFreMap);
    for n=1:length(words)
        fwords = engToFreMap.(words{n});
        for fw=1:length(fwords)
            AM.(words{n}).(fwords{fw}) = 1.0 / length(fwords);
        end
    end
    
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  tcount = struct();
  total = struct();
  % TODO: your code goes here
  for l=1:length(eng)
      frenchwordList=unique(fre{l});
      englishwordList=unique(eng{l});
      for i=1:length(frenchwordList)
          fword = frenchwordList{i};
          fwordcount = sum(ismember(fre{l}, fword));
          denom_c = 0;
          for j=1:length(englishwordList)
              denom_c = denom_c + t.(englishwordList{j}).(fword) * fwordcount;
          end
          for j=1:length(englishwordList)
              eword = englishwordList{j};
              ewordcount = sum(ismember(eng{l}, eword));
              if (~isfield(tcount, eword))
                  tcount.(eword).(fword) = 0;
              elseif (~isfield(tcount.(eword), fword))
                  tcount.(eword).(fword) = 0;
              end
              tcount.(eword).(fword) = tcount.(eword).(fword) + t.(eword).(fword) * fwordcount * ewordcount / denom_c;
              
              if (~isfield(total, eword))
                  total.(eword) = 0;
              end
              total.(eword) = total.(eword) + t.(eword).(fword) * fwordcount * ewordcount / denom_c;
          end
      end
  end
  
  ewordList = fieldnames(total);
  for i=1:length(ewordList)
      eword = ewordList{i};
      fwordList = fieldnames(tcount.(eword));
      for j=1:length(fwordList)
          fword = fwordList{j};
          t.(eword).(fword) = tcount.(eword).(fword) / total.(eword);
      end
  end
end


