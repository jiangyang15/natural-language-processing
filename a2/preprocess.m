function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');
  outSentence = regexprep( outSentence, '([\.\!\?\,])', ' $1 ');
  outSentence = regexprep( outSentence, '([:;\(\)\-\+<>\=])', ' $1 ');

  switch language
   case 'e'
    % TODO: your code here
    outSentence = regexprep( outSentence, '''s', ' ''s ');
    outSentence = regexprep( outSentence, 's''', 's '' ');

   case 'f'
    % TODO: your code here
    % Singular definite article
    outSentence = regexprep( outSentence, 'l''', 'l'' ');
    
    % Single-consonant words
    outSentence = regexprep( outSentence, 't''', 't'' ');
    outSentence = regexprep( outSentence, 'j''', 'j'' ');
    outSentence = regexprep( outSentence, 'c''', 'c'' ');
    
    % que
    outSentence = regexprep( outSentence, 'qu''', 'qu'' ');
    
    % Conjunctions puisque and lorsque
    outSentence = regexprep( outSentence, 'puisqu''on', 'puisqu'' on');
    outSentence = regexprep( outSentence, 'lorsqu''il', 'lorsqu'' il');
    outSentence = regexprep( outSentence, 'puisqu''il', 'puisqu'' il');
    outSentence = regexprep( outSentence, 'lorsqu''on', 'lorsqu'' on');

  end
  
  outSentence = regexprep( outSentence, '\s+', ' '); 
  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

