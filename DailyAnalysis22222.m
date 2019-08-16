clc;
clear all;
dataPath = 'Compressor01.xlsx';

%7:00 - 15:00
%15:00 - 22;00
%22:00 - 7:00
% Input Flow
inputOpening = [xlsread(dataPath,'C15:C99')];
% Energy cost
motorCurrent = [xlsread(dataPath,'D15:D99')];
% output temprature
outPressure = [xlsread(dataPath,'E15:E99')];
%Third part input temprature
inputTemprature = [xlsread(dataPath, 'G15:G99')];

% 构建模型
% Input： 电流值 + 三级入口温度
% 三级入口温度，体现外界气温和压强等环境变化对系统的影响
X = [inputTemprature, motorCurrent];
Y = [outPressure, inputOpening];

io = dea(X,Y,'orient','io');

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
hold on;
plot( vrs_eff, 'ro--');
hold on;
plot(scale_eff, 'kd--');

%绘制输入数据的图像
figure;
plot(X(:,1),'b*-');
hold on;
plot(X(:,2),'ro--');
hold on;
plot(Y(:,1),'m+:');
hold on;
plot(Y(:,2),'ks--');