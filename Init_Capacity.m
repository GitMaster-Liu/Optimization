function [ Xn ] = Init_Capacity( winter_typical_day,summer_typical_day,transition_typical_day)
%% 初始化容量
% Xn(1:7)=[140 140 390 340 100 400 400];
Xn=[];
%% 容量边界(可以写成传参传进来)
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
%随机容量
while 1
    for i=1:7
        Xn(i) = round(unifrnd(bonder_MIn(i), bonder_Max(i)));
    end
    if check_capacity(Xn)
        continue;
    else

        solution= get_result( Xn,winter_typical_day,summer_typical_day,transition_typical_day );%内层调用

        if norm(solution)==0
            Xn(8:10)= inf;
        else
            Xn(8:10) = evaluate(Xn(1:7), solution,winter_typical_day,summer_typical_day,transition_typical_day);
            break;
        end
    end
end
