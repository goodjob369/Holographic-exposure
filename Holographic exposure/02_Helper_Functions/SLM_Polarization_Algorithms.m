function SLM_Polarization_Algorithms()
% SLM偏振光栅算法集合
% 基于偏振体光栅理论和几何相位原理
% 版权所有 © 个人Z.Y团队Y.M

% 偏振光栅理论基础：
% 1. 几何相位 (Pancharatnam-Berry Phase): φ_PB = 2α
% 2. 液晶偏振光栅衍射效率: η = sin²(πΔnd/λ)
% 3. 布拉格衍射条件: 2n_eff*Λ*cos(φ) = λ
% 4. HSV色彩空间映射: H(色调)→偏振方向, S(饱和度)→椭圆度, V(明度)→强度

    fprintf('=== SLM偏振光栅算法库 ===\n');
    fprintf('理论基础: 几何相位 (Pancharatnam-Berry Phase)\n');
    fprintf('应用: 液晶空间光调制器偏振控制\n\n');
end

% 线性偏振光栅生成 - 基于几何相位理论
function [polarImg, grayImg] = generateLinearPolarGrating(width, height, period, angle, phase, colorMode)
    % 输入参数:
    % width, height: 图像尺寸
    % period: 光栅周期(像素)
    % angle: 旋转角度(度)
    % phase: 初始相位(度)
    % colorMode: 'color' 或 'gray'
    
    % 几何相位公式: φ_PB = 2α, 其中α是液晶分子取向角
    
    % 创建坐标网格
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    % 中心化并旋转坐标
    X0 = X - centerX;
    Y0 = Y - centerY;
    angleRad = angle * pi / 180;
    phaseRad = phase * pi / 180;
    
    X_rot = X0 * cos(angleRad) - Y0 * sin(angleRad);
    Y_rot = X0 * sin(angleRad) + Y0 * cos(angleRad);
    
    % 线性偏振光栅: 偏振方向随位置线性变化
    % 几何相位: φ = 2π*x/Λ + φ₀
    polarAngle = mod(2*pi*X_rot/period + phaseRad, pi);
    
    if strcmp(colorMode, 'color')
        % HSV彩色模式
        H = polarAngle / pi;  % 色调映射偏振方向 [0,1]
        S = ones(height, width);  % 饱和度=1 (线性偏振)
        V = ones(height, width);  % 明度=1 (最大强度)
        
        polarImg = cat(3, H, S, V);
        polarImg = hsv2rgb(polarImg) * 255;
        
        % 灰度版本: 偏振角度映射到灰度值
        grayImg = uint8(polarAngle * 255 / pi);
    else
        % 直接灰度模式
        grayImg = uint8(polarAngle * 255 / pi);
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
end

% 圆偏振光栅生成 - 基于椭圆偏振理论
function [polarImg, grayImg] = generateCircularPolarGrating(width, height, period, angle, phase, colorMode)
    % 圆偏振光栅: 椭圆度随位置变化
    % 理论: 左旋/右旋圆偏振的几何相位差
    
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    X0 = X - centerX;
    Y0 = Y - centerY;
    angleRad = angle * pi / 180;
    phaseRad = phase * pi / 180;
    
    X_rot = X0 * cos(angleRad) - Y0 * sin(angleRad);
    Y_rot = X0 * sin(angleRad) + Y0 * cos(angleRad);
    
    % 圆偏振: 椭圆度从-1(左旋)到+1(右旋)变化
    ellipticity = sin(2*pi*X_rot/period + phaseRad);
    polarAngle = atan2(Y_rot, X_rot);
    
    if strcmp(colorMode, 'color')
        % HSV彩色模式
        H = mod(polarAngle + pi, 2*pi) / (2*pi);  % 色调
        S = abs(ellipticity);  % 饱和度表示椭圆度
        V = ones(height, width);  % 明度
        
        polarImg = cat(3, H, S, V);
        polarImg = hsv2rgb(polarImg) * 255;
        
        % 灰度: 椭圆度映射
        grayImg = uint8((ellipticity + 1) * 127.5);
    else
        grayImg = uint8((ellipticity + 1) * 127.5);
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
end

