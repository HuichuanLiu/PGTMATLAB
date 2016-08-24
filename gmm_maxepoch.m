clear;
clc;
warning('off');

mydata = load('whole_data');
data = mydata.data;
cv_num = 5;
macc = zeros(20,1);
for i = 1:20
    split_data = data(3).s;
    [tr,te] = cross_validation(split_data.ldata,split_data.labels,cv_num);
    
    % cross validation
    cv_acc = zeros(cv_num,1);
    cv_entropy = zeros(cv_num,1);
    temp = gmm_m;
    
    for j = 1:cv_num
        trData = tr(j);
        teData = te(j);
        clear myGmm;
        myGmm = gmm_m;
        myGmm.train(trData.data,trData.labels,split_data.udata,i*100);
        %         myGmm.unsup_train(split_data.udata);
        [cv_acc(j),cv_entropy(j)]= myGmm.test(teData.data,teData.labels);
        i
        j
    end
    
    acc{i} = cv_acc;
    entropy{i}=cv_entropy;    
    macc(i) = mean(cv_acc);
end

eva_epoch = struct('acc',acc,'entropy',entropy);
save('eva_epoch','eva_epoch');
plot(macc);
