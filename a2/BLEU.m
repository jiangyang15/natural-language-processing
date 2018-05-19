function score = BLEU(ref, translation, order)
    translation = strsplit(' ', translation );
    for i=1:length(ref)
        ref{i} = strsplit(' ', ref{i} );
    end
    c = length(translation);
    nearestLength = c;
    nearestrefLength = c;
    for i=1:length(ref)
        len = length(ref{i});
        if nearestLength >= abs(c-len)
            nearestrefLength = len;
            nearestLength = abs(c-len);
        end
    end
    r = nearestrefLength;
    if (r < c)
        bpc = 1;
    else
        bpc = exp(1-double(r)/double(c));
    end
    pprod = 1;
    for o=1:order
        divisor = 0;
        for i=1:c-o+1
           wordsList = cell(o,0);
           for j=1:o
               wordsList(j) = translation(i+j-1);
           end
           for k=1:length(ref)
               contains = findstr(cell2mat(ref{k}), cell2mat(wordsList));
               if (~isempty(contains))
                   divisor = divisor + 1;
                   break;
               end
           end
        end
        p = double(divisor) / double(c-o+1);
        pprod = pprod * p;
    end
    score = bpc * pprod.^(1/double(order));
end