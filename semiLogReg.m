function [ model ] = semiLogReg(udata,ldata,labels,step_size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

m.initial(ldata);
m.train(ldata,labels);
py = m.f(udata);




end

