%=============================================================
% ExposureGenerator_Complete_Final.m - 全功能曝光图生成器
% 版本: V4.0.0 (完整功能版)
% 
% 版权所有 © 西北工业大学 Y.Z
% 联系邮箱: yangzhen2971@mail.nwpu.edu.cn
%
% 功能描述: 
%   - 生成全息曝光图案，支持多种光栅类型
%   - 包含SLM灰度值与偏振角度线性关系校准功能
%   - 支持多种图像处理和保存格式
%   - 提供完整的参数信息保存功能
%
% 主要功能模块:
%   1. Ronchi光栅生成
%   2. 灰度图生成（7种类型）
%   3. 图像处理（灰度化、二值化、反色、直方图均衡）
%   4. 偏振光栅生成（6种类型）
%   5. 个性化偏振光栅（15种科学研究类型）
%   6. SLM转换功能
%   7. 边界设置
%   8. 多单位支持
%
% 修改历史:
%   V4.0.0 - 2024.12.15 - 完整功能版本，包含所有原始功能
%=============================================================

function ExposureGenerator_Complete_Final()
    
    % 程序初始化
    clc;
    fprintf('=============================================================\n');
    fprintf('    全功能曝光图生成器 V4.0.0 (完整功能版)\n');
    fprintf('=============================================================\n');
    fprintf('版权所有 © 西北工业大学 Y.Z\n');
    fprintf('联系邮箱: yangzhen2971@mail.nwpu.edu.cn\n');
    fprintf('正在启动程序...\n');
    
    % 全局变量声明
    fig = [];
    panelControl = [];
    panelDisplay = [];
    axesImg = [];
    textInfo = [];
    textPhysicalSize = [];
    
    % 当前图像数据
    currentImage = [];
    currentImageType = '无图像';
    
    % UI控件句柄
    editWidth = [];
    editHeight = [];
    editPixelSize = [];
    editWavelength = [];
    popupPixelSizeUnit = [];
    popupWavelengthUnit = [];
    editRonchiPeriod = [];
    bgRonchiDirection = [];
    bgGrayType = [];
    editGrayValue = [];
    bgImageSource = [];
    editImagePath = [];
    bgImageProcessing = [];
    editThreshold = [];
    popupPolarGratingType = [];
    editPolarGratingPeriod = [];
    editPolarRotationAngle = [];
    editPolarPhase = [];
    editPolarGrayMin = [];      % 新增：最小灰度值控制
    editPolarGrayMax = [];      % 新增：最大灰度值控制
    bgPolarDirection = [];      % 新增：偏振光栅方向控制
    enableSLMConversion = [];
    editSlopeCoeff = [];
    editInterceptCoeff = [];
    popupCustomPolarGratingType = [];
    editCustomPointSpacing = [];
    editCustomPointSize = [];
    editCustomRotationAngle = [];
    popupCustomPolarPreviewMode = []; % 新增：个性化偏振光栅预览模式
    enableCustomSLMConversion = [];
    editCustomSlopeCoeff = [];
    editCustomInterceptCoeff = [];
    enableBorderCheckbox = [];
    editBorderWidth = [];
    editBorderGray = [];
    
    % 常量定义
    grayTypes = {'水平梯度', '垂直梯度', '径向梯度', '同心圆梯度', '棋盘格', '随机噪声', '固定灰度'};
    grayTypeValues = {'horizontal', 'vertical', 'radial', 'concentric', 'checkerboard', 'noise', 'constant'};
    imageSourceOptions = {'本地文件选择', '默认图像'};
    imageSourceValues = {'local', 'default'};
    processingOptions = {'灰度化', '二值化', '反色', '直方图均衡'};
    processingValues = {'grayscale', 'binary', 'invert', 'histeq'};
    polarGratingTypes = {'线性偏振', '圆偏振', '涡旋光束', '径向偏振', '角向偏振', '二维光栅'};
    polarGratingValues = {'linear', 'circular', 'vortex', 'radial', 'azimuthal', '2d'};
    
    % 个性化偏振光栅类型（科学研究专用）
    customPolarGratingTypes = {
        '矩形9点阵列', '六边形9点阵列', '相位光栅', ...
        'Pancharatnam-Berry光栅', '可调谐液晶聚合物', ...
        '带宽展宽光栅', '大角度光栅', '闪耀光栅', ...
        '涡旋光栅', '手性光子晶体', '超材料光栅', ...
        '全息光栅', '自适应可调光栅', '多波长光栅', '梯度折射率光栅'
    };
    customPolarGratingValues = {
        'square9', 'hexagon9', 'phase_grating', ...
        'pb_grating', 'psclc_tunable', ...
        'bandwidth_broadening', 'large_angle_grating', 'blazed_grating', ...
        'vortex_grating', 'chiral_photonic', 'metamaterial_grating', ...
        'holographic_grating', 'adaptive_tunable', 'multi_wavelength', 'gradient_index'
    };
    
    % 单位选项
    pixel_size_units = {'nm', 'μm', 'mm'};
    pixel_size_unit_factors = [1e-6, 1e-3, 1];
    wavelength_units = {'nm', 'μm', 'mm'};
    wavelength_unit_factors = [1, 1000, 1000000];
    
    % 默认值
    default_width = 1920;
    default_height = 2000;
    default_pixel_size = 8;
    default_wavelength = 450;
    
    % 界面布局
    dividerPosition = 0.33;
    
    % 创建主窗口
    fig = figure('Name', '全功能曝光图生成器 V4.0.0', ...
        'Position', [100, 100, 1400, 900], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Resize', 'on', ...
        'Color', [0.94 0.94 0.94], ...
        'CloseRequestFcn', @closeProgram);
    
    % 创建控制面板
    panelControl = uipanel(fig, ...
        'Title', '控制面板', ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Position', [0.02, 0.02, dividerPosition-0.02, 0.96], ...
        'BackgroundColor', [0.95 0.95 0.95]);
    
    % 创建显示面板
    panelDisplay = uipanel(fig, ...
        'Title', '图像显示', ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Position', [dividerPosition+0.01, 0.02, 0.97-dividerPosition, 0.96], ...
        'BackgroundColor', [0.95 0.95 0.95]);
    
    % 创建图像显示区域
    axesImg = axes('Parent', panelDisplay, ...
        'Position', [0.05, 0.15, 0.9, 0.8]);
    axis off;
    
    % 创建信息面板
    panelInfo = uipanel(panelDisplay, ...
        'Title', '图像信息', ...
        'FontSize', 9, ...
        'Position', [0.05, 0.02, 0.9, 0.1], ...
        'BackgroundColor', [0.95 0.95 0.95]);
    
    % 创建信息文本
    textInfo = uicontrol(panelInfo, ...
        'Style', 'text', ...
        'String', '', ...
        'Position', [10, 5, 1100, 40], ...
        'FontSize', 9, ...
        'BackgroundColor', [0.95 0.95 0.95], ...
        'HorizontalAlignment', 'left');
    
    % 创建控制面板内容
    createControlPanelContent();
    
    % 初始显示
    axes(axesImg);
    text(0.5, 0.5, '请选择功能生成图像', ...
        'FontSize', 16, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle');
    axis off;
    
    % 初始化信息显示
    params = getCurrentParams();
    updateImageInfo('等待生成', params, '请选择功能');
    
    fprintf('程序启动完成！\n');
    
    % ===== 嵌套函数定义 =====
    
    %% 获取当前参数
    function params = getCurrentParams()
        try
            params.width = str2double(get(editWidth, 'String'));
            params.height = str2double(get(editHeight, 'String'));
            params.pixel_size = str2double(get(editPixelSize, 'String'));
            params.wavelength = str2double(get(editWavelength, 'String'));
            
            % 获取单位设置
            pixelUnitIdx = get(popupPixelSizeUnit, 'Value');
            params.pixel_size_unit = pixel_size_units{pixelUnitIdx};
            params.pixel_size_factor = pixel_size_unit_factors(pixelUnitIdx);
            
            wavelengthUnitIdx = get(popupWavelengthUnit, 'Value');
            params.wavelength_unit = wavelength_units{wavelengthUnitIdx};
            params.wavelength_factor = wavelength_unit_factors(wavelengthUnitIdx);
            
            % 获取边界设置
            params.enableBorder = get(enableBorderCheckbox, 'Value');
            params.borderWidth = str2double(get(editBorderWidth, 'String'));
            params.borderGray = str2double(get(editBorderGray, 'String'));
            
            % 参数验证
            if isnan(params.width) || params.width <= 0
                params.width = default_width;
                set(editWidth, 'String', num2str(default_width));
            end
            
            if isnan(params.height) || params.height <= 0
                params.height = default_height;
                set(editHeight, 'String', num2str(default_height));
            end
            
            if isnan(params.pixel_size) || params.pixel_size <= 0
                params.pixel_size = default_pixel_size;
                set(editPixelSize, 'String', num2str(default_pixel_size));
            end
            
            if isnan(params.wavelength) || params.wavelength <= 0
                params.wavelength = default_wavelength;
                set(editWavelength, 'String', num2str(default_wavelength));
            end
            
            if isnan(params.borderWidth) || params.borderWidth < 0
                params.borderWidth = 1;
                set(editBorderWidth, 'String', '1');
            end
            
            if isnan(params.borderGray) || params.borderGray < 0 || params.borderGray > 255
                params.borderGray = 255;
                set(editBorderGray, 'String', '255');
            end
            
            % 计算物理尺寸
            params.pixel_size_mm = params.pixel_size * params.pixel_size_factor;
            params.grating_width_mm = params.width * params.pixel_size_mm;
            params.grating_height_mm = params.height * params.pixel_size_mm;
            params.wavelength_nm = params.wavelength * params.wavelength_factor;
            
            % 更新显示
            updatePhysicalSizeDisplay(params);
            
        catch e
            warning('获取参数时出错: %s，使用默认值', e.message);
            params = getDefaultParams();
        end
    end
    
    %% 获取默认参数
    function params = getDefaultParams()
        params.width = default_width;
        params.height = default_height;
        params.pixel_size = default_pixel_size;
        params.wavelength = default_wavelength;
        params.pixel_size_unit = pixel_size_units{2};
        params.wavelength_unit = wavelength_units{1};
        params.pixel_size_factor = pixel_size_unit_factors(2);
        params.wavelength_factor = wavelength_unit_factors(1);
        params.pixel_size_mm = params.pixel_size * params.pixel_size_factor;
        params.grating_width_mm = params.width * params.pixel_size_mm;
        params.grating_height_mm = params.height * params.pixel_size_mm;
        params.wavelength_nm = params.wavelength * params.wavelength_factor;
        params.enableBorder = false;
        params.borderWidth = 1;
        params.borderGray = 255;
    end
    
    %% 更新物理尺寸显示
    function updatePhysicalSizeDisplay(params)
        try
            physicalSizeStr = sprintf('宽度: %.2fmm, 高度: %.2fmm', ...
                params.grating_width_mm, params.grating_height_mm);
            set(textPhysicalSize, 'String', physicalSizeStr);
        catch
            % 忽略错误
        end
    end
    
    %% 获取光栅数学模型
    function [mathModel, principle] = getGratingMathModel(gratingType, params)
        mathModel = '';
        principle = '';
        
        if nargin < 1 || isempty(gratingType)
            mathModel = '数学模型: 未指定光栅类型';
            principle = '物理原理: 请选择具体的光栅类型以获取详细信息';
            return;
        end
        
        switch gratingType
            case 'ronchi'
                mathModel = '数学模型: T(x) = rect(x/d) * comb(x/d)，其中d为光栅周期';
                principle = 'Ronchi光栅: 由等宽透明和不透明条纹组成的二元振幅光栅，主要用于光学测量和波前检测。';
                
            case 'linear'
                mathModel = '数学模型: φ(x,y) = 2πx/Λ + φ₀，其中Λ为周期，φ₀为初相位';
                principle = '线性偏振光栅: 产生线性偏振光，偏振方向随位置线性变化，用于偏振控制和光束分离。';
                
            case 'circular'
                mathModel = '数学模型: φ(r,θ) = ±θ + φ₀，其中θ为方位角，±表示左右圆偏振';
                principle = '圆偏振光栅: 产生圆偏振光，具有螺旋波前结构，用于手性检测和角动量控制。';
                
            case 'vortex'
                mathModel = '数学模型: φ(r,θ) = lθ，其中l为拓扑荷数';
                principle = '涡旋光栅: 产生轨道角动量，具有螺旋波前和相位奇点，用于粒子操控和量子信息。';
                
            case 'pb_grating'
                mathModel = '数学模型: φ(r) = π(r²)/(λf)，其中f为焦距，λ为波长';
                principle = 'Pancharatnam-Berry光栅: 基于几何相位的液晶光栅，具有高效率和宽带特性。';
                
            otherwise
                mathModel = sprintf('数学模型: %s类型光栅', gratingType);
                principle = '物理原理: 根据具体光栅类型确定相应的物理机制和应用场景。';
        end
    end
    
    %% 创建偏振光栅选项卡
    function createPolarTab(tabPolar)
        % 光栅类型选择
        uicontrol(tabPolar, 'Style', 'text', 'String', '光栅类型:', ...
            'Position', [20, 280, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        popupPolarGratingType = uicontrol(tabPolar, 'Style', 'popupmenu', ...
            'String', polarGratingTypes, 'Value', 1, ...
            'Position', [110, 280, 180, 20]);
        
        % 周期设置
        uicontrol(tabPolar, 'Style', 'text', 'String', '周期(像素):', ...
            'Position', [20, 240, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editPolarGratingPeriod = uicontrol(tabPolar, 'Style', 'edit', ...
            'String', '20', 'Position', [110, 240, 60, 20]);
        
        % 方向设置（新增）
        uicontrol(tabPolar, 'Style', 'text', 'String', '光栅方向:', ...
            'Position', [190, 240, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        bgPolarDirection = uibuttongroup(tabPolar, 'Visible', 'on', ...
            'Position', [280, 235, 130, 30], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 创建方向单选按钮
        uicontrol(bgPolarDirection, 'Style', 'radiobutton', ...
            'String', '水平', 'Value', 1, ...
            'Position', [5, 5, 50, 20], 'Tag', 'horizontal', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        uicontrol(bgPolarDirection, 'Style', 'radiobutton', ...
            'String', '垂直', ...
            'Position', [65, 5, 50, 20], 'Tag', 'vertical', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 灰度值范围设置（新增）
        uicontrol(tabPolar, 'Style', 'text', 'String', '灰度值范围:', ...
            'Position', [20, 200, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 最小灰度值
        uicontrol(tabPolar, 'Style', 'text', 'String', '最小:', ...
            'Position', [110, 200, 30, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editPolarGrayMin = uicontrol(tabPolar, 'Style', 'edit', ...
            'String', '10', 'Position', [145, 200, 40, 20]);
        
        % 最大灰度值
        uicontrol(tabPolar, 'Style', 'text', 'String', '最大:', ...
            'Position', [200, 200, 30, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editPolarGrayMax = uicontrol(tabPolar, 'Style', 'edit', ...
            'String', '255', 'Position', [235, 200, 40, 20]);
        
        % 旋转角度设置
        uicontrol(tabPolar, 'Style', 'text', 'String', '旋转角度(°):', ...
            'Position', [20, 160, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editPolarRotationAngle = uicontrol(tabPolar, 'Style', 'edit', ...
            'String', '0', 'Position', [110, 160, 60, 20]);
        
        % 相位设置
        uicontrol(tabPolar, 'Style', 'text', 'String', '相位偏移(°):', ...
            'Position', [190, 160, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editPolarPhase = uicontrol(tabPolar, 'Style', 'edit', ...
            'String', '0', 'Position', [270, 160, 60, 20]);
        
        % SLM转换设置
        uicontrol(tabPolar, 'Style', 'text', 'String', 'SLM灰度转换:', ...
            'Position', [20, 120, 90, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        enableSLMConversion = uicontrol(tabPolar, 'Style', 'checkbox', ...
            'String', '启用', 'Position', [110, 120, 60, 20], 'Value', 0, ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 斜率系数
        uicontrol(tabPolar, 'Style', 'text', 'String', '斜率系数:', ...
            'Position', [180, 120, 60, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editSlopeCoeff = uicontrol(tabPolar, 'Style', 'edit', ...
            'String', '1.3047', 'Position', [240, 120, 60, 20]);
        
        % 截距系数
        uicontrol(tabPolar, 'Style', 'text', 'String', '截距:', ...
            'Position', [310, 120, 40, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editInterceptCoeff = uicontrol(tabPolar, 'Style', 'edit', ...
            'String', '133.85', 'Position', [350, 120, 60, 20]);
        
        % 公式说明
        uicontrol(tabPolar, 'Style', 'text', ...
            'String', '公式: 灰度值 = 斜率系数 × 角度 + 截距', ...
            'Position', [110, 95, 300, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'ForegroundColor', [0, 0, 0.8], ...
            'FontSize', 8);
        
        % 生成按钮
        uicontrol(tabPolar, 'Style', 'pushbutton', 'String', '生成偏振光栅', ...
            'Position', [50, 30, 200, 30], 'Callback', @generatePolarGrating, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.3, 0.6, 0.9], ...
            'ForegroundColor', [1 1 1]);
    end
    
    %% 创建个性化偏振光栅选项卡
    function createCustomPolarTab(tabCustomPolar)
        % 光栅类型选择
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', '光栅类型:', ...
            'Position', [20, 280, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        popupCustomPolarGratingType = uicontrol(tabCustomPolar, 'Style', 'popupmenu', ...
            'String', customPolarGratingTypes, 'Value', 1, ...
            'Position', [110, 280, 250, 20]);
        
        % 点间距设置
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', '点间距(像素):', ...
            'Position', [20, 240, 90, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editCustomPointSpacing = uicontrol(tabCustomPolar, 'Style', 'edit', ...
            'String', '100', 'Position', [110, 240, 60, 20]);
        
        % 点大小设置
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', '点大小(像素):', ...
            'Position', [20, 200, 90, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editCustomPointSize = uicontrol(tabCustomPolar, 'Style', 'edit', ...
            'String', '40', 'Position', [110, 200, 60, 20]);
        
        % 旋转角度设置
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', '旋转角度(°):', ...
            'Position', [20, 160, 90, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editCustomRotationAngle = uicontrol(tabCustomPolar, 'Style', 'edit', ...
            'String', '0', 'Position', [110, 160, 60, 20]);
        
        % 预览模式选择
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', '预览模式:', ...
            'Position', [190, 160, 70, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
            
        popupCustomPolarPreviewMode = uicontrol(tabCustomPolar, 'Style', 'popupmenu', ...
            'String', {'灰度显示', '彩色显示'}, 'Value', 1, ...
            'Position', [260, 160, 100, 20]);
        
        % SLM转换设置
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', 'SLM灰度转换:', ...
            'Position', [20, 120, 90, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        enableCustomSLMConversion = uicontrol(tabCustomPolar, 'Style', 'checkbox', ...
            'String', '启用', 'Position', [110, 120, 60, 20], 'Value', 0, ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 斜率系数
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', '斜率系数:', ...
            'Position', [180, 120, 60, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editCustomSlopeCoeff = uicontrol(tabCustomPolar, 'Style', 'edit', ...
            'String', '1.3047', 'Position', [240, 120, 60, 20]);
        
        % 截距系数
        uicontrol(tabCustomPolar, 'Style', 'text', 'String', '截距:', ...
            'Position', [310, 120, 40, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editCustomInterceptCoeff = uicontrol(tabCustomPolar, 'Style', 'edit', ...
            'String', '133.85', 'Position', [350, 120, 60, 20]);
        
        % 公式说明
        uicontrol(tabCustomPolar, 'Style', 'text', ...
            'String', '公式: 灰度值 = 斜率系数 × 角度 + 截距', ...
            'Position', [110, 95, 300, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'ForegroundColor', [0, 0, 0.8], ...
            'FontSize', 8);
        
        % 生成按钮
        uicontrol(tabCustomPolar, 'Style', 'pushbutton', 'String', '生成个性化偏振光栅', ...
            'Position', [50, 30, 200, 30], 'Callback', @generateCustomPolarGrating, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.3, 0.6, 0.9], ...
            'ForegroundColor', [1 1 1]);
    end
    
    %% 创建控制面板内容
    function createControlPanelContent()
        % 创建通用参数设置面板
        panelParams = uipanel(panelControl, ...
            'Title', '通用参数设置', ...
            'FontSize', 10, ...
            'Position', [0.05, 0.75, 0.9, 0.2], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 图像尺寸设置
        uicontrol(panelParams, 'Style', 'text', 'String', '宽度(像素):', ...
            'Position', [10, 110, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editWidth = uicontrol(panelParams, 'Style', 'edit', ...
            'String', num2str(default_width), ...
            'Position', [100, 110, 80, 20]);
        
        uicontrol(panelParams, 'Style', 'text', 'String', '高度(像素):', ...
            'Position', [10, 85, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editHeight = uicontrol(panelParams, 'Style', 'edit', ...
            'String', num2str(default_height), ...
            'Position', [100, 85, 80, 20]);
        
        % 像素尺寸设置
        uicontrol(panelParams, 'Style', 'text', 'String', '像素尺寸:', ...
            'Position', [200, 110, 60, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editPixelSize = uicontrol(panelParams, 'Style', 'edit', ...
            'String', num2str(default_pixel_size), ...
            'Position', [270, 110, 50, 20]);
        
        popupPixelSizeUnit = uicontrol(panelParams, 'Style', 'popupmenu', ...
            'String', pixel_size_units, 'Value', 2, ...
            'Position', [325, 110, 45, 20]);
        
        % 波长设置
        uicontrol(panelParams, 'Style', 'text', 'String', '照射光波长:', ...
            'Position', [200, 85, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editWavelength = uicontrol(panelParams, 'Style', 'edit', ...
            'String', num2str(default_wavelength), ...
            'Position', [270, 85, 50, 20]);
        
        popupWavelengthUnit = uicontrol(panelParams, 'Style', 'popupmenu', ...
            'String', wavelength_units, 'Value', 1, ...
            'Position', [325, 85, 45, 20]);
        
        % 物理尺寸预览
        uicontrol(panelParams, 'Style', 'text', 'String', '物理尺寸预览:', ...
            'Position', [10, 40, 90, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        textPhysicalSize = uicontrol(panelParams, 'Style', 'text', ...
            'String', '宽度: 15.36mm, 高度: 16.00mm', ...
            'Position', [10, 20, 350, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        % 创建边界设置面板
        panelBorder = uipanel(panelControl, ...
            'Title', '边界设置', ...
            'FontSize', 10, ...
            'Position', [0.05, 0.65, 0.9, 0.08], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 边界启用复选框
        enableBorderCheckbox = uicontrol(panelBorder, ...
            'Style', 'checkbox', 'String', '启用边界', ...
            'Position', [10, 30, 80, 20], 'Value', 0, ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 边界宽度设置
        uicontrol(panelBorder, 'Style', 'text', 'String', '宽度:', ...
            'Position', [100, 30, 40, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editBorderWidth = uicontrol(panelBorder, 'Style', 'edit', ...
            'String', '1', 'Position', [140, 30, 40, 20]);
        
        % 边界灰度值设置
        uicontrol(panelBorder, 'Style', 'text', 'String', '灰度值:', ...
            'Position', [200, 30, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editBorderGray = uicontrol(panelBorder, 'Style', 'edit', ...
            'String', '255', 'Position', [250, 30, 40, 20]);
        
        % 帮助按钮
        uicontrol(panelBorder, 'Style', 'pushbutton', 'String', '?', ...
            'Position', [300, 30, 20, 20], 'Callback', @showBorderHelp);
        
        % 创建选项卡组
        tabgp = uitabgroup(panelControl, 'Position', [0.05, 0.05, 0.9, 0.58]);
        
        % 创建各个功能选项卡
        tabRonchi = uitab(tabgp, 'Title', 'Ronchi光栅');
        createRonchiTab(tabRonchi);
        
        tabGray = uitab(tabgp, 'Title', '灰度图');
        createGrayTab(tabGray);
        
        tabImage = uitab(tabgp, 'Title', '图像处理');
        createImageTab(tabImage);
        
        tabPolar = uitab(tabgp, 'Title', '偏振光栅');
        createPolarTab(tabPolar);
        
        tabCustomPolar = uitab(tabgp, 'Title', '个性化偏振光栅');
        createCustomPolarTab(tabCustomPolar);
        
        % 创建底部按钮面板
        panelButtons = uipanel(panelControl, ...
            'BorderType', 'none', ...
            'Position', [0.05, 0.01, 0.9, 0.04], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 保存图像按钮
        uicontrol(panelButtons, 'Style', 'pushbutton', 'String', '保存图像', ...
            'Position', [0, 0, 120, 30], 'Callback', @saveImage, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.4, 0.8, 0.4], ...
            'ForegroundColor', [1 1 1]);
        
        % 退出程序按钮
        uicontrol(panelButtons, 'Style', 'pushbutton', 'String', '退出程序', ...
            'Position', [130, 0, 120, 30], 'Callback', @closeProgram, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.8, 0.4, 0.4], ...
            'ForegroundColor', [1 1 1]);
    end
    
    %% 创建Ronchi光栅选项卡
    function createRonchiTab(tabRonchi)
        % 周期设置
        uicontrol(tabRonchi, 'Style', 'text', 'String', '周期(像素):', ...
            'Position', [20, 280, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editRonchiPeriod = uicontrol(tabRonchi, 'Style', 'edit', ...
            'String', '15', 'Position', [110, 280, 60, 20]);
        
        % 方向设置
        uicontrol(tabRonchi, 'Style', 'text', 'String', '光栅方向:', ...
            'Position', [20, 240, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        bgRonchiDirection = uibuttongroup(tabRonchi, 'Visible', 'on', ...
            'Position', [0.3, 0.8, 0.5, 0.1], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 创建单选按钮
        uicontrol(bgRonchiDirection, 'Style', 'radiobutton', ...
            'String', '水平方向', ...
            'Position', [10, 5, 80, 20], 'Tag', 'horizontal', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        uicontrol(bgRonchiDirection, 'Style', 'radiobutton', ...
            'String', '垂直方向', ...
            'Position', [100, 5, 80, 20], 'Tag', 'vertical', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 生成按钮
        uicontrol(tabRonchi, 'Style', 'pushbutton', 'String', '生成Ronchi光栅', ...
            'Position', [50, 50, 200, 30], 'Callback', @generateRonchi, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.3, 0.6, 0.9], ...
            'ForegroundColor', [1 1 1]);
    end
    
    %% 创建灰度图选项卡
    function createGrayTab(tabGray)
        % 灰度图类型选择
        uicontrol(tabGray, 'Style', 'text', 'String', '灰度图类型:', ...
            'Position', [20, 280, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        bgGrayType = uicontrol(tabGray, 'Style', 'popupmenu', ...
            'String', grayTypes, 'Value', 1, ...
            'Position', [110, 280, 180, 20], ...
            'BackgroundColor', [1 1 1]);
        
        % 最大灰度值设置
        uicontrol(tabGray, 'Style', 'text', 'String', '最大灰度值:', ...
            'Position', [20, 220, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editGrayValue = uicontrol(tabGray, 'Style', 'edit', ...
            'String', '255', 'Position', [110, 220, 60, 20]);
        
        % 生成按钮
        uicontrol(tabGray, 'Style', 'pushbutton', 'String', '生成灰度图', ...
            'Position', [50, 50, 200, 30], 'Callback', @generateGray, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.3, 0.6, 0.9], ...
            'ForegroundColor', [1 1 1]);
    end
    
    %% 创建图像处理选项卡
    function createImageTab(tabImage)
        % 图像来源选择
        uicontrol(tabImage, 'Style', 'text', 'String', '图像来源:', ...
            'Position', [20, 280, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        bgImageSource = uicontrol(tabImage, 'Style', 'popupmenu', ...
            'String', imageSourceOptions, 'Value', 1, ...
            'Position', [110, 280, 180, 20], ...
            'BackgroundColor', [1 1 1]);
        
        % 图像路径设置
        uicontrol(tabImage, 'Style', 'text', 'String', '图像路径:', ...
            'Position', [20, 240, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editImagePath = uicontrol(tabImage, 'Style', 'edit', ...
            'String', '', 'Position', [110, 240, 200, 20]);
        
        uicontrol(tabImage, 'Style', 'pushbutton', 'String', '浏览...', ...
            'Position', [320, 240, 60, 20], 'Callback', @browseImage);
        
        % 处理类型选择
        uicontrol(tabImage, 'Style', 'text', 'String', '处理类型:', ...
            'Position', [20, 200, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        bgImageProcessing = uicontrol(tabImage, 'Style', 'popupmenu', ...
            'String', processingOptions, 'Value', 1, ...
            'Position', [110, 200, 180, 20], ...
            'BackgroundColor', [1 1 1]);
        
        % 二值化阈值设置
        uicontrol(tabImage, 'Style', 'text', 'String', '二值化阈值:', ...
            'Position', [20, 160, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        editThreshold = uicontrol(tabImage, 'Style', 'edit', ...
            'String', '0.5', 'Position', [110, 160, 60, 20]);
        
        % 处理按钮
        uicontrol(tabImage, 'Style', 'pushbutton', 'String', '处理图像', ...
            'Position', [50, 50, 200, 30], 'Callback', @processImage, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.3, 0.6, 0.9], ...
            'ForegroundColor', [1 1 1]);
    end
    
    % 其他必要的函数会从ExposureGenerator_Functions.m中复制
    % 这些函数包括: generateRonchi, generateGray, browseImage, processImage, 
    % generatePolarGrating, generateCustomPolarGrating, saveImage, etc.
    
    %% 应用边界
    function imgWithBorder = applyBorder(img, params)
        if ~params.enableBorder
            imgWithBorder = img;
            return;
        end
        
        [height, width] = size(img);
        imgWithBorder = img;
        borderWidth = params.borderWidth;
        borderGray = params.borderGray;
        
        % 应用边界
        imgWithBorder(1:borderWidth, :) = borderGray;
        imgWithBorder(height-borderWidth+1:height, :) = borderGray;
        imgWithBorder(:, 1:borderWidth) = borderGray;
        imgWithBorder(:, width-borderWidth+1:width) = borderGray;
    end
    
    %% 显示图像
    function displayImage(img, imgType)
        if nargin < 2
            imgType = '图像';
        end
        
        % 保存当前图像
        currentImage = img;
        currentImageType = imgType;
        
        % 清除旧内容
        cla(axesImg);
        
        % 显示图像
        imshow(img, [], 'Parent', axesImg);
        title(imgType, 'FontSize', 12);
    end
    
    %% 更新图像信息
    function updateImageInfo(title, params, extraInfo)
        try
            % 基本信息
            info = sprintf('图像类型: %s | 尺寸: %dx%d像素', title, params.width, params.height);
            
            % 物理尺寸信息
            if isfield(params, 'grating_width_mm') && isfield(params, 'grating_height_mm')
                info = sprintf('%s | 物理尺寸: %.2fx%.2fmm', info, params.grating_width_mm, params.grating_height_mm);
            end
            
            % 额外信息
            if nargin >= 3 && ~isempty(extraInfo)
                info = sprintf('%s | %s', info, extraInfo);
            end
            
            % 更新显示
            set(textInfo, 'String', info);
        catch
            % 容错处理
            set(textInfo, 'String', '图像信息加载中...');
        end
    end
    
    %% 生成Ronchi光栅
    function generateRonchi(~, ~)
        try
            % 获取当前参数
            params = getCurrentParams();
            
            % 获取Ronchi光栅参数
            period = str2double(get(editRonchiPeriod, 'String'));
            
            % 获取方向设置
            selectedObj = get(bgRonchiDirection, 'SelectedObject');
            if isempty(selectedObj)
                selectedDirection = 'horizontal';
            else
                selectedDirection = get(selectedObj, 'Tag');
            end
            
            % 参数验证
            if isnan(period) || period <= 0
                period = 15;
                set(editRonchiPeriod, 'String', '15');
            end
            
            % 生成Ronchi光栅
            img = zeros(params.height, params.width);
            
            if strcmp(selectedDirection, 'horizontal')
                % 水平方向光栅
                for j = 1:params.width
                    if mod(j, period) < period/2
                        img(:, j) = 255;
                    else
                        img(:, j) = 0;
                    end
                end
            else
                % 垂直方向光栅
                for i = 1:params.height
                    if mod(i, period) < period/2
                        img(i, :) = 255;
                    else
                        img(i, :) = 0;
                    end
                end
            end
            
            % 应用边界
            img = applyBorder(img, params);
            
            % 显示图像
            displayImage(img, 'Ronchi光栅');
            
            % 计算物理周期
            if strcmp(selectedDirection, 'horizontal')
                physical_period = params.grating_width_mm / (params.width / period);
            else
                physical_period = params.grating_height_mm / (params.height / period);
            end
            
            % 更新图像信息
            updateImageInfo('Ronchi光栅', params, ...
                sprintf('周期: %d 像素 (%.6f mm), 方向: %s', period, physical_period, selectedDirection));
            
        catch e
            errordlg(['生成Ronchi光栅时出错: ', e.message], '错误');
        end
    end
    
    %% 生成灰度图
    function generateGray(~, ~)
        try
            % 获取参数
            params = getCurrentParams();
            
            % 获取灰度图类型
            grayTypeIdx = get(bgGrayType, 'Value');
            grayType = grayTypeValues{grayTypeIdx};
            
            % 获取最大灰度值
            grayValue = str2double(get(editGrayValue, 'String'));
            
            % 验证灰度值
            if isnan(grayValue) || grayValue < 0 || grayValue > 255
                grayValue = 255;
                set(editGrayValue, 'String', '255');
            end
            
            % 生成图像
            img = zeros(params.height, params.width);
            
            switch grayType
                case 'horizontal' % 水平梯度
                    for j = 1:params.width
                        img(:, j) = (j-1) * grayValue / (params.width-1);
                    end
                    
                case 'vertical' % 垂直梯度
                    for i = 1:params.height
                        img(i, :) = (i-1) * grayValue / (params.height-1);
                    end
                    
                case 'radial' % 径向梯度
                    [X, Y] = meshgrid(1:params.width, 1:params.height);
                    centerX = params.width/2;
                    centerY = params.height/2;
                    R = sqrt((X - centerX).^2 + (Y - centerY).^2);
                    maxR = max(R(:));
                    img = R / maxR * grayValue;
                    
                case 'concentric' % 同心圆梯度
                    [X, Y] = meshgrid(1:params.width, 1:params.height);
                    centerX = params.width/2;
                    centerY = params.height/2;
                    R = sqrt((X - centerX).^2 + (Y - centerY).^2);
                    scaleFactor = grayValue / (min(params.width, params.height)/8);
                    img = mod(R * scaleFactor, grayValue+1);
                    
                case 'checkerboard' % 棋盘格
                    checkerSize = min(params.width, params.height) / 20;
                    [X, Y] = meshgrid(1:params.width, 1:params.height);
                    img = mod(floor(X/checkerSize) + floor(Y/checkerSize), 2) * grayValue;
                    
                case 'noise' % 随机噪声
                    img = rand(params.height, params.width) * grayValue;
                    
                case 'constant' % 固定灰度
                    img = ones(params.height, params.width) * grayValue;
            end
            
            % 应用边界
            img = applyBorder(img, params);
            
            % 显示图像
            displayImage(img, ['灰度图 (', grayTypes{grayTypeIdx}, ')']);
            
            % 更新图像信息
            updateImageInfo(['灰度图 (', grayTypes{grayTypeIdx}, ')'], params, ...
                sprintf('灰度值: %d', grayValue));
            
        catch e
            errordlg(['生成灰度图时出错: ', e.message], '错误');
        end
    end
    
    %% 浏览图像文件
    function browseImage(~, ~)
        [filename, pathname] = uigetfile({...
            '*.png;*.jpg;*.jpeg;*.bmp;*.tif', '图像文件 (*.png, *.jpg, *.jpeg, *.bmp, *.tif)'}, ...
            '选择图像');
        
        if filename ~= 0
            fullpath = fullfile(pathname, filename);
            set(editImagePath, 'String', fullpath);
            
            % 设置为"本地文件选择"模式
            set(bgImageSource, 'Value', 1);
        end
    end
    
    %% 处理图像
    function processImage(~, ~)
        try
            % 获取参数
            params = getCurrentParams();
            
            % 获取图像来源
            imageSourceIdx = get(bgImageSource, 'Value');
            imageSource = imageSourceValues{imageSourceIdx};
            
            processingIdx = get(bgImageProcessing, 'Value');
            processingType = processingValues{processingIdx};
            
            % 获取图像
            if strcmp(imageSource, 'local')
                imagePath = get(editImagePath, 'String');
                
                if isempty(imagePath) || ~exist(imagePath, 'file')
                    errordlg('请选择有效的图像文件路径', '错误');
                    return;
                end
                
                try
                    img = imread(imagePath);
                    sourceLabel = '本地文件';
                catch
                    errordlg(['无法读取图像: ', imagePath], '错误');
                    return;
                end
            else % 默认图像
                try
                    % 生成默认测试图像
                    [X, Y] = meshgrid(linspace(-5, 5, params.width), linspace(-5, 5, params.height));
                    R = sqrt(X.^2 + Y.^2);
                    img = sin(R) .* exp(-0.1*R);
                    img = (img - min(img(:))) / (max(img(:)) - min(img(:))) * 255;
                    img = uint8(img);
                    sourceLabel = '默认测试图像';
                catch
                    errordlg('生成默认图像失败', '错误');
                    return;
                end
            end
            
            % 调整图像尺寸
            img = imresize(img, [params.height, params.width]);
            
            % 转换为灰度图像
            if size(img, 3) == 3
                grayImg = rgb2gray(img);
            else
                grayImg = img;
            end
            
            % 应用图像处理
            switch processingType
                case 'grayscale'
                    processedImg = grayImg;
                    processLabel = '灰度化';
                    
                case 'binary'
                    threshold = str2double(get(editThreshold, 'String'));
                    
                    if isnan(threshold) || threshold < 0 || threshold > 1
                        threshold = 0.5;
                        set(editThreshold, 'String', '0.5');
                    end
                    
                    processedImg = imbinarize(grayImg, threshold) * 255;
                    processLabel = ['二值化 (阈值=', num2str(threshold), ')'];
                    
                case 'invert'
                    processedImg = 255 - grayImg;
                    processLabel = '反色';
                    
                case 'histeq'
                    processedImg = histeq(grayImg) * 255;
                    processLabel = '直方图均衡';
            end
            
            % 应用边界
            processedImg = applyBorder(processedImg, params);
            
            % 显示图像
            displayImage(processedImg, ['图像处理 (', processingOptions{processingIdx}, ')']);
            
            % 更新图像信息
            updateImageInfo(['图像处理 (', processingOptions{processingIdx}, ')'], params, ...
                ['来源: ', sourceLabel]);
            
        catch e
            errordlg(['处理图像时出错: ', e.message], '错误');
        end
    end
    
    %% 生成偏振光栅
    function generatePolarGrating(~, ~)
        try
            % 获取参数
            params = getCurrentParams();
            
            % 获取偏振光栅参数
            period = str2double(get(editPolarGratingPeriod, 'String'));
            rotation = str2double(get(editPolarRotationAngle, 'String'));
            phase = str2double(get(editPolarPhase, 'String'));
            
            % 获取SLM转换参数
            enableSLMConv = get(enableSLMConversion, 'Value');
            slopeCoeff = str2double(get(editSlopeCoeff, 'String'));
            interceptCoeff = str2double(get(editInterceptCoeff, 'String'));
            
            % 获取光栅类型
            gratingTypeIdx = get(popupPolarGratingType, 'Value');
            gratingType = polarGratingValues{gratingTypeIdx};
            
            % 参数验证
            if isnan(period) || period <= 0
                period = 100;
                set(editPolarGratingPeriod, 'String', '100');
            end
            
            if isnan(rotation)
                rotation = 0;
                set(editPolarRotationAngle, 'String', '0');
            end
            
            if isnan(phase)
                phase = 0;
                set(editPolarPhase, 'String', '0');
            end
            
            % 生成坐标网格
            [X, Y] = meshgrid(1:params.width, 1:params.height);
            centerX = params.width / 2;
            centerY = params.height / 2;
            
            % 应用旋转
            Xr = (X - centerX) * cosd(rotation) + (Y - centerY) * sind(rotation) + centerX;
            Yr = -(X - centerX) * sind(rotation) + (Y - centerY) * cosd(rotation) + centerY;
            
            % 根据光栅类型生成相位分布
            switch gratingType
                case 'linear' % 线性偏振
                    % 获取灰度范围
                    gray_min = str2double(get(editPolarGrayMin, 'String'));
                    gray_max = str2double(get(editPolarGrayMax, 'String'));
                    if isnan(gray_min) || gray_min < 0 || gray_min > 255
                        gray_min = 10;
                        set(editPolarGrayMin, 'String', '10');
                    end
                    if isnan(gray_max) || gray_max < 0 || gray_max > 255
                        gray_max = 255;
                        set(editPolarGrayMax, 'String', '255');
                    end
                    % 生成线性偏振光栅
                    img = zeros(params.height, params.width);
                    for x = 1:params.width
                        theta_deg = mod((x-1)/period * 180 + phase, 180); % 0~180度
                        gray_value = gray_min + (gray_max - gray_min) * theta_deg / 180;
                        img(:, x) = gray_value;
                    end
                    % 应用旋转
                    if rotation ~= 0
                        img = imrotate(img, rotation, 'bilinear', 'crop');
                    end
                    % 应用SLM转换（如有）
                    if enableSLMConv
                        mappedAngle = (img - gray_min) / (gray_max - gray_min) * 180 - 90;
                        img = slopeCoeff * mappedAngle + interceptCoeff;
                        img = max(0, min(255, img));
                    end
                    % 应用边界
                    img = applyBorder(img, params);
                    % 显示图像
                    displayImage(img, '偏振光栅 (线性偏振)');
                    % 更新信息
                    extraInfo = sprintf('周期: %d 像素, 灰度范围: [%d, %d], 旋转: %.1f°, 相位: %.1f°', period, gray_min, gray_max, rotation, phase);
                    if enableSLMConv
                        extraInfo = [extraInfo, sprintf(', SLM转换: %.4f×角度+%.2f', slopeCoeff, interceptCoeff)];
                    end
                    updateImageInfo('偏振光栅 (线性偏振)', params, extraInfo);
                    return;
                case 'circular' % 圆偏振
                    angle = mod(Xr / period * 180 + phase, 180);
                    
                case 'vortex' % 涡旋光束
                    r = sqrt((X - centerX).^2 + (Y - centerY).^2);
                    theta = atan2(Y - centerY, X - centerX);
                    angle = mod(theta * 180/pi + phase, 180);
                    
                case 'radial' % 径向偏振
                    r = sqrt((X - centerX).^2 + (Y - centerY).^2);
                    theta = atan2(Y - centerY, X - centerX);
                    angle = mod(theta * 180/pi + phase, 180);
                    
                case 'azimuthal' % 角向偏振
                    r = sqrt((X - centerX).^2 + (Y - centerY).^2);
                    theta = atan2(Y - centerY, X - centerX);
                    angle = mod(theta * 180/pi + 90 + phase, 180);
                    
                case '2d' % 二维光栅
                    angleX = mod(Xr / period * 180 + phase, 180);
                    angleY = mod(Yr / period * 180 + phase, 180);
                    angle = mod(angleX + angleY, 180);
                    
                otherwise
                    % 默认为线性偏振
                    angle = mod(Xr / period * 180 + phase, 180);
            end
            
            % 转换为灰度值
            img = angle / 180 * 255;
            
            % 应用SLM转换
            if enableSLMConv
                % 将角度映射到-90到90度范围
                mappedAngle = angle - 90;
                
                % 应用线性转换: 灰度值 = 斜率 × 角度 + 截距
                img = slopeCoeff * mappedAngle + interceptCoeff;
                
                % 限制在0-255范围内
                img = max(0, min(255, img));
            end
            
            % 应用边界
            img = applyBorder(img, params);
            
            % 显示图像
            displayImage(img, ['偏振光栅 (', polarGratingTypes{gratingTypeIdx}, ')']);
            
            % 更新图像信息
            extraInfo = sprintf('周期: %d 像素, 旋转: %.1f°, 相位: %.1f°', period, rotation, phase);
            if enableSLMConv
                extraInfo = [extraInfo, sprintf(', SLM转换: %.4f×角度+%.2f', slopeCoeff, interceptCoeff)];
            end
            updateImageInfo(['偏振光栅 (', polarGratingTypes{gratingTypeIdx}, ')'], params, extraInfo);
            
        catch e
            errordlg(['生成偏振光栅时出错: ', e.message], '错误');
        end
    end
    
    %% 生成个性化偏振光栅
    function generateCustomPolarGrating(~, ~)
        try
            % 获取当前参数
            params = getCurrentParams();
            
            % 获取个性化光栅参数
            gratingTypeIdx = get(popupCustomPolarGratingType, 'Value');
            gratingType = customPolarGratingValues{gratingTypeIdx};
            
            pointSpacing = str2double(get(editCustomPointSpacing, 'String'));
            pointSize = str2double(get(editCustomPointSize, 'String'));
            rotation = str2double(get(editCustomRotationAngle, 'String'));
            
            % 获取SLM转换参数 - 检查是否有这些控件，如果没有则不应用SLM转换
            try
                enableSLMConv = get(enableCustomSLMConversion, 'Value');
                slopeCoeff = str2double(get(editCustomSlopeCoeff, 'String'));
                interceptCoeff = str2double(get(editCustomInterceptCoeff, 'String'));
                hasSLMControls = true;
            catch
                hasSLMControls = false;
                enableSLMConv = false;
            end
            
            % 参数验证
            if isnan(pointSpacing) || pointSpacing <= 0
                pointSpacing = 100;
                set(editCustomPointSpacing, 'String', '100');
            end
            
            if isnan(pointSize) || pointSize <= 0
                pointSize = 40;
                set(editCustomPointSize, 'String', '40');
            end
            
            if isnan(rotation)
                rotation = 0;
                set(editCustomRotationAngle, 'String', '0');
            end
            
            % 显示进度条
            waitbar_h = waitbar(0, '正在生成胆甾相液晶曝光图（相位分布）...');
            
            % 根据选择的光栅类型生成相位分布
            switch gratingType
                case 'square9' % 方形9点偏振光栅
                    waitbar(0.2, waitbar_h, '生成方形9点相位分布...');
                    
                    N = min(params.height, params.width);
                    Tx = pointSpacing;
                    Ty = pointSpacing;
                    
                    % 定义9点的衍射级次（方形排列）
                    m_vals = [-1, 0, 1, -1, 0, 1, -1, 0, 1];
                    n_vals = [-1, -1, -1, 0, 0, 0, 1, 1, 1];
                    amplitudes = [1, 1, 1, 1, 0, 1, 1, 1, 1];
                    phases = [0, pi/2, pi, pi/2, 0, pi/2, pi, pi/2, 0];
                    
                    % 计算复振幅分布
                    b = zeros(N, N);
                    for i = 1:length(m_vals)
                        [x_idx, y_idx] = meshgrid(1:N, 1:N);
                        b = b + amplitudes(i) * exp(1i*(2*pi*x_idx*m_vals(i)/Tx + 2*pi*y_idx*n_vals(i)/Ty + phases(i)));
                    end
                    
                case 'hexagon9' % 六边形9点偏振光栅
                    waitbar(0.2, waitbar_h, '生成六边形9点相位分布...');
                    
                    N = min(params.height, params.width);
                    Tx = pointSpacing;
                    Ty = pointSpacing;
                    
                    % 定义六边形9点的衍射级次
                    m_vals = [0, 1, -1, 1, -1, 2, -2, 0, 0];
                    n_vals = [0, 1, 1, -1, -1, 0, 0, 2, -2];
                    amplitudes = [0, 1, 1, 1, 1, 1, 1, 1, 1];
                    phases = [0, 0, pi/2, pi/2, pi, pi/2, pi, 0, pi];
                    
                    % 计算复振幅分布
                    b = zeros(N, N);
                    for i = 1:length(m_vals)
                        [x_idx, y_idx] = meshgrid(1:N, 1:N);
                        b = b + amplitudes(i) * exp(1i*(2*pi*x_idx*m_vals(i)/Tx + 2*pi*y_idx*n_vals(i)/Ty + phases(i)));
                    end
                    
                case 'phase_grating' % 相位型偏振光栅
                    waitbar(0.2, waitbar_h, '生成10点相位型偏振光栅（0级抑制优化）...');
                    
                    N = min(params.height, params.width);
                    
                    % 优化后的10点衍射级次参数
                    m_vals = [1, -1, 1, -1, 2, -2, 2, -2, 3, -3];
                    n_vals = [1, -1, -1, 1, 2, -2, -2, 2, 0, 0];
                    
                    % 重新优化的振幅分布
                    amplitudes = [1.1547, 1.1547, 1.0, 1.0, 1.2247, 1.2247, 1.2247, 1.2247, 1.414, 0];
                    
                    % 优化相位分布
                    phases = [pi*3/4, pi*3/4, pi/4, pi/4, 0, pi/2, pi, pi/2, 0, 0];
                    
                    % 光栅周期
                    Tx = pointSpacing;
                    Ty = pointSpacing;
                    
                    % 使用优化的矩阵计算方法
                    [x_grid, y_grid] = meshgrid(1:N, 1:N);
                    
                    % 精确计算复振幅分布b
                    b = zeros(N, N);
                    
                    % 逐个计算每个衍射级次的贡献
                    for k = 1:length(m_vals)
                        phase_k = 2*pi*x_grid*m_vals(k)/Tx + 2*pi*y_grid*n_vals(k)/Ty + phases(k);
                        b = b + amplitudes(k) * exp(1i * phase_k);
                    end
                    
                    % 添加亚波长精度修正
                    subwavelength_correction = 0.05 * exp(1i * 2*pi*(x_grid + y_grid)/(4*Tx));
                    b = b + subwavelength_correction;
                    
                case 'pb_grating' % Pancharatnam-Berry相位光栅
                    waitbar(0.2, waitbar_h, '生成高精度Pancharatnam-Berry相位光栅...');
                    
                    N = min(params.height, params.width);
                    [x_grid, y_grid] = meshgrid(1:N, 1:N);
                    center_x = N/2;
                    center_y = N/2;
                    
                    % 计算精确的径向距离
                    r = sqrt((x_grid - center_x).^2 + (y_grid - center_y).^2);
                    
                    % 高精度PB透镜参数
                    f = pointSpacing * 8;
                    lambda = params.wavelength_nm * 1e-9;
                    pixel_size = params.grating_width_mm / params.width * 1e-3;
                    r_physical = r * pixel_size;
                    f_physical = f * pixel_size;
                    
                    % 高精度PB相位公式
                    alpha_pb = pi * (r_physical.^2) / (2 * f_physical * lambda);
                    
                    % 添加球差补偿项
                    spherical_aberration_correction = -0.1 * (r_physical.^4) / (8 * f_physical^3 * lambda);
                    alpha_pb = alpha_pb + spherical_aberration_correction;
                    
                    % 限制角度范围
                    alpha_pb = mod(alpha_pb, pi);
                    
                    % 添加高阶衍射抑制
                    higher_order_suppression = 0.05 * sin(4*pi*x_grid/pointSpacing) .* sin(4*pi*y_grid/pointSpacing);
                    alpha_pb = alpha_pb + higher_order_suppression;
                    
                    % 生成复振幅
                    b = exp(2i * alpha_pb);
                    
                otherwise % 其他类型的简化实现
                    waitbar(0.2, waitbar_h, '生成标准偏振光栅...');
                    
                    N = min(params.height, params.width);
                    [x_grid, y_grid] = meshgrid(1:N, 1:N);
                    
                    % 基本的相位分布
                    phase = 2*pi*x_grid/pointSpacing + 2*pi*y_grid/pointSpacing;
                    b = exp(1i * phase);
            end
            
            waitbar(0.6, waitbar_h, '计算液晶取向角度...');
            
            % 提取相位分布 c = angle(b)
            c = angle(b);
            
            % 液晶分子取向角度 = 相位/2
            theta_liquid_crystal = c * 0.5;
            
            waitbar(0.8, waitbar_h, '应用旋转变换...');
            
            % 如果有旋转角度，应用旋转变换
            if rotation ~= 0
                rotation_rad = rotation * pi / 180;
                theta_liquid_crystal = theta_liquid_crystal + rotation_rad;
            end
            
            % 将角度限制在[0, pi]范围内
            theta_liquid_crystal = mod(theta_liquid_crystal, pi);
            
            waitbar(0.9, waitbar_h, '生成最终曝光图...');
            
            % 调整到目标尺寸
            if size(theta_liquid_crystal,1) ~= params.height || size(theta_liquid_crystal,2) ~= params.width
                theta_liquid_crystal = imresize(theta_liquid_crystal, [params.height, params.width]);
            end
            
            % 将液晶取向角度转换为0-255的灰度值
            orientation_image = theta_liquid_crystal * (255/pi);
            
            % 应用SLM转换（如果有）
            if hasSLMControls && enableSLMConv
                % 将灰度值转换为角度（0-255映射到-90到90度）
                mapped_angle = (orientation_image / 255) * 180 - 90;
                
                % 应用线性转换
                orientation_image = slopeCoeff * mapped_angle + interceptCoeff;
                
                % 限制在0-255范围内
                orientation_image = max(0, min(255, orientation_image));
            end
            
            % 创建三通道偏振图像
            polarImg = zeros(params.height, params.width, 3);
            polarImg(:,:,1) = orientation_image;
            polarImg(:,:,2) = zeros(params.height, params.width);
            polarImg(:,:,3) = ones(params.height, params.width) * 255;
            
            % 应用边界
            img = applyBorder(orientation_image, params);
            
            % 获取预览模式
            previewMode = get(popupCustomPolarPreviewMode, 'Value'); % 1=灰度, 2=彩色
            
            % 显示图像
            axes(axesImg);
            
            if previewMode == 1 % 灰度显示
                imshow(uint8(img));
                colormap(gca, 'gray');
                colorbar('YTick', [0, 64, 128, 192, 255], 'YTickLabel', {'0°', '45°', '90°', '135°', '180°'});
            else % 彩色显示
                imshow(uint8(img));
                colormap(gca, 'hsv');
                colorbar('YTick', [0, 64, 128, 192, 255], 'YTickLabel', {'0°', '45°', '90°', '135°', '180°'});
            end
            
            title(['胆甾相液晶曝光图: ', customPolarGratingTypes{gratingTypeIdx}], 'FontSize', 12);
            
            % 存储当前图像
            currentImage = img;
            currentImageType = ['胆甾相液晶曝光图 (', customPolarGratingTypes{gratingTypeIdx}, ')'];
            
            % 添加光栅类型信息
            switch gratingType
                case 'square9'
                    params.gratingType = 'square9';
                case 'hexagon9'
                    params.gratingType = 'hexagon9';
                case 'phase_grating'
                    params.gratingType = 'phase_grating';
                case 'pb_grating'
                    params.gratingType = 'pb_grating';
                otherwise
                    params.gratingType = 'pb_grating';
            end
            
            % 更新图像信息
            extraInfo = sprintf('周期: %d 像素, 液晶取向角度: 0°-180°', pointSpacing);
            if hasSLMControls && enableSLMConv
                extraInfo = [extraInfo, sprintf(', SLM转换: %.4f×角度+%.2f', slopeCoeff, interceptCoeff)];
            end
            updateImageInfo(['胆甾相液晶曝光图 (', customPolarGratingTypes{gratingTypeIdx}, ')'], params, extraInfo);
                
            waitbar(1.0, waitbar_h, '完成！');
            close(waitbar_h);
            
        catch e
            % 如果有等待条，先关闭
            if exist('waitbar_h', 'var') && ishandle(waitbar_h)
                close(waitbar_h);
            end
            % 显示具体的错误信息
            errordlg(['生成个性化偏振光栅时发生错误: ', e.message], '错误');
        end
    end
    
    %% 保存图像
    function saveImage(~, ~)
        if isempty(currentImage)
            errordlg('当前没有可保存的图像', '错误');
            return;
        end
        
        % 创建保存图像选项对话框
        saveDialog = figure('Name', '保存图像选项', 'Position', [200, 200, 550, 500], ...
            'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'off', ...
            'WindowStyle', 'modal', 'Color', [0.94 0.94 0.94]);
        
        % 标题
        uicontrol(saveDialog, 'Style', 'text', 'String', '保存图像选项', ...
            'Position', [150, 450, 250, 30], 'FontSize', 16, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.94 0.94 0.94]);
        
        % 文件格式选择
        uicontrol(saveDialog, 'Style', 'text', 'String', '文件格式:', ...
            'Position', [50, 400, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        formatPopup = uicontrol(saveDialog, 'Style', 'popupmenu', ...
            'String', {'PNG图像 (*.png)', 'TIFF图像 (*.tif)', 'BMP图像 (*.bmp)', 'JPEG图像 (*.jpg)', 'EPS图像 (*.eps)', 'PDF文档 (*.pdf)', 'SVG矢量图 (*.svg)', 'FIG图像 (*.fig)'}, ...
            'Position', [200, 400, 300, 25], 'Value', 1);
        
        % 分辨率设置
        uicontrol(saveDialog, 'Style', 'text', 'String', '分辨率(DPI):', ...
            'Position', [50, 350, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        dpiPopup = uicontrol(saveDialog, 'Style', 'popupmenu', ...
            'String', {'72 (屏幕显示)', '150 (低质量打印)', '300 (标准打印)', '600 (高质量打印)', '1200 (专业打印)', '2400 (最高质量)'}, ...
            'Position', [200, 350, 300, 25], 'Value', 3);
        
        % 颜色模式选择
        uicontrol(saveDialog, 'Style', 'text', 'String', '颜色模式:', ...
            'Position', [50, 300, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        colorModePopup = uicontrol(saveDialog, 'Style', 'popupmenu', ...
            'String', {'灰度', '彩色'}, ...
            'Position', [200, 300, 300, 25], 'Value', 1);
        
        % 文件名设置
        uicontrol(saveDialog, 'Style', 'text', 'String', '文件名:', ...
            'Position', [50, 250, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        % 获取当前时间作为默认文件名
        timeStr = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
        defaultName = ['ExposurePattern_', timeStr];
        
        filenameEdit = uicontrol(saveDialog, 'Style', 'edit', ...
            'String', defaultName, ...
            'Position', [200, 250, 300, 25]);
        
        % 图像质量设置
        uicontrol(saveDialog, 'Style', 'text', 'String', '图像质量:', ...
            'Position', [50, 200, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        qualityPopup = uicontrol(saveDialog, 'Style', 'popupmenu', ...
            'String', {'高质量', '中等质量', '低质量'}, ...
            'Position', [200, 200, 300, 25], 'Value', 1);
        
        % 保存参数信息选项
        saveParamsCheckbox = uicontrol(saveDialog, 'Style', 'checkbox', ...
            'String', '保存参数信息', 'Value', 1, ...
            'Position', [200, 150, 150, 20], ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        % 提示信息
        uicontrol(saveDialog, 'Style', 'text', ...
            'String', '提示: 选择合适的格式和质量以满足您的需求', ...
            'Position', [50, 100, 450, 20], ...
            'HorizontalAlignment', 'center', ...
            'BackgroundColor', [0.94 0.94 0.94], ...
            'ForegroundColor', [0.5 0.5 0.5]);
        
        % 分隔线
        uicontrol(saveDialog, 'Style', 'text', ...
            'String', '', 'Position', [25, 80, 500, 1], ...
            'BackgroundColor', [0.8 0.8 0.8]);
        
        % 保存按钮
        uicontrol(saveDialog, 'Style', 'pushbutton', 'String', '保存图像', ...
            'Position', [150, 25, 100, 35], 'Callback', @doSaveImageCallback, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.3, 0.6, 0.9], ...
            'ForegroundColor', [1 1 1]);
        
        % 取消按钮
        uicontrol(saveDialog, 'Style', 'pushbutton', 'String', '取消', ...
            'Position', [300, 25, 100, 35], 'Callback', @(~,~)close(saveDialog), ...
            'BackgroundColor', [0.9, 0.3, 0.3], ...
            'ForegroundColor', [1 1 1]);
        
        % 保存回调函数
        function doSaveImageCallback(~,~)
            try
                % 获取用户选择
                formatIdx = get(formatPopup, 'Value');
                dpiIdx = get(dpiPopup, 'Value');
                colorModeIdx = get(colorModePopup, 'Value');
                qualityIdx = get(qualityPopup, 'Value');
                saveParams = get(saveParamsCheckbox, 'Value');
                filename = get(filenameEdit, 'String');
                
                % 文件扩展名
                formatExtensions = {'.png', '.tif', '.bmp', '.jpg', '.eps', '.pdf', '.svg', '.fig'};
                extension = formatExtensions{formatIdx};
                
                % 文件过滤器
                formatFilters = {'*.png', '*.tif', '*.bmp', '*.jpg', '*.eps', '*.pdf', '*.svg', '*.fig'};
                formatDescriptions = {'PNG图像 (*.png)', 'TIFF图像 (*.tif)', 'BMP图像 (*.bmp)', 'JPEG图像 (*.jpg)', 'EPS图像 (*.eps)', 'PDF文档 (*.pdf)', 'SVG矢量图 (*.svg)', 'FIG图像 (*.fig)'};
                
                % 构建完整文件名
                fullFilename = [filename, extension];
                
                % 打开文件保存对话框
                [file, path] = uiputfile(fullFilename, '保存图像');
                
                if file ~= 0
                    % 构建完整路径
                    fullpath = fullfile(path, file);
                    
                    % 准备图像数据
                    if colorModeIdx == 1 % 灰度
                        imgToSave = uint8(currentImage);
                    else % 彩色
                        % 如果当前图像是灰度的，转换为彩色
                        if size(currentImage, 3) == 1
                            imgToSave = uint8(gray2rgb(currentImage));
                        else
                            imgToSave = uint8(currentImage);
                        end
                    end
                    
                    % 根据格式和质量设置保存选项
                    switch formatIdx
                        case 1 % PNG
                            imwrite(imgToSave, fullpath);
                        case 2 % TIFF
                            % 设置TIFF压缩
                            tiffCompression = {'none', 'lzw', 'packbits'};
                            imwrite(imgToSave, fullpath, 'Compression', tiffCompression{qualityIdx});
                        case 3 % BMP
                            imwrite(imgToSave, fullpath);
                        case 4 % JPEG
                            % 设置JPEG质量
                            jpegQuality = [95, 75, 50]; % 高、中、低质量
                            imwrite(imgToSave, fullpath, 'Quality', jpegQuality(qualityIdx));
                        case 5 % EPS
                            % EPS格式需要特殊处理
                            try
                                % 创建临时图像
                                tempFig = figure('Visible', 'off');
                                imshow(imgToSave);
                                
                                % 获取DPI值
                                dpiValues = [72, 150, 300, 600, 1200, 2400];
                                selectedDPI = dpiValues(dpiIdx);
                                
                                % 保存为EPS
                                print(tempFig, fullpath, '-depsc', ['-r' num2str(selectedDPI)]);
                                close(tempFig);
                            catch e
                                errordlg(['保存EPS格式失败: ', e.message], '错误');
                            end
                        case 6 % PDF
                            % PDF格式需要特殊处理
                            try
                                % 创建临时图像
                                tempFig = figure('Visible', 'off');
                                imshow(imgToSave);
                                
                                % 获取DPI值
                                dpiValues = [72, 150, 300, 600, 1200, 2400];
                                selectedDPI = dpiValues(dpiIdx);
                                
                                % 保存为PDF
                                print(tempFig, fullpath, '-dpdf', ['-r' num2str(selectedDPI)]);
                                close(tempFig);
                            catch e
                                errordlg(['保存PDF格式失败: ', e.message], '错误');
                            end
                        case 7 % SVG
                            % SVG格式需要特殊处理
                            try
                                % 创建临时图像
                                tempFig = figure('Visible', 'off');
                                imshow(imgToSave);
                                
                                % 保存为SVG
                                print(tempFig, fullpath, '-dsvg');
                                close(tempFig);
                            catch e
                                errordlg(['保存SVG格式失败: ', e.message], '错误');
                            end
                        case 8 % FIG
                            % FIG格式需要特殊处理
                            try
                                % 创建临时图像
                                tempFig = figure('Visible', 'off');
                                imshow(imgToSave);
                                
                                % 保存为FIG
                                savefig(tempFig, fullpath);
                                close(tempFig);
                            catch e
                                errordlg(['保存FIG格式失败: ', e.message], '错误');
                            end
                    end
                    
                    % 保存参数信息
                    if saveParams
                        params = getCurrentParams();
                        saveParameterInfo(fullpath, params);
                    end
                    
                    % 关闭对话框
                    close(saveDialog);
                    
                    % 显示成功消息
                    msgbox(['图像已保存至: ', fullpath], '保存成功', 'help');
                end
            catch e
                errordlg(['保存图像失败: ', e.message], '错误');
            end
        end
        
        % 辅助函数：灰度转RGB
        function rgbImg = gray2rgb(grayImg)
            rgbImg = cat(3, grayImg, grayImg, grayImg);
        end
    end
    
    %% 保存参数信息
    function saveParameterInfo(imagePath, params)
        try
            [pathstr, name, ~] = fileparts(imagePath);
            paramFile = fullfile(pathstr, [name, '_参数信息.txt']);
            
            fid = fopen(paramFile, 'w', 'n', 'UTF-8');
            if fid == -1
                return;
            end
            
            fprintf(fid, '=============================================================\n');
            fprintf(fid, '曝光图生成器参数信息\n');
            fprintf(fid, '=============================================================\n');
            fprintf(fid, '生成时间: %s\n', datestr(now));
            fprintf(fid, '图像类型: %s\n', currentImageType);
            fprintf(fid, '\n--- 基本参数 ---\n');
            fprintf(fid, '图像尺寸: %d × %d 像素\n', params.width, params.height);
            fprintf(fid, '像素尺寸: %.2f %s\n', params.pixel_size, params.pixel_size_unit);
            fprintf(fid, '物理尺寸: %.4f × %.4f mm\n', params.grating_width_mm, params.grating_height_mm);
            fprintf(fid, '波长: %.1f %s (%.1f nm)\n', params.wavelength, params.wavelength_unit, params.wavelength_nm);
            
            if params.enableBorder
                fprintf(fid, '\n--- 边界设置 ---\n');
                fprintf(fid, '边界宽度: %d 像素\n', params.borderWidth);
                fprintf(fid, '边界灰度值: %d\n', params.borderGray);
            end
            
            fprintf(fid, '\n--- 技术规格 ---\n');
            fprintf(fid, '程序版本: 全功能曝光图生成器 V4.0.0\n');
            fprintf(fid, '版权所有: © 西北工业大学 Y.Z\n');
            fprintf(fid, '联系邮箱: yangzhen2971@mail.nwpu.edu.cn\n');
            
            fclose(fid);
        catch
            % 忽略保存参数信息的错误
        end
    end
    
    %% 显示边界帮助
    function showBorderHelp(~, ~)
        helpText = sprintf(['边界设置功能说明：\n\n', ...
            '• 启用边界：勾选后在图像四周添加边界\n', ...
            '• 宽度：边界的像素宽度（默认1像素）\n', ...
            '• 灰度值：边界的灰度值（0-255，默认255为白色）\n\n', ...
            '边界功能主要用于：\n', ...
            '1. 图像分割和定位\n', ...
            '2. 防止边缘效应\n', ...
            '3. 标记图像区域\n', ...
            '4. 提供参考框架']);
        
        msgbox(helpText, '边界设置帮助', 'help');
    end
    
    function closeProgram(~, ~)
        close(fig);
    end
    
end
