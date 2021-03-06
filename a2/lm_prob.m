function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);
      
  % TODO: the student implements the following
  
  for w=1:length(words)-1
      word1 = words{w};
      word2 = words{w+1};
      
      if (~isfield(LM.bi, word1))
          divident = 0;
      elseif (~isfield(LM.bi.(word1), word2))
          divident = 0;
      else
          divident = LM.bi.(word1).(word2);
      end
      
      if (~isfield(LM.uni, word1))
          divisor = 0;
      else
          divisor = LM.uni.(word1);
      end
      if (divisor == 0)
          logProb = -Inf;
          return
      end
      if w == 1
          logProb = 0;
      end
      logProb = logProb + log2(double(divident+delta)/double(divisor+delta*vocabSize));
  end
  
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return