function f = evaluate(N, solution, winter_typical_day, summer_typical_day, transition_typical_day)
%winter_typical_day,summer_typical_day,transition_typical_day�ǳ���100
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
%% ��������Զ���Ŀ�꺯��������Ŀ�꺯������һ��Ҫ�������Vһ�£�����ᱨ��
% Take a look at the following reference
% A variant of evolution strategies for vector optimization.
% In H. P. Schwefel and R. M�nner, editors, Parallel Problem Solving from
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
%��Ȼ����ֵ Mj/m3
gas_caloritic_value = 33.812;



% ����ϵ�� ȼ�ϡ��� Ԫ/kWh
c_env_f = 10/1000*0.22 ;
c_env_e = 10/1000*0.968;

% ������
r = 0.08;
d = 20;
k = ((1 + r)^d - 1)/(r*(1+r)^d);
%�ɱ����� ���������������Դ�ȹ���ȼ����¯���索�ܡ��䴢�ܡ��ȴ���
P_r=[4500;6347;1650;785;2500;150;150];
%װ������
C_inv=N*P_r;
c_mf=[0.02,0,0,0,0,0,0;
    0,0.01,0,0,0,0,0;
    0,0,0.03,0,0,0,0;
    0,0,0,0.03,0,0,0;
    0,0,0,0,0.03,0,0;
    0,0,0,0,0,0.03,0;
    0,0,0,0,0,0,0.03];
c_mr=[0.039;0.05;0.02;0.02;0.02;0.02;0.02];
C_m_f=N*c_mf*P_r;%�̶�ά���ɱ�
P_e_pv=0;P_e_cchp=0;P_ch_hp=0;P_h_gb=0;P_e_es=0;P_c_es=0;P_h_es=0;
%�����һ����ÿ��ÿСʱ����֮�ͣ�����1���Ǻĵ���
P_buy=[];
num=11;
for i=0:23
    P_e_pv=P_e_pv+solution1(1+num*i)*120+solution2(1+num*i)*122+solution3(1+num*i)*123;%�������֮��
    P_e_cchp=P_e_cchp+solution1(2+num*i)*120+solution2(2+num*i)*122+solution3(2+num*i)*123;%CCHP����֮�Ͱ��յ繦�ʼ���
    P_ch_hp=P_ch_hp+solution1(3+num*i)*120+solution2(3+num*i)*122+solution3(3+num*i)*123;%��Ե�ȱ�HP����֮�ͣ��������ȹ���֮��
    P_h_gb=P_h_gb+solution1(4+num*i)*120+solution3(4+num*i)*123;%ȼ����¯����֮�ͣ������ȹ��ʼ���
    
    P_e_es=P_e_es+abs(solution1(5+num*i)-solution1(6+num*i))*120+abs(solution2(5+num*i)-solution2(6+num*i))*122+abs(solution3(5+num*i)-solution3(6+num*i))*123;%��ŵ繦��֮��
    P_c_es=P_c_es+abs(solution2(7+num*i)-solution2(8+num*i))*122;%����书��֮��
    P_h_es=P_h_es+abs(solution1(9+num*i)-solution1(10+num*i))*120+abs(solution3(9+num*i)-solution3(10+num*i))*123;%����ȹ���֮��
    
    % һ��ĳÿʱ�̺ĵ���
    P_buy(i+1)=solution1(11+num*i)*120+solution2(11+num*i)*122+solution3(11+num*i)*123;
    
