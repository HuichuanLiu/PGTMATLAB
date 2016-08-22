function [ samples ] = cross_validation(data,labels,sample_num)
%CROSS-VALIDATION Summary of this function goes here
%   Detailed explanation goes here

smpl = sampler(data,labels);
smpl = smpl.randomize;

[tr,te] = smpl.split(1,sample_num);  

for i =2:sample_num
    [tr(i),te(i)] = smpl.split(i,sample_num);  
end

samples = struct('train',tr,'test',te);
end

