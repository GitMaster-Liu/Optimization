function f = my_fitness(N, chromosome, follow,winter_typical_day,summer_typical_day,transition_typical_day)
%winter_typical_day,summer_typical_day,transition_typical_day是除过100
chromosome=100*chromosome;
follow=100*follow;
%% function f = evaluate_objective(x, M, V)
% Function to evaluate the objective functions for the given input vector
% x. x is an array of decision variables and f(1), f(2), etc are the
% objective functions. The algorithm always minimizes the objective
% function hence if you would like to maximize the function then multiply
% the function by negative one. M is the numebr of objective functions and
% V is the number of decision variables. 
%
% This functions is basically written by the user who defines his/her own
% objective function. Make sure that the M and V matches your initial user
% input. Make sure that the 
%
% An example objective function is given below. It has two six decision
% variables are two objective functions.

% f = [];
% %% Objective function one
% % Decision variables are used to form the objective function.
% f(1) = 1 - exp(-4*x(1))*(sin(6*pi*x(1)))^6;
% sum = 0;
% for i = 2 : 6
%     sum = sum + x(i)/4;
% end
% %% Intermediate function
% g_x = 1 + 9*(sum)^(0.25);
% 
% %% Objective function two
% f(2) = g_x*(1 - ((f(1))/(g_x))^2);

%% Kursawe proposed by Frank Kursawe.
%% 在这里可以定义目标函数，但是目标函数个数一定要与输入的V一致，否则会报错
% Take a look at the following reference
% A variant of evolution strategies for vector optimization.
% In H. P. Schwefel and R. M鋘ner, editors, Parallel Problem Solving from
% Nature. 1st Workshop, PPSN I, volume 496 of Lecture Notes in Computer 
% Science, pages 193-197, Berlin, Germany, oct 1991. Springer-Verlag. 
%
% Number of objective is two, while it can have arbirtarly many decision
% variables within the range -5 and 5. Common number of variables is 3.
% Objective function one



winter_typical_day(:,1)=100*winter_typical_day(:,1);
winter_typical_day(:,2)=100*winter_typical_day(:,2);

summer_typical_day(:,1)=100*summer_typical_day(:,1);
summer_typical_day(:,2)=100*summer_typical_day(:,2);

transition_typical_day(:,1)=100*transition_typical_day(:,1);
transition_typical_day(:,2)=100*transition_typical_day(:,2);
transition_typical_day(:,3)=100*transition_typical_day(:,3);

external_ele_generator_yita = 0.37;

gas_price = 3.45;
%天然气热值 Mj/m3
gas_caloritic_value = 33.812;



% 排污系数 燃料、电 元/kWh
c_env_f = 10/1000*0.22 ;
c_env_e = 10/1000*0.968;

% 折现率
r = 0.08;
d = 20;
k = ((1 + r)^d - 1)/(r*(1+r)^d);
%成本单价 光伏、三联供、地源热供、燃气锅炉、电储能、冷储能、热储能
P_r=[4500;6347;1650;785;2500;150;150];

c_mf=[0.02,0,0,0,0,0,0;
    0,0.01,0,0,0,0,0;
    0,0,0.03,0,0,0,0;
    0,0,0,0.03,0,0,0;
    0,0,0,0,0.03,0,0;
    0,0,0,0,0,0.03,0;
    0,0,0,0,0,0,0.03];
c_mr=[0.039;0.05;0.02;0.02;0.02;0.02;0.02];
C_m_f=chromosome(1:7)*c_mf*P_r;%固定维护成本
P_e_pv=0;P_e_cchp=0;P_ch_hp=0;P_h_gb=0;P_e_es=0;P_c_es=0;P_h_es=0;
%计算出一年内每天每小时功率之和，乘以1就是耗电量
P_buy=[];

winter_num=5;
summer_num=5;
transition_num=6;
chromo_winter_num=4;
chromo_summer_num=3;
chromo_transition_num=4;


