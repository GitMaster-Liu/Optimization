function f = evaluate(N, solution, winter_typical_day, summer_typical_day, transition_typical_day)
%winter_typical_day,summer_typical_day,transition_typical_day是除过100
N=100*N;
solution=100*solution;
solution1=solution(1:264);
solution2=solution(265:528);
solution3=solution(529:792);
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
% number of objective is two, while it can have arbirtarly many decision
% variables within the range -5 and 5. Common number of variables is 3.
f = [];
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
%装机容量
C_inv=N*P_r;
c_mf=[0.02,0,0,0,0,0,0;
    0,0.01,0,0,0,0,0;
    0,0,0.03,0,0,0,0;
    0,0,0,0.03,0,0,0;
    0,0,0,0,0.03,0,0;
    0,0,0,0,0,0.03,0;
    0,0,0,0,0,0,0.03];
c_mr=[0.039;0.05;0.02;0.02;0.02;0.02;0.02];
C_m_f=N*c_mf*P_r;%固定维护成本
P_e_pv=0;P_e_cchp=0;P_ch_hp=0;P_h_gb=0;P_e_es=0;P_c_es=0;P_h_es=0;
%计算出一年内每天每小时功率之和，乘以1就是耗电量
P_buy=[];
num=11;
for i=0:23
    P_e_pv=P_e_pv+solution1(1+num*i)*120+solution2(1+num*i)*122+solution3(1+num*i)*123;%光伏功率之和
    P_e_cchp=P_e_cchp+solution1(2+num*i)*120+solution2(2+num*i)*122+solution3(2+num*i)*123;%CCHP功率之和按照电功率计算
    P_ch_hp=P_ch_hp+solution1(3+num*i)*120+solution2(3+num*i)*122+solution3(3+num*i)*123;%地缘热泵HP功率之和，按照冷热功率之和
    P_h_gb=P_h_gb+solution1(4+num*i)*120+solution3(4+num*i)*123;%燃气锅炉功率之和，按照热功率计算
    
    P_e_es=P_e_es+abs(solution1(5+num*i)-solution1(6+num*i))*120+abs(solution2(5+num*i)-solution2(6+num*i))*122+abs(solution3(5+num*i)-solution3(6+num*i))*123;%充放电功率之和
    P_c_es=P_c_es+abs(solution2(7+num*i)-solution2(8+num*i))*122;%充放冷功率之和
    P_h_es=P_h_es+abs(solution1(9+num*i)-solution1(10+num*i))*120+abs(solution3(9+num*i)-solution3(10+num*i))*123;%充放热功率之和
    
    % 一年某每时刻耗电量
    P_buy(i+1)=solution1(11+num*i)*120+solution2(11+num*i)*122+solution3(11+num*i)*123;
    
