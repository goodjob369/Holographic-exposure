function varargout = PolarizationGratingAlgorithms_Enhanced(varargin)
% 增强的偏振光栅算法模块 - 支持所有类型的偏振光栅生成
% Enhanced Polarization Grating Algorithms Module
% 版本: 4.0 - 2024年12月
% 版权所有 © 个人Z.Y团队Y.M
% 
% 支持的偏振光栅类型:
% 1. 线性偏振光栅 (Linear Polarization Grating)
% 2. 圆偏振光栅 (Circular Polarization Grating)
% 3. 涡旋光光栅 (Vortex Beam Grating)
% 4. 方位型偏振光栅 (Azimuthal Polarization Grating)
% 5. 二维偏振光栅 (2D Polarization Grating)
% 6. 个性化偏振光栅 (Custom Polarization Grating)
%    - 方形9点偏振光栅 (Square 9-point)
%    - 六边形9点偏振光栅 (Hexagonal 9-point)

%% 算法参数
if nargin == 0
    % 返回支持的光栅类型
    varargout{1} = getSupportedGratingTypes();
    return;
end

gratingType = varargin{1};
params = varargin{2};

% 默认参数
defaultParams = struct(...
    'width', 512, ...
    'height', 512, ...
    'period', 20, ...
    'amplitude', 1, ...
    'phase', 0, ...
    'colorMode', 'grayscale', ...
    'customPoints', [], ...
    'rotationAngle', 0 ...
);

% 合并参数
if isempty(params)
    params = defaultParams;
else
    fields = fieldnames(defaultParams);
    for i = 1:length(fields)
        if ~isfield(params, fields{i})
            params.(fields{i}) = defaultParams.(fields{i});
        end
    end
end

%% 生成偏振光栅
switch lower(gratingType)
    case 'linear'
        [pattern, info] = generateLinearPolarizationGrating(params);
    case 'circular'
        [pattern, info] = generateCircularPolarizationGrating(params);
    case 'vortex'
        [pattern, info] = generateVortexBeamGrating(params);
    case 'azimuthal'
        [pattern, info] = generateAzimuthalPolarizationGrating(params);
    case '2d'
        [pattern, info] = generate2DPolarizationGrating(params);
    case 'square9'
        [pattern, info] = generateSquare9PointGrating(params);
    case 'hexagon9'
        [pattern, info] = generateHexagon9PointGrating(params);
    otherwise
        error('不支持的偏振光栅类型: %s', gratingType);
end

varargout{1} = pattern;
if nargout > 1
    varargout{2} = info;
end

end

%% 支持的光栅类型
function types = getSupportedGratingTypes()
types = struct(...
    'linear', '线性偏振光栅', ...
    'circular', '圆偏振光栅', ...
    'vortex', '涡旋光光栅', ...
    'azimuthal', '方位型偏振光栅', ...
    '2d', '二维偏振光栅', ...
    'square9', '方形9点偏振光栅', ...
    'hexagon9', '六边形9点偏振光栅' ...
);
end

%% 1. 线性偏振光栅
function [pattern, info] = generateLinearPolarizationGrating(params)
% 线性偏振光栅 - 基于Pancharatnam-Berry相位原理
[X, Y] = meshgrid(1:params.width, 1:params.height);

% 线性偏振光栅的相位分布
phi = 2 * pi * X / params.period + params.phase;

% 琼斯矩阵表示
if strcmp(params.colorMode, 'color')
    % 彩色模式 - 复数相位编码
    pattern = zeros(params.height, params.width, 3);
    pattern(:,:,1) = params.amplitude * cos(phi); % 红色通道
    pattern(:,:,2) = params.amplitude * sin(phi); % 绿色通道
    pattern(:,:,3) = params.amplitude * cos(phi + pi/2); % 蓝色通道
else
    % 灰度模式 - 强度编码
    pattern = params.amplitude * (0.5 + 0.5 * cos(phi));
end

info = struct(...
    'type', '线性偏振光栅', ...
    'algorithm', 'Pancharatnam-Berry相位', ...
    'formula', 'φ(x) = 2πx/Λ + φ₀', ...
    'period', params.period, ...
    'colorMode', params.colorMode ...
);
end

%% 2. 圆偏振光栅
function [pattern, info] = generateCircularPolarizationGrating(params)
% 圆偏振光栅 - 产生左旋和右旋圆偏振光
[X, Y] = meshgrid(1:params.width, 1:params.height);

% 圆偏振光栅的相位分布
phi = 2 * pi * X / params.period + params.phase;
theta = atan2(Y - params.height/2, X - params.width/2);

