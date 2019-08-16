%% 读取负荷
typical_days = xlsread('LoadData.xlsx', 'Load', 'A3:J26');
winter_typical_day = typical_days(:,1:3);
summer_typical_day = typical_days(:,4:6);
transition_typical_day = typical_days(:,7:10);
winter_typical_day_ori = winter_typical_day;
summer_typical_day_ori = summer_typical_day;
transition_typical_day_ori = transition_typical_day;
%负荷处理：除100，单位由KW变为100KW
% [winter_typical_day,summer_typical_day,transition_typical_day]...
%     =LoadDataProcess(winter_typical_day,summer_typical_day,transition_typical_day);
winter_typical_day(:,1)=winter_typical_day(:,1)*0.01;
winter_typical_day(:,2)=winter_typical_day(:,2)*0.01;
summer_typical_day(:,1)=summer_typical_day(:,1)*0.01;
summer_typical_day(:,2)=summer_typical_day(:,2)*0.01;
transition_typical_day(:,1)=transition_typical_day(:,1)*0.01;
transition_typical_day(:,2)=transition_typical_day(:,2)*0.01;
transition_typical_day(:,3)=transition_typical_day(:,3)*0.01;
%% 测试
Xn=[76 73 324 122 85 326 348];
result = get_result( Xn,winter_typical_day, summer_typical_day, transition_typical_day );
