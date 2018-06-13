function [data,labels] = load_data(mats,annots, annotated, freq_scale)
    % constants
    f1 = freq_scale*30; % low frequency cutoff
    f2 = freq_scale*100; % high frequency cutoff
    freq_range = freq_scale*128;

    data = {}; labels = {}; 

    for i=1:size(mats,2)
    mat = char(mats(i)); 
    disp(strcat('    new file being loaded:  ',mat));

    if annotated
        annot = char(annots(i));
    else
        annot = NaN;
    end
    d = load(mat);
    d = d.psd;
    rate = size(d,1);
    if annotated
        l = process_labels(annot, mat, rate);

        % trimming down psd and labels to start at first pos label
        % and end at last pos label
        firstlast = l;
        firstlast(firstlast~=1)=0;
        first = find(firstlast, 1, 'first');
        last = find(firstlast, 1, 'last');
        d = d(:,first:last);
        l = l(first:last,:);
    end
    disp('    normalizing spectrogram');
    d = zscore(d.').';
    disp('    resizing freqs');
    d = imresize(d, [freq_range+1 size(d,2)]); 
    d = d(f1:f2, :).';


        
       
%         if strcmp(mat, 'short/Mouse464_2018-02-10_19-46-03_0000113_spectrogram.mat')==1
%             % we only annotated the first part of this file, so have
%             % to cut the rest out
%             d = d(1:120000,:);
%             l = labels{i};
%             labels{i} = l(1:120000,:);
%             fprintf('    cutdown psd and labels to size: %d, %d\n', size(d),size(cell2mat(labels(i))));
%         end
    data{i} = d;
    labels{i} = l;
    end
    disp('    done');
    end
