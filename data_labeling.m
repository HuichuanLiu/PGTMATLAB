function s = data_labeling(data)
%ldata = labeled data
%udata = unlabeled data
%labels = labels of ldata
%columne 1 of data must be the timestamp
%outputs do not contain timestamp anymore

label_num = 18;

scores = zeros(label_num,2);
scores(:,2) = [6 6.4 6 6 6 4.4 6.2 1.8 4.6 6.2 4.4 4.4 4.4 6 4.4 4.4 6 6]';


for i = 1:label_num
    scores(i,1) = data(1)-mod(data(1),86400000) + (i-1)*86400000;
end

time_start = scores(1,1);
time_end = scores(end,1);

udata = data( (data(:,1)<time_start)|(data(:,1)>time_end),: );
ldata = data( (data(:,1)>=time_start)&(data(:,1)<=time_end),: );
labels = zeros(size(ldata,1),1);

for i = 1:size(ldata,1)
    labels(i) = scores(ceil((ldata(i,1)-time_start)/86400000),2);
end
udata = udata(:,2:end);
ldata = ldata(:,2:end);

s = struct('udata',udata,'ldata',ldata,'labels',labels);

end