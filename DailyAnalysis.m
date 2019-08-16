load('chromosome.mat');
X = [chromosome(:,1:7)];%规划容量
X=[X,elite];
Y = [chromosome(:,8:11)];%5大指标
% Y = abs(Y);
% Y = Y(:,1:2);
%X=[X];
X=X(:,1:2);
% Y=Y(:,1:2);
max_X = max(X);
min_X  = min(X);
max_Y = max(Y);
min_Y = min(Y);
max_x_mat = repmat(max_X,[length(X),1]);
min_x_mat = repmat(min_X, [length(X),1]);
max_y_mat = repmat(max_Y, [length(Y),1]);
min_y_mat = repmat(min_Y, [length(Y),1]);
X1 = (X-min_x_mat)./(max_x_mat-min_x_mat);
Y2 = (Y-min_y_mat)./(max_y_mat - min_y_mat);

% for i=1:10
% X(i,:)=(X(i,:)-min_X)/(max_X-min_X);
% end
X = Y2(:,1:2);
Y = Y2(:,3:4);
% io = dea(Y2(:,1:2), Y2(:,3:4),'orient','io');
io_crs = dea(X,Y, 'orient', 'io');
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
hold on;
plot( vrs_eff, 'ro--');
hold on;
plot(scale_eff, 'kd--');

%绘制输入数据的图像
% figure;
% plot(X(:,1),'b*-');
% hold on;
% plot(X(:,2),'ro--');
% hold on;
% plot(Y(:,1),'m+:');
% hold on;
% plot(Y(:,2),'ks--');