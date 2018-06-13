function out = consecutive_ones(y)
    A = y;
    A(A==-1)=0;
    out = double(diff([~A(1);A(:)]) == 1);
    v = accumarray(cumsum(out).*A(:)+1,1);
    out(out == 1) = v(2:end);
end