end
%冬季
yita_e_cchp=[];
E_g_cchp1=0;
for i=0:23
    %CCHP消耗的一次能源能量，单位千瓦时
    yita_e_cchp(i+1)=0.4166*((solution1(2+num*i)/200).^3)-1.0135*((solution1(2+num*i)./200)).^2 ...
        +0.8365*(solution1(2+num*i)./200)+0.0926;
    E_g_cchp1=E_g_cchp1+120*solution1(2+num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end
%夏季
yita_e_cchp=[];
E_g_cchp2=0;
for i=0:23
    %CCHP消耗的一次能源能量，单位千瓦时
    yita_e_cchp(i+1)=0.4166*((solution2(2+num*i)./200)).^3-1.0135*((solution2(2+num*i)./200)).^2 ...
        +0.8365*(solution2(2+num*i)./200)+0.0926;
    E_g_cchp2=E_g_cchp2+122*solution2(2+num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end
%过渡季
yita_e_cchp=[];
E_g_cchp3=0;
for i=0:23
    %CCHP消耗的一次能源能量，单位千瓦时
    yita_e_cchp(i+1)=0.4166*((solution3(2+num*i)./200)).^3-1.0135*((solution3(2+num*i)./200)).^2 ...
        +0.8365*(solution3(2+num*i)./200)+0.0926;
    E_g_cchp3=E_g_cchp3+123*solution3(2+num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end


P_i=[P_e_pv,P_e_cchp,P_ch_hp,P_h_gb,P_e_es,P_c_es,P_h_es];

C_m_r=P_i*c_mr*1;%运行维护成本，delta t为1
C_m=C_m_f+C_m_r;

%峰谷平单价
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
C=C_inv+k*C_ope;
f(1)=C;%经济性指标
%% 接下来计算环境保护指标
%C_env就等于通过天然气消耗的总能量（千瓦时）乘以治理系数c_env_f
%加上通过买电总能量乘以治理系数c_env_e
E_buy=0;
for i=1:24
    E_buy=E_buy+P_buy(i);
end

C_env=c_env_f*Q_use+E_buy*c_env_e;%E_buy等于P_buy每个元素相加的结果
f(2)=C_env;%环境保护指标

%% 接下来计算一次能源浪费率指标
E_e_dem=0;%电总负荷
E_c_dem=0;%冷总负荷
E_h_dem=0;%热总负荷
for i=1:24
    E_e_dem=E_e_dem+120*winter_typical_day(i,1)+122*summer_typical_day(i,1)+123*transition_typical_day(i,1);%电总负荷
    E_c_dem=E_c_dem+122*summer_typical_day(i,2);%冷总负荷
    E_h_dem=E_h_dem+120*winter_typical_day(i,2)+123*transition_typical_day(i,3);%热总负荷
end

E_dem=E_e_dem+E_c_dem+E_h_dem;%电、冷、热总负荷

yita=E_dem./((E_buy./external_ele_generator_yita)+Q_use);%c_power是发电厂发电效率

f(3)=1-yita;%一次能源浪费率指标




% %% 计算净负荷变化量指标
% P_je=[];%电净负荷
% P_jc=[];%冷净负荷
% P_jh=[];%热净负荷
% %冬季
% for day=1:120
%     for i=1:24
%         P_je(i+24*day-24)=winter_typical_day(i,1)+solution1(5+num*i-num)-solution1(6+num*i-num);%电净负荷=负荷-放电+充电
%         P_jc(i+24*day-24)=0;%冷净负荷
%         P_jh(i+24*day-24)=winter_typical_day(i,2)+solution1(9+num*i-num)-solution1(10+num*i-num);%热净负荷
%     end
% end
% %夏季
% for day=121:242
%     for i=1:24
%         P_je(i+24*day-24)=summer_typical_day(i,1)+solution2(5+num*i-num)-solution2(6+num*i-num);%电净负荷=负荷-放电+充电
%         P_jc(i+24*day-24)=summer_typical_day(i,2)+solution2(7+num*i-num)-solution2(8+num*i-num);%冷净负荷
%         P_jh(i+24*day-24)=0;%热净负荷
%     end
% end
% %过渡季
% for day=243:365
%     for i=1:24
%         P_je(i+24*day-24)=transition_typical_day(i,1)+solution3(5+num*i-num)-solution3(6+num*i-num);%电净负荷=负荷-放电+充电
%         P_jc(i+24*day-24)=0;%冷净负荷
%         P_jh(i+24*day-24)=transition_typical_day(i,3)+solution3(9+num*i-num)-solution3(10+num*i-num);%热净负荷
%     end
% end
% sum_je=0;%电净负荷变化平方和
% sum_jc=0;%冷净负荷变化平方和
% sum_jh=0;%热净负荷变化平方和
% for i=2:8760
%     sum_je=sum_je+(P_je(i)-P_je(i-1)).^2;
%     sum_jc=sum_jc+(P_jc(i)-P_jc(i-1)).^2;
%     sum_jh=sum_jh+(P_jh(i)-P_jh(i-1)).^2;
% end
% S=8758\(sum_je+sum_jc+sum_jh);
% 
% 
% f(4)= S  ;%安全运行（净负荷变化量指标）
