% Iman Wahle 6/13/18
% train_main:
% Given directory of spectrograms and annotations, trains neural network
% to predict syllable instances. 
% In a file called <net name>_net.m, saves
%       net: neural net model
%       W: PCA weights
%       b: PCA mean
%       freq_scale: how much to downsample frequencies by


% what to name this neural net model when saving
net_name = input('Neural net name: ','s'); 

% load in training data from folder
% files should be named <id>_spectrogram.mat, <id>.annot

path = input('Training data folder path: ','s');
files = dir(strcat(path,'*_spectrogram.mat'));
mats = {}; annots = {};
for file=files.'
   % mat_name = strcat(path,file.name);
    mats{end+1} = strcat(path,file.name);
    annots{end+1} = strrep(strcat(path,file.name), '_spectrogram.mat', '.annot');
end

% setting constants
chunk_size = 24; % window size for a training example
red_size=60; % how many principle components to reduce to
mult=[0, .75,-.75]; % factors of noise to add to the psd
neg_scale = 3; % how many times more neg examples than pos examples
freq_scale = 1;


% load in spectrograms and process annotations
disp('Loading training data');
[data, labels] = load_data(mats,annots,1, freq_scale);

% sampling 1/10 of data and calculating PCA W and b with it
disp('Taking PCA sample');
pca_sample = [];
for i=1:size(data,2)
    fprintf('    Data set: %d\n',i);
    d = cell2mat(data(i)).'; 
    pca_part = zeros([size(1:10:size(d,2),2), size(d,1)*chunk_size]);
    % sample 1/10 of it and chunk
    disp(size(d,2));
    cnt = 1;
    for ind=1:10:size(d,2)
        [chunk_vec, chunk_l] = single_chunk(d,nan,ind,chunk_size, 0);
        pca_part(cnt,:) = chunk_vec.'; % putting each obs in a row
        cnt = cnt+1;
    end
    pca_sample = [pca_sample; pca_part];
end

disp('Calculating PCA W,b');
W = pca_red(pca_sample, red_size);
psd_chunk_pca = pca_sample*W;
b = mean(psd_chunk_pca); % subtracting out mean
psd_chunk_pca = bsxfun(@minus, psd_chunk_pca, b); 

% constructing training set with eqaual pos/neg examples, noise added,
% chunking, and PCA
disp('Formatting full data set');
allX = []; ally = [];
for i=1:size(data,2)    
    for scale=mult
        fprintf('     Data set: %d, noise scaled by: %d \n', i, scale);
        d = data{i}; % feats x obs
        % add noise and zscore again
        d = zscore(scale*randn(size(d)) + d).';
        y = labels{i}.'; % 1 x obs
        
        % taking pos/neg samples 
        pos = zeros(size(y));
        pos(y==1)=1;
        posind = find(pos);
        
        neg = zeros(size(y));
        neg(y==-1)=1;
        negind = find(neg);
        negindsample = datasample(negind, size(posind, 2)*neg_scale, 'Replace', false);
        
        inds = [posind negindsample];

        partX = zeros([size(inds,2), chunk_size*size(d,1)]);
        party = zeros([size(inds,2), 1]);
            
        % vectorizing chunked examples
        cnt = 1;
        for ind=inds
            [Xchunk, ychunk] = single_chunk(d, y, ind, chunk_size, 1);
            partX(cnt,:) = Xchunk;
            party(cnt,:) = ychunk;
            cnt = cnt+1;
            
        end

        % reduce to principle components
        partX = bsxfun(@minus, partX*W, b); 
        allX = [allX; partX];
        ally = [ally; party];
    end
end  

% training neural net (make sure Neural Network Toolbox is installed)
disp('Training neural net');
ally(ally==-1)=0;
net = patternnet([100,100]);
[net,tr] = train(net, allX.',ally.');
nntraintool
% save neural net in form as net, W, b.
disp('Training finished, saving neural net');
save(strcat(path, net_name, '_net.m'), 'net', 'W', 'b', 'freq_scale');
disp('Finished.');



