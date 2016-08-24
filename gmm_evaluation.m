clear;
clc;
warning('OFF');

mydata = load('whole_data');
data = mydata.data;
cv_num = 5;

results = struct('cv_acc',[],'cv_entropy',[],'models',[],'pSize',[]);

% applying data patches with different split window: pSize = [10,50,150,200,300,400,800];
for i = 1:size(data,2)
    split_data = data(i).s; 
    [tr,te] = cross_validation(split_data.ldata,split_data.labels,cv_num);
    
    % cross validation
    cv_acc = zeros(cv_num,1);
    cv_entropy = zeros(cv_num,1);
    temp = gmm_m;
    cv_modedls = [temp];
    
    for j = 1:cv_num
        trData = tr(j);
        teData = te(j);
        clear myGmm;
        myGmm = gmm_m;
        myGmm.train(trData.data,trData.labels,split_data.udata);
%         myGmm.unsup_train(split_data.udata);        
        [cv_acc(j),cv_entropy(j)]= myGmm.test(teData.data,teData.labels);
        cv_model(j) = myGmm;
        i
        j
        ma = mean(cv_acc);
    end
    
    result{i}.cv_acc = cv_acc;
    result{i}.entropy = cv_entropy;
    result{i}.models = cv_model;
    result{i}.pSize = split_data.pSize;
end

save('gmm_eva','result');