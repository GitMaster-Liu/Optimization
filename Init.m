function  x  = Init( winter_typical_day,summer_typical_day,transition_typical_day,cop_equipment )
x=[];
%% �����߽�
bonder_Max=[140 140 390 340 100 400 400];
bonder_MIn=[30 30 30 20 20 50 50];
%���ɱ߽�:�硢�䡢�� ��λ100KW
MAX_Elec = 140; 
MAX_Cold = 390;
MAX_Hot = 340;
MIN_Elec = 30;
MIN_Cold = 30;
MIN_Hot = 20;
%�����߽磺�硢�䡢�� ��λ100KW
MAX_PN_Elec = 20*5;
MAX_PN_Cold = 50*8;
MAX_PN_Hot = 50*8;
MIN_PN_Elec = 20;   %���洢���ʣ�ҲΪ���������С����
MIN_PN_Cold = 50;
MIN_PN_Hot = 50;
%% ���ӷֶ�����
Num_winer = 4;%�����豸����
Num_summer = 3;
Num_transition = 4;
Index_winter = 1;
Index_summer = Index_winter+Num_winer*24;
Index_trasition = Index_summer+Num_summer*24;
%% ��ʼ������ 
Xn(1:7)=[140 140 390 340 100 400 400];
%�������
% Xn(1) = round(unifrnd(MIN_Elec, MAX_Elec));    %PV
% Xn(2) = round(unifrnd(MIN_Elec, MAX_Elec));    %CCHP
alpha_2 = 0.3;  %���ط�Χϵ��
% Xn(3) = round(unifrnd(MIN_Hot, MAX_Cold));     %HP
alpha_3 = 0.2;
% Xn(4) = round(unifrnd(MIN_Hot, MAX_Hot));     %GB
alpha_4 = 0.3;
% Xn(5) = round(unifrnd(MIN_PN_Elec, MAX_PN_Elec));   %�����洢������
alpha_5 = 0.1;
alpha_6 = 0.9;
% x(6) = round(unifrnd(MIN_PN_Cold, MAX_PN_Cold));   %��
% x(7) = round(unifrnd(MIN_PN_Hot, MAX_PN_Hot));     %��

%% ����
H = alpha_6*Xn(5);   %�索��޹�λH����ʼΪ����
n=1;
j=1;
while n&&(j<100)
    j=j+1;
    for i=Index_winter:Num_winer:(Index_winter+Num_winer*22)   %������8-103�ţ�ǰ23Сʱ��8-99��
        k=1;
        m=1;
        while k&&(m<100)        %���һ���ʼֵ
            m=m+1;
            x(i) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %���CCHP�ķ�����
            x(i+1) = round(unifrnd((-1)*min(alpha_6*Xn(5)-H,MIN_PN_Elec)...
                ,min(H-alpha_5*Xn(5),MIN_PN_Elec)));   %����洢������Ϊ�ͷţ���Ϊ�洢
            x(i+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %���HP�ķ�����
            %H_temp=H-x(i+1)+x(i+2);     %�����жϵ�ǰ��Һλ�Ƿ���
            %����PV+CCHP+Pds <= Pch+����+HP�ĺĵ磬����Һλ�����ڵ��ޣ������������������ (������繦��=����ǿ��*����)
            if (Xn(1) * winter_typical_day(floor((i-Index_winter)/Num_winer)+1,3) + x(i) + x(i+1)...
                    <= winter_typical_day(floor((i-Index_winter)/Num_winer)+1,1) + x(i+2)/cop_equipment(3,3))
                k = 0;
            end
        end
        x(i+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %���GB�ķ�����
        %����ǰ23��Сʱ��ŵ�ĺ�ÿ��Сʱ�ı䵱ǰ�Ĺ�λ H=H+Pch-Pds
        H = H-x(i+1);
    end
    if (alpha_6*Xn(5)-H<MIN_PN_Elec)     %��24��Сʱʣ��Ĳ�ֵ����С�ڳ�繦��
        n=0;
    end
end
%��24��Сʱ�Ѵ���޳���,ֻ�ܳ岻�ܷ�
x(Index_winter+Num_winer*23+1)=H-alpha_6*Xn(5);
k=1;
n=1;
while k&&(n<100)         %�����һСʱ�ı�������ʼֵ
    n=n+1;
    x(Index_winter+Num_winer*23) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %���CCHP�ķ�����
    x(Index_winter+Num_winer*23+2) = round(unifrnd(alpha_3*Xn(3)+1, Xn(3)+1));  %���HP�ķ�����
    if (Xn(1) * winter_typical_day(24,3) + x(Index_winter+Num_winer*23) + x(Index_winter+Num_winer*23+1)...
            < winter_typical_day(24,1) + x(Index_winter+Num_winer*23+2)/cop_equipment(3,3))
       k = 0;
    end
end
x(Index_winter+Num_winer*23+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %���GB�ķ�����

%% �ļ�
H = alpha_6*Xn(5);   %�索��޹�λH����ʼΪ����
n=1;
j=1;
while n&&(j<100)
    j=j+1;
    for i=Index_summer:Num_summer:(Index_summer+Num_summer*22)  %(104-175)
        k=1;
        n=1;
        while k&&(n<100) %���һ���ʼֵ
            n=n+1;
            x(i) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %���CCHP�ķ�����
            x(i+1) = round(unifrnd((-1)*min(alpha_6*Xn(5)-H,MIN_PN_Elec)...
                ,min(H-alpha_5*Xn(5),MIN_PN_Elec)));   %����洢������Ϊ�ͷţ���Ϊ�洢
            x(i+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %���HP��������
            %����PV+CCHP+Pds <= Pch+����+HP�ĺĵ磬����������������� (������繦��=����ǿ��*����)
            if (Xn(1) * summer_typical_day(floor((i-Index_summer)/Num_summer)+1,3) + x(i) + x(i+1) ...
                    <=  summer_typical_day(floor((i-Index_summer)/Num_summer)+1,1) + x(i+2)/cop_equipment(3,2))
                k = 0;
            end
        end
        %����ǰ23��Сʱ��ŵ�ĺ�ÿ��Сʱ�ı䵱ǰ�Ĺ�λ H=H+Pch-Pds
        H = H-x(i+1);
    end
    if (alpha_6*Xn(5)-H<MIN_PN_Elec)
        n=0;
    end
end
%��24��Сʱ�Ѵ���޳���,ֻ�ܳ岻�ܷ�
x(Index_summer+Num_summer*23+1)=H-alpha_6*Xn(5);
k=1;
n=1;
while k&&(n<100)         %�����һСʱ�ı�������ʼֵ
    n=n+1;
    x(Index_summer+Num_summer*23) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %���CCHP�ķ�����
    x(Index_summer+Num_summer*23+2) = round(unifrnd(alpha_3*Xn(3)+1, Xn(3)+1));  %���HP��������
    if (Xn(1) * summer_typical_day(24,3) + x(Index_summer+Num_summer*23) + x(Index_summer+Num_summer*23+1)...
            <= summer_typical_day(24,1) + x(Index_summer+Num_summer*23+2)/cop_equipment(3,3))
       k = 0;
    end
end

%% ���ɼ�
H = alpha_6*Xn(5);   %�索��޹�λH����ʼΪ����
n=1;
j=1;
while n&&(j<100)
    j=j+1;
    for i=Index_trasition:Num_transition:Index_trasition+Num_transition*22  %(176-271)
        k=1;
        n=1;
        while k&&(n<100) %���һ���ʼֵ
            n=n+1;
            x(i) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %���CCHP�ķ�����
            x(i+1) = round(unifrnd((-1)*min(alpha_6*Xn(5)-H,MIN_PN_Elec)...
                ,min(H-alpha_5*Xn(5),MIN_PN_Elec)));   %����洢������Ϊ�ͷţ���Ϊ�洢
            x(i+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %���HP�ķ�����
            %����PV+CCHP+Pds <= Pch+����+HP�ĺĵ磬����������������� (������繦��=����ǿ��*����)
            if (Xn(1) * transition_typical_day(floor((i-Index_trasition)/Num_transition)+1,4) + x(i) + x(i+1) ...
                    <= transition_typical_day(floor((i-Index_trasition)/Num_transition)+1,1) + x(i+2)/cop_equipment(3,3))
                k = 0;
            end
        end
        x(i+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %���GB�ķ�����
        %����ǰ23��Сʱ��ŵ�ĺ�ÿ��Сʱ�ı䵱ǰ�Ĺ�λ H=H+Pch-Pds
        H = H-x(i+1);
    end
    if (alpha_6*Xn(5)-H<MIN_PN_Elec)
        n=0;
    end
end
%��24��Сʱ�Ѵ���޳���,ֻ�ܳ岻�ܷ�
x(Index_trasition+Num_transition*23+1)=H-alpha_6*Xn(5);
k=1;
n=1;
while k&&(n<100)         %�����һСʱ�ı�������ʼֵ
    n=n+1;
    x(Index_trasition+Num_transition*23) = round(unifrnd(alpha_2*Xn(2), Xn(2)));  %���CCHP�ķ�����
    x(Index_trasition+Num_transition*23+2) = round(unifrnd(alpha_3*Xn(3), Xn(3)));  %���HP�ķ�����
    if (Xn(1) * transition_typical_day(24,4) + x(Index_trasition+Num_transition*23) + x(Index_trasition+Num_transition*23+1)...
            <= transition_typical_day(24,1) + x(Index_trasition+Num_transition*23+2)/cop_equipment(3,3))
       k = 0;
    end
end
x(Index_trasition+Num_transition*23+3) = round(unifrnd(alpha_4*Xn(4), Xn(4)));  %���GB�ķ�����
%% ��CCHP�Ĺ��ʽ��г�2����
% for i=8:5:123
%     x(i)=0.5*x(i);
% end
% for i=128:4:221
%     x(i)=0.5*x(i);
% end
% for i=224:5:339
%     x(i)=0.5*x(i);
% end