% 涡旋偏振光栅 - 基于轨道角动量理论
function [polarImg, grayImg] = generateVortexPolarGrating(width, height, period, angle, phase, topologicalCharge, colorMode)
    % 涡旋光栅: 携带轨道角动量的偏振光
    % 理论: φ = lθ + φ₀, 其中l是拓扑荷数
    
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    X0 = X - centerX;
    Y0 = Y - centerY;
    phaseRad = phase * pi / 180;
    
    % 极坐标
    [theta, rho] = cart2pol(X0, Y0);
    
    % 涡旋相位: φ = l*θ (l为拓扑荷数)
    vortexPhase = mod(topologicalCharge * theta + phaseRad, 2*pi);
    
    % 径向调制
    radialModulation = 1;
    if period > 0
        radialModulation = 0.5 + 0.5 * cos(2*pi*rho/period);
    end
    
    if strcmp(colorMode, 'color')
        % HSV彩色模式
        H = vortexPhase / (2*pi);  % 色调表示相位
        S = radialModulation;  % 饱和度表示径向调制
        V = ones(height, width);  % 明度
        
        % 中心奇点处理
        centerMask = rho < 5;
        S(centerMask) = 0;  % 中心为白色
        
        polarImg = cat(3, H, S, V);
        polarImg = hsv2rgb(polarImg) * 255;
        
        % 灰度: 相位映射
        grayImg = uint8(vortexPhase * 255 / (2*pi));
    else
        grayImg = uint8(vortexPhase * 255 / (2*pi));
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
end

% 径向偏振光栅 - 基于径向对称理论
function [polarImg, grayImg] = generateRadialPolarGrating(width, height, period, angle, phase, colorMode)
    % 径向偏振: 偏振方向沿径向分布
    % 应用: 紧聚焦、光学微操控
    
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    X0 = X - centerX;
    Y0 = Y - centerY;
    phaseRad = phase * pi / 180;
    
    [theta, rho] = cart2pol(X0, Y0);
    
    % 径向偏振: 偏振方向 = 径向角度
    radialAngle = mod(theta + phaseRad, pi);
    
    % 径向调制
    radialModulation = 1;
    if period > 0
        radialModulation = 0.5 + 0.5 * cos(2*pi*rho/period);
    end
    
    if strcmp(colorMode, 'color')
        H = radialAngle / pi;  % 色调表示径向角
        S = radialModulation;  % 饱和度表示径向调制
        V = ones(height, width);  % 明度
        
        % 中心处理
        centerMask = rho < 3;
        S(centerMask) = 0;
        
        polarImg = cat(3, H, S, V);
        polarImg = hsv2rgb(polarImg) * 255;
        
        grayImg = uint8(radialAngle * 255 / pi);
    else
        grayImg = uint8(radialAngle * 255 / pi);
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
end

% 方位偏振光栅 - 基于方位对称理论
function [polarImg, grayImg] = generateAzimuthalPolarGrating(width, height, period, angle, phase, colorMode)
    % 方位偏振: 偏振方向沿切向分布
    % 应用: 光学涡旋产生、角动量转换
    
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    X0 = X - centerX;
    Y0 = Y - centerY;
    phaseRad = phase * pi / 180;
    
    [theta, rho] = cart2pol(X0, Y0);
    
    % 方位偏振: 偏振方向 = 切向角度
    azimuthalAngle = mod(theta + pi/2 + phaseRad, pi);
    
    % 径向调制
    radialModulation = 1;
    if period > 0
        radialModulation = 0.5 + 0.5 * cos(2*pi*rho/period);
    end
    
    if strcmp(colorMode, 'color')
        H = azimuthalAngle / pi;
        S = radialModulation;
        V = ones(height, width);
        
        % 中心处理
        centerMask = rho < 3;
        S(centerMask) = 0;
        
        polarImg = cat(3, H, S, V);
        polarImg = hsv2rgb(polarImg) * 255;
        
        grayImg = uint8(azimuthalAngle * 255 / pi);
    else
        grayImg = uint8(azimuthalAngle * 255 / pi);
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
end

% 二维偏振光栅 - 基于二维周期结构
function [polarImg, grayImg] = generate2DPolarGrating(width, height, periodX, periodY, angle, phase, colorMode)
    % 二维偏振光栅: X和Y方向都有周期性变化
    % 应用: 复杂偏振场调控、多功能器件
    
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    X0 = X - centerX;
    Y0 = Y - centerY;
    angleRad = angle * pi / 180;
    phaseRad = phase * pi / 180;
    
    X_rot = X0 * cos(angleRad) - Y0 * sin(angleRad);
    Y_rot = X0 * sin(angleRad) + Y0 * cos(angleRad);
    
    % 二维周期调制
    phaseX = 2*pi*X_rot/periodX;
    phaseY = 2*pi*Y_rot/periodY;
    
    % 复合偏振角度
    polarAngle = mod(0.5*(sin(phaseX) + sin(phaseY))*pi + phaseRad, pi);
    
    % 椭圆度调制
    ellipticity = sin(phaseX) .* sin(phaseY);
    
    if strcmp(colorMode, 'color')
        H = polarAngle / pi;
        S = abs(ellipticity);
        V = ones(height, width);
        
        polarImg = cat(3, H, S, V);
        polarImg = hsv2rgb(polarImg) * 255;
        
        grayImg = uint8(polarAngle * 255 / pi);
    else
        grayImg = uint8(polarAngle * 255 / pi);
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
end

