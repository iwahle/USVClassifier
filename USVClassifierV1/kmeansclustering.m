function[idx,C,X,num_feats] = kmeansclustering(psd, labels, k)
    % input:
    %   syllable spectrogram: each row is a feature, each column is a frame
    %   labels: 1=syl, -1=not-syl. 1xnum_frames
    %   k = number of clusters
    
    
    % constants
    std_width = 100;
    num_feats=size(psd,1);
    
    % calculate start times and end times
    dy = labels(2:end) - labels(1:end-1);
    st = find(dy==2) + 1; % offset by one to get first frame in syl
    en = find(dy==-2);
    
    % iterate through syllables to resize and vectorize
    X = []; % fill with clustering data
    disp(size(st));
    for i=1:min(size(st,2),size(en,2))
        % current syllable:
        x = psd(:,st(1,i):en(1,i));
%         % scale syllables to be the same number of frames
%         x = imresize(x, [num_feats std_width]);
        % center syllable:
        x = center_syllables(x,std_width);
        % put scaled syllables into vector format
        x = reshape(x, 1, size(x,1)*size(x,2));
        % add syllable to dataset
        X = [X; x];
    end
    disp('Clustering');
    % kmeans cluster
    [idx,C] = kmeans(X,k,'Distance','cosine');
    
    figure;
    for i=1:size(C,1)
        subplot(5,ceil(k/5),i)
        imagesc(reshape(C(i,:),[num_feats std_width]));
    end
    
    % display cluster distribution
    for i=1:k
        fprintf('Cluster#: ');
        fprintf('%d',i);
        fprintf(' #syllables: ');
        fprintf('%d\n',sum(idx==i));
end


 