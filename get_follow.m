function follow = get_follow(N, chromosome,winter_typical_day,summer_typical_day,transition_typical_day)
%% 此函数是为了在获得染色体编码后得到随动量
follow=[];
cop_equipment = [0.157,-1,-1;-2,1.36,1.20;-1,5,4;-1,-1,0.85];

winter_num=5;
summer_num=5;
transition_num=6;
chromo_winter_num=4;
chromo_summer_num=3;
chromo_transition_num=4;

%先分析冬季
yita_e_cchp=[];
for i=0:23
    follow(1+winter_num*i)= winter_typical_day(i+1,3)*N(5);%P_e_pv
    follow(2+winter_num*i)=chromosome(3+chromo_winter_num*i)/cop_equipment(3,3);%P_e_hp
    follow(3+winter_num*i) = winter_typical_day(i+1,1)-follow(1+winter_num*i) ...
    -chromosome(1+chromo_winter_num*i)-chromosome(2+chromo_winter_num*i) ...
    +follow(2+winter_num*i);%P_e_buy
    yita_e_cchp(i+1)=0.4166*(chromosome(1+chromo_winter_num*i)./200).^3-1.0135*(chromosome(1+chromo_winter_num*i)./200).^2 ...
        +0.8365*(chromosome(1+5*i)./200)+0.0926;
    follow(5+winter_num*i)=0.85.*cop_equipment(2,3).*chromosome(1+chromo_winter_num*i)*(1-yita_e_cchp(i+1)-0.15) ...
        ./yita_e_cchp(i+1);%P_h_cchp
    
    follow(4+winter_num*i)=winter_typical_day(i+1,2)-chromosome(3+chromo_winter_num*i)-chromosome(4+chromo_winter_num*i);%P_h_ES
end

%再分析夏季
yita_e_cchp=[];
for i=0:23
    follow(121+summer_num*i)= summer_typical_day(i+1,3)*N(5);%P_e_pv
    follow(122+summer_num*i)=chromosome(99+chromo_summer_num*i)/cop_equipment(3,2);%P_e_hp
    follow(123+summer_num*i) = summer_typical_day(i+1,1)-follow(121+summer_num*i) ...
    -chromosome(97+chromo_summer_num*i)-chromosome(98+chromo_summer_num*i) ...
    +follow(122+summer_num*i);%P_e_buy
    yita_e_cchp(i+1)=0.4166*(chromosome(97+chromo_summer_num*i)./200).^3-1.0135*(chromosome(97+chromo_summer_num*i)./200).^2 ...
        +0.8365*(chromosome(97+4*i)./200)+0.0926;
    follow(125+summer_num*i)=0.85.*cop_equipment(2,2).*chromosome(97+chromo_summer_num*i)*(1-yita_e_cchp(i+1)-0.15) ...
        ./yita_e_cchp(i+1);%P_c_cchp
    
    follow(124+summer_num*i)=summer_typical_day(i+1,2)-chromosome(99+chromo_summer_num*i)-follow(124+summer_num*i);%P_c_ES
end
    
    
%最后分析过渡季
yita_e_cchp=[];
for i=0:23
    follow(241+transition_num*i)= transition_typical_day(i+1,4)*chromosome(5);%P_e_pv
    follow(242+transition_num*i)=chromosome(171+chromo_transition_num*i)/cop_equipment(3,3);%P_e_hp
    follow(243+transition_num*i) = transition_typical_day(i+1,1)-follow(241+transition_num*i) ...
    -chromosome(169+chromo_transition_num*i)-chromosome(170+chromo_transition_num*i)+follow(242+transition_num*i);%P_e_buy
    yita_e_cchp(i+1)=0.4166*(chromosome(169+chromo_transition_num*i)./200).^3-1.0135*(chromosome(169+chromo_transition_num*i)./200).^2 ...
        +0.8365*(chromosome(169+chromo_transition_num*i)./200)+0.0926;
    follow(245+transition_num*i)=0.85.*cop_equipment(2,2).*chromosome(169+chromo_transition_num*i)*(1-yita_e_cchp(i+1)-0.15) ...
        ./yita_e_cchp(i+1);%P_c_cchp
    
    follow(244+transition_num*i)=transition_typical_day(i+1,2)-follow(245+transition_num*i);%制冷量P_c_ES
  
    follow(246+transition_num*i)=transition_typical_day(i+1,3)-chromosome(171+chromo_transition_num*i)-chromosome(172+chromo_transition_num*i);%检查是储热还是放热

end






