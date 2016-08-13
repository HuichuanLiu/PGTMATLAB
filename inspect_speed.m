function [period] = inpsect_speed(patient,threshold)
conn = BD_connection('linear_accelerometer',patient);
sql = 'SELECT MAX(_id) from linear_accelerometer';
curs = exec(conn,sql);
curs = fetch(curs);
rowNum = cell2mat(curs.data);

lastId = 0;
speed = [0 0 0 0 0];

%divide the data into 1000 subsets
for id = rowNum/10000:rowNum/10000:rowNum
    sql = ['SELECT timestamp,double_values_0,double_values_1,double_values_2 from linear_accelerometer WHERE _id>',int2str(lastId),' and _id < ',int2str(id)];
    curs = exec(conn,sql)
    curs = fetch(curs)
    values = cell2mat(curs.data);
    
    % ploting the distribution of linear_acceleration
    histogram(values(:,4));
    xlim([-10,10]);
    %ylim([0,2000]);
    [mu,sigma,muci,sigmaci] = normfit(values,0.05);
    m = mean(values);
    a = mean(values)+1.96*std(values)./sqrt(size(values,1));
    b = mean(values)-1.96*std(values)./sqrt(size(values,1));
    
    % for each subset, calculate the speed(i) = speed(i-1)+t*a
    for i = 2:size(values)
        timeGap = (values(i,1)-values(i-1,1))/1000;
        speed1 = speed(i-1,2)+timeGap*values(i,2);
        speed2 = speed(i-1,3)+timeGap*values(i,3);
        speed3 = speed(i-1,4)+timeGap*values(i,4);
        speed = [speed; values(i,1),speed1,speed2,speed3,sqrt(speed1^2+speed1^2+speed1^2)];
        i
        
    end   
    lastId = id;   
end
    
end



