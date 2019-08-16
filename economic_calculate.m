function [investment_payoff_period,cash_incomes,elec_incomes ,heat_incomes ,cooling_incomes] = economic_calculate(initial_outlay, year_gas_cost, year_ele_cost, year_maintenance_cost,design_period, ...
    typical_days, summer_day_period, winter_day_period, transition_day_period, elec_prices, heat_price)

fprintf('economic_calculate');

%ECONOMIC 此处显示有关此函数的摘要
%   此处显示详细说明
%initial_outlay - 初始投资
%year_gas_cost - 年购气成本
%year_ele_cost - 年购电成本
%year_maintenance_cost - 年维护成本
%design_period - 设计年限

%typical_days - 典型日负荷数据
%summer_day_period - 夏季负荷时长
%winter_day_period - 冬季负荷时长
%transition_day_period - 过渡期时长

winter_typical_day = typical_days(:,1:3);
summer_typical_day = typical_days(:,4:6);
transition_typical_day = typical_days(:,7:10);



%现金支出
cash_outlays = ones(design_period,1)*(year_gas_cost+year_ele_cost+year_maintenance_cost);
cash_outlays(1) = cash_outlays(1) + initial_outlay;
%现金流入，售电、售热、售冷收益
elec_incomes = summer_day_period*(sum(summer_typical_day(:,1).*elec_prices)) + ...
    winter_day_period*(sum(winter_typical_day(:,1).*elec_prices)) + ...
    transition_day_period*(sum(transition_typical_day(:,1).*elec_prices));
elec_incomes=elec_incomes/10000;
heat_incomes = winter_day_period*(sum(winter_typical_day(:,2))*3600*1000*heat_price/(10^9)) + ...
    transition_day_period*(sum(transition_typical_day(:,3))*3600*1000*heat_price/(10^9));
heat_incomes = heat_incomes/10000;
cooling_incomes = summer_day_period*(sum(summer_typical_day(:,2))*3600*1000*heat_price/(10^9)) + ...
    transition_day_period*(sum(transition_typical_day(:,2))*3600*1000*heat_price/(10^9));
cooling_incomes = cooling_incomes/10000;

cash_incomes = elec_incomes + heat_incomes + cooling_incomes;

%%%%*****************经济指标******************
%净现金流 万元
net_cashes = cash_incomes - cash_outlays;
%折现率
r = 0.08;
%现值系数
present_values = ones(design_period, 1);
for i = 1:1:design_period
    if i == 1
        present_values(1) = 1/(1 + r); 
    else
        present_values(i) = present_values(i -1)/(1 + r);
    end
end
%净现金流量现值 万元
net_cash_present_values = present_values.*net_cashes;
%累计净现金流量现值
accumulative_net_cash_present_values = zeros(design_period, 1);
for i = 1:1:design_period
    if i == 1
        accumulative_net_cash_present_values(i) = net_cash_present_values(i);
    else
        accumulative_net_cash_present_values(i) = accumulative_net_cash_present_values(i -1)+ ...
            net_cash_present_values(i);
    end
end
% 动态投资回收期
% (累计净现金流量出现正值-1) + 上年累计净现金流量现值的绝对值/出现正值年份净现金流量现值 
% 累计净现金流量出现正值的年份
accumulative_cash_present_positive_year = find(accumulative_net_cash_present_values>0 ,1);
%净现金流量出现正值年份
net_cash_present_positive_year = find(net_cash_present_values>0, 1);
investment_payoff_period = 21;
if ~(isempty(accumulative_cash_present_positive_year)) && ~(isempty(net_cash_present_positive_year))
    if(accumulative_cash_present_positive_year(1) == 1)
        investment_payoff_period = accumulative_cash_present_positive_year(1) - 1 + ...
            abs(accumulative_net_cash_present_values(accumulative_cash_present_positive_year(1)))/...
            net_cash_present_values(net_cash_present_positive_year);
    else
        investment_payoff_period = accumulative_cash_present_positive_year(1) - 1 + ...
            abs(accumulative_net_cash_present_values(accumulative_cash_present_positive_year(1) -1))/...
            net_cash_present_values(net_cash_present_positive_year);
    end    
end
fprintf('动态投资回收期 %f\n',investment_payoff_period);


