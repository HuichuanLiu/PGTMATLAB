clear;
m=logReg;
s = load('data_800.mat');
ldata = s.ldata;
udata = s.udata;
labels = s.labels;

%---------- cross-validation------------%






trdata = [1,2;2,2;0,1;1,0];
trlabels = [10;12;5;4];
m.initial(trdata);
m.train(trdata,trlabels);
[acc,entropy,py]=m.test(trdata,trlabels);