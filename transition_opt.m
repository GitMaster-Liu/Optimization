function [result] = transition_opt( pv_capactiy,cchp_capacity,hp_capacity, gb_capacity,es_capacity,...
    hs_capacity, cs_capacity, typical_days)


%OPT_WITH_YALMIP 此处显示有关此函数的摘要
% %   此处显示详细说明
% %负荷边界:电、冷、热 单位100KW
% load_elec_upper = 140;
% load_elec_lower = 30; % 看数据
% load_heat_upper = 340;
% load_heat_lower = 30; % 看数据
% load_cold_upper = 390;
% load_cold_lower = 20; % 看数据
% 
% % 储能容量边界
% es_working_period = 5;
% hs_working_period = 8;
% cs_working_period = 8;
% capacity_es_upper = 20*es_working_period;
% capacity_es_lower = 0;
% capacity_hs_upper = 50*hs_working_period;
% capacity_hs_lower = 0;
% capacity_cs_upper = 50*cs_working_period;
% capacity_cs_lower = 0;

% ************************Test***********
% 优化当前容量下的组合

%**************************Test**********

% 负荷数据
winter_typical_day = [typical_days(:,1:2)/100, typical_days(:,3)];
summer_typical_day = [typical_days(:,4:5)/100, typical_days(:,6)];
transition_typical_day = [typical_days(:,7:9)/100, typical_days(:,10)];
%*****************End********************
%%%*****************COP**************
cop_h_hp = 4;
cop_c_hp = 5;
cop_h_cchp = 1.2;
cop_c_cchp = 1.36;
cchp_yita_dis = 0.15;
cchp_yita_waste = 0.85;
cchp_yita = 0.4;
gb_yita = 0.85;
energy_storage_charge_yita = [0.98 0.95 0.95];
energy_storage_discharge_yita = [0.98 0.95 0.95];
energy_storage_wasting_yita = [0.01 0.02 0.02];

energy_storage_capacity_lower = [0.1 0.1 0.1];
energy_storage_capacity_upper = [0.9 0.9 0.9];

%出力约束
min_load_yita = [0,0.3,0.2,0.3,0,0,0,0,0,0];
max_load_yita = [1,1,1,1,1,1,1,1,1,1];

% 分时电价，峰谷平单价
peak = 1.4;
flat = 0.78;
cereal = 0.3;
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
elec_prices = [cereal_prices;flat_prices1;peak_prices1; ...
    flat_prices2;peak_prices2;flat_prices3];
gas_price = 3.45;
%天然气热值 Mj/m3
gas_caloritic_value = 33.812;

% 设备固定维护系数
% 运行维护系数
c_m_r = [0.039, 0.05, 0.02, 0.02, 0.02, 0.02, 0.02];
%*************************************************
day_period = 24;
%%****************** 变量顺序********
% 光伏出力、CCHP出力、地源热泵出力、锅炉出力
% 储能与释能功率 - (储电、储冷、储热) 、电网购电
% 共计 11 位
var_number = 11;



% 过渡季典型日
%*******************构建模型******************
x = sdpvar(var_number * day_period, 1,'full');

% **约束**
Constraints = [];
% **目标**
objectives = 0;
% 中间用以约束储能的变量：实时容量、容量变化量
nergy_storage_init_capacity = energy_storage_capacity_upper.*[es_capacity, cs_capacity, hs_capacity];
energy_storage_delta = [];

% 瞬时功率最大值
output_power_limit = [pv_capactiy, cchp_capacity,hp_capacity,gb_capacity,...
    es_capacity/5, es_capacity/5, cs_capacity/8, cs_capacity/8, hs_capacity/8, hs_capacity/8];

for index = 1:var_number:1+(day_period-1)*var_number
    temp = x(index:index+var_number-1);
    Constraints = [Constraints, temp(1) == pv_capactiy*transition_typical_day(ceil(index/var_number),3)];%光伏约束
    Constraints = [Constraints, temp(1) + temp(2) + temp(6) + temp(11) ...
        == transition_typical_day(ceil(index/var_number),1) + temp(3)/cop_h_hp + temp(5)];%电负荷约束 地源热泵用于制热
    cchp_cool = 0.85*(temp(2)*(1 - cchp_yita - cchp_yita_dis))*cop_h_cchp/cchp_yita;
    Constraints = [Constraints, cchp_cool + temp(8)  ...
        == transition_typical_day(ceil(index/var_number),2) + temp(7)];%冷负荷约束
%     cchp_yita = 0.4166*(temp(2)/cchp_capacity)^3 - 1.0135*(temp(2)/cchp_capacity)^2 ...
%         + 0.8365*(temp(2)/cchp_capacity) + 0.0926;%非线性，不能用

    Constraints = [Constraints, temp(3) + temp(4) + temp(10) ...
        == transition_typical_day(ceil(index/var_number),2) + temp(9)]; %热负荷约束
    % 储能约束
%     Constraints = [Constraints, temp(5)*temp(6) == 0];
%     Constraints = [Constraints, temp(7)*temp(8) == 0];
    % 储能容量约束
    energy_storage_delta =[energy_storage_delta; energy_storage_charge_yita.*(temp(5:2:9)') - ...
        temp(6:2:10)'./energy_storage_discharge_yita];
    es_init_capacity = (1 - energy_storage_wasting_yita).*nergy_storage_init_capacity + ...
        energy_storage_delta(ceil(index/var_number),:);
    Constraints = [Constraints, energy_storage_capacity_lower.*[es_capacity cs_capacity hs_capacity] ...
        <= es_init_capacity <= energy_storage_capacity_upper.*[es_capacity cs_capacity hs_capacity]];
        % 范围约束
    Constraints = [Constraints, min_load_yita.*output_power_limit <= temp(1:10)' <= ...
        max_load_yita.*output_power_limit];
    Constraints = [Constraints, temp(11)>= 0];
    
    %更新目标函数
    % 储能出力
    energy_output_power = [abs(temp(6)- temp(5)); abs(temp(8) - temp(7)); abs(temp(10) - temp(9))];
    objectives = objectives + c_m_r * [temp(1:4);energy_output_power] + ...
        elec_prices(ceil(index/var_number))*temp(11) + temp(2)*(3600000/1000000)*gas_price/cchp_yita/gas_caloritic_value ...
        + temp(4)*(3600000/1000000)*gas_price/gb_yita/gas_caloritic_value;
end

% 一天变化量为零，约束
Constraints = [Constraints, sum(energy_storage_delta) == [0 0 0]];

options = sdpsettings('verbose', 2, 'solver','cplex');
sol = optimize(Constraints,objectives, options);

if(sol.problem == 0)
    'Optimization is successful : '
    result=value(x);
else
    disp('Optimization is failed!');
    sol.problem
    sol.info
end
