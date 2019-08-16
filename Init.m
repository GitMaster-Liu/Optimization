function  x  = Init( winter_typical_day,summer_typical_day,transition_typical_day,cop_equipment )
x=[];
%% 容量边界
bonder_Max=[140 140 390 340 100 400 400];
bonder_MIn=[30 30 30 20 20 50 50];
%负荷边界:电、冷、热 单位100KW
MAX_Elec = 140; 
MAX_Cold = 390;
MAX_Hot = 340;
MIN_Elec = 30;
MIN_Cold = 30;
MIN_Hot = 20;
%容量边界：电、冷、热 单位100KW
MAX_PN_Elec = 20*5;
MAX_PN_Cold = 50*8;
MAX_PN_Hot = 50*8;
MIN_PN_Elec = 20;   %最大存储功率，也为可随机的最小容量
MIN_PN_Cold = 50;
MIN_PN_Hot = 50;
%% 粒子分段索引
Num_winer = 4;%冬季设备个数
Num_summer = 3;
Num_transition = 4;
Index_winter = 1;
Index_summer = Index_winter+Num_winer*24;
Index_trasition = Index_summer+Num_summer*24;
%% 初始化粒子 
Xn(1:7)=[140 140 390 340 100 400 400];
%随机容量
% Xn(1) = round(unifrnd(MIN_Elec, MAX_Elec));    %PV
% Xn(2) = round(unifrnd(MIN_Elec, MAX_Elec));    %CCHP
alpha_2 = 0.3;  %负载范围系数
% Xn(3) = round(unifrnd(MIN_Hot, MAX_Cold));     %HP
alpha_3 = 0.2;
% Xn(4) = round(unifrnd(MIN_Hot, MAX_Hot));     %GB
alpha_4 = 0.3;
% Xn(5) = round(unifrnd(MIN_PN_Elec, MAX_PN_Elec));   %随机电存储的容量
alpha_5 = 0.1;
alpha_6 = 0.9;
% x(6) = round(unifrnd(MIN_PN_Cold, MAX_PN_Cold));   %冷
% x(7) = round(unifrnd(MIN_PN_Hot, MAX_PN_Hot));     %热