for i=0:23
    P_e_pv=P_e_pv+follow(1+winter_num*i)*120+follow(121+summer_num*i)*122+follow(241+transition_num*i)*123;%光伏功率之和
    P_e_cchp=P_e_cchp+chromosome(1+chromo_winter_num*i)*120+chromosome(97+chromo_summer_num*i)*122+chromosome(169+chromo_transition_num*i)*123;%CCHP功率之和按照电功率计算
    P_ch_hp=P_ch_hp+chromosome(3+chromo_winter_num*i)*120+chromosome(99+chromo_summer_num*i)*122+chromosome(171+chromo_transition_num*i)*123;%地缘热泵HP功率之和，按照冷热功率之和
    P_h_gb=P_h_gb+chromosome(4+chromo_winter_num*i)*120+chromosome(172+chromo_transition_num*i)*123;%燃气锅炉功率之和，按照热功率计算
    
    P_e_es=P_e_es+abs(chromosome(2+chromo_winter_num*i))*120+abs(chromosome(98+chromo_summer_num*i))*122+abs(chromosome(170+chromo_transition_num*i))*123;%充放电功率之和
    P_c_es=P_c_es+abs(follow(124+summer_num*i))*122+abs(follow(244+transition_num*i))*123;%充放冷功率之和
    P_h_es=P_h_es+abs(follow(4+winter_num*i))*120+abs(follow(246+transition_num*i))*123;%充放热功率之和
    
    % 一年某每时刻耗电量
    P_buy(i+1)=follow(3+winter_num*i)*120+follow(123+summer_num*i)*122+follow(243+transition_num*i)*123;
    
end
%冬季
yita_e_cchp=[];
E_g_cchp1=0;
for i=0:23
    %CCHP消耗的一次能源能量，单位千瓦时
    yita_e_cchp(i+1)=0.4166*((chromosome(1+chromo_winter_num*i)/200).^3)-1.0135*((chromosome(1+chromo_winter_num*i)./200)).^2 ...
        +0.8365*(chromosome(1+chromo_winter_num*i)./200)+0.0926;
    E_g_cchp1=E_g_cchp1+120*chromosome(1+chromo_winter_num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end
%夏季
yita_e_cchp=[];
E_g_cchp2=0;
for i=0:23
    %CCHP消耗的一次能源能量，单位千瓦时
    yita_e_cchp(i+1)=0.4166*((chromosome(97+chromo_summer_num*i)./200)).^3-1.0135*((chromosome(97+chromo_summer_num*i)./200)).^2 ...
        +0.8365*(chromosome(97+chromo_summer_num*i)./200)+0.0926;
    E_g_cchp2=E_g_cchp2+122*chromosome(97+chromo_summer_num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end
%过渡季
yita_e_cchp=[];
E_g_cchp3=0;
for i=0:23
    %CCHP消耗的一次能源能量，单位千瓦时
    yita_e_cchp(i+1)=0.4166*((chromosome(169+chromo_transition_num*i)./200)).^3-1.0135*((chromosome(169+chromo_transition_num*i)./200)).^2 ...
        +0.8365*(chromosome(169+chromo_transition_num*i)./200)+0.0926;
    E_g_cchp3=E_g_cchp3+123*chromosome(169+chromo_transition_num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end


P_i=[P_e_pv,P_e_cchp,P_ch_hp,P_h_gb,P_e_es,P_c_es,P_h_es];

C_m_r=P_i*c_mr*1;%运行维护成本，delta t为1
C_m=C_m_f+C_m_r;

%峰谷平单价
peak = 0.78;
flat = 0.5;
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
ele_price = [cereal_prices;flat_prices1;peak_prices1;...
    flat_prices2;peak_prices2;flat_prices3];
% ele_price为电价表

%购电价格
C_e=P_buy*ele_price;
%燃料价格，只有天然气，CCHP和GB使用了天然气
%所以根据CCHP和GB消耗总能量除以热值，热值为gas_caloritic_value，价格gas_price
Q_use=P_h_gb/0.85+E_g_cchp1+E_g_cchp2+E_g_cchp3;%消耗的总能量，单位是千瓦时
C_f=Q_use*3.6/gas_caloritic_value*gas_price;
C_ope=C_m+C_e+C_f;



unproper_win_h=0;
unproper_sum_c=0;
unproper_tr_c=0;
unproper_tr_h=0;
for i=4:5:119
    unproper_win_h=unproper_win_h+follow(i);
end
for i=124:5:239
    unproper_sum_c=unproper_sum_c+follow(i);
end
for i=244:6:382
    unproper_tr_c=unproper_tr_c+follow(i);
end
for i=246:6:384
    unproper_tr_h=unproper_tr_h+follow(i);
end
unproper_win_e=0;
unproper_sum_e=0;
unproper_tr_e=0;
for i=2:4:94
    unproper_win_e=unproper_win_e+follow(i);
end
for i=98:3:167
    unproper_sum_e=unproper_sum_e+follow(i);
end
for i=170:4:262
    unproper_tr_e=unproper_tr_e+follow(i);
end

unproper=abs(unproper_win_h)+abs(unproper_sum_c)+abs(unproper_tr_c)+abs(unproper_tr_h)+abs(unproper_win_e)+abs(unproper_sum_e)+abs(unproper_tr_e);

f=unproper;%经济性指标
