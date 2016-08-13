function [accsCell,linear_accsCell] = rule_base_filter
%RULE_BASE_FILTER Summary of this function goes here
%   execute the rule base selection
% accs = load('accsCell_P04');
% accs = struct2cell(accs);
% accs = accs{1};
% accs2linearaccs(accs);
% phone-state-base rules
calls_periods = search_calls('P04');
%screen_on_periods = search_screens('P04');
screen_on_periods = search_screen_on('P04');
% merge valid periods
periods = merge_periods(calls_periods,screen_on_periods);

[~,accsCell] = get_accs(periods,'P04');
[linear_accsCell] = accs2linearaccs(accsCell);

%save('accs_P04','accs');
save('accsCell_P04','accsCell');
save('linear_accsCell_P04','linear_accsCell');
end

function [periods] = search_calls(patient)
conn = DB_connection('communication',patient);
sql = 'SELECT timestamp,call_duration FROM calls WHERE call_duration >0 AND (call_type = 1 OR call_type = 2)';

curs = exec(conn,sql);
curs = fetch(curs);

data = cell2mat(curs.data);
periods = [data(:,1) data(:,1)+data(:,2)*1000];
close(curs);
close(conn);
end

function [periods] = search_screen_on(patient)

conn = DB_connection('screen',patient);
sql = 'SELECT timestamp FROM screen WHERE screen_status = 1';

curs = exec(conn,sql);
curs = fetch(curs);
data = cell2mat(curs.data);

sql = 'SELECT timestamp FROM screen WHERE screen_status = 0';

curs = exec(conn,sql);
curs = fetch(curs);
data2 = cell2mat(curs.data);
close(curs);
close(conn);

%pad matrix to same size
if size(data,1)~=size(data2,1)
    [m,I] = max([size(data,1),size(data2,1)]);
    if I == 1
        data2(m)=0;
    else
        data(m)=0;
    end
end

% produce rough periods and find out invalid points
% periods where end time is later then the start time of next will be
% dropped
periods = zeros(size(data,1),2);

for i=1:size(data)
    periods(i,1) = data(i);
    periods(i,2) = min(data2(data2>data(i)));
    if i~=1
        if periods(i,1)<periods(i-1,2)||periods(i-1,2)-periods(i-1,1)>5*1000*60*60
            periods(i-1,:)=0;
        end
    end
end

% diff = (periods(:,2)-periods(:,1));
% dn = diff/86400000 + 719529;   %# == datenum(1970,1,1)
% date = datestr(dn);

periods = [periods(periods(:,1)~=0,1),periods(periods(:,2)~=0,2)];

diff = (periods(:,2)-periods(:,1));
dn = diff/86400000 + 719529;   %# == datenum(1970,1,1)
date = datestr(dn);

end

function [period] = merge_periods(period1,period2)
period = [period1;period2];
[temp,I] = sort(period);

for i=1:size(temp)
    temp(i,2)=period(I(i),2);
end
period = [];
period(1,:) = temp(1,:);

for i=2:size(temp)
    if temp(i,1)>=period(end,2)
        period=[period;temp(i,:)];
    else
        period(end,2)=temp(i,2);
    end
end

% dn = period/86400000 + 719529;   %# == datenum(1970,1,1)
% date = [datestr(dn(:,1)),datestr(dn(:,2))];


end

function [accs,accsCell] = get_accs(periods,patient)
conn = DB_connection('accelerometer',patient);
accs = [];
data = [];
accsCell = {};
for i=1:size(periods)
    sql = ['SELECT timestamp,double_values_0,double_values_1,double_values_2 from accelerometer where timestamp>=' int2str(periods(i,1)) ' and timestamp<=' int2str(periods(i,2))];
    clear curs;
    curs = exec(conn,sql);
    curs = fetch(curs);
    curs = curs.data;
    if size(curs,2)==4
        data = cell2mat(curs);
        data(:,5) = sqrt(data(:,2).^2+data(:,3).^2+data(:,4).^2);
        accs = [accs;data];
        accsCell = [accsCell;data];
    end
end
close(conn);
clear curs;
end

function [linear_accs] = accs2linearaccs(accsCell)
conn = DB_connection('gravity','P04');
linear_accs = {};
for i = 1:size(accsCell)
    temp = accsCell{i};
    sql = ['SELECT timestamp,double_values_0,double_values_1,double_values_2 FROM GRAVITY WHERE timestamp>=' int2str(temp(1,1)) ' AND timestamp<=' int2str(temp(end,1))];
    curs = exec(conn,sql);
    curs = fetch(curs);
    gravity = cell2mat(curs.data);
    
    for j = 1:size(temp)
        [~,I] = min(abs(gravity(:,1)-temp(j,1)));
        temp(j,2:4) = temp(j,2:4)-gravity(I,2:4);
    end
    temp(:,5) = sqrt(temp(:,2).^2+temp(:,3).^2+temp(:,4).^2);
    linear_accs{i,1} = temp;
end

close(curs);
close(conn);
end