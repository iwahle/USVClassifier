function y = syl_filter(y,k)
    % filters out syllables shorter than k frames
    % does not filter if k = 0
    if k==0
        return
    end
    for i=1:k
        c = consecutive_ones(y);
        y(c<k & c>0)=-1;
    end
end
    