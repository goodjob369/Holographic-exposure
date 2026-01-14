% 辅助函数和回调函数

% 获取当前设置的参数，并考虑单位转换
function params = getCurrentParams(handles)
    % 获取UI元素句柄
    editWidth = handles.editWidth;
    editHeight = handles.editHeight;
    editGratingWidth = handles.editGratingWidth;
    popupGratingWidthUnit = handles.popupGratingWidthUnit;
    editGratingHeight = handles.editGratingHeight;
    popupGratingHeightUnit = handles.popupGratingHeightUnit;
    editWavelength = handles.editWavelength;
    popupWavelengthUnit = handles.popupWavelengthUnit;
    
    % 获取参数值
    params.width = str2double(get(editWidth, 'String'));
    params.height = str2double(get(editHeight, 'String'));
    
    % 获取光栅宽度及单位
    params.grating_width = str2double(get(editGratingWidth, 'String'));
    widthUnitIdx = get(popupGratingWidthUnit, 'Value');
    grating_width_units = get(popupGratingWidthUnit, 'String');
    grating_width_unit_factors = [1e-6, 1e-3, 1, 10]; % 相对于mm的转换因子
    params.grating_width_unit = grating_width_units{widthUnitIdx};
    params.grating_width_factor = grating_width_unit_factors(widthUnitIdx);
    
    % 获取光栅高度及单位
    params.grating_height = str2double(get(editGratingHeight, 'String'));
    heightUnitIdx = get(popupGratingHeightUnit, 'Value');
    grating_height_units = get(popupGratingHeightUnit, 'String');
    grating_height_unit_factors = [1e-6, 1e-3, 1, 10]; % 相对于mm的转换因子
    params.grating_height_unit = grating_height_units{heightUnitIdx};
    params.grating_height_factor = grating_height_unit_factors(heightUnitIdx);
    
    % 获取波长及单位
    params.wavelength = str2double(get(editWavelength, 'String'));
    wavelengthUnitIdx = get(popupWavelengthUnit, 'Value');
    wavelength_units = get(popupWavelengthUnit, 'String');
    wavelength_unit_factors = [1, 1000, 1000000]; % 相对于nm的转换因子
    params.wavelength_unit = wavelength_units{wavelengthUnitIdx};
    params.wavelength_factor = wavelength_unit_factors(wavelengthUnitIdx);
    
    % 验证参数有效性
    default_width = 1920;
    default_height = 2000;
    default_grating_width = 1.0;
    default_grating_height = 0.6;
    default_wavelength = 450;
    
    if isnan(params.width) || params.width <= 0
        params.width = default_width;
        set(editWidth, 'String', num2str(default_width));
    end
    
    if isnan(params.height) || params.height <= 0
        params.height = default_height;
        set(editHeight, 'String', num2str(default_height));
    end
    
    if isnan(params.grating_width) || params.grating_width <= 0
        params.grating_width = default_grating_width;
        set(editGratingWidth, 'String', num2str(default_grating_width));
    end
    
    if isnan(params.grating_height) || params.grating_height <= 0
        params.grating_height = default_grating_height;
        set(editGratingHeight, 'String', num2str(default_grating_height));
    end
    
    if isnan(params.wavelength) || params.wavelength <= 0
        params.wavelength = default_wavelength;
        set(editWavelength, 'String', num2str(default_wavelength));
    end
    
    % 标准化参数（转换为标准单位：mm和nm）
    params.grating_width_mm = params.grating_width * params.grating_width_factor;
    params.grating_height_mm = params.grating_height * params.grating_height_factor;
    params.wavelength_nm = params.wavelength * params.wavelength_factor;
end

