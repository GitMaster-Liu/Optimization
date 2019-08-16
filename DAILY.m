
% X=[];
% %规划容量
% X(1,:) = chromosome(13,1:7);
% X(2,:) = chromosome(2,1:7);
% X(3,:) = chromosome(23,1:7);
% X(4,:) = chromosome(10,1:7);
% X(5,:) = chromosome(74,1:7);
% X(6,:) = chromosome(49,1:7);

% num=[6*10^8,6*10^5,1,2*10^8];
Y=[];
% Y(1,:) = num-chromosome(13,8:11);
% Y(2,:) = num-chromosome(2,8:11);
% Y(3,:) = num-chromosome(23,8:11);
% Y(4,:) = num-chromosome(10,8:11);
% Y(5,:) = num-chromosome(74,8:11);
% Y(6,:) = num-chromosome(49,8:11);

Y(1,:) = chromosome(13,8:11);
Y(2,:) = chromosome(2,8:11);
Y(3,:) = chromosome(23,8:11);
Y(4,:) = chromosome(10,8:11);
Y(5,:) = chromosome(74,8:11);
Y(6,:) = chromosome(49,8:11);

for i=1:23
    Y(i,:) = chromosome(i,8:11);
end


% Y(1,5)=10-investment_payoff_period(13);
% Y(2,5)=10-investment_payoff_period(2);
% Y(3,5)=10-investment_payoff_period(23);
% Y(4,5)=10-investment_payoff_period(10);
% Y(5,5)=10-investment_payoff_period(74);
% Y(6,5)=10-investment_payoff_period(49);


for i=1:23
    Y(i,5)=10-investment_payoff_period(i);
end

%5大指标
X=Y(:,1:4);
Y=Y(:,5);
%% 归一化处理
max_X = max(X);
min_X  = min(X);
max_Y = max(Y);
min_Y = min(Y);
max_x_mat = repmat(max_X,[23,1]);
min_x_mat = repmat(min_X, [23,1]);
max_y_mat = repmat(max_Y, [23,1]);
min_y_mat = repmat(min_Y, [23,1]);
X = (X-min_x_mat)./(max_x_mat-min_x_mat);
Y = (Y-min_y_mat)./(max_y_mat - min_y_mat);





%  io = dea(X(1,:),Y(1,:),'orient','io');

io_crs = dea(X, Y, 'orient', 'io');
fprintf(' Dea crs \n');
deadisp(io_crs);
% CRS theta
crs_eff = io_crs.eff;

fprintf('Dea vrs\n')
io_vrs = dea(X,Y,'orient', 'io', 'rts', 'vrs');
deadisp(io_vrs);
vrs_eff = io_vrs.eff;

fprintf('Dea scale\n');
io_scale = deascale(X, Y, 'orient', 'io');
deadisp(io_scale);
scale_eff = io_scale.eff.scale; 

figure;
plot(crs_eff, 'b*-');
% hold on;
% plot( vrs_eff, 'ro--');
% hold on;
% plot(scale_eff, 'kd--');

%绘制输入数据的图像
% figure;
% plot(X(:,1),'b*-');
% hold on;
% plot(X(:,2),'ro--');
% hold on;
% plot(Y(:,1),'m+:');
% hold on;
% plot(Y(:,2),'ks--');
xlabel("备选方案");
ylabel("综合效率");