if strcmp(params.colorMode, 'color')
    % 彩色模式 - 显示左旋和右旋分量
    pattern = zeros(params.height, params.width, 3);
    % 左旋圆偏振 (红色通道)
    pattern(:,:,1) = params.amplitude * (0.5 + 0.5 * cos(phi + theta));
    % 右旋圆偏振 (蓝色通道)
    pattern(:,:,3) = params.amplitude * (0.5 + 0.5 * cos(phi - theta));
    % 线性分量 (绿色通道)
    pattern(:,:,2) = params.amplitude * (0.5 + 0.5 * cos(phi));
else
    % 灰度模式
    pattern = params.amplitude * (0.5 + 0.5 * cos(phi + theta));
end

info = struct(...
    'type', '圆偏振光栅', ...
    'algorithm', '几何相位调制', ...
    'formula', 'φ(x,y) = 2πx/Λ ± θ(x,y)', ...
    'period', params.period, ...
    'colorMode', params.colorMode ...
);
end

%% 3. 涡旋光光栅
function [pattern, info] = generateVortexBeamGrating(params)
% 涡旋光光栅 - 产生轨道角动量
[X, Y] = meshgrid(1:params.width, 1:params.height);
X = X - params.width/2;
Y = Y - params.height/2;

% 涡旋相位
theta = atan2(Y, X);
r = sqrt(X.^2 + Y.^2);

% 拓扑荷数 (默认为1)
topologicalCharge = 1;
if isfield(params, 'topologicalCharge')
    topologicalCharge = params.topologicalCharge;
end

vortexPhase = topologicalCharge * theta;
gratingPhase = 2 * pi * X / params.period;

if strcmp(params.colorMode, 'color')
    % 彩色模式 - 显示相位分布
    pattern = zeros(params.height, params.width, 3);
    pattern(:,:,1) = params.amplitude * (0.5 + 0.5 * cos(vortexPhase + gratingPhase));
    pattern(:,:,2) = params.amplitude * (0.5 + 0.5 * sin(vortexPhase + gratingPhase));
    pattern(:,:,3) = params.amplitude * (0.5 + 0.5 * cos(2*vortexPhase));
else
    % 灰度模式
    pattern = params.amplitude * (0.5 + 0.5 * cos(vortexPhase + gratingPhase));
end

info = struct(...
    'type', '涡旋光光栅', ...
    'algorithm', '拓扑相位调制', ...
    'formula', 'φ(r,θ) = lθ + 2πx/Λ', ...
    'topologicalCharge', topologicalCharge, ...
    'colorMode', params.colorMode ...
);
end

%% 4. 方位型偏振光栅
function [pattern, info] = generateAzimuthalPolarizationGrating(params)
% 方位型偏振光栅 - 径向和角向偏振
[X, Y] = meshgrid(1:params.width, 1:params.height);
X = X - params.width/2;
Y = Y - params.height/2;

theta = atan2(Y, X);
r = sqrt(X.^2 + Y.^2);

% 方位角调制
azimuthalPhase = 2 * theta + params.phase;
radialModulation = sin(2 * pi * r / params.period);

if strcmp(params.colorMode, 'color')
    % 彩色模式
    pattern = zeros(params.height, params.width, 3);
    pattern(:,:,1) = params.amplitude * (0.5 + 0.5 * cos(azimuthalPhase) .* radialModulation);
    pattern(:,:,2) = params.amplitude * (0.5 + 0.5 * sin(azimuthalPhase) .* radialModulation);
    pattern(:,:,3) = params.amplitude * (0.5 + 0.5 * cos(azimuthalPhase + pi/2));
else
    % 灰度模式
    pattern = params.amplitude * (0.5 + 0.5 * cos(azimuthalPhase) .* radialModulation);
end

info = struct(...
    'type', '方位型偏振光栅', ...
    'algorithm', '径向-角向相位调制', ...
    'formula', 'φ(r,θ) = 2θ + sin(2πr/Λ)', ...
    'period', params.period, ...
    'colorMode', params.colorMode ...
);
end

%% 5. 二维偏振光栅
function [pattern, info] = generate2DPolarizationGrating(params)
% 二维偏振光栅 - X和Y方向同时调制
[X, Y] = meshgrid(1:params.width, 1:params.height);

% 二维光栅相位
phaseX = 2 * pi * X / params.period;
phaseY = 2 * pi * Y / params.period;
phase2D = phaseX + phaseY + params.phase;

if strcmp(params.colorMode, 'color')
    % 彩色模式
    pattern = zeros(params.height, params.width, 3);
    pattern(:,:,1) = params.amplitude * (0.5 + 0.5 * cos(phaseX));
    pattern(:,:,2) = params.amplitude * (0.5 + 0.5 * cos(phaseY));
    pattern(:,:,3) = params.amplitude * (0.5 + 0.5 * cos(phase2D));
else
    % 灰度模式
    pattern = params.amplitude * (0.5 + 0.5 * cos(phase2D));
end