%% 冬季
H = alpha_6*Xn(5);   %电储蓄罐柜位H，初始为满罐
n=1;
j=1;
while n&&(j<100)
    j=j+1;
    for i=Index_winter:Num_winer:(Index_winter+Num_winer*22)   %冬季共8-103号，前23小时的8-99号
        k=1;
        m=1;
        while k&&(m<100)        %随机一组初始值
            m=m+1;
            x(i) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %随机CCHP的发电量
            x(i+1) = round(unifrnd((-1)*min(alpha_6*Xn(5)-H,MIN_PN_Elec)...
                ,min(H-alpha_5*Xn(5),MIN_PN_Elec)));   %随机存储量，正为释放，负为存储
            x(i+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %随机HP的发热量
            %H_temp=H-x(i+1)+x(i+2);     %用于判断当前的液位是否超限
            %满足PV+CCHP+Pds <= Pch+负荷+HP的耗电，并且液位不低于底限，否则则重新随机生成 (光伏发电功率=光照强度*容量)
            if (Xn(1) * winter_typical_day(floor((i-Index_winter)/Num_winer)+1,3) + x(i) + x(i+1)...
                    <= winter_typical_day(floor((i-Index_winter)/Num_winer)+1,1) + x(i+2)/cop_equipment(3,3))
                k = 0;
            end
        end
        x(i+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %随机GB的发热量
        %计算前23个小时充放电的和每个小时改变当前的柜位 H=H+Pch-Pds
        H = H-x(i+1);
    end
    if (alpha_6*Xn(5)-H<MIN_PN_Elec)     %第24个小时剩余的差值必须小于充电功率
        n=0;
    end
end
%第24个小时把储存罐充满,只能冲不能放
x(Index_winter+Num_winer*23+1)=H-alpha_6*Xn(5);
k=1;
n=1;
while k&&(n<100)         %给最后一小时的变量赋初始值
    n=n+1;
    x(Index_winter+Num_winer*23) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %随机CCHP的发电量
    x(Index_winter+Num_winer*23+2) = round(unifrnd(alpha_3*Xn(3)+1, Xn(3)+1));  %随机HP的发热量
    if (Xn(1) * winter_typical_day(24,3) + x(Index_winter+Num_winer*23) + x(Index_winter+Num_winer*23+1)...
            < winter_typical_day(24,1) + x(Index_winter+Num_winer*23+2)/cop_equipment(3,3))
       k = 0;
    end
end
x(Index_winter+Num_winer*23+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %随机GB的发热量

%% 夏季
H = alpha_6*Xn(5);   %电储蓄罐柜位H，初始为满罐
n=1;
j=1;
while n&&(j<100)
    j=j+1;
    for i=Index_summer:Num_summer:(Index_summer+Num_summer*22)  %(104-175)
        k=1;
        n=1;
        while k&&(n<100) %随机一组初始值
            n=n+1;
            x(i) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %随机CCHP的发电量
            x(i+1) = round(unifrnd((-1)*min(alpha_6*Xn(5)-H,MIN_PN_Elec)...
                ,min(H-alpha_5*Xn(5),MIN_PN_Elec)));   %随机存储量，正为释放，负为存储
            x(i+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %随机HP的制冷量
            %满足PV+CCHP+Pds <= Pch+负荷+HP的耗电，否则则重新随机生成 (光伏发电功率=光照强度*容量)
            if (Xn(1) * summer_typical_day(floor((i-Index_summer)/Num_summer)+1,3) + x(i) + x(i+1) ...
                    <=  summer_typical_day(floor((i-Index_summer)/Num_summer)+1,1) + x(i+2)/cop_equipment(3,2))
                k = 0;
            end
        end
        %计算前23个小时充放电的和每个小时改变当前的柜位 H=H+Pch-Pds
        H = H-x(i+1);
    end
    if (alpha_6*Xn(5)-H<MIN_PN_Elec)
        n=0;
    end
end
%第24个小时把储存罐充满,只能冲不能放
x(Index_summer+Num_summer*23+1)=H-alpha_6*Xn(5);
k=1;
n=1;
while k&&(n<100)         %给最后一小时的变量赋初始值
    n=n+1;
    x(Index_summer+Num_summer*23) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %随机CCHP的发电量
    x(Index_summer+Num_summer*23+2) = round(unifrnd(alpha_3*Xn(3)+1, Xn(3)+1));  %随机HP的制冷量
    if (Xn(1) * summer_typical_day(24,3) + x(Index_summer+Num_summer*23) + x(Index_summer+Num_summer*23+1)...
            <= summer_typical_day(24,1) + x(Index_summer+Num_summer*23+2)/cop_equipment(3,3))
       k = 0;
    end
end

%% 过渡季
H = alpha_6*Xn(5);   %电储蓄罐柜位H，初始为满罐
n=1;
j=1;
while n&&(j<100)
    j=j+1;
    for i=Index_trasition:Num_transition:Index_trasition+Num_transition*22  %(176-271)
        k=1;
        n=1;
        while k&&(n<100) %随机一组初始值
            n=n+1;
            x(i) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %随机CCHP的发电量
            x(i+1) = round(unifrnd((-1)*min(alpha_6*Xn(5)-H,MIN_PN_Elec)...
                ,min(H-alpha_5*Xn(5),MIN_PN_Elec)));   %随机存储量，正为释放，负为存储
            x(i+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %随机HP的发热量
            %满足PV+CCHP+Pds <= Pch+负荷+HP的耗电，否则则重新随机生成 (光伏发电功率=光照强度*容量)
            if (Xn(1) * transition_typical_day(floor((i-Index_trasition)/Num_transition)+1,4) + x(i) + x(i+1) ...
                    <= transition_typical_day(floor((i-Index_trasition)/Num_transition)+1,1) + x(i+2)/cop_equipment(3,3))
                k = 0;
            end
        end
        x(i+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %随机GB的发热量
        %计算前23个小时充放电的和每个小时改变当前的柜位 H=H+Pch-Pds
        H = H-x(i+1);
    end
    if (alpha_6*Xn(5)-H<MIN_PN_Elec)
        n=0;
    end
end
%第24个小时把储存罐充满,只能冲不能放
x(Index_trasition+Num_transition*23+1)=H-alpha_6*Xn(5);
k=1;
n=1;
while k&&(n<100)         %给最后一小时的变量赋初始值
    n=n+1;
    x(Index_trasition+Num_transition*23) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %随机CCHP的发电量
    x(Index_trasition+Num_transition*23+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %随机HP的发热量
    if (Xn(1) * transition_typical_day(24,4) + x(Index_trasition+Num_transition*23) + x(Index_trasition+Num_transition*23+1)...
            <= transition_typical_day(24,1) + x(Index_trasition+Num_transition*23+2)/cop_equipment(3,3))
       k = 0;
    end
end
x(Index_trasition+Num_transition*23+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %随机GB的发热量
%% 将CCHP的功率进行除2换算
% for i=8:5:123
%     x(i)=0.5*x(i);
% end
% for i=128:4:221
%     x(i)=0.5*x(i);
% end
% for i=224:5:339
%     x(i)=0.5*x(i);
% end