% 更新图像信息显示
function updateImageInfo(textInfo, imgType, params, extraInfo)
    infoStr = sprintf('图像类型: %s | 尺寸: %dx%d 像素 | 物理尺寸: %.2f%s×%.2f%s | 波长: %.2f%s', ...
        imgType, params.width, params.height, ...
        params.grating_width, params.grating_width_unit, ...
        params.grating_height, params.grating_height_unit, ...
        params.wavelength, params.wavelength_unit);
    
    if nargin > 3 && ~isempty(extraInfo)
        infoStr = [infoStr, ' | ', extraInfo];
    end
    
    set(textInfo, 'String', infoStr);
end

% ===== 提示功能函数 =====
% 显示Ronchi光栅帮助信息
function showRonchiHelp()
    helpText = sprintf(['Ronchi光栅信息:\n\n', ...
        '- Ronchi光栅是由等宽明暗条纹组成的周期性结构\n', ...
        '- 周期值是指一个明暗条纹对的宽度（像素）\n', ...
        '- 物理周期 = 光栅物理宽度 / (图像宽度 / 周期像素)\n', ...
        '- 应用：光学测试、光栅衍射、全息曝光等']);
    
    msgbox(helpText, 'Ronchi光栅帮助', 'help');
end

% 显示灰度图类型帮助信息
function showGrayTypeHelp(grayType)
    switch grayType
        case 'horizontal'
            helpText = sprintf(['水平渐变:\n\n', ...
                '- 灰度值从左到右线性变化（0-255）\n', ...
                '- 左侧为黑色（0），右侧为白色（255）\n', ...
                '- 用途：模拟水平方向上的线性相移、密度变化等']);
            
        case 'vertical'
            helpText = sprintf(['垂直渐变:\n\n', ...
                '- 灰度值从上到下线性变化（0-255）\n', ...
                '- 上方为黑色（0），下方为白色（255）\n', ...
                '- 用途：模拟垂直方向上的线性相移、密度变化等']);
            
        case 'radial'
            helpText = sprintf(['径向渐变:\n\n', ...
                '- 灰度值从中心向四周线性变化（0-255）\n', ...
                '- 中心为黑色（0），边缘为白色（255）\n', ...
                '- 用途：模拟径向光强分布、透镜效应等']);
            
        case 'concentric'
            helpText = sprintf(['同心圆渐变:\n\n', ...
                '- 灰度值沿同心圆周期性变化（0-255）\n', ...
                '- 形成从中心向外的同心环状图案\n', ...
                '- 用途：模拟同心圆衍射、波浪图案等']);
            
        case 'checkerboard'
            helpText = sprintf(['棋盘格:\n\n', ...
                '- 灰度值在棋盘格状区域交替变化（0/255）\n', ...
                '- 形成明暗相间的棋盘状图案\n', ...
                '- 用途：相机标定、图像处理基准图案等']);
            
        case 'noise'
            helpText = sprintf(['随机噪声:\n\n', ...
                '- 灰度值随机分布（0-255）\n', ...
                '- 每个像素值随机生成\n', ...
                '- 用途：模拟噪声干扰、散射介质、随机相位等']);
            
        case 'constant'
            helpText = sprintf(['固定灰度值:\n\n', ...
                '- 整个图像使用同一灰度值（0-255）\n', ...
                '- 可自定义灰度值\n', ...
                '- 用途：生成均匀曝光强度、标准参考图等']);
    end
    
    msgbox(helpText, '灰度图类型帮助', 'help');
end

% 显示图像处理帮助信息
function showImageProcessingHelp()
    helpText = sprintf(['图像灰度处理:\n\n', ...
        '- 灰度转换: 将彩色图像转换为灰度图（0-255）\n', ...
        '- 二值化: 将灰度图转换为二值图像（0/255），通过阈值控制\n', ...
        '- 反相: 将图像灰度值反转（255-原值）\n', ...
        '- 直方图均衡化: 增强图像对比度，改善灰度分布\n\n', ...
        '应用：处理各类图像以满足不同的曝光需求']);
    
    msgbox(helpText, '图像处理帮助', 'help');
end