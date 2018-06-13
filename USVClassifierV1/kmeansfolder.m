function [idx, C, X,num_feats] = kmeansfolder(folder_path, k)
    %folder_path = path to folder with classifications in it
    % k = num clusters
    
    
    % constants
    std_width = 50;
    
    X = []; % fill with syllables in vector form
    % compile syllables from all files in folder
    count = 0;
    files = dir(strcat(folder_path,'*classification.mat'));
    for file =files'
        % only want to do five files right now
%         count = count + 1;
%         if count > 1 
%             break;
%         end
        
        disp(file.name);
        % unpack file
        f = load(strcat(folder_path,file.name));
        psd = f.X_test;
        labels = f.predY;
        labels(labels>.5)=1;
        labels(labels<=.5)=-1;
        labels=fill_gaps(labels,3);
        labels=syl_filter(labels,3);
        num_feats=size(psd,1);

        % calculate start times and end times
        dy = labels(2:end) - labels(1:end-1);
        st = find(dy==2) + 1; % offset by one to get first frame in syl
        en = find(dy==-2);

        % iterate through syllables to resize and vectorize
        disp(size(st));
        for i=1:min(size(st,2),size(en,2))
            % current syllable:
            x = psd(:,st(1,i):en(1,i));
            % downsample syllable
            x = imresize(x, [round(num_feats)/2 round(size(x,2)/2)]);
            % center syllable:
            x = center_syllables(x,std_width);
            % put scaled syllables into vector format
            x = reshape(x, 1, size(x,1)*size(x,2));
            % add syllable to dataset
            X = [X; x];
        end
    end
    
    
    disp('Clustering');
    % kmeans cluster
    [idx,C] = kmeans(X,k,'Distance','cosine');
    
    % display repertoire
    figure;
    for i=1:size(C,1)
        subplot(5,ceil(k/5),i)
        imagesc(reshape(C(i,:),[round(num_feats/2) std_width]));
    end
    
    % display cluster distribution
    for i=1:k
        fprintf('Cluster#: ');
        fprintf('%d',i);
        fprintf(' #syllables: ');
        fprintf('%d\n',sum(idx==i));
    end
    %save('clusterdatacosine.m','idx','C','X','num_feats');
end
% path to current classifications: 
% 'Z:\Tomomi\Behavior videos\180305- caltech WT\180305 Caltech WT batch1 naive\'

% things to try: 
% changing the standardized width
% different distance measures for clustering - mupet uses cosine to avoid
% grouping dependent on magnitude
% mediod clustering to avoid blurring
% more syllables
% padding and centering instead of scaling width
% debug padding at the beginning from chunking