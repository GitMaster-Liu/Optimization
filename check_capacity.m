function [ output ] = check_capacity( capacity_series )
%CHECK_CAPACITY 此处显示有关此函数的摘要
%   此处显示详细说明
% Input
% capacity_series -设备装机容量
% min_load_elec - 最小电负荷
% min_load_cooling - 最小冷负荷
% min_load_heat - 最小热负荷

% return output 
% 0 - 不满足， 1 - 满足

%% ******************Test****************
% capacity_series = [44 44 63 23 54 279 303];
% 冬季、夏季、过度季
% max_load_elec = [11180.4 13762.35 11190];
min_load_elec = [4328.723438 6808.380469 6865.40625];
% max_load_cooling = [0 38229.67529 0];
min_load_cooling = [0 9695.909288 0];
% max_load_heat = [33950.24609 0 6807.4];
min_load_heat = [14780.02832 0 2484.6];

% 求最小值，变换数量单位,最终输入为如下数据即可
min_load_elec = min(min_load_elec(min_load_elec~=0))/100 ;
min_load_heat = min(min_load_heat(min_load_heat~=0))/100;
min_load_cooling = min(min_load_cooling(min_load_cooling~=0))/100;
%*************************End Test**********
% CCHP 机组参数
cop_h_cchp = 1.2;
cop_c_cchp = 1.36;
cchp_yita_dis = 0.15;
cchp_yita_waste = 0.85;
cchp_yita = 0.4;

% % 考虑过度季，CCHP满足最小发电负荷
% 电负荷不用考虑，因为可以外购电
min_prod_elec = 0.3 * capacity_series(2);

% 考虑过度季，CCHP 单独供热满足最小热负荷
min_prod_heat = 0.3 * capacity_series(2)*(1 - cchp_yita_dis - cchp_yita)* ...
    cop_h_cchp/cchp_yita;
% 考虑夏季，CCHP+地源热泵最小出力满足最小冷负荷
min_prod_cooling =  0.3 * capacity_series(2)*(1 - cchp_yita_dis - cchp_yita_waste)* ...
    cop_c_cchp/cchp_yita + 0.2 * capacity_series(3);

output = 0;
if(min_prod_elec < min_load_elec && ...
        min_prod_heat < min_load_heat && ...
        min_prod_cooling < min_load_cooling)
    output = 1;
end


end

