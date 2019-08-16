function [pass_flag] = check1( x,winter_typical_day,summer_typical_day,transition_typical_day,cop_equipment )
%��������Ƿ�����Լ�������������������
pass_flag=true;
%% ���ӷֶ�����
Num_winter = 4;%�����豸����
Num_summer = 3;
Num_transition = 4;
Index_winter = 1;
Index_summer = Index_winter+Num_winter*24;
Index_trasition = Index_summer+Num_summer*24;

%% �����߽�
Xn(1:7)=[140 140 390 340 100 400 400];
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
MIN_PN_Elec = Xn(5)*0.2;   %���洢���ʣ�ҲΪ���������С����
MIN_PN_Cold = 50;
MIN_PN_Hot = 50;
%% ��������Ƿ�����Լ�������������������
k=ones(1,72);
Electric_Load=zeros(1,72);
%����
H=0;
for i=Index_winter:Num_winter:(Index_winter+Num_winter*23)
    H=H-x(i+1);
    if (Xn(1) * winter_typical_day((i-Index_winter)/Num_winter+1,3) + x(i) + x(i+1)...
            <= winter_typical_day((i-Index_winter)/Num_winter+1,1) + x(i+2)/cop_equipment(3,3)...
            && (-1)*MIN_PN_Elec<=x(i+1)<=MIN_PN_Elec...
            && (-1)*MAX_PN_Elec<= H <=MAX_PN_Elec )
        k((i-Index_winter)/Num_winter+1) = 0;
    end
    Electric_Load((i-Index_winter)/Num_winter+1)=(winter_typical_day((i-Index_winter)/Num_winter+1,1) + x(i+2)/cop_equipment(3,3))-...
        (Xn(1) * winter_typical_day((i-Index_winter)/Num_winter+1,3) + x(i) + x(i+1));
end
%�ļ�
H=0;
for i=Index_summer:Num_summer:(Index_summer+Num_summer*23)  %(104-175)
    H=H-x(i+1);
    if (Xn(1) * summer_typical_day((i-Index_summer)/Num_summer+1,3) + x(i) + x(i+1) ...
            <= summer_typical_day((i-Index_summer)/Num_summer+1,1) + x(i+2)/cop_equipment(3,2)...
            && (-1)*MIN_PN_Elec<=x(i+1)<=MIN_PN_Elec...
            && (-1)*MAX_PN_Elec<= H <=MAX_PN_Elec)
        k((i-Index_summer)/Num_summer+24+1) = 0;
    end
    Electric_Load((i-Index_summer)/Num_summer+24+1)=(summer_typical_day((i-Index_summer)/Num_summer+1,1) + x(i+2)/cop_equipment(3,2))...
        - (Xn(1) * summer_typical_day((i-Index_summer)/Num_summer+1,3) + x(i) + x(i+1));
end
%���ɼ�
H=0;
for i=Index_trasition:Num_transition:Index_trasition+Num_transition*23  %(176-271)
    H=H-x(i+1);
    if (Xn(1) * transition_typical_day((i-Index_trasition)/Num_transition+1,4) + x(i) + x(i+1) ...
            <= transition_typical_day((i-Index_trasition)/Num_transition+1,1) + x(i+2)/cop_equipment(3,3)...
            && (-1)*MIN_PN_Elec<=x(i+1)<=MIN_PN_Elec...
            && (-1)*MAX_PN_Elec<= H <=MAX_PN_Elec)
        k((i-Index_trasition)/Num_transition+48+1) = 0;
    end
    Electric_Load((i-Index_trasition)/Num_transition+48+1)=(transition_typical_day((i-Index_trasition)/Num_transition+1,1) + x(i+2)/cop_equipment(3,3))...
        -(Xn(1) * transition_typical_day((i-Index_trasition)/Num_transition+1,4) + x(i) + x(i+1));

end
%�粻����������һ�����������³�ʼ��һ������
% t=1:72;
% plot(t,Electric_Load,'rx');
if norm(k,2)~=0
    %x=Init(winter_typical_day,summer_typical_day,transition_typical_day,cop_equipment);
    pass_flag=false;
end

end

