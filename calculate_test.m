function [investment_payoff_period,cash_incomes,elec_incomes ,heat_incomes, cooling_incomes] = ...
    calculate_test(chromosome, elite, elite_follow)
%%
% 100元/GJ
gas_price=4.85;
elec_price=0.78;
gas_caloritic_value = 33.812;
heat_price = (gas_price/gas_caloritic_value)*10^3;
%设计年限
design_period = 20;
% 典型日
typical_days = xlsread('LoadData.xlsx', 'Load', 'A3:J26');
winter_typical_day = typical_days(:,1:3);
summer_typical_day = typical_days(:,4:6);
transition_typical_day = typical_days(:,7:10);


winter_typical_day(:,1)=0.01*winter_typical_day(:,1);
winter_typical_day(:,2)=0.01*winter_typical_day(:,2);

summer_typical_day(:,1)=0.01*summer_typical_day(:,1);
summer_typical_day(:,2)=0.01*summer_typical_day(:,2);

transition_typical_day(:,1)=0.01*transition_typical_day(:,1);
transition_typical_day(:,2)=0.01*transition_typical_day(:,2);
transition_typical_day(:,3)=0.01*transition_typical_day(:,3);

%供能时长,天
transition_day_period = 123;
summer_day_period = 122;
winter_day_period = 120;

%峰谷平单价
peak = elec_price;
flat = elec_price;
cereal = elec_price;
%11:00 – 15:00
peak_prices1 = ones(5,1) .* peak;
%19:00 – 21:00
peak_prices2 = ones(3,1) .* peak;
%08:00 – 10:00
flat_prices1 = ones(3,1) .* flat;
%16:00 – 18:00
flat_prices2 = ones(3,1) .* flat;
%22:00 – 23:00
flat_prices3 = ones(2,1) .* flat;
%00:00 -07:00
cereal_prices = ones(8,1) .* cereal;
elec_prices = [cereal_prices;flat_prices1;peak_prices1;...
    flat_prices2;peak_prices2;flat_prices3];

[pop,temp]=size(chromosome);
clear temp;
best_fitness=[];
% elite=[];
generation=[];
% elite_follow=[];
for i=1:pop
%% 通过计算得到的数据
%%%*************测试数据*********
% 费用单位为 万元
    [initial_outlay(i), year_gas_cost(i), year_ele_cost(i), year_maintenance_cost(i)] = get_cost(chromosome(i,1:7), elite(i,:), elite_follow(i,:),winter_typical_day,summer_typical_day,transition_typical_day);
%%%*************End*************
%% 调用经济测算函数
    [investment_payoff_period(i),cash_incomes,elec_incomes ,heat_incomes, cooling_incomes] = economic_calculate(0.0001*initial_outlay(i), 0.0001*year_gas_cost(i), 0.0001*year_ele_cost(i), 0.0001*year_maintenance_cost(i),design_period,...
        typical_days, summer_day_period, winter_day_period, transition_day_period, elec_prices, heat_price);
end