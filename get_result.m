function [result] = get_result( Xn,winter_typical_day, summer_typical_day, transition_typical_day )
% function [ flag,x ] = get_result_winter( pv_capactiy,cchp_capacity,hp_capacity, gb_capacity,es_capacity,...
%     hs_capacity, cs_capacity)
% ************************Test***********
% 优化当前容量下的组合
pv_capactiy = Xn(1);
cchp_capacity = Xn(2);
hp_capacity = Xn(3);
gb_capacity = Xn(4);
es_capacity = Xn(5);
cs_capacity = Xn(6);
hs_capacity = Xn(7);
%*****************End********************
% 冬季典型日
day_period = 24;
%%****************** 变量顺序********
% 光伏出力、CCHP出力、地源热泵出力、锅炉出力
% 储能与释能功率 - (储电、储热) 、电网购电
% 共计 9 位
var_number = 11;
%%%*****************COP**************
cop_h_hp = 4;
cop_c_hp = 5;
cop_h_cchp = 1.2;
cop_c_cchp = 1.36;
cchp_yita_dis = 0.15;
cchp_yita_waste = 0.85;
cchp_yita = 0.42;
gb_yita = 0.85;
energy_storage_charge_yita = [0.98 0.95 0.95];
energy_storage_discharge_yita = [0.98 0.95 0.95];
energy_storage_wasting_yita = [0.01 0.02 0.02];

energy_storage_capacity_lower = [0.1 0.1 0.1];
energy_storage_capacity_upper = [0.9 0.9 0.9];

%出力约束
% min_load_yita = [0,0.3,0.2,0.3,0,0,0,0,0,0];
min_load_yita_w = [0,0.3,0.2,0.3,0,0,0,0,0,0];
min_load_yita_s = [0,0.3,0.2,0,0,0,0,0,0,0];
min_load_yita_t = [0,0.3,0,0,0,0,0,0,0,0];
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
%*******************构建模型******************
x = sdpvar(3 * var_number * day_period, 1,'full');

% **约束**
Constraints = [];
% **目标**
objectives = 0;
% 中间用以约束储能的变量：实时容量、容量变化量
% nergy_storage_init_capacity = energy_storage_capacity_lower.*[es_capacity, cs_capacity, hs_capacity];
nergy_storage_init_capacity = [0.5 0.5 0.5].*[es_capacity, cs_capacity, hs_capacity];
energy_storage_delta_w = [];
energy_storage_delta_s = [];
energy_storage_delta_t = [];

% 瞬时功率最大值
output_power_limit = [pv_capactiy, cchp_capacity,hp_capacity,gb_capacity,...
    es_capacity/5, es_capacity/5, cs_capacity/8, cs_capacity/8, hs_capacity/8, hs_capacity/8];

for index = 1:var_number:1+(day_period-1)*var_number
    %% 冬季
    temp_w = x(index:index+var_number-1);
    Constraints = [Constraints, temp_w(1) == pv_capactiy*winter_typical_day(ceil(index/var_number),3)];
    %PV发电量+CCHP发电量+ES放电量+买电量=电负荷+HP发热的耗电量+放电量
    Constraints = [Constraints, temp_w(1) + temp_w(2) + temp_w(6) + temp_w(11) ...
        == winter_typical_day(ceil(index/var_number),1) + temp_w(3)/cop_h_hp + temp_w(5)];
%     cchp_yita = 0.4166*(temp(2)/cchp_capacity)^3 - 1.0135*(temp(2)/cchp_capacity)^2 ...
%         + 0.8365*(temp(2)/cchp_capacity) + 0.0926;
    cchp_heat = (temp_w(2)*(1 - cchp_yita - cchp_yita_dis))*cop_h_cchp/cchp_yita;
    %HP发热量+GB发热量+CCHP发热量+ES放热=热负荷+ES储热
    Constraints = [Constraints, temp_w(3) + temp_w(4) + cchp_heat + temp_w(10) ...
        == winter_typical_day(ceil(index/var_number),2) + temp_w(9)];
    % 储能约束
