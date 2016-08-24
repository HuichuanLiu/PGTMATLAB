clear;
clc;

pSize = [800,400,300,200,150,50,10];
for i = 1:7
temp = load(['data_' int2str(pSize(i))]);
temp.s.pSize = pSize(i);
data(i) = temp;
end

save('whole_data','data');


