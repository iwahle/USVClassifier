
function y=fill_gaps(y,k)
    old = y;
    dy = y(2:end) - y(1:end-1);
    st = find(dy==-2);
    en = find(dy==2);
    for i=1:size(en,2)-1
%         disp('comparison');
%         disp(en(i+1));
%         disp(st(i));
        if en(i+1) - st(i) <= k
            %disp('filling');
            y(st(i):en(i+1))=1;
        end
    end
    %figure;imagesc([old; ones(size(old)); y]);
end