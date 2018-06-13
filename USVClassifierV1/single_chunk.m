
function [chunk_vec, chunk_l] = single_chunk(psd, y, frame, chunk_size, annotated)
    % inputs:
    %    psd: feats x frames spectrogram
    %    y: 1 x frames annotations of spectrogram
    %    frame: which frame to chunk
    %    chunk_size: width of chunk to take
    %    annotated: 1 of y has annotations, 0 otherwise.
    % single_chunk vectorizes a feat x chunk_size sized window centered
    % around the frame-th column in psd. It returns this vector, along with
    % its corresponding annotation (+1 if at least half the frames in 
    % the window are +1, -1 otherwise). 
    
    half = round(chunk_size/2); 
    num_freq = size(psd,1);
    chunk_l=-1;
    if (frame-half < 1) % left edge case
        pad_val = mean(psd(:,1));
        window = [pad_val*ones(num_freq,half-frame) psd(:,1:half+frame)];
        if annotated
            if (sum(y(:,1:frame+half)==1) >= half)
                chunk_l=1;
            end
        end
    elseif (frame+half > size(psd,2)) % right edge case
        pad_val = mean(psd(:,1));
        window = [psd(:,(frame-half:end)) pad_val*ones(num_freq, (frame+half)-size(psd,2)-1)];
        if annotated
            if (sum(y(:,frame-half:end)==1)>=half)
                chunk_l=1;
            end
        end
    else % generic case
        window = psd(:, (-1*half+1:half) + frame);
        if annotated
            if (sum(y(:,(-1*half+1:half)+frame)==1)>=half)
                chunk_l=1;
            end
        end
    end
    chunk_vec = reshape(window, num_freq*chunk_size ,1);
    if ~annotated
        chunk_l = nan;
    end
end