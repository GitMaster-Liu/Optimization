function [result] = summer_opt( pv_capactiy,cchp_capacity,hp_capacity, gb_capacity,es_capacity,...
    hs_capacity, cs_capacity, typical_days)


%OPT_WITH_YALMIP �˴���ʾ�йش˺�����ժҪ
% %   �˴���ʾ��ϸ˵��
% %���ɱ߽�:�硢�䡢�� ��λ100KW
% load_elec_upper = 140;
% load_elec_lower = 30; % ������
% load_heat_upper = 340;
% load_heat_lower = 30; % ������
% load_cold_upper = 390;
% load_cold_lower = 20; % ������
% 
% % ���������߽�
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
% �Ż���ǰ�����µ����

%**************************Test**********

% ��������
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

%����Լ��
min_load_yita = [0,0.3,0.2,0,0,0,0,0,0,0];
max_load_yita = [1,1,1,1,1,1,1,1,1,1];

% ��ʱ��ۣ����ƽ����
peak = 1.4;
flat = 0.78;
cereal = 0.3;
%11:00 �C 15:00
peak_prices1 = ones(5,1) .* peak;
%19:00 �C 21:00
peak_prices2 = ones(3,1) .* peak;
%08:00 �C 10:00
flat_prices1 = ones(3,1) .* flat;
%16:00 �C 18:00
flat_prices2 = ones(3,1) .* flat;
%22:00 �C 23:00
flat_prices3 = ones(2,1) .* flat;
%00:00 -07:00
cereal_prices = ones(8,1) .* cereal;
elec_prices = [cereal_prices;flat_prices1;peak_prices1; ...
    flat_prices2;peak_prices2;flat_prices3];
gas_price = 3.45;
%��Ȼ����ֵ Mj/m3
gas_caloritic_value = 33.812;

% �豸�̶�ά��ϵ��
% ����ά��ϵ��
c_m_r = [0.039, 0.05, 0.02, 0.02, 0.02, 0.02, 0.02];
%*************************************************
day_period = 24;
%%****************** ����˳��********
% ���������CCHP��������Դ�ȱó�������¯����
% ���������ܹ��� - (���硢���䡢����) ����������
% ���� 11 λ
var_number = 11;



% �ļ�������
%*******************����ģ��******************
x = sdpvar(var_number * day_period, 1,'full');

% **Լ��**
Constraints = [];
% **Ŀ��**
objectives = 0;
% �м�����Լ�����ܵı�����ʵʱ�����������仯��
nergy_storage_init_capacity = energy_storage_capacity_upper.*[es_capacity, cs_capacity, hs_capacity];
energy_storage_delta = [];

% ˲ʱ�������ֵ
output_power_limit = [pv_capactiy, cchp_capacity,hp_capacity,gb_capacity,...
    es_capacity/5, es_capacity/5, cs_capacity/8, cs_capacity/8, hs_capacity/8, hs_capacity/8];

for index = 1:var_number:1+(day_period-1)*var_number
    temp = x(index:index+var_number-1);
    Constraints = [Constraints, temp(1) == pv_capactiy*summer_typical_day(ceil(index/var_number),3)];%���Լ��
    Constraints = [Constraints, temp(1) + temp(2) + temp(6) + temp(11) ...
        == summer_typical_day(ceil(index/var_number),1) + temp(3)/cop_c_hp + temp(5)];%�縺��Լ�� ��Դ�ȱ���������
    cchp_cool = 0.85*(temp(2)*(1 - cchp_yita - cchp_yita_dis))*cop_c_cchp/cchp_yita;
    Constraints = [Constraints, cchp_cool + temp(3) + temp(8)  ...%�����temp(3)�ǵ�Ե�ȱ����书��
        == summer_typical_day(ceil(index/var_number),2) + temp(7)];%�为��Լ��
%     cchp_yita = 0.4166*(temp(2)/cchp_capacity)^3 - 1.0135*(temp(2)/cchp_capacity)^2 ...
%         + 0.8365*(temp(2)/cchp_capacity) + 0.0926;%�����ԣ�������

    Constraints = [Constraints, temp(4) == 0];
    Constraints = [Constraints, [temp(9) temp(10)] == [0 0]];    %�ļ�û������,�ȸ���Լ��
    % ����Լ��
%     Constraints = [Constraints, temp(5)*temp(6) == 0];
%     Constraints = [Constraints, temp(7)*temp(8) == 0];
    % ��������Լ��
    energy_storage_delta =[energy_storage_delta; energy_storage_charge_yita.*(temp(5:2:9)') - ...
        temp(6:2:10)'./energy_storage_discharge_yita];
    es_init_capacity = (1 - energy_storage_wasting_yita).*nergy_storage_init_capacity + ...
        energy_storage_delta(ceil(index/var_number),:);
    Constraints = [Constraints, energy_storage_capacity_lower.*[es_capacity cs_capacity hs_capacity] ...
        <= es_init_capacity <= energy_storage_capacity_upper.*[es_capacity cs_capacity hs_capacity]];
        % ��ΧԼ��
    Constraints = [Constraints, min_load_yita.*output_power_limit <= temp(1:10)' <= ...
        max_load_yita.*output_power_limit];
    Constraints = [Constraints, temp(11)>= 0];
    
    %����Ŀ�꺯��
    % ���ܳ���
    energy_output_power = [abs(temp(6)- temp(5)); abs(temp(8) - temp(7)); abs(temp(10) - temp(9))];
    objectives = objectives + c_m_r * [temp(1:4);energy_output_power] + ...
        elec_prices(ceil(index/var_number))*temp(11) + temp(2)*(3600000/1000000)*gas_price/cchp_yita/gas_caloritic_value ...
        + temp(4)*(3600000/1000000)*gas_price/gb_yita/gas_caloritic_value;
end

% һ��仯��Ϊ�㣬Լ��
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
