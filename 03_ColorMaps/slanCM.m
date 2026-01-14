function colorList = slanCM(type, num)
% slanCM - 轻量级科学颜色映射函数
%
% 用法:
%   colorList = slanCM(type)      - 返回256色的颜色映射
%   colorList = slanCM(type, num) - 返回num色的颜色映射
%
% 支持的颜色映射类型:
%   'batlow'  - 科学可视化推荐色彩
%   'roma'    - 发散型色彩
%   'vik'     - 蓝白红发散色彩
%   'cork'    - 绿白棕发散色彩
%   'turbo'   - 彩虹色彩改进版
%   'viridis' - 感知均匀色彩
%   'plasma'  - 等离子色彩
%   'inferno' - 火焰色彩
%   'magma'   - 岩浆色彩
%   'parula'  - MATLAB默认色彩
%
% 版权所有 © 西北工业大学 Y.Z
% 此为轻量级替代版本，用于替代原始33MB的slanCM_Data.mat

    if nargin < 2
        num = 256;
    end
    if nargin < 1
        type = 'viridis';
    end

    % 获取基础颜色映射 (256色)
    switch lower(type)
        case 'batlow'
            % Batlow - 科学可视化推荐
            Cmap = batlow_colormap();
        case 'roma'
            % Roma - 发散型
            Cmap = roma_colormap();
        case 'vik'
            % Vik - 蓝白红
            Cmap = vik_colormap();
        case 'cork'
            % Cork - 绿白棕
            Cmap = cork_colormap();
        case 'turbo'
            % Turbo - 彩虹改进版
            Cmap = turbo_colormap();
        case 'viridis'
            % Viridis - 感知均匀
            Cmap = viridis_colormap();
        case 'plasma'
            % Plasma
            Cmap = plasma_colormap();
        case 'inferno'
            % Inferno
            Cmap = inferno_colormap();
        case 'magma'
            % Magma
            Cmap = magma_colormap();
        case 'parula'
            % MATLAB Parula
            Cmap = parula(256);
        otherwise
            % 默认使用viridis
            Cmap = viridis_colormap();
    end

    % 插值到指定数量的颜色
    if num ~= 256
        Ci = 1:256;
        Cq = linspace(1, 256, num);
        colorList = [interp1(Ci, Cmap(:,1), Cq, 'linear')', ...
                     interp1(Ci, Cmap(:,2), Cq, 'linear')', ...
                     interp1(Ci, Cmap(:,3), Cq, 'linear')'];
    else
        colorList = Cmap;
    end
end

%% 内置颜色映射定义

function cmap = batlow_colormap()
    % Batlow科学色彩 - 从深蓝到黄色
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        cmap(i,:) = [0.005 + 0.99*t^0.8, ...
                     0.098 + 0.75*t - 0.3*t^2, ...
                     0.35 - 0.35*t + 0.1*t^2];
    end
end

function cmap = roma_colormap()
    % Roma发散色彩 - 从蓝绿到红
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        if t < 0.5
            s = t * 2;
            cmap(i,:) = [0.26 + 0.74*s, 0.58 + 0.42*s, 0.76 - 0.26*s];
        else
            s = (t - 0.5) * 2;
            cmap(i,:) = [1.0, 1.0 - 0.5*s, 0.5 - 0.4*s];
        end
    end
end

function cmap = vik_colormap()
    % Vik蓝白红发散色彩
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        if t < 0.5
            s = t * 2;
            cmap(i,:) = [0.09 + 0.91*s, 0.21 + 0.79*s, 0.58 + 0.42*s];
        else
            s = (t - 0.5) * 2;
            cmap(i,:) = [1.0, 1.0 - 0.7*s, 1.0 - 0.85*s];
        end
    end
end

function cmap = cork_colormap()
    % Cork绿白棕发散色彩
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        if t < 0.5
            s = t * 2;
            cmap(i,:) = [0.17 + 0.83*s, 0.39 + 0.61*s, 0.33 + 0.67*s];
        else
            s = (t - 0.5) * 2;
            cmap(i,:) = [1.0 - 0.3*s, 1.0 - 0.45*s, 1.0 - 0.65*s];
        end
    end
end

function cmap = turbo_colormap()
    % Turbo彩虹改进版
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        cmap(i,1) = max(0, min(1, 0.13572*sin(4.61539*t-1.17353) + 0.92414*sin(1.92128*t+0.24503) + 0.09958));
        cmap(i,2) = max(0, min(1, 0.68724*sin(2.21547*t+0.80756) + 0.32276*sin(4.25498*t-0.68149) + 0.09));
        cmap(i,3) = max(0, min(1, 0.42648*sin(5.46*t+2.36) + 0.57352*sin(2.93*t+3.14) + 0.1));
    end
end

function cmap = viridis_colormap()
    % Viridis感知均匀色彩
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        cmap(i,:) = [0.267 + 0.004*t + 0.329*t^2, ...
                     0.004 + 0.873*t - 0.377*t^2, ...
                     0.329 + 0.478*t - 0.807*t^2 + 0.5*t^3];
    end
end

function cmap = plasma_colormap()
    % Plasma色彩
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        cmap(i,:) = [0.05 + 0.85*t + 0.1*t^2, ...
                     0.03 + 0.4*t - 0.43*t^2 + 0.5*t^3, ...
                     0.53 + 0.47*t - 1.0*t^2 + 0.5*t^3];
    end
end

function cmap = inferno_colormap()
    % Inferno火焰色彩
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        cmap(i,:) = [min(1, 0.0 + 1.5*t - 0.5*t^2), ...
                     max(0, min(1, -0.03 + 0.8*t)), ...
                     max(0, min(1, 0.02 + 0.6*t - 0.62*t^2))];
    end
end

function cmap = magma_colormap()
    % Magma岩浆色彩
    n = 256;
    cmap = zeros(n, 3);
    for i = 1:n
        t = (i-1)/(n-1);
        cmap(i,:) = [min(1, 0.0 + 1.2*t), ...
                     max(0, min(1, 0.0 + 0.5*t + 0.5*t^2)), ...
                     max(0, min(1, 0.02 + 0.8*t - 0.3*t^2))];
    end
end
