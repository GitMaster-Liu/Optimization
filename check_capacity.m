function [ output ] = check_capacity( capacity_series )
%CHECK_CAPACITY �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% Input
% capacity_series -�豸װ������
% min_load_elec - ��С�縺��
% min_load_cooling - ��С�为��
% min_load_heat - ��С�ȸ���

% return output 
% 0 - �����㣬 1 - ����

%% ******************Test****************
% capacity_series = [44 44 63 23 54 279 303];
% �������ļ������ȼ�
% max_load_elec = [11180.4 13762.35 11190];
min_load_elec = [4328.723438 6808.380469 6865.40625];
% max_load_cooling = [0 38229.67529 0];
min_load_cooling = [0 9695.909288 0];
% max_load_heat = [33950.24609 0 6807.4];
min_load_heat = [14780.02832 0 2484.6];

% ����Сֵ���任������λ,��������Ϊ�������ݼ���
min_load_elec = min(min_load_elec(min_load_elec~=0))/100 ;
min_load_heat = min(min_load_heat(min_load_heat~=0))/100;
min_load_cooling = min(min_load_cooling(min_load_cooling~=0))/100;
%*************************End Test**********
% CCHP �������
cop_h_cchp = 1.2;
cop_c_cchp = 1.36;
cchp_yita_dis = 0.15;
cchp_yita_waste = 0.85;
cchp_yita = 0.4;

% % ���ǹ��ȼ���CCHP������С���縺��
% �縺�ɲ��ÿ��ǣ���Ϊ�����⹺��
min_prod_elec = 0.3 * capacity_series(2);

% ���ǹ��ȼ���CCHP ��������������С�ȸ���
min_prod_heat = 0.3 * capacity_series(2)*(1 - cchp_yita_dis - cchp_yita)* ...
    cop_h_cchp/cchp_yita;
% �����ļ���CCHP+��Դ�ȱ���С����������С�为��
min_prod_cooling =  0.3 * capacity_series(2)*(1 - cchp_yita_dis - cchp_yita_waste)* ...
    cop_c_cchp/cchp_yita + 0.2 * capacity_series(3);

output = 0;
if(min_prod_elec < min_load_elec && ...
        min_prod_heat < min_load_heat && ...
        min_prod_cooling < min_load_cooling)
    output = 1;
end


end

