%% 读取负荷
typical_days = xlsread('LoadData.xlsx', 'Load', 'A3:J26');
winter_typical_day = typical_days(:,1:3);
summer_typical_day = typical_days(:,4:6);
transition_typical_day = typical_days(:,7:10);
winter_typical_day_ori = winter_typical_day;
summer_typical_day_ori = summer_typical_day;
transition_typical_day_ori = transition_typical_day;
%负荷处理：除100，单位由KW变为100KW
winter_typical_day(:,1)=0.01*winter_typical_day(:,1);
winter_typical_day(:,2)=0.01*winter_typical_day(:,2);

summer_typical_day(:,1)=0.01*summer_typical_day(:,1);
summer_typical_day(:,2)=0.01*summer_typical_day(:,2);

transition_typical_day(:,1)=0.01*transition_typical_day(:,1);
transition_typical_day(:,2)=0.01*transition_typical_day(:,2);
transition_typical_day(:,3)=0.01*transition_typical_day(:,3);
%% data
load('chromosome_best1.mat');
winter_elc_DsCh = elite(11,2:4:94)';
winter_elc_PV = elite_follow(11,1:5:116)';
winter_elc_CCHP = elite(11,1:4:93)';
winter_elc_HP = elite_follow(11,2:5:117)';
% winter_elc_BUY = winter_typical_day(:,1)-winter_elc_PV-winter_elc_CCHP-winter_elc_DsCh;
winter_elc_BUY = winter_typical_day(:,1)-winter_elc_PV-winter_elc_CCHP;
%% figure
figure;
x=1:24;
% plot(x,summer_typical_day(:,2),'-*g','LineWidth',1.5);
bar(-winter_typical_day(:,1)-winter_elc_HP(:,1),'k');
hold on;
%bar(-winter_typical_day(:,1),'g');
A=[winter_elc_PV+winter_elc_CCHP+winter_elc_BUY+winter_elc_DsCh];
bar(winter_elc_PV+winter_elc_CCHP+winter_elc_BUY-winter_elc_DsCh,'g');

% legend('电负荷','光伏','CCHP','买电');
% ,winter_elc_CCHP,winter_elc_BUY
% bar(summer_typical_day(:,2));