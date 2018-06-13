
function [prec, rec, f1] = prec_rec(computed, truth)%, title_label)
    %precision and recall
    %precision = relevant retrieved /retrieved 
    %recall = relevant retrieved / relevant total
    %relevant retrieved = sum(bin_auto & bin_manual)
    %retrieved = sum(bin_auto)
    %relevant total = sum(bin_manual)
    computed(computed==-1)=0;
    truth(truth==-1)=0;
    comp = computed & truth;
    rel_ret = sum(comp==1);
    ret_tot = sum(computed==1);
    rel_tot = sum(truth==1);
    prec = 100*rel_ret/ret_tot;
    rec = 100*rel_ret/rel_tot;
%     fprintf('Precision (percent): %d\n', prec);
%     fprintf('Recall (percent): %d\n', rec);
    f1 = 2*prec*rec/(prec+rec);
%     fprintf('f1 score: %d\n', f1);
    %figure;imagesc([computed truth]');title(title_label);
end
