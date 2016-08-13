function conn = BD_connection(table,patient)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
username = '';
pw = '';
driver = 'org.sqlite.JDBC';
%dbpath = '/Users/huichuan/Documents/GraduateDesign/PD_data/P02/accelerometer.dec.db';
%URL = 'jdbc:sqlite:/Users/huichuan/Documents/GraduateDesign/PD_data/P02/accelerometer.dec.db';
dbpath = ['/Users/huichuan/Documents/GraduateDesign/PD_data/' patient '/' table '.dec.db'];
URL = ['jdbc:sqlite:' dbpath];
conn = database(dbpath,username,pw,driver,URL);
end
