function disp_syls(X,y)
    % find starts and ends of syllables, locations stored in st, en
    dy = y(2:end) - y(1:end-1);
    st = find(dy==2) + 1; % offset by one to get first frame in syl
    en = find(dy==-2);
    fprintf('Number of positive syllables: %d\n',size(en,2));
    if size(en,2)<1
        disp('No syllables in this dataset');
        return
    end
    % now we can plot all of our positive syllables to see how it looks
    Xpos = 5*ones(size(X,1),1);
    if st(1,1) < en(1,1)
        for i=1:min(size(st,2), size(en,2))
            Xpos = [Xpos X(:,st(i):en(i)) 5*ones(size(X,1),1)];
        end
    else
        for i=1:min(size(st,2), size(en,2))
            Xpos = [Xpos X(:,en(i):st(i))];
        end 
    end
    figure;imagesc(Xpos);
end