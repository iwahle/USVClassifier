function labels = process_labels(annot_file, mat_file, fr)
    disp('    Processing Labels');
    
    prec = .001024;
    label_data = importdata(annot_file);
    % scaling frame data
    if fr == 513
        scale = 1;
    elseif fr == 257 
        scale = 2*1000/1024;
    end
    start_frames = round(scale*label_data.data(:,[1]));
    end_frames = round(scale*label_data.data(:,[2]));
    
    % converting start/end frames to start/end times
    mat = load(mat_file);
    start_times = mat.t(start_frames);
    end_times = mat.t(end_frames);

    
    % denoting vocalization times with 1's
    labels(1:length(mat.t), 1:1) = -1; % = zeros([length(mat.t) 1]);
    labels(round(start_times/prec):round(end_times/prec)) = 1;
    for i=1:length(start_times)
        labels(round(start_times(i)/prec):round(end_times(i)/prec)) = 1;
    end

 
end