end
%����
yita_e_cchp=[];
E_g_cchp1=0;
for i=0:23
    %CCHP���ĵ�һ����Դ��������λǧ��ʱ
    yita_e_cchp(i+1)=0.4166*((solution1(2+num*i)/200).^3)-1.0135*((solution1(2+num*i)./200)).^2 ...
        +0.8365*(solution1(2+num*i)./200)+0.0926;
    E_g_cchp1=E_g_cchp1+120*solution1(2+num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end
%�ļ�
yita_e_cchp=[];
E_g_cchp2=0;
for i=0:23
    %CCHP���ĵ�һ����Դ��������λǧ��ʱ
    yita_e_cchp(i+1)=0.4166*((solution2(2+num*i)./200)).^3-1.0135*((solution2(2+num*i)./200)).^2 ...
        +0.8365*(solution2(2+num*i)./200)+0.0926;
    E_g_cchp2=E_g_cchp2+122*solution2(2+num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end
%���ɼ�
yita_e_cchp=[];
E_g_cchp3=0;
for i=0:23
    %CCHP���ĵ�һ����Դ��������λǧ��ʱ
    yita_e_cchp(i+1)=0.4166*((solution3(2+num*i)./200)).^3-1.0135*((solution3(2+num*i)./200)).^2 ...
        +0.8365*(solution3(2+num*i)./200)+0.0926;
    E_g_cchp3=E_g_cchp3+123*solution3(2+num*i)*(1-yita_e_cchp(i+1)-0.15)./yita_e_cchp(i+1);
end


P_i=[P_e_pv,P_e_cchp,P_ch_hp,P_h_gb,P_e_es,P_c_es,P_h_es];

C_m_r=P_i*c_mr*1;%����ά���ɱ���delta tΪ1
C_m=C_m_f+C_m_r;

%���ƽ����
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
ele_price = [cereal_prices;flat_prices1;peak_prices1;...
    flat_prices2;peak_prices2;flat_prices3];
% ele_priceΪ��۱�

%����۸�
C_e=P_buy*ele_price;
%ȼ�ϼ۸�ֻ����Ȼ����CCHP��GBʹ������Ȼ��
%���Ը���CCHP��GB����������������ֵ����ֵΪgas_caloritic_value���۸�gas_price
Q_use=P_h_gb/0.85+E_g_cchp1+E_g_cchp2+E_g_cchp3;%���ĵ�����������λ��ǧ��ʱ
C_f=Q_use*3.6/gas_caloritic_value*gas_price;
C_ope=C_m+C_e+C_f;
C=C_inv+k*C_ope;
f(1)=C;%������ָ��
%% ���������㻷������ָ��
%C_env�͵���ͨ����Ȼ�����ĵ���������ǧ��ʱ����������ϵ��c_env_f
%����ͨ�������������������ϵ��c_env_e
E_buy=0;
for i=1:24
    E_buy=E_buy+P_buy(i);
end

C_env=c_env_f*Q_use+E_buy*c_env_e;%E_buy����P_buyÿ��Ԫ����ӵĽ��
f(2)=C_env;%��������ָ��

%% ����������һ����Դ�˷���ָ��
E_e_dem=0;%���ܸ���
E_c_dem=0;%���ܸ���
E_h_dem=0;%���ܸ���
for i=1:24
    E_e_dem=E_e_dem+120*winter_typical_day(i,1)+122*summer_typical_day(i,1)+123*transition_typical_day(i,1);%���ܸ���
    E_c_dem=E_c_dem+122*summer_typical_day(i,2);%���ܸ���
    E_h_dem=E_h_dem+120*winter_typical_day(i,2)+123*transition_typical_day(i,3);%���ܸ���
end

E_dem=E_e_dem+E_c_dem+E_h_dem;%�硢�䡢���ܸ���

yita=E_dem./((E_buy./external_ele_generator_yita)+Q_use);%c_power�Ƿ��糧����Ч��

f(3)=1-yita;%һ����Դ�˷���ָ��




% %% ���㾻���ɱ仯��ָ��
% P_je=[];%�羻����
% P_jc=[];%�侻����
% P_jh=[];%�Ⱦ�����
% %����
% for day=1:120
%     for i=1:24
%         P_je(i+24*day-24)=winter_typical_day(i,1)+solution1(5+num*i-num)-solution1(6+num*i-num);%�羻����=����-�ŵ�+���
%         P_jc(i+24*day-24)=0;%�侻����
%         P_jh(i+24*day-24)=winter_typical_day(i,2)+solution1(9+num*i-num)-solution1(10+num*i-num);%�Ⱦ�����
%     end
% end
% %�ļ�
% for day=121:242
%     for i=1:24
%         P_je(i+24*day-24)=summer_typical_day(i,1)+solution2(5+num*i-num)-solution2(6+num*i-num);%�羻����=����-�ŵ�+���
%         P_jc(i+24*day-24)=summer_typical_day(i,2)+solution2(7+num*i-num)-solution2(8+num*i-num);%�侻����
%         P_jh(i+24*day-24)=0;%�Ⱦ�����
%     end
% end
% %���ɼ�
% for day=243:365
%     for i=1:24
%         P_je(i+24*day-24)=transition_typical_day(i,1)+solution3(5+num*i-num)-solution3(6+num*i-num);%�羻����=����-�ŵ�+���
%         P_jc(i+24*day-24)=0;%�侻����
%         P_jh(i+24*day-24)=transition_typical_day(i,3)+solution3(9+num*i-num)-solution3(10+num*i-num);%�Ⱦ�����
%     end
% end
% sum_je=0;%�羻���ɱ仯ƽ����
% sum_jc=0;%�侻���ɱ仯ƽ����
% sum_jh=0;%�Ⱦ����ɱ仯ƽ����
% for i=2:8760
%     sum_je=sum_je+(P_je(i)-P_je(i-1)).^2;
%     sum_jc=sum_jc+(P_jc(i)-P_jc(i-1)).^2;
%     sum_jh=sum_jh+(P_jh(i)-P_jh(i-1)).^2;
% end
% S=8758\(sum_je+sum_jc+sum_jh);
% 
% 
% f(4)= S  ;%��ȫ���У������ɱ仯��ָ�꣩