%     Constraints = [Constraints, temp(5)*temp(6) == 0];
%     Constraints = [Constraints, temp(7)*temp(8) == 0];
    Constraints = [Constraints, [temp_w(7) temp_w(8)] == [0 0]];    %冬季没有制冷
    % 储能容量约束
    energy_storage_delta_w =[energy_storage_delta_w; energy_storage_charge_yita.*(temp_w(5:2:9)') - ...
        temp_w(6:2:10)'./energy_storage_discharge_yita];
    es_init_capacity = (1 - energy_storage_wasting_yita).*nergy_storage_init_capacity + ...
        energy_storage_delta_w(ceil(index/var_number),:);
    Constraints = [Constraints, energy_storage_capacity_lower.*[es_capacity cs_capacity hs_capacity] ...
        <= es_init_capacity <= energy_storage_capacity_upper.*[es_capacity cs_capacity hs_capacity]];
        % 范围约束
    Constraints = [Constraints, min_load_yita_w.*output_power_limit <= temp_w(1:10)' <= ...
        max_load_yita.*output_power_limit];
    Constraints = [Constraints, temp_w(11)>= 0];
    
    %更新目标函数
    % 储能出力
    energy_output_power = [abs(temp_w(6)- temp_w(5)); abs(temp_w(8) - temp_w(7)); abs(temp_w(10) - temp_w(9))];
    objectives = objectives + c_m_r * [temp_w(1:4);energy_output_power] + ...
        elec_prices(ceil(index/var_number))*temp_w(11) + temp_w(2)*3.6*gas_price/cchp_yita/gas_caloritic_value ...
        + temp_w(4)*3.6*gas_price/gb_yita/gas_caloritic_value;
    %% 夏季
    temp_s = x((var_number*day_period+index):(var_number*day_period+index)+var_number-1);
    Constraints = [Constraints, temp_s(1) == pv_capactiy*summer_typical_day(ceil(index/var_number),3)];
    Constraints = [Constraints, temp_s(1) + temp_s(2) + temp_s(6) + temp_s(11) ...
        == summer_typical_day(ceil(index/var_number),1) + temp_s(3)/cop_c_hp + temp_s(5)];
%     cchp_yita = 0.4166*(temp(2)/cchp_capacity)^3 - 1.0135*(temp(2)/cchp_capacity)^2 ...
%         + 0.8365*(temp(2)/cchp_capacity) + 0.0926;
    cchp_cold = (temp_s(2)*(1 - cchp_yita - cchp_yita_dis))*cop_c_cchp/cchp_yita;
    Constraints = [Constraints, temp_s(3) + cchp_cold + temp_s(8) ...
        == summer_typical_day(ceil(index/var_number),2) + temp_s(7)];
    % 储能约束
%     Constraints = [Constraints, temp(5)*temp(6) == 0];
%     Constraints = [Constraints, temp(7)*temp(8) == 0];
    Constraints = [Constraints, temp_s(4) == 0];
    Constraints = [Constraints, [temp_s(9) temp_s(10)] == [0 0]];    %夏季没有制热
    % 储能容量约束
    energy_storage_delta_s =[energy_storage_delta_s; energy_storage_charge_yita.*(temp_s(5:2:9)') - ...
        temp_s(6:2:10)'./energy_storage_discharge_yita];
    es_init_capacity = (1 - energy_storage_wasting_yita).*nergy_storage_init_capacity + ...
        energy_storage_delta_s(ceil(index/var_number),:);
    Constraints = [Constraints, energy_storage_capacity_lower.*[es_capacity cs_capacity hs_capacity] ...
        <= es_init_capacity <= energy_storage_capacity_upper.*[es_capacity cs_capacity hs_capacity]];
        % 范围约束
    Constraints = [Constraints, min_load_yita_s.*output_power_limit <= temp_s(1:10)' <= ...
        max_load_yita.*output_power_limit];
    Constraints = [Constraints, temp_s(11)>= 0];
    
    %更新目标函数
    % 储能出力
    energy_output_power = [abs(temp_s(6)- temp_s(5)); abs(temp_s(8) - temp_s(7)); abs(temp_s(10) - temp_s(9))];
    objectives = objectives + c_m_r * [temp_s(1:4);energy_output_power] + ...
        elec_prices(ceil(index/var_number))*temp_s(11) + temp_s(2)*3.6*gas_price/cchp_yita/gas_caloritic_value ...
        + temp_s(4)*3.6*gas_price/gb_yita/gas_caloritic_value;
    %% 过渡季
    temp_t = x((2*var_number*day_period+index):(2*var_number*day_period+index)+var_number-1);
    Constraints = [Constraints, temp_t(1) == pv_capactiy*transition_typical_day(ceil(index/var_number),4)];
    Constraints = [Constraints, temp_t(1) + temp_t(2) + temp_t(6) + temp_t(11) ...
        == transition_typical_day(ceil(index/var_number),1) + temp_t(3)/cop_h_hp + temp_t(5)];
%     cchp_yita = 0.4166*(temp(2)/cchp_capacity)^3 - 1.0135*(temp(2)/cchp_capacity)^2 ...
%         + 0.8365*(temp(2)/cchp_capacity) + 0.0926;
    cchp_heat = (temp_t(2)*(1 - cchp_yita - cchp_yita_dis))*cop_h_cchp/cchp_yita;
    Constraints = [Constraints, temp_t(3) + temp_t(4) + cchp_heat + temp_t(10) ...
        == transition_typical_day(ceil(index/var_number),3) + temp_t(9)];

    % 储能约束
%     Constraints = [Constraints, temp(5)*temp(6) == 0];
    Constraints = [Constraints, [temp_t(3) temp_t(4)] == [0 0]];
    Constraints = [Constraints, [temp_t(7) temp_t(8)] == [0 0]];
%     Constraints = [Constraints, [temp(7) temp(8)] == [0 0]];    %冬季没有制冷
    % 储能容量约束
    energy_storage_delta_t =[energy_storage_delta_t; energy_storage_charge_yita.*(temp_t(5:2:9)') - ...
        temp_t(6:2:10)'./energy_storage_discharge_yita];
    es_init_capacity = (1 - energy_storage_wasting_yita).*nergy_storage_init_capacity + ...
        energy_storage_delta_t(ceil(index/var_number),:);
    Constraints = [Constraints, energy_storage_capacity_lower.*[es_capacity cs_capacity hs_capacity] ...
        <= es_init_capacity <= energy_storage_capacity_upper.*[es_capacity cs_capacity hs_capacity]];
        % 范围约束
    Constraints = [Constraints, min_load_yita_t.*output_power_limit <= temp_t(1:10)' <= ...
        max_load_yita.*output_power_limit];
    Constraints = [Constraints, temp_t(11)>= 0];
    
    %更新目标函数
    % 储能出力
    energy_output_power = [abs(temp_t(6)- temp_t(5)); abs(temp_t(8) - temp_t(7)); abs(temp_t(10) - temp_t(9))];
    objectives = objectives + c_m_r * [temp_t(1:4);energy_output_power] + ...
        elec_prices(ceil(index/var_number))*temp_t(11) + temp_t(2)*3.6*gas_price/cchp_yita/gas_caloritic_value ...
        + temp_t(4)*3.6*gas_price/gb_yita/gas_caloritic_value;
end

% 一天变化量为零，约束
Constraints = [Constraints, sum(energy_storage_delta_w) == [0 0 0]];
Constraints = [Constraints, sum(energy_storage_delta_s) == [0 0 0]];
Constraints = [Constraints, sum(energy_storage_delta_t) == [0 0 0]];

options = sdpsettings('verbose', 2, 'solver','gurobi');
sol = optimize(Constraints,objectives, options);

if(sol.problem == 0)
    'Optimization is successful : '
    
%     value(x);
    result=value(x);
else
    disp('Optimization is failed!');
    sol.problem
    sol.info
    result=0;
end