% 个性化9点方形偏振光栅
function [polarImg, grayImg] = generateCustomSquare9Grating(width, height, spacing, pointSize, angle, colorMode)
    % 9点方形阵列偏振光栅
    % 每个点具有不同的偏振态
    
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    X0 = X - centerX;
    Y0 = Y - centerY;
    angleRad = angle * pi / 180;
    
    X_rot = X0 * cos(angleRad) - Y0 * sin(angleRad);
    Y_rot = X0 * sin(angleRad) + Y0 * cos(angleRad);
    
    % 初始化图像
    if strcmp(colorMode, 'color')
        polarImg = zeros(height, width, 3);
        polarImg(:,:,3) = 1;  % V通道设为1
    else
        polarImg = zeros(height, width, 3);
    end
    
    grayImg = zeros(height, width);
    
    % 定义9个点的位置和偏振态
    positions = [-spacing, 0, spacing; -spacing, 0, spacing];  % x坐标
    positions(2,:) = [-spacing, 0, spacing];  % y坐标
    
    % 偏振角度 (弧度)
    angles = [0, pi/4, pi/2; 3*pi/4, pi, 5*pi/4; 3*pi/2, 7*pi/4, 0];
    
    pointIdx = 1;
    for i = 1:3
        for j = 1:3
            px = positions(1, j);
            py = positions(2, i);
            pAngle = angles(i, j);
            
            % 创建圆形点
            dist = sqrt((X_rot - px).^2 + (Y_rot - py).^2);
            mask = dist <= pointSize/2;
            
            if strcmp(colorMode, 'color')
                % HSV模式
                polarImg(mask, :, 1) = pAngle / (2*pi);  % H
                polarImg(mask, :, 2) = 1;  % S
                % V已经设为1
            end
            
            % 灰度模式
            grayImg(mask) = pAngle * 255 / (2*pi);
            
            pointIdx = pointIdx + 1;
        end
    end
    
    if strcmp(colorMode, 'color')
        polarImg = hsv2rgb(polarImg) * 255;
    else
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
    
    grayImg = uint8(grayImg);
end

% 个性化6边形偏振光栅
function [polarImg, grayImg] = generateCustomHexagon9Grating(width, height, spacing, pointSize, angle, colorMode)
    % 6边形9点阵列偏振光栅
    
    [X, Y] = meshgrid(1:width, 1:height);
    centerX = width / 2;
    centerY = height / 2;
    
    X0 = X - centerX;
    Y0 = Y - centerY;
    angleRad = angle * pi / 180;
    
    X_rot = X0 * cos(angleRad) - Y0 * sin(angleRad);
    Y_rot = X0 * sin(angleRad) + Y0 * cos(angleRad);
    
    % 初始化图像
    if strcmp(colorMode, 'color')
        polarImg = zeros(height, width, 3);
        polarImg(:,:,3) = 1;  % V通道设为1
    else
        polarImg = zeros(height, width, 3);
    end
    
    grayImg = zeros(height, width);
    
    % 6边形+中心点的位置
    hexRadius = spacing;
    positions = [
        0, 0;  % 中心点
        hexRadius, 0;  % 右
        hexRadius/2, hexRadius*sqrt(3)/2;  % 右上
        -hexRadius/2, hexRadius*sqrt(3)/2;  % 左上
        -hexRadius, 0;  % 左
        -hexRadius/2, -hexRadius*sqrt(3)/2;  % 左下
        hexRadius/2, -hexRadius*sqrt(3)/2;  % 右下
        0, hexRadius*sqrt(3)/3;  % 上
        0, -hexRadius*sqrt(3)/3;  % 下
    ];
    
    % 对应的偏振角度
    angles = [0, pi/6, pi/3, pi/2, 2*pi/3, 5*pi/6, pi, 7*pi/6, 4*pi/3];
    
    for i = 1:9
        px = positions(i, 1);
        py = positions(i, 2);
        pAngle = angles(i);
        
        % 创建圆形点
        dist = sqrt((X_rot - px).^2 + (Y_rot - py).^2);
        mask = dist <= pointSize/2;
        
        if strcmp(colorMode, 'color')
            polarImg(mask, :, 1) = pAngle / (2*pi);  % H
            polarImg(mask, :, 2) = 1;  % S
        end
        
        grayImg(mask) = pAngle * 255 / (2*pi);
    end
    
    if strcmp(colorMode, 'color')
        polarImg = hsv2rgb(polarImg) * 255;
    else
        polarImg = repmat(grayImg, [1, 1, 3]);
    end
    
    grayImg = uint8(grayImg);
end