info = struct(...
    'type', '二维偏振光栅', ...
    'algorithm', '二维相位调制', ...
    'formula', 'φ(x,y) = 2π(x+y)/Λ + φ₀', ...
    'period', params.period, ...
    'colorMode', params.colorMode ...
);
end

%% 6. 方形9点偏振光栅
function [pattern, info] = generateSquare9PointGrating(params)
% 方形9点偏振光栅 - 个性化定制
pattern = zeros(params.height, params.width);

% 计算9个点的位置 (3x3网格)
centerX = params.width / 2;
centerY = params.height / 2;
spacing = params.period * 2; % 点间距

positions = zeros(9, 2);
idx = 1;
for i = -1:1
    for j = -1:1
        positions(idx, :) = [centerX + i*spacing, centerY + j*spacing];
        idx = idx + 1;
    end
end

% 生成每个点的相位分布
for i = 1:9
    x0 = positions(i, 1);
    y0 = positions(i, 2);
    
    [X, Y] = meshgrid(1:params.width, 1:params.height);
    
    % 高斯包络
    sigma = params.period / 2;
    envelope = exp(-((X-x0).^2 + (Y-y0).^2) / (2*sigma^2));
    
    % 相位调制 (每个点不同的相位)
    pointPhase = (i-1) * 2*pi/9 + params.phase;
    
    if strcmp(params.colorMode, 'color')
        if i == 1
            pattern = zeros(params.height, params.width, 3);
        end
        pattern(:,:,1) = pattern(:,:,1) + params.amplitude * envelope .* cos(pointPhase);
        pattern(:,:,2) = pattern(:,:,2) + params.amplitude * envelope .* sin(pointPhase);
        pattern(:,:,3) = pattern(:,:,3) + params.amplitude * envelope .* cos(pointPhase + pi/2);
    else
        pattern = pattern + params.amplitude * envelope .* (0.5 + 0.5 * cos(pointPhase));
    end
end

% 归一化
if strcmp(params.colorMode, 'color')
    pattern = pattern / max(pattern(:));
else
    pattern = pattern / max(pattern(:));
end

info = struct(...
    'type', '方形9点偏振光栅', ...
    'algorithm', '多点相位调制', ...
    'formula', 'φᵢ = 2π(i-1)/9 + φ₀', ...
    'points', 9, ...
    'arrangement', '3×3方形阵列', ...
    'colorMode', params.colorMode ...
);
end

%% 7. 六边形9点偏振光栅
function [pattern, info] = generateHexagon9PointGrating(params)
% 六边形9点偏振光栅 - 蜂窝结构
pattern = zeros(params.height, params.width);

centerX = params.width / 2;
centerY = params.height / 2;
radius = params.period * 1.5;

% 六边形排列：中心1个点 + 周围6个点 + 外围2个点
positions = zeros(9, 2);
positions(1, :) = [centerX, centerY]; % 中心点

% 内层六边形 (6个点)
for i = 1:6
    angle = (i-1) * pi/3;
    positions(i+1, :) = [centerX + radius*cos(angle), centerY + radius*sin(angle)];
end

% 外层点 (2个点)
positions(8, :) = [centerX + radius*1.5, centerY];
positions(9, :) = [centerX - radius*1.5, centerY];

% 生成每个点的相位分布
for i = 1:9
    x0 = positions(i, 1);
    y0 = positions(i, 2);
    
    [X, Y] = meshgrid(1:params.width, 1:params.height);
    
    % 高斯包络
    sigma = params.period / 3;
    envelope = exp(-((X-x0).^2 + (Y-y0).^2) / (2*sigma^2));
    
    % 六边形对称相位
    if i == 1
        pointPhase = 0; % 中心点
    elseif i <= 7
        pointPhase = (i-2) * pi/3 + params.phase; % 六边形点
    else
        pointPhase = pi + params.phase; % 外围点
    end
    
    if strcmp(params.colorMode, 'color')
        if i == 1
            pattern = zeros(params.height, params.width, 3);
        end
        pattern(:,:,1) = pattern(:,:,1) + params.amplitude * envelope .* cos(pointPhase);
        pattern(:,:,2) = pattern(:,:,2) + params.amplitude * envelope .* sin(pointPhase);
        pattern(:,:,3) = pattern(:,:,3) + params.amplitude * envelope .* cos(pointPhase + pi/3);
    else
        pattern = pattern + params.amplitude * envelope .* (0.5 + 0.5 * cos(pointPhase));
    end
end

% 归一化
if strcmp(params.colorMode, 'color')
    pattern = pattern / max(pattern(:));
else
    pattern = pattern / max(pattern(:));
end

info = struct(...
    'type', '六边形9点偏振光栅', ...
    'algorithm', '六边形对称相位调制', ...
    'formula', 'φᵢ = (i-2)π/3 + φ₀', ...
    'points', 9, ...
    'arrangement', '六边形对称阵列', ...
    'colorMode', params.colorMode ...
);
end
