
function [chunk_vec, chunk_l] = single_chunk(psd, y, frame, chunk_size, annotated)
    half = round(chunk_size/2); 
    num_freq = size(psd,1);
    %chunk_l=-1;
    if (frame-half < 1) % left edge case
        pad_val = mean(psd(:,1));
        window = [pad_val*ones(num_freq,half-frame) psd(:,1:half+frame)];
%         if annotated
%             if (sum(y(:,1:frame+half)==1) >= half)
%                 chunk_l=1;
%             end
%         end
    elseif (frame+half > size(psd,2)) % right edge case
        pad_val = mean(psd(:,1));
        window = [psd(:,(frame-half:end)) pad_val*ones(num_freq, (frame+half)-size(psd,2)-1)];
%         if annotated
%             if (sum(y(:,frame-half:end)==1)>=half)
%                 chunk_l=1;
%             end
%         end
    else % generic case
        window = psd(:, (-1*half+1:half) + frame);
%         if annotated
%             if (sum(y(:,(-1*half+1:half)+frame)==1)>=half)
%                 chunk_l=1;
%             end
%         end
    end
    chunk_vec = [psd(:,frame); mean(window,2); std(window,0,2)];
        
    %chunk_vec = reshape(window, num_freq*chunk_size ,1);
    if ~annotated
        chunk_l = nan;
    else
        chunk_l = y(:,frame);
    end
end