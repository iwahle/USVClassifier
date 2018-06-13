% Iman Wahle 6/13/18
% predict_main
% Given a directory of spectrograms and a neural net (saved in the format
% produced by train_main), predict_main will generate syllable
% classifications for each frame and save in a
% <spectrogram>_classification.m file. 

% loading neural net to predict with, should be in format returned
% by train_main
mdlfile = input('Path to classifier model file: ','s');
n = importdata(mdlfile);
net = n.net; W = n.W; b = n.b; freq_scale = n.freq_scale;

% loading spectrograms to classify
% directory should contain spectrograms named in the format
% <spectrogram_name>_spectrogram.m
path = input('Path to directory containing spectrograms: ','s');
files = dir(strcat(path,'\*_spectrogram.mat'));

mats = {};
for file=files.'
    mats{end+1} = strcat(path, file.name);
end

disp('Loading test data');
[data,labels] = load_data(mats, nan, 0, freq_scale);

disp('Formatting test data');
allX = {};
for i=1:size(data,2)
    fprintf('    Data set: %d\n',i);
    d = data{i}.'; % feats x obs
    partX = zeros([size(d,2),chunk_size*size(d,1)]);
    
    % vectorizing chunked examples
    for ind=1:size(d,2)
        [Xchunk, ~] = single_chunk(d, nan, ind, chunk_size, 0);
        partX(ind,:) = Xchunk;
    end

    % reduce to principle components
    partX = bsxfun(@minus, partX*W, b);
    allX{end+1} = partX;
end

% generate predictions
disp('Generating predictions');
preds = {};
for i=1:size(allX,2)
    preds{end+1} = net(allX{i}.');
end

% displaying predictions
disp('Displaying predicted probabilities');
for i=1:size(preds,2)
    figure;imagesc([data{i}.'; preds{i}; preds{i}; preds{i}]);
end

% binary prediction constants:
threshhold = 0.5;   % cutoff between pos and neg instances
fill_constant = 3;  % if pos instances are only this far apart, fill
                    % between them with positive as well
cut_constant = 3;   % if pos sections are less than this long, make them neg

% generating binary predictions
disp('Generating binary predictions');
bin_preds = {};
for i=1:size(preds,2)
    pred = preds{i};
    pred(pred>=threshhold) = 1;
    pred(pred<threshhold) = -1;
    pred = fill_gaps(pred, fill_constant);
    pred = syl_filter(pred, cut_constant);
    bin_preds{end+1} = pred;
end

% displaying predicted positive syllables
disp('Displaying predicted positive syllable instances');
for i=1:size(preds,2)
    disp_syls(data{i}.',bin_preds{i});
end

% save classifications
disp('Saving classifications');
for i=1:size(mats,2)
    file_name = strrep(mats{i}, '_spectrogram', '_classification');
    prob_pred = preds{i};
    bin_pred = bin_preds{i};
    save(file_name, 'prob_pred', 'bin_pred');
end
disp('Finished.');




