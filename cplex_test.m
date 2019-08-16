clc;
clear all;
pv_capactiy = 20;
cchp_capacity = 100;
hp_capacity = 80;
gb_capacity = 80;
es_capacity = 20;
hs_capacity = 400;
cs_capacity = 200;
Xn=[pv_capactiy cchp_capacity cchp_capacity gb_capacity es_capacity cs_capacity hs_capacity]
typical_days = xlsread('LoadData.xlsx', 'Load', 'A3:J26');
winter_typical_day = [typical_days(:,1:2)/100, typical_days(:,3)];
summer_typical_day = [typical_days(:,4:5)/100, typical_days(:,6)];
transition_typical_day = [typical_days(:,7:9)/100, typical_days(:,10)];
% result = get_result_winter( Xn,winter_typical_day );
% result = get_result_summer( Xn,summer_typical_day );
result = get_result_transition( Xn,transition_typical_day );