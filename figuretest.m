figure
 plot(1:24, elite_follow(1,4:5:119), 'linewidth',2)%冬热
%plot(1:24, elite_follow(1,124:5:239), 'linewidth',2)%夏冷
%plot(1:24, elite_follow(244:6:382), 'linewidth',2)%过渡冷
%plot(1:24, elite_follow(246:6:384), 'linewidth',2)%过渡热

% plot(1:24, elite(2:4:94), 'linewidth',2)%冬电
%plot(1:24, elite(98:3:167), 'linewidth',2)%夏电
%plot(1:24, elite(170:4:262), 'linewidth',2)%过渡电
xlabel('Time','fontsize',15);
ylabel('P_c_ES','fontsize',15);
sum=0;
for i=170:4:262
    sum=sum+elite(i);
end
sum