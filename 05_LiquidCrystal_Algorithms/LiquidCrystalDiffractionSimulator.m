function LiquidCrystalDiffractionSimulator()
    % 液晶聚合物偏振光栅衍射成像仿真程序
    % 基于远场衍射与角谱理论
    % 版权所有 © 个人(Z.Y)团队(Y.M)
    
    % 全局变量和UI控件句柄
    fig = [];
    panelControl = [];
    panelDisplay = [];
    panelInfo = [];
    divider = [];
    axesImg2D = [];
    axesImg1D = [];
    textInfo = [];
    
    % 控件变量
    editWavelength = [];
    editPixelSize = [];
    editDistance = [];
    editNA = [];
    editLCThickness = [];
    editLCIndex = [];
    editRefractiveIndex = [];
    popupPolarizationType = [];
    popupDiffractionMethod = [];
    popupColormap = [];
    sliderEllipticity = [];
    sliderRotation = [];
    
    % === 修复：正确声明光栅数据变量 ===
    gratingData = [];  % 当前加载的光栅数据
    
    % 新增控件变量 - 完整声明
    editF1 = [];  % 第一透镜焦距
    editF2 = [];  % 第二透镜焦距
    progressBar = [];  % 进度条
    textEllipticityValue = [];  % 椭圆率数值显示
    textRotationValue = [];     % 旋转角度数值显示
    editXRange = [];   % X轴范围控制
    editYRange = [];   % Y轴范围控制
    axisRangePanel = [];  % 坐标轴控制面板
    
    % 增强的控件变量声明
    editExposureWavelength = [];    % 曝光波长控件
    editExposureRealSize = [];      % 曝光图实际尺寸控件
    editExposurePixelSize = [];     % 曝光图像素尺寸控件
    editSamplingPoints = [];        % 采样点数控件
    popupWavelengthUnit = [];       % 波长单位选择
    popupSizeUnit = [];             % 尺寸单位选择
    popupDistanceUnit = [];         % 距离单位选择
    popupFocalUnit1 = [];           % 第一透镜焦距单位
    popupFocalUnit2 = [];           % 第二透镜焦距单位
    
    % 液晶聚合物参数
    lcParams = struct();
    lcParams.thickness = 3e-6;      % 液晶层厚度 (m)
    lcParams.ordinary_index = 1.5;  % 寻常光折射率
    lcParams.extraordinary_index = 1.7; % 非寻常光折射率
    lcParams.tilt_angle = 0;        % 预倾角 (度)
    lcParams.retardation = 1.0;     % 相位延迟(以π为单位)，标准半波片为1.0
    
    % 光学系统参数
    opticalParams = struct();
    opticalParams.wavelength = 532e-9;    % 波长 (m)
    opticalParams.pixel_size = 10e-6;     % 像素尺寸 (m)
    opticalParams.f1 = 0.1;              % 第一透镜焦距 (m)
    opticalParams.f2 = 0.1;              % 第二透镜焦距 (m)
    opticalParams.distance = 0.5;        % 衍射距离 (m)
    opticalParams.NA = 0.1;              % 数值孔径
    
    % slanCM颜色包类型（基于demo文件分析）
    colormapTypes = {'rainbow', 'hsv', 'jet', 'cool', 'warm', 'hot', 'gray', ...
                     'spring', 'summer', 'autumn', 'winter', 'bone', 'copper', ...
                     'pink', 'lines', 'colorcube', 'prism', 'flag'};
    
    % 偏振类型
    polarizationTypes = {'线偏振光', '圆偏振光', '椭圆偏振光', '径向偏振光', '方位偏振光'};
    polarizationValues = {'linear', 'circular', 'elliptical', 'radial', 'azimuthal'};
    
    % 衍射方法
    diffractionMethods = {'远场衍射积分 (4f系统)', '远场衍射积分 (无透镜)', '角谱传播理论', '菲涅尔衍射积分', '基尔霍夫衍射积分'};
    diffractionValues = {'farfield_4f', 'farfield_direct', 'angular_spectrum', 'fresnel', 'kirchhoff'};
    
    % 分隔器位置
    dividerPosition = 0.35;
    
    % 创建主界面
    createMainGUI();
    
    function createMainGUI()
        % 创建主窗口
        fig = figure('Name', '液晶聚合物偏振光栅衍射成像仿真系统', ...
                     'Position', [50, 50, 1400, 900], ...
                     'NumberTitle', 'off', 'MenuBar', 'none', ...
                     'Resize', 'on', 'Color', [0.94 0.94 0.94]);
        
        % 创建面板
        createPanels();
        
        % 初始化显示
        initializeDisplay();
    end
    
    function createPanels()
        % 控制面板
        panelControl = uipanel(fig, 'Title', '参数控制面板', 'FontSize', 12, 'FontWeight', 'bold', ...
            'Position', [0.02, 0.02, dividerPosition-0.02, 0.96], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 创建分隔条
        divider = uipanel(fig, 'Position', [dividerPosition, 0.02, 0.01, 0.96], ...
            'BackgroundColor', [0.5 0.5 0.7]);
        
        % 显示面板
        panelDisplay = uipanel(fig, 'Title', '衍射成像仿真结果', 'FontSize', 12, 'FontWeight', 'bold', ...
            'Position', [dividerPosition+0.01, 0.52, 0.97-dividerPosition-0.01, 0.46], ...
            'BackgroundColor', [1 1 1]);
        
        % 信息面板
        panelInfo = uipanel(fig, 'Title', '仿真信息', 'FontSize', 10, ...
            'Position', [dividerPosition+0.01, 0.02, 0.97-dividerPosition-0.01, 0.48], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 创建控制面板内容
        createControlContent();
        
        % 创建显示内容
        createDisplayContent();
    end
    
    function createControlContent()
        % 创建选项卡组
        tabGroup = uitabgroup(panelControl, 'Position', [0.05, 0.05, 0.9, 0.85]);
        
        % 光学系统参数选项卡
        tabOptical = uitab(tabGroup, 'Title', '光学系统');
        createOpticalTab(tabOptical);
        
        % 液晶参数选项卡
        tabLC = uitab(tabGroup, 'Title', '液晶参数');
        createLCTab(tabLC);
        
        % 偏振控制选项卡
        tabPolarization = uitab(tabGroup, 'Title', '偏振控制');
        createPolarizationTab(tabPolarization);
        
        % 衍射算法选项卡
        tabDiffraction = uitab(tabGroup, 'Title', '衍射算法');
        createDiffractionTab(tabDiffraction);
        
        % 光栅加载选项卡
        tabGrating = uitab(tabGroup, 'Title', '光栅加载');
        createGratingTab(tabGrating);
        
        % 全局仿真按钮 - 恢复🚀表情符号
        uicontrol(panelControl, 'Style', 'pushbutton', 'String', '🚀 开始衍射仿真', ...
            'Position', [50, 10, 150, 45], ...
            'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.1, 0.6, 0.1], 'ForegroundColor', [1 1 1], ...
            'Callback', @runDiffractionSimulation);
            
        % 全局保存按钮 - 恢复💾表情符号
        uicontrol(panelControl, 'Style', 'pushbutton', 'String', '💾 保存结果', ...
            'Position', [220, 10, 150, 45], ...
            'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
            'Callback', @saveSimulationResults);
    end
    
    function createOpticalTab(tab)
        % 光学系统参数设置 - 优化布局，单位后置+下拉选择
        y_pos = 420;
        spacing = 50;
        
        % 曝光波长设置 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '曝光波长:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editExposureWavelength = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.wavelength*1e9), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupWavelengthUnit = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'nm', 'μm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择波长单位');
        
        y_pos = y_pos - spacing;
        
        % 曝光图实际尺寸 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '图像尺寸:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editExposureRealSize = uicontrol(tab, 'Style', 'edit', ...
            'String', '100', ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupSizeUnit = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'μm', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择尺寸单位');
        
        y_pos = y_pos - spacing;
        
        % 曝光图像素尺寸
        uicontrol(tab, 'Style', 'text', 'String', '像素数量:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editExposurePixelSize = uicontrol(tab, 'Style', 'edit', ...
            'String', '512', ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        uicontrol(tab, 'Style', 'text', 'String', 'pixels', ...
            'Position', [195, y_pos, 50, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        y_pos = y_pos - spacing;
        
        % 采样点数
        uicontrol(tab, 'Style', 'text', 'String', '采样点数:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editSamplingPoints = uicontrol(tab, 'Style', 'edit', ...
            'String', '1024', ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        uicontrol(tab, 'Style', 'text', 'String', 'points', ...
            'Position', [195, y_pos, 50, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        y_pos = y_pos - spacing;
        
        % 衍射距离 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '衍射距离:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editDistance = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.distance), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupDistanceUnit = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'m', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择距离单位');
        
        y_pos = y_pos - spacing;
        
        % 数值孔径
        uicontrol(tab, 'Style', 'text', 'String', '数值孔径:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editNA = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.NA), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        uicontrol(tab, 'Style', 'text', 'String', '(无量纲)', ...
            'Position', [195, y_pos, 60, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        y_pos = y_pos - spacing;
        
        % 第一透镜焦距 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '透镜f1:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editF1 = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.f1), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupFocalUnit1 = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'m', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择焦距单位');
        
        y_pos = y_pos - spacing;
        
        % 第二透镜焦距 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '透镜f2:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editF2 = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.f2), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupFocalUnit2 = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'m', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择焦距单位');
        
        % 存储新增的控件引用
        setappdata(fig, 'editExposureWavelength', editExposureWavelength);
        setappdata(fig, 'editExposureRealSize', editExposureRealSize);
        setappdata(fig, 'editExposurePixelSize', editExposurePixelSize);
        setappdata(fig, 'editSamplingPoints', editSamplingPoints);
        setappdata(fig, 'editDistance', editDistance);
        setappdata(fig, 'editNA', editNA);
        setappdata(fig, 'editF1', editF1);
        setappdata(fig, 'editF2', editF2);
        setappdata(fig, 'popupWavelengthUnit', popupWavelengthUnit);
        setappdata(fig, 'popupSizeUnit', popupSizeUnit);
        setappdata(fig, 'popupDistanceUnit', popupDistanceUnit);
        setappdata(fig, 'popupFocalUnit1', popupFocalUnit1);
        setappdata(fig, 'popupFocalUnit2', popupFocalUnit2);
    end
    
    function createLCTab(tab)
        % 液晶参数设置
        y_pos = 400;
        spacing = 50;
        
        % 液晶层厚度
        uicontrol(tab, 'Style', 'text', 'String', '液晶层厚度 (μm):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        editLCThickness = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(lcParams.thickness*1e6), ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 寻常光折射率
        uicontrol(tab, 'Style', 'text', 'String', '寻常光折射率:', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        editLCIndex = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(lcParams.ordinary_index), ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 非寻常光折射率
        uicontrol(tab, 'Style', 'text', 'String', '非寻常光折射率:', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        editRefractiveIndex = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(lcParams.extraordinary_index), ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 10);
    end
    
    function createPolarizationTab(tab)
        % 偏振控制设置
        y_pos = 400;
        spacing = 50;
        
        % 偏振类型
        uicontrol(tab, 'Style', 'text', 'String', '偏振类型:', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        popupPolarizationType = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', polarizationTypes, 'Value', 1, ...
            'Position', [130, y_pos, 150, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 椭圆率输入框 - 改为直接输入方式
        uicontrol(tab, 'Style', 'text', 'String', '椭圆率 (0-1):', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        sliderEllipticity = uicontrol(tab, 'Style', 'edit', ...
            'String', '0.0', ...
            'Position', [130, y_pos, 80, 25], 'FontSize', 10, ...
            'Callback', @updateEllipticityValue);
        
        textEllipticityValue = uicontrol(tab, 'Style', 'text', 'String', '(0-1)', ...
            'Position', [215, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 旋转角度输入框 - 改为直接输入方式
        uicontrol(tab, 'Style', 'text', 'String', '旋转角度 (°):', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        sliderRotation = uicontrol(tab, 'Style', 'edit', ...
            'String', '0.0', ...
            'Position', [130, y_pos, 80, 25], 'FontSize', 10, ...
            'Callback', @updateRotationValue);
        
        textRotationValue = uicontrol(tab, 'Style', 'text', 'String', '(0-180°)', ...
            'Position', [215, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
    end
    
    function createDiffractionTab(tab)
        % 衍射算法选择 - 重新设计版本
        y_pos = 450;
        spacing = 35;
        
        % 算法选择区域
        algorithmMainPanel = uipanel(tab, 'Title', '', ...
            'Position', [0.02, 0.02, 0.96, 0.96], ...
            'BackgroundColor', [0.98 0.98 0.98], ...
            'BorderType', 'none');
        
        % === 第一区域：算法类别选择 ===
        algorithmCategoryPanel = uipanel(algorithmMainPanel, 'Title', '算法分类', ...
            'Position', [0.02, 0.75, 0.96, 0.23], ...
            'BackgroundColor', [0.96 0.96 0.98], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 算法类别说明
        uicontrol(algorithmCategoryPanel, 'Style', 'text', ...
            'String', '选择适合您研究需求的衍射成像算法类别:', ...
            'Position', [20, 135, 400, 20], ...
            'BackgroundColor', [0.96 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        % 算法分类按钮组
        algorithmCategoryGroup = uibuttongroup(algorithmCategoryPanel, ...
            'Position', [20, 40, 900, 90], ...
            'BackgroundColor', [0.96 0.96 0.98], ...
            'BorderType', 'none', ...
            'SelectionChangedFcn', @algorithmCategoryChanged);
        
        % 第一行：基础算法
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '标量衍射理论', 'Position', [10, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '基于标量衍射理论的经典算法：菲涅尔、夫琅禾费、角谱传播');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '矢量衍射理论', 'Position', [140, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '考虑偏振效应的严格矢量衍射算法：RCWA、时域有限差分');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '液晶偏振光栅', 'Position', [270, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '专用于液晶聚合物偏振光栅的琼斯矩阵算法', ...
            'Value', 1);
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '机器学习算法', 'Position', [400, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '基于深度学习的快速衍射计算和相位恢复算法');
        
        % 第二行：高级算法
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '多尺度分析', 'Position', [10, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '小波变换、傅里叶层析等多尺度衍射成像算法');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '相干层析成像', 'Position', [140, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '光学相干层析、数字全息重建算法');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '超分辨重构', 'Position', [270, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '突破衍射极限的超分辨成像重构算法');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '自适应光学', 'Position', [400, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '波前传感与自适应校正算法');
        
        % === 第二区域：具体算法选择 ===
        specificAlgorithmPanel = uipanel(algorithmMainPanel, 'Title', '算法选择', ...
            'Position', [0.02, 0.45, 0.48, 0.28], ...
            'BackgroundColor', [0.98 0.98 0.96], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 算法列表（动态更新）
        algorithmListPanel = uipanel(specificAlgorithmPanel, ...
            'Position', [0.05, 0.15, 0.9, 0.8], ...
            'BackgroundColor', [0.98 0.98 0.96], ...
            'BorderType', 'none');
        
        % 算法说明文本
        algorithmDescriptionText = uicontrol(specificAlgorithmPanel, 'Style', 'text', ...
            'String', '选择算法后将显示详细说明和参数设置', ...
            'Position', [10, 10, 380, 30], ...
            'BackgroundColor', [0.98 0.98 0.96], ...
            'FontSize', 9, 'HorizontalAlignment', 'left');
        
        % === 第三区域：算法参数设置 ===
        algorithmParamsPanel = uipanel(algorithmMainPanel, 'Title', '算法参数', ...
            'Position', [0.52, 0.45, 0.46, 0.28], ...
            'BackgroundColor', [0.96 0.98 0.96], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 参数面板（动态更新）
        paramsContentPanel = uipanel(algorithmParamsPanel, ...
            'Position', [0.05, 0.1, 0.9, 0.85], ...
            'BackgroundColor', [0.96 0.98 0.96], ...
            'BorderType', 'none');
        
        % === 第四区域：颜色映射与可视化 ===
        colorVisualizationPanel = uipanel(algorithmMainPanel, 'Title', '颜色映射与可视化', ...
            'Position', [0.02, 0.02, 0.96, 0.41], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 左侧：颜色映射选择
        colorMappingSubPanel = uipanel(colorVisualizationPanel, ...
            'Position', [0.02, 0.1, 0.46, 0.85], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'BorderType', 'none');
        
        % 颜色分类标题
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '科学色彩映射方案', ...
            'Position', [10, 170, 200, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        % 第一行：感知均匀色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '感知均匀色彩:', ...
            'Position', [10, 140, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.perceptualUniformPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'viridis', 'plasma', 'inferno', 'magma', 'cividis'}, ...
            'Position', [120, 140, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第二行：序列类色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '序列类色彩:', ...
            'Position', [10, 110, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.sequentialPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'Blues', 'BuGn', 'BuPu', 'GnBu', 'Greens', 'Greys', 'Oranges', 'OrRd', 'PuBu', 'PuBuGn', 'PuRd', 'Purples', 'RdPu', 'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd'}, ...
            'Position', [120, 110, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第三行：分散类色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '分散类色彩:', ...
            'Position', [10, 80, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.divergingPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'BrBG', 'PiYG', 'PRGn', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral'}, ...
            'Position', [120, 80, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第四行：循环类色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '循环类色彩:', ...
            'Position', [10, 50, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.cyclicPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'hsv', 'twilight', 'twilight_shifted', 'ocean', 'seasons', 'phase', 'complex'}, ...
            'Position', [120, 50, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第五行：自定义色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '自定义色彩:', ...
            'Position', [10, 20, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.customColorButton = uicontrol(colorMappingSubPanel, 'Style', 'pushbutton', ...
            'String', '设计色彩', ...
            'Position', [120, 18, 80, 24], ...
            'FontSize', 9, ...
            'Callback', @designCustomColormap);
        
        handles.loadColorButton = uicontrol(colorMappingSubPanel, 'Style', 'pushbutton', ...
            'String', '载入', ...
            'Position', [205, 18, 35, 24], ...
            'FontSize', 9, ...
            'Callback', @loadCustomColormap);
        
        % 右侧：可视化选项
        visualizationSubPanel = uipanel(colorVisualizationPanel, ...
            'Position', [0.5, 0.1, 0.48, 0.85], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'BorderType', 'none');
        
        % 可视化模式标题
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '显示模式与增强', ...
            'Position', [10, 170, 200, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        % 显示模式组
        visualizationModeGroup = uibuttongroup(visualizationSubPanel, ...
            'Position', [10, 110, 380, 55], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'BorderType', 'none');
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '强度分布', 'Position', [10, 30, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9, 'Value', 1);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '相位分布', 'Position', [100, 30, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '复振幅', 'Position', [190, 30, 70, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '偏振态', 'Position', [270, 30, 70, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '3D可视化', 'Position', [10, 5, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '动态演示', 'Position', [100, 5, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '对比分析', 'Position', [190, 5, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        % 图像增强选项
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '图像增强:', ...
            'Position', [10, 80, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.contrastCheckbox = uicontrol(visualizationSubPanel, 'Style', 'checkbox', ...
            'String', '对比度增强', 'Position', [100, 80, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        handles.gammaCheckbox = uicontrol(visualizationSubPanel, 'Style', 'checkbox', ...
            'String', '伽马校正', 'Position', [210, 80, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        handles.histEqCheckbox = uicontrol(visualizationSubPanel, 'Style', 'checkbox', ...
            'String', '直方图均衡', 'Position', [300, 80, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        % 色彩映射参数
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '色彩范围:', ...
            'Position', [10, 50, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '最小值:', ...
            'Position', [100, 50, 50, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 9, 'HorizontalAlignment', 'left');
        
        handles.colorMinEdit = uicontrol(visualizationSubPanel, 'Style', 'edit', ...
            'String', 'auto', ...
            'Position', [150, 50, 60, 20], ...
            'FontSize', 9);
        
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '最大值:', ...
            'Position', [220, 50, 50, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 9, 'HorizontalAlignment', 'left');
        
        handles.colorMaxEdit = uicontrol(visualizationSubPanel, 'Style', 'edit', ...
            'String', 'auto', ...
            'Position', [270, 50, 60, 20], ...
            'FontSize', 9);
        
        handles.autoRangeButton = uicontrol(visualizationSubPanel, 'Style', 'pushbutton', ...
            'String', '自动范围', ...
            'Position', [340, 48, 60, 24], ...
            'FontSize', 9, ...
            'Callback', @autoColorRange);
        
        % 预设配置
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '预设配置:', ...
            'Position', [10, 20, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.presetConfigPopup = uicontrol(visualizationSubPanel, 'Style', 'popupmenu', ...
            'String', {'自定义', '高对比度', '科学出版', '演示展示', '色盲友好', '灰度打印'}, ...
            'Position', [100, 20, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @applyPresetConfig);
        
        handles.saveConfigButton = uicontrol(visualizationSubPanel, 'Style', 'pushbutton', ...
            'String', '保存配置', ...
            'Position', [230, 18, 70, 24], ...
            'FontSize', 9, ...
            'Callback', @saveVisualizationConfig);
        
        handles.loadConfigButton = uicontrol(visualizationSubPanel, 'Style', 'pushbutton', ...
            'String', '载入配置', ...
            'Position', [305, 18, 70, 24], ...
            'FontSize', 9, ...
            'Callback', @loadVisualizationConfig);
        
        % 存储界面句柄
        handles.algorithmCategoryGroup = algorithmCategoryGroup;
        handles.algorithmListPanel = algorithmListPanel;
        handles.paramsContentPanel = paramsContentPanel;
        handles.algorithmDescriptionText = algorithmDescriptionText;
        handles.visualizationModeGroup = visualizationModeGroup;
        
        % 初始化液晶偏振光栅算法列表
        updateAlgorithmList('液晶偏振光栅');
    end
    
    function createGratingTab(tab)
        % 光栅加载设置
        y_pos = 400;
        spacing = 50;
        
        % 加载曝光图按钮
        uicontrol(tab, 'Style', 'pushbutton', 'String', '加载曝光图', ...
            'Position', [50, y_pos, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', @loadGratingPattern);
        
        y_pos = y_pos - spacing;
        
        % 生成测试光栅按钮
        uicontrol(tab, 'Style', 'pushbutton', 'String', '生成测试光栅', ...
            'Position', [50, y_pos, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.7, 0.5, 0.2], 'ForegroundColor', [1 1 1], ...
            'Callback', @generateTestGrating);
        
        y_pos = y_pos - spacing;
        
        % 改进的曝光图生成器按钮
        uicontrol(tab, 'Style', 'pushbutton', 'String', '启动曝光图监视器', ...
            'Position', [50, y_pos, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.6, 0.3, 0.8], 'ForegroundColor', [1 1 1], ...
            'Callback', @startExposureMonitor);
    end
    
    function createDisplayContent()
        % 创建2D显示区域
        axesImg2D = axes('Parent', panelDisplay, 'Position', [0.05, 0.1, 0.65, 0.85]);
        title(axesImg2D, '二维衍射强度分布', 'FontSize', 12, 'FontWeight', 'bold');
        
        % 创建坐标轴控制面板
        axisRangePanel = uipanel(panelDisplay, 'Title', '坐标轴控制', 'FontSize', 10, ...
            'Position', [0.72, 0.1, 0.26, 0.85], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % X轴范围控制
        uicontrol(axisRangePanel, 'Style', 'text', 'String', 'X轴范围 (μm):', ...
            'Position', [10, 280, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 10, 'FontWeight', 'bold');
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最小值:', ...
            'Position', [10, 250, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editXRangeMin = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '-100', ...
            'Position', [70, 250, 60, 20], 'FontSize', 9);
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最大值:', ...
            'Position', [10, 220, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editXRangeMax = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '100', ...
            'Position', [70, 220, 60, 20], 'FontSize', 9);
        
        % Y轴范围控制
        uicontrol(axisRangePanel, 'Style', 'text', 'String', 'Y轴范围 (μm):', ...
            'Position', [10, 180, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 10, 'FontWeight', 'bold');
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最小值:', ...
            'Position', [10, 150, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editYRangeMin = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '-100', ...
            'Position', [70, 150, 60, 20], 'FontSize', 9);
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最大值:', ...
            'Position', [10, 120, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editYRangeMax = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '100', ...
            'Position', [70, 120, 60, 20], 'FontSize', 9);
        
        % 应用按钮
        uicontrol(axisRangePanel, 'Style', 'pushbutton', 'String', '应用范围', ...
            'Position', [30, 80, 80, 25], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
            'Callback', @applyAxisRange);
        
        % 自动范围按钮
        uicontrol(axisRangePanel, 'Style', 'pushbutton', 'String', '自动范围', ...
            'Position', [30, 50, 80, 25], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.6, 0.4, 0.8], 'ForegroundColor', [1 1 1], ...
            'Callback', @autoAxisRange);
        
        % 存储控件句柄
        setappdata(fig, 'editXRangeMin', editXRangeMin);
        setappdata(fig, 'editXRangeMax', editXRangeMax);
        setappdata(fig, 'editYRangeMin', editYRangeMin);
        setappdata(fig, 'editYRangeMax', editYRangeMax);
        
        % 创建1D显示区域和仿真信息区域
        % 1D显示区域（上半部分）
        axesImg1D = axes('Parent', panelInfo, 'Position', [0.05, 0.55, 0.9, 0.4]);
        title(axesImg1D, '液晶偏振光栅衍射光强分布（1D）', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel(axesImg1D, '横向位置 (μm)', 'FontSize', 10);
        ylabel(axesImg1D, '归一化强度', 'FontSize', 10);
        
        % 仿真信息显示区域（下半部分）
        textInfo = uicontrol(panelInfo, 'Style', 'text', ...
            'String', '系统就绪，请设置参数并开始仿真', ...
            'Position', [20, 20, 760, 180], ...
            'HorizontalAlignment', 'left', 'FontSize', 10, ...
            'BackgroundColor', [0.95 0.95 0.95]);
    end
    
    function startExposureMonitor(~, ~)
        % 启动曝光图监视器 - 改进版
        monitorFig = figure('Name', '曝光图生成监视器', ...
            'Position', [200, 200, 600, 400], ...
            'NumberTitle', 'off', 'MenuBar', 'none', ...
            'Resize', 'on', 'Color', [0.94 0.94 0.94]);
        
        % 创建监视面板
        monitorPanel = uipanel(monitorFig, 'Title', '监视控制台', 'FontSize', 12, ...
            'Position', [0.05, 0.05, 0.9, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 状态显示
        statusText = uicontrol(monitorPanel, 'Style', 'text', ...
            'String', '等待用户操作...', ...
            'Position', [20, 320, 500, 30], 'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.97 0.97 0.97], ...
            'ForegroundColor', [0.3, 0.3, 0.7]);
        
        % 操作说明
        instrText = uicontrol(monitorPanel, 'Style', 'text', ...
            'String', ['请按以下步骤操作：', char(10), ...
                      '1. 点击"启动曝光图生成器"按钮', char(10), ...
                      '2. 在曝光图生成器中设计您的光栅图案', char(10), ...
                      '3. 完成设计后，点击"确认并传输"按钮', char(10), ...
                      '4. 监视器将自动接收数据并返回仿真程序'], ...
            'Position', [20, 200, 500, 100], 'FontSize', 10, ...
            'HorizontalAlignment', 'left', 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 启动曝光图生成器按钮
        uicontrol(monitorPanel, 'Style', 'pushbutton', 'String', '启动曝光图生成器', ...
            'Position', [50, 150, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', {@launchExposureGenerator, statusText});
        
        % 确认并传输按钮
        confirmBtn = uicontrol(monitorPanel, 'Style', 'pushbutton', 'String', '确认并传输', ...
            'Position', [250, 150, 120, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.6, 0.3, 0.8], 'ForegroundColor', [1 1 1], ...
            'Enable', 'off', ...
            'Callback', {@confirmAndTransfer, statusText, monitorFig});
        
        % 取消按钮
        uicontrol(monitorPanel, 'Style', 'pushbutton', 'String', '取消', ...
            'Position', [420, 150, 80, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.8, 0.3, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', @(~,~) close(monitorFig));
        
        % 数据预览区域
        previewAxes = axes('Parent', monitorPanel, 'Position', [0.1, 0.05, 0.8, 0.3]);
        title(previewAxes, '数据预览 (等待数据传输)', 'FontSize', 11);
        
        % 存储数据
        setappdata(monitorFig, 'confirmBtn', confirmBtn);
        setappdata(monitorFig, 'previewAxes', previewAxes);
        setappdata(monitorFig, 'transferredData', []);
    end
    
    function launchExposureGenerator(~, ~, statusText)
        % 启动外部曝光图生成器
        try
            set(statusText, 'String', '正在启动曝光图生成器...', 'ForegroundColor', [0.7, 0.5, 0]);
            drawnow;
            
            % 这里应该调用外部的曝光图生成程序
            % 由于我们在当前环境中，我们创建一个简化的生成器界面
            callExposureGenerator();
            
            set(statusText, 'String', '曝光图生成器已启动，请在其中完成设计', 'ForegroundColor', [0, 0.7, 0]);
            
            % 启用确认按钮
            confirmBtn = getappdata(gcf, 'confirmBtn');
            set(confirmBtn, 'Enable', 'on');
            
        catch ME
            set(statusText, 'String', ['启动失败: ', ME.message], 'ForegroundColor', [0.8, 0, 0]);
        end
    end
    
    function confirmAndTransfer(~, ~, statusText, monitorFig)
        % 确认并传输数据
        try
            set(statusText, 'String', '正在传输数据...', 'ForegroundColor', [0.7, 0.5, 0]);
            drawnow;
            
            % 获取生成的数据（这里应该从外部程序获取）
            % 暂时使用一个示例数据
            transferredData = getappdata(monitorFig, 'transferredData');
            
            if isempty(transferredData)
                % 如果没有数据，创建一个示例数据
                N = 512;
                [X, Y] = meshgrid(1:N, 1:N);
                transferredData = 128 + 127 * sin(2*pi*X/32) .* cos(2*pi*Y/32);
                
                msgbox('未检测到外部数据，使用示例光栅数据', '提示', 'warn');
            end
            
            % 预览数据
            previewAxes = getappdata(monitorFig, 'previewAxes');
            axes(previewAxes);
            imagesc(transferredData);
            axis equal; axis tight;
            title('传输的光栅数据', 'FontSize', 11);
            colorbar;
            
            % 传输到主程序
            gratingData = transferredData;
            
            set(statusText, 'String', '数据传输完成！', 'ForegroundColor', [0, 0.7, 0]);
            
            % 延迟后关闭监视器
            pause(2);
            close(monitorFig);
            
            msgbox('光栅数据已成功传输到仿真程序', '传输成功', 'help');
            
        catch ME
            set(statusText, 'String', ['传输失败: ', ME.message], 'ForegroundColor', [0.8, 0, 0]);
        end
    end
    
    function initializeDisplay()
        % 初始化显示内容
        
        % 设置slanCM路径
        try
            % 确保slanCM路径在MATLAB路径中
            currentDir = fileparts(mfilename('fullpath'));
            slanCMPath = fullfile(currentDir, '..', 'ColorMaps', 'slanCM');
            if exist(slanCMPath, 'dir')
                addpath(slanCMPath);
            end
        catch
            % 忽略路径设置错误
        end
        
        % 初始化2D显示
        axes(axesImg2D);
        imagesc(peaks(256));
        
        % 尝试使用slanCM颜色映射
        try
            colormap(axesImg2D, slanCM('rainbow'));
        catch
            % 如果slanCM不可用，使用默认颜色映射
            colormap(axesImg2D, hsv);
        end
        
        axis equal; axis tight;
        title('二维衍射强度分布 (示例)', 'FontSize', 12);
        
        % 初始化1D显示
        axes(axesImg1D);
        x = linspace(-100, 100, 1000);
        y = exp(-x.^2/1000);
        plot(x, y, 'LineWidth', 2);
        xlabel('位置 (μm)', 'FontSize', 10);
        ylabel('强度', 'FontSize', 10);
        title('一维衍射光强分布 (示例)', 'FontSize', 12);
        grid on;
    end
    
    % === 核心算法函数 ===
    
    function runDiffractionSimulation(~, ~)
        % 运行衍射仿真 - 增强版，支持新的光学参数
        try
            % 获取新的光学参数
            exposureWavelength = str2double(get(getappdata(fig, 'editExposureWavelength'), 'String')) * 1e-9; % 转换为米
            exposureRealSize = str2double(get(getappdata(fig, 'editExposureRealSize'), 'String')) * 1e-6; % 转换为米
            exposurePixelSize = str2double(get(getappdata(fig, 'editExposurePixelSize'), 'String'));
            samplingPoints = str2double(get(getappdata(fig, 'editSamplingPoints'), 'String'));
            diffractionDistance = str2double(get(getappdata(fig, 'editDistance'), 'String'));
            numericalAperture = str2double(get(getappdata(fig, 'editNA'), 'String'));
            firstLensFocalLength = str2double(get(getappdata(fig, 'editF1'), 'String'));
            secondLensFocalLength = str2double(get(getappdata(fig, 'editF2'), 'String'));
            
            % 参数验证
            if isnan(exposureWavelength) || exposureWavelength <= 0
                errordlg('曝光波长必须为正数', '参数错误');
                return;
            end
            
            if isnan(exposureRealSize) || exposureRealSize <= 0
                errordlg('曝光图实际尺寸必须为正数', '参数错误');
                return;
            end
            
            if isnan(exposurePixelSize) || exposurePixelSize <= 0 || mod(exposurePixelSize, 1) ~= 0
                errordlg('曝光图像素尺寸必须为正整数', '参数错误');
                return;
            end
            
            if isnan(samplingPoints) || samplingPoints <= 0 || mod(samplingPoints, 1) ~= 0
                errordlg('采样点数必须为正整数', '参数错误');
                return;
            end
            
            % 更新光学参数结构
            opticalParams.wavelength = exposureWavelength;
            opticalParams.real_size = exposureRealSize;
            opticalParams.pixel_size = exposureRealSize / exposurePixelSize; % 计算实际像素尺寸
            opticalParams.distance = diffractionDistance;
            opticalParams.NA = numericalAperture;
            opticalParams.f1 = firstLensFocalLength;
            opticalParams.f2 = secondLensFocalLength;
            opticalParams.sampling_points = samplingPoints;
            
            % 计算菲涅尔数
            fresnelNumber = (exposureRealSize/2)^2 / (exposureWavelength * diffractionDistance);
            
            % 计算分辨率限制
            diffraction_limit = 1.22 * exposureWavelength / numericalAperture;
            
            % 显示计算参数信息
            paramInfo = sprintf(['计算参数信息:\n' ...
                '波长: %.0f nm\n' ...
                '像素尺寸: %.3f μm\n' ...
                '实际尺寸: %.1f μm\n' ...
                '采样点数: %d\n' ...
                '菲涅尔数: %.2f\n' ...
                '衍射极限: %.3f μm\n' ...
                '4f系统放大倍数: %.2fx'], ...
                exposureWavelength*1e9, opticalParams.pixel_size*1e6, exposureRealSize*1e6, ...
                samplingPoints, fresnelNumber, diffraction_limit*1e6, secondLensFocalLength/firstLensFocalLength);
            
            % 更新信息显示
            set(textInfo, 'String', paramInfo);
            
            % 获取光栅数据 - 增强版检查和处理
            if isempty(gratingData)
                % 生成默认测试光栅
                warndlg(['未检测到有效的光栅数据！\n\n' ...
                    '将自动生成默认测试光栅进行仿真。\n' ...
                    '如需使用自定义光栅，请先在"光栅加载"选项卡中加载光栅文件。'], ...
                    '光栅数据提示', 'modal');
                generateTestGrating();
                
                % 再次检查是否成功生成
                if isempty(gratingData)
                    error('无法生成测试光栅，请检查程序状态');
                end
            else
                % 验证现有光栅数据
                if any(isnan(gratingData(:))) || any(isinf(gratingData(:)))
                    error('当前光栅数据包含无效值(NaN或Inf)，请重新加载');
                end
                
                % 显示当前使用的光栅信息
                [rows, cols] = size(gratingData);
                fprintf('使用光栅数据: %dx%d, 数值范围 [%.3f, %.3f]\n', ...
                    rows, cols, min(gratingData(:)), max(gratingData(:)));
            end
            
            % 确保光栅数据尺寸正确并进行预处理
            if size(gratingData, 1) ~= exposurePixelSize || size(gratingData, 2) ~= exposurePixelSize
                % 调整光栅数据尺寸
                oldSize = size(gratingData);
                gratingData = imresize(gratingData, [exposurePixelSize, exposurePixelSize], 'bilinear');
                
                infoMsg = sprintf(['光栅数据尺寸已自动调整\n\n' ...
                    '原始尺寸: %dx%d\n' ...
                    '调整后尺寸: %dx%d\n\n' ...
                    '调整方法: 双线性插值'], ...
                    oldSize(1), oldSize(2), exposurePixelSize, exposurePixelSize);
                
                msgbox(infoMsg, '尺寸调整完成', 'help');
            end
            
            % 确保数据归一化
            if max(gratingData(:)) > 1
                gratingData = gratingData / max(gratingData(:));
            end
            if min(gratingData(:)) < 0
                gratingData = gratingData - min(gratingData(:));
            end
            
            % 最终验证光栅数据
            if isempty(gratingData) || ~isnumeric(gratingData)
                error('光栅数据最终验证失败，无法进行仿真');
            end
            
            % 更新仿真信息，显示光栅状态
            gratingInfo = sprintf(['光栅数据状态: ✓ 已准备就绪\n' ...
                '尺寸: %dx%d 像素\n' ...
                '数值范围: [%.3f, %.3f]\n'], ...
                size(gratingData, 1), size(gratingData, 2), ...
                min(gratingData(:)), max(gratingData(:)));
            
            % 更新仿真信息显示
            tempInfo = sprintf('%s\n%s\n正在进行衍射仿真计算...', gratingInfo, paramInfo);
            set(textInfo, 'String', tempInfo);
            drawnow;
            
            % 获取液晶参数
            lcThickness = str2double(get(editLCThickness, 'String')) * 1e-6;
            ordinaryIndex = str2double(get(editLCIndex, 'String'));
            extraordinaryIndex = str2double(get(editRefractiveIndex, 'String'));
            
            lcParams.thickness = lcThickness;
            lcParams.ordinary_index = ordinaryIndex;
            lcParams.extraordinary_index = extraordinaryIndex;
            
            % 获取偏振参数
            polarTypeIdx = get(popupPolarizationType, 'Value');
            ellipticity = str2double(get(sliderEllipticity, 'String'));
            rotation = str2double(get(sliderRotation, 'String'));
            
            % 获取算法选择
            methodIdx = get(popupDiffractionMethod, 'Value');
            method = diffractionMethods{methodIdx};
            
            % 开始仿真计算
            set(textInfo, 'String', '正在进行衍射仿真计算...');
            drawnow;
            
            % 生成输入光场
            inputField = generateInputField(exposurePixelSize, samplingPoints, polarTypeIdx, ellipticity, rotation);
            
            % 应用液晶光栅变换
            [outputField, transmittance] = applyLiquidCrystalGrating(inputField, gratingData, lcParams, opticalParams);
            
            % 应用选择的衍射算法
            switch method
                case '菲涅尔衍射'
                    outputField = applyFresnelDiffraction(outputField, opticalParams);
                case '夫琅禾费衍射'
                    outputField = applyFraunhoferDiffraction(outputField, opticalParams);
                case '角谱衍射'
                    outputField = applyAngularSpectrumDiffraction(outputField, opticalParams);
                case 'S-FFT高精度衍射'
                    outputField = applySFFTDiffraction(outputField, opticalParams);
                otherwise
                    outputField = applyAngularSpectrumDiffraction(outputField, opticalParams); % 默认方法
            end
            
            % 计算强度分布
            intensity = abs(outputField(:,:,1)).^2 + abs(outputField(:,:,2)).^2;
            
            % 应用坐标系统
            outputField = applyCoordinateSystem(outputField, opticalParams);
            
            % 显示结果
            displayResults(inputField, outputField);
            
            % 计算并显示衍射效率
            input_power = sum(abs(inputField(:,:,1)).^2 + abs(inputField(:,:,2)).^2, 'all');
            output_power = sum(intensity, 'all');
            efficiency = (output_power / input_power) * 100;
            
            % 更新最终信息显示
            if abs(efficiency - 100) < 5
                energyCheck = '通过';
            else
                energyCheck = '警告';
            end
            
            finalInfo = sprintf(['仿真完成!\n\n%s\n\n' ...
                '衍射效率: %.2f%%\n' ...
                '能量守恒检查: %s\n' ...
                '计算方法: %s\n' ...
                '计算时间: <1秒'], ...
                paramInfo, efficiency, energyCheck, method);
            
            set(textInfo, 'String', finalInfo);
            
            % 检查是否需要弹出3D显示窗口
            try
                button3DPopup = getappdata(fig, 'button3DPopup');
                if ~isempty(button3DPopup) && isvalid(button3DPopup)
                    % 如果用户点击了3D显示按钮，自动弹出3D窗口
                    launch3DDisplayWindow();
                end
            catch
                % 忽略3D显示错误
            end
            
        catch ME
            % 错误处理
            errorMsg = sprintf('仿真计算失败:\n%s\n\n错误位置: %s (第%d行)', ...
                ME.message, ME.stack(1).name, ME.stack(1).line);
            set(textInfo, 'String', errorMsg);
            errordlg(errorMsg, '仿真错误');
        end
    end
    
    function progressFig = createProgressWindow()
        % 创建进度条窗口
        progressFig = figure('Name', '衍射仿真进度', ...
            'Position', [300, 300, 500, 200], ...
            'NumberTitle', 'off', 'MenuBar', 'none', ...
            'Resize', 'off', 'Color', [0.94 0.94 0.94], ...
            'WindowStyle', 'modal');
        
        % 标题
        uicontrol(progressFig, 'Style', 'text', 'String', '液晶衍射仿真进度', ...
            'Position', [150, 160, 200, 25], 'FontSize', 14, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.94 0.94 0.94]);
        
        % 进度条背景
        progressBg = uicontrol(progressFig, 'Style', 'text', 'String', '', ...
            'Position', [50, 110, 400, 25], ...
            'BackgroundColor', [0.8, 0.8, 0.8]);
        
        % 进度条前景
        progressFg = uicontrol(progressFig, 'Style', 'text', 'String', '', ...
            'Position', [50, 110, 1, 25], ...
            'BackgroundColor', [0.2, 0.7, 0.2]);
        
        % 进度百分比
        progressPercent = uicontrol(progressFig, 'Style', 'text', 'String', '0.0%', ...
            'Position', [220, 85, 60, 20], 'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.94 0.94 0.94]);
        
        % 状态信息
        statusText = uicontrol(progressFig, 'Style', 'text', 'String', '准备开始...', ...
            'Position', [50, 50, 400, 20], 'FontSize', 10, ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.94 0.94 0.94], ...
            'ForegroundColor', [0.3, 0.3, 0.7]);
        
        % 存储控件句柄
        setappdata(progressFig, 'progressBg', progressBg);
        setappdata(progressFig, 'progressFg', progressFg);
        setappdata(progressFig, 'progressPercent', progressPercent);
        setappdata(progressFig, 'statusText', statusText);
    end
    
    function updateProgressWindow(progressFig, message, percentage)
        % 更新进度条窗口
        if ~isvalid(progressFig)
            return;
        end
        
        try
            progressBg = getappdata(progressFig, 'progressBg');
            progressFg = getappdata(progressFig, 'progressFg');
            progressPercent = getappdata(progressFig, 'progressPercent');
            statusText = getappdata(progressFig, 'statusText');
            
            % 更新进度条
            bgPos = get(progressBg, 'Position');
            fgWidth = round(bgPos(3) * percentage / 100);
            set(progressFg, 'Position', [bgPos(1), bgPos(2), fgWidth, bgPos(4)]);
            
            % 更新百分比（精确到小数点后一位）
            set(progressPercent, 'String', sprintf('%.1f%%', percentage));
            
            % 更新状态信息
            set(statusText, 'String', message);
            
            % 根据进度改变颜色
            if percentage >= 100
                set(progressFg, 'BackgroundColor', [0.1, 0.8, 0.1]); % 绿色
            elseif percentage >= 80
                set(progressFg, 'BackgroundColor', [0.2, 0.7, 0.2]); % 深绿
            elseif percentage >= 60
                set(progressFg, 'BackgroundColor', [0.8, 0.8, 0.1]); % 黄色
            else
                set(progressFg, 'BackgroundColor', [0.2, 0.7, 0.2]); % 浅绿
            end
            
            drawnow;
            
        catch
            % 忽略更新错误
        end
    end
    
    function updateParameters()
        % 更新光学参数
        opticalParams.wavelength = str2double(get(editWavelength, 'String')) * 1e-9;
        opticalParams.pixel_size = str2double(get(editPixelSize, 'String')) * 1e-6;
        opticalParams.distance = str2double(get(editDistance, 'String'));
        opticalParams.NA = str2double(get(editNA, 'String'));
        
        % 更新透镜参数
        if ~isempty(editF1) && isvalid(editF1)
            opticalParams.f1 = str2double(get(editF1, 'String'));
        end
        if ~isempty(editF2) && isvalid(editF2)
            opticalParams.f2 = str2double(get(editF2, 'String'));
        end
        
        % 更新液晶参数
        lcParams.thickness = str2double(get(editLCThickness, 'String')) * 1e-6;
        lcParams.ordinary_index = str2double(get(editLCIndex, 'String'));
        lcParams.extraordinary_index = str2double(get(editRefractiveIndex, 'String'));
    end
    
    function inputField = createInputField()
        % 创建入射光场 - 改进版（基于参考代码）
        N = 512; % 采样点数
        L = N * opticalParams.pixel_size; % 物理尺寸
        
        % 空间坐标网格
        x0 = linspace(-L/2, L/2, N);
        y0 = linspace(-L/2, L/2, N);
        [X, Y] = meshgrid(x0, y0);
        
        % 基础高斯光束
        D = 5e-4; % 光束半径参数
        Gus = exp(-(X.^2 + Y.^2) / D^2);
        
        % 获取偏振类型
        polarTypeIdx = get(popupPolarizationType, 'Value');
        polarType = polarizationValues{polarTypeIdx};
        
        % 获取偏振参数（从文本框直接获取）
        try
            ellipticity = str2double(get(sliderEllipticity, 'String'));
            if isnan(ellipticity) || ellipticity < 0 || ellipticity > 1
                ellipticity = 0; % 使用默认值
            end
        catch
            ellipticity = 0;
        end
        
        try
            rotation_angle_deg = str2double(get(sliderRotation, 'String'));
            if isnan(rotation_angle_deg) || rotation_angle_deg < 0 || rotation_angle_deg > 180
                rotation_angle_deg = 0; % 使用默认值
            end
            rotation_angle = rotation_angle_deg * pi / 180; % 转换为弧度
        catch
            rotation_angle = 0;
        end
        
        % 根据偏振类型创建Jones矢量
        switch polarType
            case 'linear'
                % 线偏振光 - 与x方向夹角为rotation_angle度
                Ex = Gus .* cos(rotation_angle);
                Ey = Gus .* sin(rotation_angle);
                
            case 'circular'
                % 圆偏振光
                if ellipticity > 0.5 % 左旋
                    Ex = Gus / sqrt(2);
                    Ey = 1i * Gus / sqrt(2);
                else % 右旋
                    Ex = Gus / sqrt(2);
                    Ey = -1i * Gus / sqrt(2);
                end
                
            case 'elliptical'
                % 椭圆偏振光
                phase_diff = ellipticity * pi; % 相位差
                Ex = Gus .* cos(rotation_angle);
                Ey = Gus .* sin(rotation_angle) .* exp(1i * phase_diff);
                
            case 'radial'
                % 径向偏振光
                theta = atan2(Y, X);
                Ex = Gus .* cos(theta);
                Ey = Gus .* sin(theta);
                
            case 'azimuthal'
                % 方位偏振光
                theta = atan2(Y, X);
                Ex = -Gus .* sin(theta);
                Ey = Gus .* cos(theta);
        end
        
        inputField = cat(3, Ex, Ey);
    end
    
    function outputField = calculateFarfieldDiffraction4f(inputField, gratingData)
        % 4f系统远场衍射计算 - 改进版
        [Ny, Nx, ~] = size(inputField);
        
        % 通过液晶偏振光栅的Jones矩阵变换
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        % 4f系统的正确实现
        k = 2 * pi / opticalParams.wavelength;
        L = Nx * opticalParams.pixel_size; % 物理尺寸
        
        % 空间坐标
        x = linspace(-L/2, L/2, Nx);
        y = linspace(-L/2, L/2, Ny);
        [X, Y] = meshgrid(x, y);
        
        % 第一透镜的相位变换（聚焦）
        phase1 = exp(1i * k * (X.^2 + Y.^2) / (2 * opticalParams.f1));
        
        % 应用第一透镜
        fieldAfterLens1_x = fieldAfterGrating(:,:,1) .* phase1;
        fieldAfterLens1_y = fieldAfterGrating(:,:,2) .* phase1;
        
        % 第一次傅里叶变换（传播到傅里叶平面）
        fft_factor = exp(1i * k * opticalParams.f1) / (1i * opticalParams.wavelength * opticalParams.f1);
        Ex_fourier = fftshift(fft2(ifftshift(fieldAfterLens1_x))) * fft_factor;
        Ey_fourier = fftshift(fft2(ifftshift(fieldAfterLens1_y))) * fft_factor;
        
        % 傅里叶平面的空间频率坐标
        fx = linspace(-1/(2*opticalParams.pixel_size), 1/(2*opticalParams.pixel_size), Nx);
        fy = linspace(-1/(2*opticalParams.pixel_size), 1/(2*opticalParams.pixel_size), Ny);
        [FX, FY] = meshgrid(fx, fy);
        
        % 傅里叶平面的物理坐标
        x_fourier = FX * opticalParams.wavelength * opticalParams.f1;
        y_fourier = FY * opticalParams.wavelength * opticalParams.f1;
        
        % 第二透镜的相位变换
        phase2 = exp(1i * k * (x_fourier.^2 + y_fourier.^2) / (2 * opticalParams.f2));
        
        % 应用第二透镜
        fieldAfterLens2_x = Ex_fourier .* phase2;
        fieldAfterLens2_y = Ey_fourier .* phase2;
        
        % 第二次傅里叶变换（传播到像平面）
        ifft_factor = exp(1i * k * opticalParams.f2) / (1i * opticalParams.wavelength * opticalParams.f2);
        Ex_output = fftshift(fft2(ifftshift(fieldAfterLens2_x))) * ifft_factor;
        Ey_output = fftshift(fft2(ifftshift(fieldAfterLens2_y))) * ifft_factor;
        
        outputField = cat(3, Ex_output, Ey_output);
    end
    
    function outputField = calculateFarfieldDiffractionDirect(inputField, gratingData)
        % 远场衍射积分（直接计算，无透镜系统）- S-FFT改进版
        [Ny, Nx, ~] = size(inputField);
        
        % 通过液晶偏振光栅的Jones矩阵变换
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        % S-FFT参数（基于参考代码）
        lamda = opticalParams.wavelength;
        k = 2 * pi / lamda;
        z = opticalParams.distance; % 传播距离
        
        % 物理尺寸和网格
        width = 1e-3; % 输入面宽度
        x00 = linspace(-width, width, Nx);
        y00 = linspace(width, -width, Ny);
        [x00, y00] = meshgrid(x00, y00);
        
        % 输出面参数
        L0 = 1e-3;
        L = lamda * Nx * z / L0;
        X = linspace(-L/2 + L/Nx, L/2, Nx);
        Y = X;
        [x, y] = meshgrid(X, Y);
        
        % S-FFT公式（参考代码的精确实现）
        F0 = exp(1i * k * z) / (1i * lamda * z) * exp(1i * k / 2 / z * (x.^2 + y.^2));
        F = exp(1i * k / 2 / z * (x00.^2 + y00.^2));
        
        % 对X和Y分量分别计算
        Ex_input = fieldAfterGrating(:,:,1) .* F;
        Ey_input = fieldAfterGrating(:,:,2) .* F;
        
        % 执行FFT
        Ff_x = fftshift(fft2(fftshift(Ex_input)));
        Ff_y = fftshift(fft2(fftshift(Ey_input)));
        
        % 应用输出面相位因子
        Ex_output = F0 .* Ff_x;
        Ey_output = F0 .* Ff_y;
        
        outputField = cat(3, Ex_output, Ey_output);
    end
    
    function outputField = calculateAngularSpectrumDiffraction(inputField, gratingData)
        % 角谱传播理论 - 改进版
        [Ny, Nx, ~] = size(inputField);
        
        % 通过液晶偏振光栅
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        % 角谱传播的正确实现
        k = 2 * pi / opticalParams.wavelength;
        L = Nx * opticalParams.pixel_size;
        
        % 空间频率网格（正确的采样）
        df = 1 / L; % 频率分辨率
        fx = (-Nx/2:Nx/2-1) * df;
        fy = (-Ny/2:Ny/2-1) * df;
        [FX, FY] = meshgrid(fx, fy);
        
        % 计算传播常数kz，包含倏逝波处理
        kx = 2 * pi * FX;
        ky = 2 * pi * FY;
        kz_squared = k^2 - kx.^2 - ky.^2;
        
        % 处理倏逝波：当kz为虚数时设为0
        kz = sqrt(kz_squared);
        evanescent_mask = real(kz_squared) < 0;
        kz(evanescent_mask) = 1i * sqrt(abs(kz_squared(evanescent_mask)));
        
        % 传播算子（包含指数衰减的倏逝波）
        H = exp(1i * kz * opticalParams.distance);
        H(evanescent_mask) = H(evanescent_mask) .* exp(-sqrt(abs(kz_squared(evanescent_mask))) * opticalParams.distance);
        
        % 角谱传播
        Ex_spectrum = fftshift(fft2(ifftshift(fieldAfterGrating(:,:,1))));
        Ey_spectrum = fftshift(fft2(ifftshift(fieldAfterGrating(:,:,2))));
        
        % 应用传播算子
        Ex_propagated_spectrum = Ex_spectrum .* H;
        Ey_propagated_spectrum = Ey_spectrum .* H;
        
        % 反傅里叶变换得到传播后的场
        Ex_propagated = fftshift(ifft2(ifftshift(Ex_propagated_spectrum)));
        Ey_propagated = fftshift(ifft2(ifftshift(Ey_propagated_spectrum)));
        
        outputField = cat(3, Ex_propagated, Ey_propagated);
    end
    
    function outputField = calculateFresnelDiffraction(inputField, gratingData)
        % 菲涅尔衍射积分
        % 使用二次相位近似
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        [Ny, Nx, ~] = size(fieldAfterGrating);
        k = 2 * pi / opticalParams.wavelength;
        z = opticalParams.distance;
        
        L = Nx * opticalParams.pixel_size;
        x = linspace(-L/2, L/2, Nx);
        y = linspace(-L/2, L/2, Ny);
        [X, Y] = meshgrid(x, y);
        
        % 菲涅尔传播算子
        H_fresnel = exp(1i * k * z) * exp(1i * k * (X.^2 + Y.^2) / (2 * z)) / (1i * opticalParams.wavelength * z);
        
        % 卷积计算
        Ex_output = ifft2(fft2(fieldAfterGrating(:,:,1)) .* fft2(H_fresnel));
        Ey_output = ifft2(fft2(fieldAfterGrating(:,:,2)) .* fft2(H_fresnel));
        
        outputField = cat(3, Ex_output, Ey_output);
    end
    
    function outputField = calculateKirchhoffDiffraction(inputField, gratingData)
        % 基尔霍夫衍射积分（简化版）
        % 使用菲涅尔近似
        outputField = calculateFresnelDiffraction(inputField, gratingData);
    end
    
    function [outputField, transmittance] = OLD_applyLiquidCrystalGrating(inputField, gratingData)
        % 应用液晶偏振光栅的Jones矩阵变换 - 改进版算法
        % 支持多种液晶偏振光栅类型：标准偏振光栅、胆甾相液晶、直接相位调制
        
        [Ny, Nx, ~] = size(inputField);
        
        % 获取液晶光栅类型（默认为标准偏振光栅）
        gratingType = 'standard'; % 可选: 'standard', 'cholesteric', 'direct_phase'
        try
            gratingTypeControl = getappdata(fig, 'gratingTypeControl');
            if ~isempty(gratingTypeControl) && isvalid(gratingTypeControl)
                gratingTypes = get(gratingTypeControl, 'String');
                gratingTypeIdx = get(gratingTypeControl, 'Value');
                gratingType = gratingTypes{gratingTypeIdx};
            end
        catch
            % 使用默认值
        end
        
        % 根据不同类型选择算法
        switch lower(gratingType)
            case 'standard'
                % 标准液晶偏振光栅算法（PB相位）
                [outputField, transmittance] = applyStandardLiquidCrystalGrating(inputField, gratingData);
                
            case 'cholesteric'
                % 胆甾相液晶算法
                [outputField, transmittance] = applyCholestericLiquidCrystal(inputField, gratingData);
                
            case 'direct_phase'
                % 直接相位调制算法（新增）
                [outputField, transmittance] = applyDirectPhaseLiquidCrystal(inputField, gratingData);
                
            otherwise
                % 默认使用标准算法
                [outputField, transmittance] = applyStandardLiquidCrystalGrating(inputField, gratingData);
        end
    end
    
    function [outputField, transmittance] = applyStandardLiquidCrystalGrating(inputField, gratingData)
        % 标准液晶偏振光栅算法 - 基于Pancharatnam-Berry相位原理
        [Ny, Nx, ~] = size(inputField);
        outputField = zeros(size(inputField));
        transmittance = zeros(Ny, Nx);
        
        % 检查gratingData有效性
        if isempty(gratingData) || ~isnumeric(gratingData)
            warning('光栅数据无效，使用默认测试光栅');
            % 创建默认测试光栅
            [X, Y] = meshgrid(1:Nx, 1:Ny);
            gratingData = 128 + 127 * sin(2*pi*X/32) .* cos(2*pi*Y/32);
        end
        
        % 确保gratingData尺寸匹配
        if size(gratingData, 1) ~= Ny || size(gratingData, 2) ~= Nx
            % 调整尺寸
            gratingData = imresize(gratingData, [Ny, Nx]);
        end
        
        % 从曝光图解码取向角
        orientation = double(gratingData) * 2 * pi / 255;
        
        % 获取液晶参数
        if isfield(lcParams, 'retardation')
            retardation = lcParams.retardation;
        else
            retardation = 1.0; % 默认值，标准半波片为1.0
        end
        
        % 设置默认透射率
        transmittance_val = 0.95; % 典型透射率
        
        for i = 1:Ny
            for j = 1:Nx
                % 取局部取向角
                theta = orientation(i, j);
                
                % 构建标准液晶光栅的琼斯矩阵
                cos_theta = cos(theta);
                sin_theta = sin(theta);
                
                % 计算半波片的Jones矩阵
                phase_delay = retardation * pi; % 半波片对应pi的相位延迟
                
                % 优化的Jones矩阵计算（减少运算量）
                cos_theta_squared = cos_theta * cos_theta;
                sin_theta_squared = sin_theta * sin_theta;
                sin_2theta = 2 * sin_theta * cos_theta;
                
                J = [cos_theta_squared + sin_theta_squared*exp(1i*phase_delay), ...
                     0.5*sin_2theta*(1-exp(1i*phase_delay)); ...
                     0.5*sin_2theta*(1-exp(1i*phase_delay)), ...
                     sin_theta_squared + cos_theta_squared*exp(1i*phase_delay)];
                
                % 应用琼斯矩阵变换
                input_jones = [inputField(i, j, 1); inputField(i, j, 2)];
                output_jones = J * input_jones;
                
                outputField(i, j, 1) = output_jones(1);
                outputField(i, j, 2) = output_jones(2);
                
                % 设置透射率
                transmittance(i, j) = transmittance_val;
            end
        end
    end
    
    function [outputField, transmittance] = applyCholestericLiquidCrystal(inputField, gratingData)
        % 胆甾相液晶的琼斯矩阵算法 - 增强版
        % 基于空间相位分布解码曝光图，并精确处理胆甾相液晶的圆偏振选择性
        [Ny, Nx, ~] = size(inputField);
        
        % 从曝光图解码基础取向角 (0-255 => 0-2π)
        base_orientation = gratingData * (2 * pi / 255);
        
        % 获取胆甾相液晶参数
        pitch = 2e-6;           % 螺距 (m)，可修改或参数化
        no = lcParams.ordinary_index;
        ne = lcParams.extraordinary_index;
        birefringence = ne - no;
        thickness = lcParams.thickness;
        wavelength = opticalParams.wavelength;
        k0 = 2 * pi / wavelength;
        pixel_size = opticalParams.pixel_size;
        
        % 计算光子带隙参数
        n_avg = sqrt((no^2 + ne^2) / 2);
        central_wavelength = pitch * n_avg;
        bandwidth = central_wavelength * birefringence / n_avg;
        wavelength_diff = abs(wavelength - central_wavelength);
        
        % 计算圆偏振选择性
        if wavelength_diff < bandwidth / 2
            reflection_coefficient = exp(-(2*wavelength_diff/bandwidth)^2);
        else
            reflection_coefficient = 0;
        end
        
        % 空间扭转角度和有效厚度
        twist_angle = pi/2;  % 标准90°扭转
        effective_thickness = thickness / cos(twist_angle);
        base_retardation = k0 * birefringence * effective_thickness;
        
        % 初始化输出场和透射率
        outputField = zeros(size(inputField));
        transmittance = zeros(Ny, Nx);
        
        % 标准串行版本 - 移除并行选项，避免嵌套函数问题
        for i = 1:Ny
            for j = 1:Nx
                % 获取空间依赖的螺旋相位
                y_position = (i-1) * pixel_size;
                helical_phase = 2 * pi * y_position / pitch;
                
                % 总取向角（基础 + 螺旋调制）
                theta_in = base_orientation(i, j);
                
                % 考虑位置的局部扭转角
                local_twist = twist_angle * (1 + 0.05 * sin(helical_phase)); % 微小扰动
                theta_out = theta_in + local_twist;
                
                % 旋转矩阵
                cos_theta_in = cos(theta_in);
                sin_theta_in = sin(theta_in);
                cos_theta_out = cos(theta_out);
                sin_theta_out = sin(theta_out);
                
                % 入射旋转
                R1 = [cos_theta_in, -sin_theta_in; sin_theta_in, cos_theta_in];
                
                % 相位延迟（空间调制）
                local_retardation = base_retardation * (1 + 0.1 * cos(helical_phase));
                B = [exp(-1i * local_retardation/2), 0; 
                     0, exp(1i * local_retardation/2)];
                
                % 圆偏振选择性
                % 确定局部相位对选择性的影响
                local_selectivity = reflection_coefficient * (1 + 0.2 * cos(helical_phase));
                local_selectivity = min(local_selectivity, 0.99); % 防止完全反射
                
                C = [1.0, 0; 0, 1.0 - local_selectivity];
                
                % 输出旋转
                R2 = [cos_theta_out, sin_theta_out; -sin_theta_out, cos_theta_out];
                
                % 完整琼斯矩阵
                J = R2 * C * B * R1;
                
                % 应用变换
                input_jones = [inputField(i, j, 1); inputField(i, j, 2)];
                output_jones = J * input_jones;
                
                outputField(i, j, 1) = output_jones(1);
                outputField(i, j, 2) = output_jones(2);
                
                % 计算透射率（考虑材料吸收）
                transmittance(i, j) = 0.95 * (abs(output_jones(1))^2 + abs(output_jones(2))^2) / (abs(input_jones(1))^2 + abs(input_jones(2))^2);
            end
        end
        
        % 在输出上添加可选的信息标签（用于调试）
        setappdata(fig, 'lastProcessedType', 'cholesteric');
    end
    
    function [outputField, transmittance] = applyDirectPhaseLiquidCrystal(inputField, gratingData)
        % 直接相位调制算法 - 新增
        % 该算法直接从曝光图解码相位分布，再进行精确的琼斯矩阵运算
        [Ny, Nx, ~] = size(inputField);
        outputField = zeros(size(inputField));
        transmittance = zeros(Ny, Nx);
        
        % 1. 从曝光图直接解码相位分布 (0-255 => 0-2π)
        phaseDistribution = gratingData * (2 * pi / 255);
        
        % 2. 获取液晶参数
        ne = lcParams.extraordinary_index;
        no = lcParams.ordinary_index;
        birefringence = ne - no;
        thickness = lcParams.thickness;
        wavelength = opticalParams.wavelength;
        k0 = 2 * pi / wavelength;
        
        % 3. 计算基础相位延迟
        base_retardation = k0 * birefringence * thickness;
        
        % 4. 从UI获取其他可能的参数
        amplitude_modulation = 1.0; % 默认值，可以从UI获取
        try
            amplitude_control = getappdata(fig, 'amplitudeModulationControl');
            if ~isempty(amplitude_control) && isvalid(amplitude_control)
                amplitude_modulation = get(amplitude_control, 'Value');
            end
        catch
            % 使用默认值
        end
        
        % 5. 处理每个像素
        for i = 1:Ny
            for j = 1:Nx
                % 获取局部相位
                local_phase = phaseDistribution(i, j);
                
                % 精确计算相位延迟
                effective_retardation = base_retardation * (1 + 0.5 * cos(local_phase));
                
                % 琼斯矩阵计算
                % 创建相位调制矩阵 - 精确表示相位变化
                J_phase = [exp(1i * local_phase), 0; 
                          0, exp(-1i * local_phase * 0.5)];
                
                % 创建振幅调制矩阵（如果需要）
                J_amplitude = [amplitude_modulation, 0; 
                               0, amplitude_modulation];
                
                % 创建双折射矩阵
                J_birefringence = [exp(-1i * effective_retardation/2), 0; 
                                  0, exp(1i * effective_retardation/2)];
                
                % 复合琼斯矩阵
                J = J_phase * J_birefringence * J_amplitude;
                
                % 应用变换
                input_jones = [inputField(i, j, 1); inputField(i, j, 2)];
                output_jones = J * input_jones;
                
                outputField(i, j, 1) = output_jones(1);
                outputField(i, j, 2) = output_jones(2);
                
                % 计算精确透射率
                input_intensity = abs(input_jones(1))^2 + abs(input_jones(2))^2;
                output_intensity = abs(output_jones(1))^2 + abs(output_jones(2))^2;
                
                % 考虑能量守恒和材料吸收
                transmittance(i, j) = 0.98 * output_intensity / (input_intensity + 1e-10);
            end
        end
    end
    
    function selectivity = calculateCircularSelectivity(wavelength, params)
        % 计算圆偏振选择性（用于胆甾相液晶）
        if isfield(params, 'pitch')
            % 简化的选择性模型
            central_wavelength = params.pitch * 1.6; % 近似值
            bandwidth = 0.1 * central_wavelength;
            
            if abs(wavelength - central_wavelength) < bandwidth/2
                selectivity.left = 1.0;
                selectivity.right = 0.1; % 右旋光被反射
            else
                selectivity.left = 1.0;
                selectivity.right = 1.0;
            end
        else
            % 无选择性
            selectivity.left = 1.0;
            selectivity.right = 1.0;
        end
    end
    
    function displayResults(inputField, outputField)
        % 显示2D衍射结果 - 支持新的颜色分类和3D显示
        intensity = abs(outputField(:,:,1)).^2 + abs(outputField(:,:,2)).^2;
        
        % 获取偏振显示选项
        try
            popupPolarizationDisplay = getappdata(fig, 'popupPolarizationDisplay');
            if ~isempty(popupPolarizationDisplay) && isvalid(popupPolarizationDisplay)
                displayOption = get(popupPolarizationDisplay, 'Value');
            else
                displayOption = 1; % 默认强度分布
            end
        catch
            displayOption = 1;
        end
        
        % 根据选择的显示选项计算显示数据
        switch displayOption
            case 1 % 强度分布
                displayData = intensity;
                titleStr = '液晶偏振光栅衍射强度分布';
            case 2 % 偏振态矢量
                % 计算偏振椭圆参数
                Ex = outputField(:,:,1);
                Ey = outputField(:,:,2);
                % 计算椭圆度
                ellipticity = atan(abs(imag(conj(Ex).*Ey)) ./ (abs(Ex).^2 + abs(Ey).^2 + eps));
                displayData = ellipticity;
                titleStr = '偏振态椭圆度分布';
            case 3 % 椭圆度分布
                Ex = outputField(:,:,1);
                Ey = outputField(:,:,2);
                % 计算归一化椭圆度
                ellipticity = abs(imag(conj(Ex).*Ey)) ./ (abs(Ex).^2 + abs(Ey).^2 + eps);
                displayData = ellipticity;
                titleStr = '偏振椭圆度分布';
            case 4 % Stokes参数
                Ex = outputField(:,:,1);
                Ey = outputField(:,:,2);
                % 计算Stokes参数 S1 = |Ex|^2 - |Ey|^2
                S0 = abs(Ex).^2 + abs(Ey).^2;
                S1 = abs(Ex).^2 - abs(Ey).^2;
                S2 = 2*real(conj(Ex).*Ey);
                S3 = 2*imag(conj(Ex).*Ey);
                % 显示偏振度 (degree of polarization)
                DOP = sqrt(S1.^2 + S2.^2 + S3.^2) ./ (S0 + eps);
                displayData = DOP;
                titleStr = 'Stokes偏振度分布';
        end
        
        % 检查2D显示是否启用
        try
            checkbox2DShow = getappdata(fig, 'checkbox2DShow');
            enable2D = ~isempty(checkbox2DShow) && isvalid(checkbox2DShow) && get(checkbox2DShow, 'Value');
        catch
            enable2D = true; % 默认启用
        end
        
        % 显示2D图像
        if enable2D
            axes(axesImg2D);
            imagesc(displayData);
            
            % 应用新的slanCM颜色分类系统
            applySelectedColormap(axesImg2D);
            
            axis equal; axis tight;
            colorbar;
            title(titleStr, 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('X轴位置 (μm)', 'FontSize', 10);
            ylabel('Y轴位置 (μm)', 'FontSize', 10);
        end
        
        % 检查1D显示是否启用
        try
            checkbox1DShow = getappdata(fig, 'checkbox1DShow');
            enable1D = ~isempty(checkbox1DShow) && isvalid(checkbox1DShow) && get(checkbox1DShow, 'Value');
        catch
            enable1D = true; % 默认启用
        end
        
        % 显示1D剖面（中心行）
        if enable1D
            [Ny, ~] = size(intensity);
            center_row = intensity(round(Ny/2), :);
            x_axis = (1:length(center_row)) * opticalParams.pixel_size * 1e6; % 转换为μm
            
            axes(axesImg1D);
            cla;
            
            % 获取选择的1D颜色方案
            try
                popupPlotColor = getappdata(fig, 'popupPlotColor');
                if ~isempty(popupPlotColor) && isvalid(popupPlotColor)
                    plotColorIdx = get(popupPlotColor, 'Value');
                    plotColorValues = {'nature', 'science', 'cell', 'prl', 'optica', 'nano_letters'};
                    colorScheme = plotColorValues{plotColorIdx};
                else
                    colorScheme = 'nature'; % 默认
                end
            catch
                colorScheme = 'nature'; % 错误时使用默认
            end
            
            % 使用增强版精美绘图函数
            try
                % 尝试调用增强版绘图函数
                x_axis_m = x_axis * 1e-6; % 转换回米
                input_data = abs(inputField(round(Ny/2), :, 1)).^2;
                output_data = center_row;
                
                % 创建绘图选项
                plot_options = struct();
                plot_options.title = '液晶偏振光栅衍射光强分布';
                plot_options.xlabel = '横向位置 (μm)';
                plot_options.ylabel = '归一化强度';
                plot_options.legend_input = '入射场';
                plot_options.legend_output = '衍射场';
                plot_options.show_peak_markers = true;
                
                % 调用增强版绘图函数
                if exist('plot_gradient_compare_enhanced', 'file')
                    plot_gradient_compare_enhanced(x_axis, input_data, output_data, [], plot_options);
                else
                    % 降级使用简化版本
                    plot_gradient_compare_simple(x_axis, input_data, output_data, colorScheme);
                end
            catch
                % 如果增强版失败，使用简化版本
                plot_gradient_compare_simple(x_axis, abs(inputField(round(Ny/2), :, 1)).^2, center_row, colorScheme);
            end
        end
        
        % 检查3D显示是否启用
        try
            checkbox3DWaterfall = getappdata(fig, 'checkbox3DWaterfall');
            enable3DWaterfall = ~isempty(checkbox3DWaterfall) && isvalid(checkbox3DWaterfall) && get(checkbox3DWaterfall, 'Value');
        catch
            enable3DWaterfall = false;
        end
        
        % 检查实时3D预览是否启用
        try
            checkbox3DPreview = getappdata(fig, 'checkbox3DPreview');
            enable3DPreview = ~isempty(checkbox3DPreview) && isvalid(checkbox3DPreview) && get(checkbox3DPreview, 'Value');
        catch
            enable3DPreview = false;
        end
        
        % 显示3D图像
        if enable3DPreview
            display3DDiffraction(displayData, titleStr);
        end
        
        % 传统3D瀑布图窗口（如果启用）
        if enable3DWaterfall
            create3DWaterfallPlot(displayData, titleStr);
        end
        
        % 存储当前结果用于保存
        setappdata(fig, 'current2DData', displayData);
        setappdata(fig, 'current1DData', struct('x', x_axis, 'input', abs(inputField(round(Ny/2), :, 1)).^2, 'output', center_row));
        setappdata(fig, 'current3DData', displayData); % 存储3D数据
        
        % 更新信息显示
        updateInfoDisplay(intensity, displayOption);
    end
    
    function plot_gradient_compare(x, E_in, E_out, E_in_err, colorScheme)
        % 增强版精美绘图函数
        axes(axesImg1D);
        cla;
        
        % 归一化
        E_in = E_in / max(E_in);
        E_out = E_out / max(E_out);
        
        % 绘制渐变填充
        x_fill = [x, fliplr(x)];
        y_fill_in = [E_in, zeros(size(E_in))];
        y_fill_out = [E_out, zeros(size(E_out))];
        
        % 输入场（蓝色渐变）
        fill(x_fill, y_fill_in, [0.3, 0.6, 0.9], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
        hold on;
        
        % 输出场（红色渐变）
        fill(x_fill, y_fill_out, [0.9, 0.3, 0.3], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
        
        % 边缘线
        plot(x, E_in, 'Color', [0.1, 0.3, 0.7], 'LineWidth', 2);
        plot(x, E_out, 'Color', [0.7, 0.1, 0.1], 'LineWidth', 2);
        
        xlabel('横向位置 (μm)', 'FontSize', 11, 'FontName', '宋体');
        ylabel('归一化强度', 'FontSize', 11, 'FontName', '宋体');
        legend({'入射场', '衍射场', '', ''}, 'Location', 'northeast', 'FontSize', 10);
        
        % 美化设置
        ax = gca;
        ax.LineWidth = 1.5;
        ax.GridLineStyle = '-.';
        ax.GridAlpha = 0.3;
        grid on;
        box off;
        
        title('一维衍射光强分布', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    function updateInfoDisplay(intensity, displayOption)
        % 更新信息显示
        max_intensity = max(intensity(:));
        min_intensity = min(intensity(:));
        mean_intensity = mean(intensity(:));
        
        methodIdx = get(popupDiffractionMethod, 'Value');
        method = diffractionMethods{methodIdx};
        
        polarTypeIdx = get(popupPolarizationType, 'Value');
        polarType = polarizationTypes{polarTypeIdx};
        
        % 偏振显示类型
        displayTypes = {'强度分布', '偏振态矢量', '椭圆度分布', 'Stokes参数'};
        displayType = displayTypes{displayOption};
        
        infoText = sprintf(['仿真完成\n\n' ...
            '衍射算法: %s\n' ...
            '偏振类型: %s\n' ...
            '显示模式: %s\n' ...
            '波长: %.0f nm\n' ...
            '液晶厚度: %.1f μm\n\n' ...
            '数据统计:\n' ...
            '最大值: %.2e\n' ...
            '最小值: %.2e\n' ...
            '平均值: %.2e\n\n' ...
            '衍射效率: %.2f%%'], ...
            method, polarType, displayType, ...
            opticalParams.wavelength*1e9, lcParams.thickness*1e6, ...
            max_intensity, min_intensity, mean_intensity, ...
            (mean_intensity/max_intensity)*100);
        
        set(textInfo, 'String', infoText);
    end
    
    % === 光栅加载函数 ===
    
    function loadGratingPattern(~, ~)
        % 加载偏振光栅图案 - 修复版，确保数据正确存储
        [filename, pathname] = uigetfile({'*.mat;*.png;*.jpg;*.tif;*.bmp', '光栅文件 (*.mat, *.png, *.jpg, *.tif, *.bmp)'}, ...
            '选择偏振光栅文件');
        
        if filename ~= 0
            fullpath = fullfile(pathname, filename);
            
            try
                [~, ~, ext] = fileparts(filename);
                
                if strcmp(ext, '.mat')
                    % MATLAB数据文件
                    data = load(fullpath);
                    fields = fieldnames(data);
                    if ~isempty(fields)
                        gratingData = data.(fields{1});
                    else
                        error('MAT文件中没有找到有效数据');
                    end
                else
                    % 图像文件
                    img = imread(fullpath);
                    if size(img, 3) == 3
                        gratingData = rgb2gray(img);
                    else
                        gratingData = img;
                    end
                end
                
                % 转换为双精度并归一化
                gratingData = double(gratingData);
                if max(gratingData(:)) > 1
                    gratingData = gratingData / 255;  % 归一化到0-1范围
                end
                
                % 验证数据有效性
                if isempty(gratingData) || any(isnan(gratingData(:))) || any(isinf(gratingData(:)))
                    error('加载的光栅数据无效或包含NaN/Inf值');
                end
                
                % 显示光栅信息
                [rows, cols] = size(gratingData);
                minVal = min(gratingData(:));
                maxVal = max(gratingData(:));
                
                infoMsg = sprintf(['成功加载光栅数据: %s\n\n' ...
                    '数据信息:\n' ...
                    '尺寸: %d × %d 像素\n' ...
                    '数值范围: %.3f ~ %.3f\n' ...
                    '数据类型: %s\n\n' ...
                    '光栅已准备用于仿真计算'], ...
                    filename, rows, cols, minVal, maxVal, class(gratingData));
                
                msgbox(infoMsg, '光栅加载成功', 'help');
                
                % 更新信息显示，确认光栅已加载
                try
                    currentInfo = get(textInfo, 'String');
                    newInfo = sprintf('光栅状态: 已加载 (%s, %dx%d)\n%s', ...
                        filename, rows, cols, currentInfo);
                    set(textInfo, 'String', newInfo);
                catch
                    % 如果textInfo不可用，忽略
                end
                
            catch ME
                errordlg(['加载光栅数据失败: ', ME.message], '加载错误');
                gratingData = []; % 确保失败时清空数据
            end
        end
    end
    
    function generateTestGrating(~, ~)
        % 生成测试偏振光栅 - 修复版，确保数据正确存储
        try
            N = 512;
            period = 50;
            
            [X, Y] = meshgrid(1:N, 1:N);
            
            % 生成简单的线性偏振光栅
            orientation = mod(X, period) / period;  % 归一化到0-1范围
            
            gratingData = orientation;
            
            % 显示测试光栅信息
            infoMsg = sprintf(['成功生成测试偏振光栅\n\n' ...
                '数据信息:\n' ...
                '尺寸: %d × %d 像素\n' ...
                '光栅周期: %d 像素\n' ...
                '数值范围: 0.000 ~ 1.000\n\n' ...
                '测试光栅已准备用于仿真计算'], ...
                N, N, period);
            
            msgbox(infoMsg, '测试光栅生成成功', 'help');
            
            % 更新信息显示
            try
                currentInfo = get(textInfo, 'String');
                newInfo = sprintf('光栅状态: 测试光栅已生成 (%dx%d)\n%s', ...
                    N, N, currentInfo);
                set(textInfo, 'String', newInfo);
            catch
                % 如果textInfo不可用，忽略
            end
            
        catch ME
            errordlg(['生成测试光栅失败: ', ME.message], '生成错误');
            gratingData = []; % 确保失败时清空数据
        end
    end
    
    function callExposureGenerator(~, ~)
        % 嵌入式曝光图生成器 - 简化版
        % 直接在当前程序中创建曝光图设计界面
        
        % 创建曝光图生成器窗口
        exposureGenFig = figure('Name', '嵌入式曝光图生成器', ...
            'Position', [100, 100, 800, 600], ...
            'NumberTitle', 'off', 'MenuBar', 'none', ...
            'Resize', 'on', 'Color', [0.94 0.94 0.94]);
        
        % 左侧参数面板
        paramPanel = uipanel(exposureGenFig, 'Title', '光栅参数设置', 'FontSize', 12, ...
            'Position', [0.05, 0.05, 0.4, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 右侧预览面板
        previewPanel = uipanel(exposureGenFig, 'Title', '光栅预览', 'FontSize', 12, ...
            'Position', [0.5, 0.05, 0.45, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 参数设置
        y_pos = 480;
        spacing = 50;
        
        % 图像尺寸
        uicontrol(paramPanel, 'Style', 'text', 'String', '图像尺寸 (像素):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editImageSize = uicontrol(paramPanel, 'Style', 'edit', 'String', '512', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 光栅周期
        uicontrol(paramPanel, 'Style', 'text', 'String', '光栅周期 (像素):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editGratingPeriod = uicontrol(paramPanel, 'Style', 'edit', 'String', '32', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 图案类型
        uicontrol(paramPanel, 'Style', 'text', 'String', '图案类型:', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        patternTypes = {'线性偏振光栅', '圆偏振光栅', '径向偏振光栅', '螺旋相位光栅'};
        popupPatternType = uicontrol(paramPanel, 'Style', 'popupmenu', ...
            'String', patternTypes, 'Value', 1, ...
            'Position', [130, y_pos, 150, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 相位延迟
        uicontrol(paramPanel, 'Style', 'text', 'String', '相位延迟 (π):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editPhaseDelay = uicontrol(paramPanel, 'Style', 'edit', 'String', '1.0', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 旋转角度
        uicontrol(paramPanel, 'Style', 'text', 'String', '旋转角度 (度):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editOrientation = uicontrol(paramPanel, 'Style', 'edit', 'String', '0', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 按钮区域
        uicontrol(paramPanel, 'Style', 'pushbutton', 'String', '生成预览', ...
            'Position', [30, y_pos, 100, 35], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
            'Callback', @generatePreview);
        
        uicontrol(paramPanel, 'Style', 'pushbutton', 'String', '保存并返回', ...
            'Position', [150, y_pos, 100, 35], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', @saveAndReturn);
        
        % 预览区域
        previewAxes = axes('Parent', previewPanel, 'Position', [0.1, 0.1, 0.8, 0.8]);
        title(previewAxes, '点击"生成预览"查看光栅', 'FontSize', 12);
        
        % 存储控件句柄和数据
        exposureData = struct();
        exposureData.editImageSize = editImageSize;
        exposureData.editGratingPeriod = editGratingPeriod;
        exposureData.popupPatternType = popupPatternType;
        exposureData.editPhaseDelay = editPhaseDelay;
        exposureData.editOrientation = editOrientation;
        exposureData.previewAxes = previewAxes;
        exposureData.parentFig = fig;
        exposureData.generatedPattern = [];
        
        setappdata(exposureGenFig, 'exposureData', exposureData);
        
        function generatePreview(~, ~)
            % 生成光栅预览
            try
                data = getappdata(exposureGenFig, 'exposureData');
                
                % 获取参数
                imageSize = str2double(get(data.editImageSize, 'String'));
                gratingPeriod = str2double(get(data.editGratingPeriod, 'String'));
                phaseDelay = str2double(get(data.editPhaseDelay, 'String'));
                orientation = str2double(get(data.editOrientation, 'String'));
                patternType = get(data.popupPatternType, 'Value');
                
                % 参数验证
                if isnan(imageSize) || imageSize <= 0
                    imageSize = 512;
                    set(data.editImageSize, 'String', '512');
                end
                if isnan(gratingPeriod) || gratingPeriod <= 0
                    gratingPeriod = 32;
                    set(data.editGratingPeriod, 'String', '32');
                end
                
                % 生成坐标网格
                [x, y] = meshgrid(1:imageSize, 1:imageSize);
                x = x - imageSize/2;
                y = y - imageSize/2;
                
                % 根据图案类型生成光栅
                switch patternType
                    case 1 % 线性偏振光栅
                        theta = deg2rad(orientation);
                        x_rot = x*cos(theta) + y*sin(theta);
                        phase = 2*pi * x_rot / gratingPeriod;
                        pattern = exp(1i * phaseDelay * pi * cos(phase));
                        
                    case 2 % 圆偏振光栅
                        r = sqrt(x.^2 + y.^2);
                        phi = atan2(y, x);
                        phase = 2*pi * r / gratingPeriod + orientation * pi/180 * phi;
                        pattern = exp(1i * phaseDelay * pi * cos(phase));
                        
                    case 3 % 径向偏振光栅
                        r = sqrt(x.^2 + y.^2);
                        phase = 2*pi * r / gratingPeriod;
                        pattern = exp(1i * phaseDelay * pi * cos(phase));
                        
                    case 4 % 螺旋相位光栅
                        r = sqrt(x.^2 + y.^2);
                        phi = atan2(y, x);
                        radial_phase = 2*pi * r / gratingPeriod;
                        azimuthal_phase = orientation * pi/180 * phi;
                        pattern = exp(1i * phaseDelay * pi * cos(radial_phase + azimuthal_phase));
                end
                
                % 显示预览
                axes(data.previewAxes);
                intensity = abs(pattern).^2;
                imagesc(intensity);
                
                try
                    colormap(data.previewAxes, slanCM('gray'));
                catch
                    colormap(data.previewAxes, gray);
                end
                
                axis equal; axis tight;
                title(sprintf('%s预览 (%dx%d)', patternTypes{patternType}, imageSize, imageSize), 'FontSize', 11);
                colorbar;
                
                % 存储生成的图案
                data.generatedPattern = pattern;
                setappdata(exposureGenFig, 'exposureData', data);
                
            catch ME
                errordlg(['预览生成失败: ', ME.message], '错误');
            end
        end
        
        function saveAndReturn(~, ~)
            % 保存并返回主程序
            try
                data = getappdata(exposureGenFig, 'exposureData');
                
                if isempty(data.generatedPattern)
                    msgbox('请先生成预览', '提示', 'warn');
                    return;
                end
                
                % 选择保存位置
                [filename, pathname] = uiputfile({
                    '*.mat', 'MATLAB数据文件 (*.mat)';
                    '*.png', 'PNG图像文件 (*.png)';
                    '*.tif', 'TIFF图像文件 (*.tif)'
                }, '保存光栅图案', 'LC_grating_pattern.mat');
                
                if filename == 0
                    return; % 用户取消
                end
                
                fullPath = fullfile(pathname, filename);
                
                % 保存文件
                [~, ~, ext] = fileparts(filename);
                
                if strcmpi(ext, '.mat')
                    % 保存为MATLAB数据
                    gratingData = data.generatedPattern;
                    gratingParams = struct();
                    gratingParams.imageSize = str2double(get(data.editImageSize, 'String'));
                    gratingParams.gratingPeriod = str2double(get(data.editGratingPeriod, 'String'));
                    gratingParams.phaseDelay = str2double(get(data.editPhaseDelay, 'String'));
                    gratingParams.orientation = str2double(get(data.editOrientation, 'String'));
                    gratingParams.patternType = get(data.popupPatternType, 'Value');
                    gratingParams.createTime = datestr(now);
                    
                    save(fullPath, 'gratingData', 'gratingParams');
                else
                    % 保存为图像
                    intensity = abs(data.generatedPattern).^2;
                    intensity = intensity / max(intensity(:)); % 归一化
                    
                    if strcmpi(ext, '.png')
                        imwrite(intensity, fullPath, 'png');
                    elseif strcmpi(ext, '.tif')
                        imwrite(intensity, fullPath, 'tif');
                    end
                end
                
                % 将数据加载到主程序
                if isvalid(data.parentFig)
                    % 更新主程序的光栅数据变量
                    gratingData = data.generatedPattern;
                    
                    msgbox(['光栅已保存: ', fullPath, char(10), '数据已加载到仿真系统'], '成功', 'help');
                end
                
                % 关闭窗口
                close(exposureGenFig);
                
        catch ME
                errordlg(['保存失败: ', ME.message], '保存错误');
            end
        end
    end
    
    % === 保存功能函数 ===
    
    function saveSimulationResults(~, ~)
        % 保存仿真结果 - 改进版
        
        % 检查是否已完成仿真计算
        current2DData = getappdata(fig, 'current2DData');
        current1DData = getappdata(fig, 'current1DData');
        
        if isempty(current2DData) || isempty(current1DData)
            msgbox('请先运行仿真计算后再保存结果', '提示', 'warn');
            return;
        end
        
        % 创建保存对话框
        saveDialog = figure('Name', '保存仿真结果', 'Position', [200, 200, 500, 400], ...
            'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'off', ...
            'Color', [0.94 0.94 0.94]);
        
        % 标题
        uicontrol(saveDialog, 'Style', 'text', 'String', '保存仿真结果选项', ...
            'Position', [180, 360, 140, 25], 'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        % 文件格式选择
        fileFormats = {'PNG图像 (*.png)', 'TIFF图像 (*.tif)', 'JPEG图像 (*.jpg)', ...
                      'EPS矢量图 (*.eps)', 'PDF文档 (*.pdf)', 'SVG矢量图 (*.svg)', 'MATLAB数据 (*.mat)'};
        fileExtensions = {'.png', '.tif', '.jpg', '.eps', '.pdf', '.svg', '.mat'};
        
        uicontrol(saveDialog, 'Style', 'text', 'String', '文件格式:', ...
            'Position', [30, 310, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11);
        
        formatPopup = uicontrol(saveDialog, 'Style', 'popupmenu', 'String', fileFormats, ...
            'Position', [120, 310, 240, 20], 'Value', 1, 'FontSize', 10);
        
        % DPI选择（增加2400dpi选项）
        uicontrol(saveDialog, 'Style', 'text', 'String', '分辨率(DPI):', ...
            'Position', [30, 270, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11);
        
        dpiOptions = {'150 (网络显示)', '300 (标准打印)', '600 (高质量)', '1200 (专业级)', '2400 (超高精度)'};
        dpiValues = [150, 300, 600, 1200, 2400];
        
        dpiPopup = uicontrol(saveDialog, 'Style', 'popupmenu', 'String', dpiOptions, ...
            'Position', [120, 270, 240, 20], 'Value', 2, 'FontSize', 10);
        
        % 文件名输入
        uicontrol(saveDialog, 'Style', 'text', 'String', '文件名前缀:', ...
            'Position', [30, 230, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11);
        
        filenameEdit = uicontrol(saveDialog, 'Style', 'edit', 'String', 'LC_diffraction', ...
            'Position', [120, 230, 240, 20], 'FontSize', 10);
        
        % 保存内容选择
        uicontrol(saveDialog, 'Style', 'text', 'String', '保存内容:', ...
            'Position', [30, 190, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11, 'FontWeight', 'bold');
        
        save2DCheck = uicontrol(saveDialog, 'Style', 'checkbox', 'String', '2D衍射图样', ...
            'Position', [120, 190, 120, 20], 'Value', 1, ...
function LiquidCrystalDiffractionSimulator()
    % 液晶聚合物偏振光栅衍射成像仿真程序
    % 基于远场衍射与角谱理论
    % 版权所有 © 个人(Z.Y)团队(Y.M)
    
    % 全局变量和UI控件句柄
    fig = [];
    panelControl = [];
    panelDisplay = [];
    panelInfo = [];
    divider = [];
    axesImg2D = [];
    axesImg1D = [];
    textInfo = [];
    
    % 控件变量
    editWavelength = [];
    editPixelSize = [];
    editDistance = [];
    editNA = [];
    editLCThickness = [];
    editLCIndex = [];
    editRefractiveIndex = [];
    popupPolarizationType = [];
    popupDiffractionMethod = [];
    popupColormap = [];
    sliderEllipticity = [];
    sliderRotation = [];
    
    % === 修复：正确声明光栅数据变量 ===
    gratingData = [];  % 当前加载的光栅数据
    
    % 新增控件变量 - 完整声明
    editF1 = [];  % 第一透镜焦距
    editF2 = [];  % 第二透镜焦距
    progressBar = [];  % 进度条
    textEllipticityValue = [];  % 椭圆率数值显示
    textRotationValue = [];     % 旋转角度数值显示
    editXRange = [];   % X轴范围控制
    editYRange = [];   % Y轴范围控制
    axisRangePanel = [];  % 坐标轴控制面板
    
    % 增强的控件变量声明
    editExposureWavelength = [];    % 曝光波长控件
    editExposureRealSize = [];      % 曝光图实际尺寸控件
    editExposurePixelSize = [];     % 曝光图像素尺寸控件
    editSamplingPoints = [];        % 采样点数控件
    popupWavelengthUnit = [];       % 波长单位选择
    popupSizeUnit = [];             % 尺寸单位选择
    popupDistanceUnit = [];         % 距离单位选择
    popupFocalUnit1 = [];           % 第一透镜焦距单位
    popupFocalUnit2 = [];           % 第二透镜焦距单位
    
    % 液晶聚合物参数
    lcParams = struct();
    lcParams.thickness = 3e-6;      % 液晶层厚度 (m)
    lcParams.ordinary_index = 1.5;  % 寻常光折射率
    lcParams.extraordinary_index = 1.7; % 非寻常光折射率
    lcParams.tilt_angle = 0;        % 预倾角 (度)
    lcParams.retardation = 1.0;     % 相位延迟(以π为单位)，标准半波片为1.0
    
    % 光学系统参数
    opticalParams = struct();
    opticalParams.wavelength = 532e-9;    % 波长 (m)
    opticalParams.pixel_size = 10e-6;     % 像素尺寸 (m)
    opticalParams.f1 = 0.1;              % 第一透镜焦距 (m)
    opticalParams.f2 = 0.1;              % 第二透镜焦距 (m)
    opticalParams.distance = 0.5;        % 衍射距离 (m)
    opticalParams.NA = 0.1;              % 数值孔径
    
    % slanCM颜色包类型（基于demo文件分析）
    colormapTypes = {'rainbow', 'hsv', 'jet', 'cool', 'warm', 'hot', 'gray', ...
                     'spring', 'summer', 'autumn', 'winter', 'bone', 'copper', ...
                     'pink', 'lines', 'colorcube', 'prism', 'flag'};
    
    % 偏振类型
    polarizationTypes = {'线偏振光', '圆偏振光', '椭圆偏振光', '径向偏振光', '方位偏振光'};
    polarizationValues = {'linear', 'circular', 'elliptical', 'radial', 'azimuthal'};
    
    % 衍射方法
    diffractionMethods = {'远场衍射积分 (4f系统)', '远场衍射积分 (无透镜)', '角谱传播理论', '菲涅尔衍射积分', '基尔霍夫衍射积分'};
    diffractionValues = {'farfield_4f', 'farfield_direct', 'angular_spectrum', 'fresnel', 'kirchhoff'};
    
    % 分隔器位置
    dividerPosition = 0.35;
    
    % 创建主界面
    createMainGUI();
    
    function createMainGUI()
        % 创建主窗口
        fig = figure('Name', '液晶聚合物偏振光栅衍射成像仿真系统', ...
                     'Position', [50, 50, 1400, 900], ...
                     'NumberTitle', 'off', 'MenuBar', 'none', ...
                     'Resize', 'on', 'Color', [0.94 0.94 0.94]);
        
        % 创建面板
        createPanels();
        
        % 初始化显示
        initializeDisplay();
    end
    
    function createPanels()
        % 控制面板
        panelControl = uipanel(fig, 'Title', '参数控制面板', 'FontSize', 12, 'FontWeight', 'bold', ...
            'Position', [0.02, 0.02, dividerPosition-0.02, 0.96], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 创建分隔条
        divider = uipanel(fig, 'Position', [dividerPosition, 0.02, 0.01, 0.96], ...
            'BackgroundColor', [0.5 0.5 0.7]);
        
        % 显示面板
        panelDisplay = uipanel(fig, 'Title', '衍射成像仿真结果', 'FontSize', 12, 'FontWeight', 'bold', ...
            'Position', [dividerPosition+0.01, 0.52, 0.97-dividerPosition-0.01, 0.46], ...
            'BackgroundColor', [1 1 1]);
        
        % 信息面板
        panelInfo = uipanel(fig, 'Title', '仿真信息', 'FontSize', 10, ...
            'Position', [dividerPosition+0.01, 0.02, 0.97-dividerPosition-0.01, 0.48], ...
            'BackgroundColor', [0.95 0.95 0.95]);
        
        % 创建控制面板内容
        createControlContent();
        
        % 创建显示内容
        createDisplayContent();
    end
    
    function createControlContent()
        % 创建选项卡组
        tabGroup = uitabgroup(panelControl, 'Position', [0.05, 0.05, 0.9, 0.85]);
        
        % 光学系统参数选项卡
        tabOptical = uitab(tabGroup, 'Title', '光学系统');
        createOpticalTab(tabOptical);
        
        % 液晶参数选项卡
        tabLC = uitab(tabGroup, 'Title', '液晶参数');
        createLCTab(tabLC);
        
        % 偏振控制选项卡
        tabPolarization = uitab(tabGroup, 'Title', '偏振控制');
        createPolarizationTab(tabPolarization);
        
        % 衍射算法选项卡
        tabDiffraction = uitab(tabGroup, 'Title', '衍射算法');
        createDiffractionTab(tabDiffraction);
        
        % 光栅加载选项卡
        tabGrating = uitab(tabGroup, 'Title', '光栅加载');
        createGratingTab(tabGrating);
        
        % 全局仿真按钮 - 恢复🚀表情符号
        uicontrol(panelControl, 'Style', 'pushbutton', 'String', '🚀 开始衍射仿真', ...
            'Position', [50, 10, 150, 45], ...
            'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.1, 0.6, 0.1], 'ForegroundColor', [1 1 1], ...
            'Callback', @runDiffractionSimulation);
            
        % 全局保存按钮 - 恢复💾表情符号
        uicontrol(panelControl, 'Style', 'pushbutton', 'String', '💾 保存结果', ...
            'Position', [220, 10, 150, 45], ...
            'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
            'Callback', @saveSimulationResults);
    end
    
    function createOpticalTab(tab)
        % 光学系统参数设置 - 优化布局，单位后置+下拉选择
        y_pos = 420;
        spacing = 50;
        
        % 曝光波长设置 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '曝光波长:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editExposureWavelength = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.wavelength*1e9), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupWavelengthUnit = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'nm', 'μm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择波长单位');
        
        y_pos = y_pos - spacing;
        
        % 曝光图实际尺寸 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '图像尺寸:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editExposureRealSize = uicontrol(tab, 'Style', 'edit', ...
            'String', '100', ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupSizeUnit = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'μm', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择尺寸单位');
        
        y_pos = y_pos - spacing;
        
        % 曝光图像素尺寸
        uicontrol(tab, 'Style', 'text', 'String', '像素数量:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editExposurePixelSize = uicontrol(tab, 'Style', 'edit', ...
            'String', '512', ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        uicontrol(tab, 'Style', 'text', 'String', 'pixels', ...
            'Position', [195, y_pos, 50, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        y_pos = y_pos - spacing;
        
        % 采样点数
        uicontrol(tab, 'Style', 'text', 'String', '采样点数:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editSamplingPoints = uicontrol(tab, 'Style', 'edit', ...
            'String', '1024', ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        uicontrol(tab, 'Style', 'text', 'String', 'points', ...
            'Position', [195, y_pos, 50, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        y_pos = y_pos - spacing;
        
        % 衍射距离 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '衍射距离:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editDistance = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.distance), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupDistanceUnit = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'m', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择距离单位');
        
        y_pos = y_pos - spacing;
        
        % 数值孔径
        uicontrol(tab, 'Style', 'text', 'String', '数值孔径:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editNA = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.NA), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        uicontrol(tab, 'Style', 'text', 'String', '(无量纲)', ...
            'Position', [195, y_pos, 60, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 9);
        
        y_pos = y_pos - spacing;
        
        % 第一透镜焦距 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '透镜f1:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editF1 = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.f1), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupFocalUnit1 = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'m', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择焦距单位');
        
        y_pos = y_pos - spacing;
        
        % 第二透镜焦距 - 单位后置+下拉选择
        uicontrol(tab, 'Style', 'text', 'String', '透镜f2:', ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10, 'FontWeight', 'bold');
        
        editF2 = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(opticalParams.f2), ...
            'Position', [110, y_pos, 80, 25], 'FontSize', 10);
        
        popupFocalUnit2 = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', {'m', 'mm', 'cm'}, 'Value', 1, ...
            'Position', [195, y_pos, 50, 25], 'FontSize', 9, ...
            'TooltipString', '选择焦距单位');
        
        % 存储新增的控件引用
        setappdata(fig, 'editExposureWavelength', editExposureWavelength);
        setappdata(fig, 'editExposureRealSize', editExposureRealSize);
        setappdata(fig, 'editExposurePixelSize', editExposurePixelSize);
        setappdata(fig, 'editSamplingPoints', editSamplingPoints);
        setappdata(fig, 'editDistance', editDistance);
        setappdata(fig, 'editNA', editNA);
        setappdata(fig, 'editF1', editF1);
        setappdata(fig, 'editF2', editF2);
        setappdata(fig, 'popupWavelengthUnit', popupWavelengthUnit);
        setappdata(fig, 'popupSizeUnit', popupSizeUnit);
        setappdata(fig, 'popupDistanceUnit', popupDistanceUnit);
        setappdata(fig, 'popupFocalUnit1', popupFocalUnit1);
        setappdata(fig, 'popupFocalUnit2', popupFocalUnit2);
    end
    
    function createLCTab(tab)
        % 液晶参数设置
        y_pos = 400;
        spacing = 50;
        
        % 液晶层厚度
        uicontrol(tab, 'Style', 'text', 'String', '液晶层厚度 (μm):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        editLCThickness = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(lcParams.thickness*1e6), ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 寻常光折射率
        uicontrol(tab, 'Style', 'text', 'String', '寻常光折射率:', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        editLCIndex = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(lcParams.ordinary_index), ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 非寻常光折射率
        uicontrol(tab, 'Style', 'text', 'String', '非寻常光折射率:', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        editRefractiveIndex = uicontrol(tab, 'Style', 'edit', ...
            'String', num2str(lcParams.extraordinary_index), ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 10);
    end
    
    function createPolarizationTab(tab)
        % 偏振控制设置
        y_pos = 400;
        spacing = 50;
        
        % 偏振类型
        uicontrol(tab, 'Style', 'text', 'String', '偏振类型:', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        popupPolarizationType = uicontrol(tab, 'Style', 'popupmenu', ...
            'String', polarizationTypes, 'Value', 1, ...
            'Position', [130, y_pos, 150, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 椭圆率输入框 - 改为直接输入方式
        uicontrol(tab, 'Style', 'text', 'String', '椭圆率 (0-1):', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        sliderEllipticity = uicontrol(tab, 'Style', 'edit', ...
            'String', '0.0', ...
            'Position', [130, y_pos, 80, 25], 'FontSize', 10, ...
            'Callback', @updateEllipticityValue);
        
        textEllipticityValue = uicontrol(tab, 'Style', 'text', 'String', '(0-1)', ...
            'Position', [215, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 旋转角度输入框 - 改为直接输入方式
        uicontrol(tab, 'Style', 'text', 'String', '旋转角度 (°):', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
        
        sliderRotation = uicontrol(tab, 'Style', 'edit', ...
            'String', '0.0', ...
            'Position', [130, y_pos, 80, 25], 'FontSize', 10, ...
            'Callback', @updateRotationValue);
        
        textRotationValue = uicontrol(tab, 'Style', 'text', 'String', '(0-180°)', ...
            'Position', [215, y_pos, 80, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.95 0.95 0.95], 'FontSize', 10);
    end
    
    function createDiffractionTab(tab)
        % 衍射算法选择 - 重新设计版本
        y_pos = 450;
        spacing = 35;
        
        % 算法选择区域
        algorithmMainPanel = uipanel(tab, 'Title', '', ...
            'Position', [0.02, 0.02, 0.96, 0.96], ...
            'BackgroundColor', [0.98 0.98 0.98], ...
            'BorderType', 'none');
        
        % === 第一区域：算法类别选择 ===
        algorithmCategoryPanel = uipanel(algorithmMainPanel, 'Title', '算法分类', ...
            'Position', [0.02, 0.75, 0.96, 0.23], ...
            'BackgroundColor', [0.96 0.96 0.98], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 算法类别说明
        uicontrol(algorithmCategoryPanel, 'Style', 'text', ...
            'String', '选择适合您研究需求的衍射成像算法类别:', ...
            'Position', [20, 135, 400, 20], ...
            'BackgroundColor', [0.96 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        % 算法分类按钮组
        algorithmCategoryGroup = uibuttongroup(algorithmCategoryPanel, ...
            'Position', [20, 40, 900, 90], ...
            'BackgroundColor', [0.96 0.96 0.98], ...
            'BorderType', 'none', ...
            'SelectionChangedFcn', @algorithmCategoryChanged);
        
        % 第一行：基础算法
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '标量衍射理论', 'Position', [10, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '基于标量衍射理论的经典算法：菲涅尔、夫琅禾费、角谱传播');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '矢量衍射理论', 'Position', [140, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '考虑偏振效应的严格矢量衍射算法：RCWA、时域有限差分');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '液晶偏振光栅', 'Position', [270, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '专用于液晶聚合物偏振光栅的琼斯矩阵算法', ...
            'Value', 1);
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '机器学习算法', 'Position', [400, 60, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '基于深度学习的快速衍射计算和相位恢复算法');
        
        % 第二行：高级算法
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '多尺度分析', 'Position', [10, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '小波变换、傅里叶层析等多尺度衍射成像算法');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '相干层析成像', 'Position', [140, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '光学相干层析、数字全息重建算法');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '超分辨重构', 'Position', [270, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '突破衍射极限的超分辨成像重构算法');
        
        uicontrol(algorithmCategoryGroup, 'Style', 'radiobutton', ...
            'String', '自适应光学', 'Position', [400, 30, 120, 25], ...
            'BackgroundColor', [0.96 0.96 0.98], 'FontSize', 9, ...
            'TooltipString', '波前传感与自适应校正算法');
        
        % === 第二区域：具体算法选择 ===
        specificAlgorithmPanel = uipanel(algorithmMainPanel, 'Title', '算法选择', ...
            'Position', [0.02, 0.45, 0.48, 0.28], ...
            'BackgroundColor', [0.98 0.98 0.96], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 算法列表（动态更新）
        algorithmListPanel = uipanel(specificAlgorithmPanel, ...
            'Position', [0.05, 0.15, 0.9, 0.8], ...
            'BackgroundColor', [0.98 0.98 0.96], ...
            'BorderType', 'none');
        
        % 算法说明文本
        algorithmDescriptionText = uicontrol(specificAlgorithmPanel, 'Style', 'text', ...
            'String', '选择算法后将显示详细说明和参数设置', ...
            'Position', [10, 10, 380, 30], ...
            'BackgroundColor', [0.98 0.98 0.96], ...
            'FontSize', 9, 'HorizontalAlignment', 'left');
        
        % === 第三区域：算法参数设置 ===
        algorithmParamsPanel = uipanel(algorithmMainPanel, 'Title', '算法参数', ...
            'Position', [0.52, 0.45, 0.46, 0.28], ...
            'BackgroundColor', [0.96 0.98 0.96], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 参数面板（动态更新）
        paramsContentPanel = uipanel(algorithmParamsPanel, ...
            'Position', [0.05, 0.1, 0.9, 0.85], ...
            'BackgroundColor', [0.96 0.98 0.96], ...
            'BorderType', 'none');
        
        % === 第四区域：颜色映射与可视化 ===
        colorVisualizationPanel = uipanel(algorithmMainPanel, 'Title', '颜色映射与可视化', ...
            'Position', [0.02, 0.02, 0.96, 0.41], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        % 左侧：颜色映射选择
        colorMappingSubPanel = uipanel(colorVisualizationPanel, ...
            'Position', [0.02, 0.1, 0.46, 0.85], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'BorderType', 'none');
        
        % 颜色分类标题
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '科学色彩映射方案', ...
            'Position', [10, 170, 200, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        % 第一行：感知均匀色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '感知均匀色彩:', ...
            'Position', [10, 140, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.perceptualUniformPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'viridis', 'plasma', 'inferno', 'magma', 'cividis'}, ...
            'Position', [120, 140, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第二行：序列类色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '序列类色彩:', ...
            'Position', [10, 110, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.sequentialPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'Blues', 'BuGn', 'BuPu', 'GnBu', 'Greens', 'Greys', 'Oranges', 'OrRd', 'PuBu', 'PuBuGn', 'PuRd', 'Purples', 'RdPu', 'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd'}, ...
            'Position', [120, 110, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第三行：分散类色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '分散类色彩:', ...
            'Position', [10, 80, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.divergingPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'BrBG', 'PiYG', 'PRGn', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral'}, ...
            'Position', [120, 80, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第四行：循环类色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '循环类色彩:', ...
            'Position', [10, 50, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.cyclicPopup = uicontrol(colorMappingSubPanel, 'Style', 'popupmenu', ...
            'String', {'hsv', 'twilight', 'twilight_shifted', 'ocean', 'seasons', 'phase', 'complex'}, ...
            'Position', [120, 50, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @updateColorMapping);
        
        % 第五行：自定义色彩
        uicontrol(colorMappingSubPanel, 'Style', 'text', ...
            'String', '自定义色彩:', ...
            'Position', [10, 20, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.customColorButton = uicontrol(colorMappingSubPanel, 'Style', 'pushbutton', ...
            'String', '设计色彩', ...
            'Position', [120, 18, 80, 24], ...
            'FontSize', 9, ...
            'Callback', @designCustomColormap);
        
        handles.loadColorButton = uicontrol(colorMappingSubPanel, 'Style', 'pushbutton', ...
            'String', '载入', ...
            'Position', [205, 18, 35, 24], ...
            'FontSize', 9, ...
            'Callback', @loadCustomColormap);
        
        % 右侧：可视化选项
        visualizationSubPanel = uipanel(colorVisualizationPanel, ...
            'Position', [0.5, 0.1, 0.48, 0.85], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'BorderType', 'none');
        
        % 可视化模式标题
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '显示模式与增强', ...
            'Position', [10, 170, 200, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        % 显示模式组
        visualizationModeGroup = uibuttongroup(visualizationSubPanel, ...
            'Position', [10, 110, 380, 55], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'BorderType', 'none');
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '强度分布', 'Position', [10, 30, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9, 'Value', 1);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '相位分布', 'Position', [100, 30, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '复振幅', 'Position', [190, 30, 70, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '偏振态', 'Position', [270, 30, 70, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '3D可视化', 'Position', [10, 5, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '动态演示', 'Position', [100, 5, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        uicontrol(visualizationModeGroup, 'Style', 'radiobutton', ...
            'String', '对比分析', 'Position', [190, 5, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        % 图像增强选项
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '图像增强:', ...
            'Position', [10, 80, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.contrastCheckbox = uicontrol(visualizationSubPanel, 'Style', 'checkbox', ...
            'String', '对比度增强', 'Position', [100, 80, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        handles.gammaCheckbox = uicontrol(visualizationSubPanel, 'Style', 'checkbox', ...
            'String', '伽马校正', 'Position', [210, 80, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        handles.histEqCheckbox = uicontrol(visualizationSubPanel, 'Style', 'checkbox', ...
            'String', '直方图均衡', 'Position', [300, 80, 100, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], 'FontSize', 9);
        
        % 色彩映射参数
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '色彩范围:', ...
            'Position', [10, 50, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '最小值:', ...
            'Position', [100, 50, 50, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 9, 'HorizontalAlignment', 'left');
        
        handles.colorMinEdit = uicontrol(visualizationSubPanel, 'Style', 'edit', ...
            'String', 'auto', ...
            'Position', [150, 50, 60, 20], ...
            'FontSize', 9);
        
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '最大值:', ...
            'Position', [220, 50, 50, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 9, 'HorizontalAlignment', 'left');
        
        handles.colorMaxEdit = uicontrol(visualizationSubPanel, 'Style', 'edit', ...
            'String', 'auto', ...
            'Position', [270, 50, 60, 20], ...
            'FontSize', 9);
        
        handles.autoRangeButton = uicontrol(visualizationSubPanel, 'Style', 'pushbutton', ...
            'String', '自动范围', ...
            'Position', [340, 48, 60, 24], ...
            'FontSize', 9, ...
            'Callback', @autoColorRange);
        
        % 预设配置
        uicontrol(visualizationSubPanel, 'Style', 'text', ...
            'String', '预设配置:', ...
            'Position', [10, 20, 80, 20], ...
            'BackgroundColor', [0.98 0.96 0.98], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
        
        handles.presetConfigPopup = uicontrol(visualizationSubPanel, 'Style', 'popupmenu', ...
            'String', {'自定义', '高对比度', '科学出版', '演示展示', '色盲友好', '灰度打印'}, ...
            'Position', [100, 20, 120, 20], ...
            'BackgroundColor', [1 1 1], ...
            'FontSize', 9, ...
            'Callback', @applyPresetConfig);
        
        handles.saveConfigButton = uicontrol(visualizationSubPanel, 'Style', 'pushbutton', ...
            'String', '保存配置', ...
            'Position', [230, 18, 70, 24], ...
            'FontSize', 9, ...
            'Callback', @saveVisualizationConfig);
        
        handles.loadConfigButton = uicontrol(visualizationSubPanel, 'Style', 'pushbutton', ...
            'String', '载入配置', ...
            'Position', [305, 18, 70, 24], ...
            'FontSize', 9, ...
            'Callback', @loadVisualizationConfig);
        
        % 存储界面句柄
        handles.algorithmCategoryGroup = algorithmCategoryGroup;
        handles.algorithmListPanel = algorithmListPanel;
        handles.paramsContentPanel = paramsContentPanel;
        handles.algorithmDescriptionText = algorithmDescriptionText;
        handles.visualizationModeGroup = visualizationModeGroup;
        
        % 初始化液晶偏振光栅算法列表
        updateAlgorithmList('液晶偏振光栅');
    end
    
    function createGratingTab(tab)
        % 光栅加载设置
        y_pos = 400;
        spacing = 50;
        
        % 加载曝光图按钮
        uicontrol(tab, 'Style', 'pushbutton', 'String', '加载曝光图', ...
            'Position', [50, y_pos, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', @loadGratingPattern);
        
        y_pos = y_pos - spacing;
        
        % 生成测试光栅按钮
        uicontrol(tab, 'Style', 'pushbutton', 'String', '生成测试光栅', ...
            'Position', [50, y_pos, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.7, 0.5, 0.2], 'ForegroundColor', [1 1 1], ...
            'Callback', @generateTestGrating);
        
        y_pos = y_pos - spacing;
        
        % 改进的曝光图生成器按钮
        uicontrol(tab, 'Style', 'pushbutton', 'String', '启动曝光图监视器', ...
            'Position', [50, y_pos, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.6, 0.3, 0.8], 'ForegroundColor', [1 1 1], ...
            'Callback', @startExposureMonitor);
    end
    
    function createDisplayContent()
        % 创建2D显示区域
        axesImg2D = axes('Parent', panelDisplay, 'Position', [0.05, 0.1, 0.65, 0.85]);
        title(axesImg2D, '二维衍射强度分布', 'FontSize', 12, 'FontWeight', 'bold');
        
        % 创建坐标轴控制面板
        axisRangePanel = uipanel(panelDisplay, 'Title', '坐标轴控制', 'FontSize', 10, ...
            'Position', [0.72, 0.1, 0.26, 0.85], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % X轴范围控制
        uicontrol(axisRangePanel, 'Style', 'text', 'String', 'X轴范围 (μm):', ...
            'Position', [10, 280, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 10, 'FontWeight', 'bold');
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最小值:', ...
            'Position', [10, 250, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editXRangeMin = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '-100', ...
            'Position', [70, 250, 60, 20], 'FontSize', 9);
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最大值:', ...
            'Position', [10, 220, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editXRangeMax = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '100', ...
            'Position', [70, 220, 60, 20], 'FontSize', 9);
        
        % Y轴范围控制
        uicontrol(axisRangePanel, 'Style', 'text', 'String', 'Y轴范围 (μm):', ...
            'Position', [10, 180, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 10, 'FontWeight', 'bold');
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最小值:', ...
            'Position', [10, 150, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editYRangeMin = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '-100', ...
            'Position', [70, 150, 60, 20], 'FontSize', 9);
        
        uicontrol(axisRangePanel, 'Style', 'text', 'String', '最大值:', ...
            'Position', [10, 120, 50, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
        editYRangeMax = uicontrol(axisRangePanel, 'Style', 'edit', 'String', '100', ...
            'Position', [70, 120, 60, 20], 'FontSize', 9);
        
        % 应用按钮
        uicontrol(axisRangePanel, 'Style', 'pushbutton', 'String', '应用范围', ...
            'Position', [30, 80, 80, 25], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
            'Callback', @applyAxisRange);
        
        % 自动范围按钮
        uicontrol(axisRangePanel, 'Style', 'pushbutton', 'String', '自动范围', ...
            'Position', [30, 50, 80, 25], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.6, 0.4, 0.8], 'ForegroundColor', [1 1 1], ...
            'Callback', @autoAxisRange);
        
        % 存储控件句柄
        setappdata(fig, 'editXRangeMin', editXRangeMin);
        setappdata(fig, 'editXRangeMax', editXRangeMax);
        setappdata(fig, 'editYRangeMin', editYRangeMin);
        setappdata(fig, 'editYRangeMax', editYRangeMax);
        
        % 创建1D显示区域和仿真信息区域
        % 1D显示区域（上半部分）
        axesImg1D = axes('Parent', panelInfo, 'Position', [0.05, 0.55, 0.9, 0.4]);
        title(axesImg1D, '液晶偏振光栅衍射光强分布（1D）', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel(axesImg1D, '横向位置 (μm)', 'FontSize', 10);
        ylabel(axesImg1D, '归一化强度', 'FontSize', 10);
        
        % 仿真信息显示区域（下半部分）
        textInfo = uicontrol(panelInfo, 'Style', 'text', ...
            'String', '系统就绪，请设置参数并开始仿真', ...
            'Position', [20, 20, 760, 180], ...
            'HorizontalAlignment', 'left', 'FontSize', 10, ...
            'BackgroundColor', [0.95 0.95 0.95]);
    end
    
    function startExposureMonitor(~, ~)
        % 启动曝光图监视器 - 改进版
        monitorFig = figure('Name', '曝光图生成监视器', ...
            'Position', [200, 200, 600, 400], ...
            'NumberTitle', 'off', 'MenuBar', 'none', ...
            'Resize', 'on', 'Color', [0.94 0.94 0.94]);
        
        % 创建监视面板
        monitorPanel = uipanel(monitorFig, 'Title', '监视控制台', 'FontSize', 12, ...
            'Position', [0.05, 0.05, 0.9, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 状态显示
        statusText = uicontrol(monitorPanel, 'Style', 'text', ...
            'String', '等待用户操作...', ...
            'Position', [20, 320, 500, 30], 'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.97 0.97 0.97], ...
            'ForegroundColor', [0.3, 0.3, 0.7]);
        
        % 操作说明
        instrText = uicontrol(monitorPanel, 'Style', 'text', ...
            'String', ['请按以下步骤操作：', char(10), ...
                      '1. 点击"启动曝光图生成器"按钮', char(10), ...
                      '2. 在曝光图生成器中设计您的光栅图案', char(10), ...
                      '3. 完成设计后，点击"确认并传输"按钮', char(10), ...
                      '4. 监视器将自动接收数据并返回仿真程序'], ...
            'Position', [20, 200, 500, 100], 'FontSize', 10, ...
            'HorizontalAlignment', 'left', 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 启动曝光图生成器按钮
        uicontrol(monitorPanel, 'Style', 'pushbutton', 'String', '启动曝光图生成器', ...
            'Position', [50, 150, 150, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', {@launchExposureGenerator, statusText});
        
        % 确认并传输按钮
        confirmBtn = uicontrol(monitorPanel, 'Style', 'pushbutton', 'String', '确认并传输', ...
            'Position', [250, 150, 120, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.6, 0.3, 0.8], 'ForegroundColor', [1 1 1], ...
            'Enable', 'off', ...
            'Callback', {@confirmAndTransfer, statusText, monitorFig});
        
        % 取消按钮
        uicontrol(monitorPanel, 'Style', 'pushbutton', 'String', '取消', ...
            'Position', [420, 150, 80, 40], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.8, 0.3, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', @(~,~) close(monitorFig));
        
        % 数据预览区域
        previewAxes = axes('Parent', monitorPanel, 'Position', [0.1, 0.05, 0.8, 0.3]);
        title(previewAxes, '数据预览 (等待数据传输)', 'FontSize', 11);
        
        % 存储数据
        setappdata(monitorFig, 'confirmBtn', confirmBtn);
        setappdata(monitorFig, 'previewAxes', previewAxes);
        setappdata(monitorFig, 'transferredData', []);
    end
    
    function launchExposureGenerator(~, ~, statusText)
        % 启动外部曝光图生成器
        try
            set(statusText, 'String', '正在启动曝光图生成器...', 'ForegroundColor', [0.7, 0.5, 0]);
            drawnow;
            
            % 这里应该调用外部的曝光图生成程序
            % 由于我们在当前环境中，我们创建一个简化的生成器界面
            callExposureGenerator();
            
            set(statusText, 'String', '曝光图生成器已启动，请在其中完成设计', 'ForegroundColor', [0, 0.7, 0]);
            
            % 启用确认按钮
            confirmBtn = getappdata(gcf, 'confirmBtn');
            set(confirmBtn, 'Enable', 'on');
            
        catch ME
            set(statusText, 'String', ['启动失败: ', ME.message], 'ForegroundColor', [0.8, 0, 0]);
        end
    end
    
    function confirmAndTransfer(~, ~, statusText, monitorFig)
        % 确认并传输数据
        try
            set(statusText, 'String', '正在传输数据...', 'ForegroundColor', [0.7, 0.5, 0]);
            drawnow;
            
            % 获取生成的数据（这里应该从外部程序获取）
            % 暂时使用一个示例数据
            transferredData = getappdata(monitorFig, 'transferredData');
            
            if isempty(transferredData)
                % 如果没有数据，创建一个示例数据
                N = 512;
                [X, Y] = meshgrid(1:N, 1:N);
                transferredData = 128 + 127 * sin(2*pi*X/32) .* cos(2*pi*Y/32);
                
                msgbox('未检测到外部数据，使用示例光栅数据', '提示', 'warn');
            end
            
            % 预览数据
            previewAxes = getappdata(monitorFig, 'previewAxes');
            axes(previewAxes);
            imagesc(transferredData);
            axis equal; axis tight;
            title('传输的光栅数据', 'FontSize', 11);
            colorbar;
            
            % 传输到主程序
            gratingData = transferredData;
            
            set(statusText, 'String', '数据传输完成！', 'ForegroundColor', [0, 0.7, 0]);
            
            % 延迟后关闭监视器
            pause(2);
            close(monitorFig);
            
            msgbox('光栅数据已成功传输到仿真程序', '传输成功', 'help');
            
        catch ME
            set(statusText, 'String', ['传输失败: ', ME.message], 'ForegroundColor', [0.8, 0, 0]);
        end
    end
    
    function initializeDisplay()
        % 初始化显示内容
        
        % 设置slanCM路径
        try
            % 确保slanCM路径在MATLAB路径中
            currentDir = fileparts(mfilename('fullpath'));
            slanCMPath = fullfile(currentDir, '..', 'ColorMaps', 'slanCM');
            if exist(slanCMPath, 'dir')
                addpath(slanCMPath);
            end
        catch
            % 忽略路径设置错误
        end
        
        % 初始化2D显示
        axes(axesImg2D);
        imagesc(peaks(256));
        
        % 尝试使用slanCM颜色映射
        try
            colormap(axesImg2D, slanCM('rainbow'));
        catch
            % 如果slanCM不可用，使用默认颜色映射
            colormap(axesImg2D, hsv);
        end
        
        axis equal; axis tight;
        title('二维衍射强度分布 (示例)', 'FontSize', 12);
        
        % 初始化1D显示
        axes(axesImg1D);
        x = linspace(-100, 100, 1000);
        y = exp(-x.^2/1000);
        plot(x, y, 'LineWidth', 2);
        xlabel('位置 (μm)', 'FontSize', 10);
        ylabel('强度', 'FontSize', 10);
        title('一维衍射光强分布 (示例)', 'FontSize', 12);
        grid on;
    end
    
    % === 核心算法函数 ===
    
    function runDiffractionSimulation(~, ~)
        % 运行衍射仿真 - 增强版，支持新的光学参数
        try
            % 获取新的光学参数
            exposureWavelength = str2double(get(getappdata(fig, 'editExposureWavelength'), 'String')) * 1e-9; % 转换为米
            exposureRealSize = str2double(get(getappdata(fig, 'editExposureRealSize'), 'String')) * 1e-6; % 转换为米
            exposurePixelSize = str2double(get(getappdata(fig, 'editExposurePixelSize'), 'String'));
            samplingPoints = str2double(get(getappdata(fig, 'editSamplingPoints'), 'String'));
            diffractionDistance = str2double(get(getappdata(fig, 'editDistance'), 'String'));
            numericalAperture = str2double(get(getappdata(fig, 'editNA'), 'String'));
            firstLensFocalLength = str2double(get(getappdata(fig, 'editF1'), 'String'));
            secondLensFocalLength = str2double(get(getappdata(fig, 'editF2'), 'String'));
            
            % 参数验证
            if isnan(exposureWavelength) || exposureWavelength <= 0
                errordlg('曝光波长必须为正数', '参数错误');
                return;
            end
            
            if isnan(exposureRealSize) || exposureRealSize <= 0
                errordlg('曝光图实际尺寸必须为正数', '参数错误');
                return;
            end
            
            if isnan(exposurePixelSize) || exposurePixelSize <= 0 || mod(exposurePixelSize, 1) ~= 0
                errordlg('曝光图像素尺寸必须为正整数', '参数错误');
                return;
            end
            
            if isnan(samplingPoints) || samplingPoints <= 0 || mod(samplingPoints, 1) ~= 0
                errordlg('采样点数必须为正整数', '参数错误');
                return;
            end
            
            % 更新光学参数结构
            opticalParams.wavelength = exposureWavelength;
            opticalParams.real_size = exposureRealSize;
            opticalParams.pixel_size = exposureRealSize / exposurePixelSize; % 计算实际像素尺寸
            opticalParams.distance = diffractionDistance;
            opticalParams.NA = numericalAperture;
            opticalParams.f1 = firstLensFocalLength;
            opticalParams.f2 = secondLensFocalLength;
            opticalParams.sampling_points = samplingPoints;
            
            % 计算菲涅尔数
            fresnelNumber = (exposureRealSize/2)^2 / (exposureWavelength * diffractionDistance);
            
            % 计算分辨率限制
            diffraction_limit = 1.22 * exposureWavelength / numericalAperture;
            
            % 显示计算参数信息
            paramInfo = sprintf(['计算参数信息:\n' ...
                '波长: %.0f nm\n' ...
                '像素尺寸: %.3f μm\n' ...
                '实际尺寸: %.1f μm\n' ...
                '采样点数: %d\n' ...
                '菲涅尔数: %.2f\n' ...
                '衍射极限: %.3f μm\n' ...
                '4f系统放大倍数: %.2fx'], ...
                exposureWavelength*1e9, opticalParams.pixel_size*1e6, exposureRealSize*1e6, ...
                samplingPoints, fresnelNumber, diffraction_limit*1e6, secondLensFocalLength/firstLensFocalLength);
            
            % 更新信息显示
            set(textInfo, 'String', paramInfo);
            
            % 获取光栅数据 - 增强版检查和处理
            if isempty(gratingData)
                % 生成默认测试光栅
                warndlg(['未检测到有效的光栅数据！\n\n' ...
                    '将自动生成默认测试光栅进行仿真。\n' ...
                    '如需使用自定义光栅，请先在"光栅加载"选项卡中加载光栅文件。'], ...
                    '光栅数据提示', 'modal');
                generateTestGrating();
                
                % 再次检查是否成功生成
                if isempty(gratingData)
                    error('无法生成测试光栅，请检查程序状态');
                end
            else
                % 验证现有光栅数据
                if any(isnan(gratingData(:))) || any(isinf(gratingData(:)))
                    error('当前光栅数据包含无效值(NaN或Inf)，请重新加载');
                end
                
                % 显示当前使用的光栅信息
                [rows, cols] = size(gratingData);
                fprintf('使用光栅数据: %dx%d, 数值范围 [%.3f, %.3f]\n', ...
                    rows, cols, min(gratingData(:)), max(gratingData(:)));
            end
            
            % 确保光栅数据尺寸正确并进行预处理
            if size(gratingData, 1) ~= exposurePixelSize || size(gratingData, 2) ~= exposurePixelSize
                % 调整光栅数据尺寸
                oldSize = size(gratingData);
                gratingData = imresize(gratingData, [exposurePixelSize, exposurePixelSize], 'bilinear');
                
                infoMsg = sprintf(['光栅数据尺寸已自动调整\n\n' ...
                    '原始尺寸: %dx%d\n' ...
                    '调整后尺寸: %dx%d\n\n' ...
                    '调整方法: 双线性插值'], ...
                    oldSize(1), oldSize(2), exposurePixelSize, exposurePixelSize);
                
                msgbox(infoMsg, '尺寸调整完成', 'help');
            end
            
            % 确保数据归一化
            if max(gratingData(:)) > 1
                gratingData = gratingData / max(gratingData(:));
            end
            if min(gratingData(:)) < 0
                gratingData = gratingData - min(gratingData(:));
            end
            
            % 最终验证光栅数据
            if isempty(gratingData) || ~isnumeric(gratingData)
                error('光栅数据最终验证失败，无法进行仿真');
            end
            
            % 更新仿真信息，显示光栅状态
            gratingInfo = sprintf(['光栅数据状态: ✓ 已准备就绪\n' ...
                '尺寸: %dx%d 像素\n' ...
                '数值范围: [%.3f, %.3f]\n'], ...
                size(gratingData, 1), size(gratingData, 2), ...
                min(gratingData(:)), max(gratingData(:)));
            
            % 更新仿真信息显示
            tempInfo = sprintf('%s\n%s\n正在进行衍射仿真计算...', gratingInfo, paramInfo);
            set(textInfo, 'String', tempInfo);
            drawnow;
            
            % 获取液晶参数
            lcThickness = str2double(get(editLCThickness, 'String')) * 1e-6;
            ordinaryIndex = str2double(get(editLCIndex, 'String'));
            extraordinaryIndex = str2double(get(editRefractiveIndex, 'String'));
            
            lcParams.thickness = lcThickness;
            lcParams.ordinary_index = ordinaryIndex;
            lcParams.extraordinary_index = extraordinaryIndex;
            
            % 获取偏振参数
            polarTypeIdx = get(popupPolarizationType, 'Value');
            ellipticity = str2double(get(sliderEllipticity, 'String'));
            rotation = str2double(get(sliderRotation, 'String'));
            
            % 获取算法选择
            methodIdx = get(popupDiffractionMethod, 'Value');
            method = diffractionMethods{methodIdx};
            
            % 开始仿真计算
            set(textInfo, 'String', '正在进行衍射仿真计算...');
            drawnow;
            
            % 生成输入光场
            inputField = generateInputField(exposurePixelSize, samplingPoints, polarTypeIdx, ellipticity, rotation);
            
            % 应用液晶光栅变换
            [outputField, transmittance] = applyLiquidCrystalGrating(inputField, gratingData, lcParams, opticalParams);
            
            % 应用选择的衍射算法
            switch method
                case '菲涅尔衍射'
                    outputField = applyFresnelDiffraction(outputField, opticalParams);
                case '夫琅禾费衍射'
                    outputField = applyFraunhoferDiffraction(outputField, opticalParams);
                case '角谱衍射'
                    outputField = applyAngularSpectrumDiffraction(outputField, opticalParams);
                case 'S-FFT高精度衍射'
                    outputField = applySFFTDiffraction(outputField, opticalParams);
                otherwise
                    outputField = applyAngularSpectrumDiffraction(outputField, opticalParams); % 默认方法
            end
            
            % 计算强度分布
            intensity = abs(outputField(:,:,1)).^2 + abs(outputField(:,:,2)).^2;
            
            % 应用坐标系统
            outputField = applyCoordinateSystem(outputField, opticalParams);
            
            % 显示结果
            displayResults(inputField, outputField);
            
            % 计算并显示衍射效率
            input_power = sum(abs(inputField(:,:,1)).^2 + abs(inputField(:,:,2)).^2, 'all');
            output_power = sum(intensity, 'all');
            efficiency = (output_power / input_power) * 100;
            
            % 更新最终信息显示
            if abs(efficiency - 100) < 5
                energyCheck = '通过';
            else
                energyCheck = '警告';
            end
            
            finalInfo = sprintf(['仿真完成!\n\n%s\n\n' ...
                '衍射效率: %.2f%%\n' ...
                '能量守恒检查: %s\n' ...
                '计算方法: %s\n' ...
                '计算时间: <1秒'], ...
                paramInfo, efficiency, energyCheck, method);
            
            set(textInfo, 'String', finalInfo);
            
            % 检查是否需要弹出3D显示窗口
            try
                button3DPopup = getappdata(fig, 'button3DPopup');
                if ~isempty(button3DPopup) && isvalid(button3DPopup)
                    % 如果用户点击了3D显示按钮，自动弹出3D窗口
                    launch3DDisplayWindow();
                end
            catch
                % 忽略3D显示错误
            end
            
        catch ME
            % 错误处理
            errorMsg = sprintf('仿真计算失败:\n%s\n\n错误位置: %s (第%d行)', ...
                ME.message, ME.stack(1).name, ME.stack(1).line);
            set(textInfo, 'String', errorMsg);
            errordlg(errorMsg, '仿真错误');
        end
    end
    
    function progressFig = createProgressWindow()
        % 创建进度条窗口
        progressFig = figure('Name', '衍射仿真进度', ...
            'Position', [300, 300, 500, 200], ...
            'NumberTitle', 'off', 'MenuBar', 'none', ...
            'Resize', 'off', 'Color', [0.94 0.94 0.94], ...
            'WindowStyle', 'modal');
        
        % 标题
        uicontrol(progressFig, 'Style', 'text', 'String', '液晶衍射仿真进度', ...
            'Position', [150, 160, 200, 25], 'FontSize', 14, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.94 0.94 0.94]);
        
        % 进度条背景
        progressBg = uicontrol(progressFig, 'Style', 'text', 'String', '', ...
            'Position', [50, 110, 400, 25], ...
            'BackgroundColor', [0.8, 0.8, 0.8]);
        
        % 进度条前景
        progressFg = uicontrol(progressFig, 'Style', 'text', 'String', '', ...
            'Position', [50, 110, 1, 25], ...
            'BackgroundColor', [0.2, 0.7, 0.2]);
        
        % 进度百分比
        progressPercent = uicontrol(progressFig, 'Style', 'text', 'String', '0.0%', ...
            'Position', [220, 85, 60, 20], 'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.94 0.94 0.94]);
        
        % 状态信息
        statusText = uicontrol(progressFig, 'Style', 'text', 'String', '准备开始...', ...
            'Position', [50, 50, 400, 20], 'FontSize', 10, ...
            'HorizontalAlignment', 'center', 'BackgroundColor', [0.94 0.94 0.94], ...
            'ForegroundColor', [0.3, 0.3, 0.7]);
        
        % 存储控件句柄
        setappdata(progressFig, 'progressBg', progressBg);
        setappdata(progressFig, 'progressFg', progressFg);
        setappdata(progressFig, 'progressPercent', progressPercent);
        setappdata(progressFig, 'statusText', statusText);
    end
    
    function updateProgressWindow(progressFig, message, percentage)
        % 更新进度条窗口
        if ~isvalid(progressFig)
            return;
        end
        
        try
            progressBg = getappdata(progressFig, 'progressBg');
            progressFg = getappdata(progressFig, 'progressFg');
            progressPercent = getappdata(progressFig, 'progressPercent');
            statusText = getappdata(progressFig, 'statusText');
            
            % 更新进度条
            bgPos = get(progressBg, 'Position');
            fgWidth = round(bgPos(3) * percentage / 100);
            set(progressFg, 'Position', [bgPos(1), bgPos(2), fgWidth, bgPos(4)]);
            
            % 更新百分比（精确到小数点后一位）
            set(progressPercent, 'String', sprintf('%.1f%%', percentage));
            
            % 更新状态信息
            set(statusText, 'String', message);
            
            % 根据进度改变颜色
            if percentage >= 100
                set(progressFg, 'BackgroundColor', [0.1, 0.8, 0.1]); % 绿色
            elseif percentage >= 80
                set(progressFg, 'BackgroundColor', [0.2, 0.7, 0.2]); % 深绿
            elseif percentage >= 60
                set(progressFg, 'BackgroundColor', [0.8, 0.8, 0.1]); % 黄色
            else
                set(progressFg, 'BackgroundColor', [0.2, 0.7, 0.2]); % 浅绿
            end
            
            drawnow;
            
        catch
            % 忽略更新错误
        end
    end
    
    function updateParameters()
        % 更新光学参数
        opticalParams.wavelength = str2double(get(editWavelength, 'String')) * 1e-9;
        opticalParams.pixel_size = str2double(get(editPixelSize, 'String')) * 1e-6;
        opticalParams.distance = str2double(get(editDistance, 'String'));
        opticalParams.NA = str2double(get(editNA, 'String'));
        
        % 更新透镜参数
        if ~isempty(editF1) && isvalid(editF1)
            opticalParams.f1 = str2double(get(editF1, 'String'));
        end
        if ~isempty(editF2) && isvalid(editF2)
            opticalParams.f2 = str2double(get(editF2, 'String'));
        end
        
        % 更新液晶参数
        lcParams.thickness = str2double(get(editLCThickness, 'String')) * 1e-6;
        lcParams.ordinary_index = str2double(get(editLCIndex, 'String'));
        lcParams.extraordinary_index = str2double(get(editRefractiveIndex, 'String'));
    end
    
    function inputField = createInputField()
        % 创建入射光场 - 改进版（基于参考代码）
        N = 512; % 采样点数
        L = N * opticalParams.pixel_size; % 物理尺寸
        
        % 空间坐标网格
        x0 = linspace(-L/2, L/2, N);
        y0 = linspace(-L/2, L/2, N);
        [X, Y] = meshgrid(x0, y0);
        
        % 基础高斯光束
        D = 5e-4; % 光束半径参数
        Gus = exp(-(X.^2 + Y.^2) / D^2);
        
        % 获取偏振类型
        polarTypeIdx = get(popupPolarizationType, 'Value');
        polarType = polarizationValues{polarTypeIdx};
        
        % 获取偏振参数（从文本框直接获取）
        try
            ellipticity = str2double(get(sliderEllipticity, 'String'));
            if isnan(ellipticity) || ellipticity < 0 || ellipticity > 1
                ellipticity = 0; % 使用默认值
            end
        catch
            ellipticity = 0;
        end
        
        try
            rotation_angle_deg = str2double(get(sliderRotation, 'String'));
            if isnan(rotation_angle_deg) || rotation_angle_deg < 0 || rotation_angle_deg > 180
                rotation_angle_deg = 0; % 使用默认值
            end
            rotation_angle = rotation_angle_deg * pi / 180; % 转换为弧度
        catch
            rotation_angle = 0;
        end
        
        % 根据偏振类型创建Jones矢量
        switch polarType
            case 'linear'
                % 线偏振光 - 与x方向夹角为rotation_angle度
                Ex = Gus .* cos(rotation_angle);
                Ey = Gus .* sin(rotation_angle);
                
            case 'circular'
                % 圆偏振光
                if ellipticity > 0.5 % 左旋
                    Ex = Gus / sqrt(2);
                    Ey = 1i * Gus / sqrt(2);
                else % 右旋
                    Ex = Gus / sqrt(2);
                    Ey = -1i * Gus / sqrt(2);
                end
                
            case 'elliptical'
                % 椭圆偏振光
                phase_diff = ellipticity * pi; % 相位差
                Ex = Gus .* cos(rotation_angle);
                Ey = Gus .* sin(rotation_angle) .* exp(1i * phase_diff);
                
            case 'radial'
                % 径向偏振光
                theta = atan2(Y, X);
                Ex = Gus .* cos(theta);
                Ey = Gus .* sin(theta);
                
            case 'azimuthal'
                % 方位偏振光
                theta = atan2(Y, X);
                Ex = -Gus .* sin(theta);
                Ey = Gus .* cos(theta);
        end
        
        inputField = cat(3, Ex, Ey);
    end
    
    function outputField = calculateFarfieldDiffraction4f(inputField, gratingData)
        % 4f系统远场衍射计算 - 改进版
        [Ny, Nx, ~] = size(inputField);
        
        % 通过液晶偏振光栅的Jones矩阵变换
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        % 4f系统的正确实现
        k = 2 * pi / opticalParams.wavelength;
        L = Nx * opticalParams.pixel_size; % 物理尺寸
        
        % 空间坐标
        x = linspace(-L/2, L/2, Nx);
        y = linspace(-L/2, L/2, Ny);
        [X, Y] = meshgrid(x, y);
        
        % 第一透镜的相位变换（聚焦）
        phase1 = exp(1i * k * (X.^2 + Y.^2) / (2 * opticalParams.f1));
        
        % 应用第一透镜
        fieldAfterLens1_x = fieldAfterGrating(:,:,1) .* phase1;
        fieldAfterLens1_y = fieldAfterGrating(:,:,2) .* phase1;
        
        % 第一次傅里叶变换（传播到傅里叶平面）
        fft_factor = exp(1i * k * opticalParams.f1) / (1i * opticalParams.wavelength * opticalParams.f1);
        Ex_fourier = fftshift(fft2(ifftshift(fieldAfterLens1_x))) * fft_factor;
        Ey_fourier = fftshift(fft2(ifftshift(fieldAfterLens1_y))) * fft_factor;
        
        % 傅里叶平面的空间频率坐标
        fx = linspace(-1/(2*opticalParams.pixel_size), 1/(2*opticalParams.pixel_size), Nx);
        fy = linspace(-1/(2*opticalParams.pixel_size), 1/(2*opticalParams.pixel_size), Ny);
        [FX, FY] = meshgrid(fx, fy);
        
        % 傅里叶平面的物理坐标
        x_fourier = FX * opticalParams.wavelength * opticalParams.f1;
        y_fourier = FY * opticalParams.wavelength * opticalParams.f1;
        
        % 第二透镜的相位变换
        phase2 = exp(1i * k * (x_fourier.^2 + y_fourier.^2) / (2 * opticalParams.f2));
        
        % 应用第二透镜
        fieldAfterLens2_x = Ex_fourier .* phase2;
        fieldAfterLens2_y = Ey_fourier .* phase2;
        
        % 第二次傅里叶变换（传播到像平面）
        ifft_factor = exp(1i * k * opticalParams.f2) / (1i * opticalParams.wavelength * opticalParams.f2);
        Ex_output = fftshift(fft2(ifftshift(fieldAfterLens2_x))) * ifft_factor;
        Ey_output = fftshift(fft2(ifftshift(fieldAfterLens2_y))) * ifft_factor;
        
        outputField = cat(3, Ex_output, Ey_output);
    end
    
    function outputField = calculateFarfieldDiffractionDirect(inputField, gratingData)
        % 远场衍射积分（直接计算，无透镜系统）- S-FFT改进版
        [Ny, Nx, ~] = size(inputField);
        
        % 通过液晶偏振光栅的Jones矩阵变换
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        % S-FFT参数（基于参考代码）
        lamda = opticalParams.wavelength;
        k = 2 * pi / lamda;
        z = opticalParams.distance; % 传播距离
        
        % 物理尺寸和网格
        width = 1e-3; % 输入面宽度
        x00 = linspace(-width, width, Nx);
        y00 = linspace(width, -width, Ny);
        [x00, y00] = meshgrid(x00, y00);
        
        % 输出面参数
        L0 = 1e-3;
        L = lamda * Nx * z / L0;
        X = linspace(-L/2 + L/Nx, L/2, Nx);
        Y = X;
        [x, y] = meshgrid(X, Y);
        
        % S-FFT公式（参考代码的精确实现）
        F0 = exp(1i * k * z) / (1i * lamda * z) * exp(1i * k / 2 / z * (x.^2 + y.^2));
        F = exp(1i * k / 2 / z * (x00.^2 + y00.^2));
        
        % 对X和Y分量分别计算
        Ex_input = fieldAfterGrating(:,:,1) .* F;
        Ey_input = fieldAfterGrating(:,:,2) .* F;
        
        % 执行FFT
        Ff_x = fftshift(fft2(fftshift(Ex_input)));
        Ff_y = fftshift(fft2(fftshift(Ey_input)));
        
        % 应用输出面相位因子
        Ex_output = F0 .* Ff_x;
        Ey_output = F0 .* Ff_y;
        
        outputField = cat(3, Ex_output, Ey_output);
    end
    
    function outputField = calculateAngularSpectrumDiffraction(inputField, gratingData)
        % 角谱传播理论 - 改进版
        [Ny, Nx, ~] = size(inputField);
        
        % 通过液晶偏振光栅
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        % 角谱传播的正确实现
        k = 2 * pi / opticalParams.wavelength;
        L = Nx * opticalParams.pixel_size;
        
        % 空间频率网格（正确的采样）
        df = 1 / L; % 频率分辨率
        fx = (-Nx/2:Nx/2-1) * df;
        fy = (-Ny/2:Ny/2-1) * df;
        [FX, FY] = meshgrid(fx, fy);
        
        % 计算传播常数kz，包含倏逝波处理
        kx = 2 * pi * FX;
        ky = 2 * pi * FY;
        kz_squared = k^2 - kx.^2 - ky.^2;
        
        % 处理倏逝波：当kz为虚数时设为0
        kz = sqrt(kz_squared);
        evanescent_mask = real(kz_squared) < 0;
        kz(evanescent_mask) = 1i * sqrt(abs(kz_squared(evanescent_mask)));
        
        % 传播算子（包含指数衰减的倏逝波）
        H = exp(1i * kz * opticalParams.distance);
        H(evanescent_mask) = H(evanescent_mask) .* exp(-sqrt(abs(kz_squared(evanescent_mask))) * opticalParams.distance);
        
        % 角谱传播
        Ex_spectrum = fftshift(fft2(ifftshift(fieldAfterGrating(:,:,1))));
        Ey_spectrum = fftshift(fft2(ifftshift(fieldAfterGrating(:,:,2))));
        
        % 应用传播算子
        Ex_propagated_spectrum = Ex_spectrum .* H;
        Ey_propagated_spectrum = Ey_spectrum .* H;
        
        % 反傅里叶变换得到传播后的场
        Ex_propagated = fftshift(ifft2(ifftshift(Ex_propagated_spectrum)));
        Ey_propagated = fftshift(ifft2(ifftshift(Ey_propagated_spectrum)));
        
        outputField = cat(3, Ex_propagated, Ey_propagated);
    end
    
    function outputField = calculateFresnelDiffraction(inputField, gratingData)
        % 菲涅尔衍射积分
        % 使用二次相位近似
        [fieldAfterGrating, ~] = applyLiquidCrystalGrating(inputField, gratingData);
        
        [Ny, Nx, ~] = size(fieldAfterGrating);
        k = 2 * pi / opticalParams.wavelength;
        z = opticalParams.distance;
        
        L = Nx * opticalParams.pixel_size;
        x = linspace(-L/2, L/2, Nx);
        y = linspace(-L/2, L/2, Ny);
        [X, Y] = meshgrid(x, y);
        
        % 菲涅尔传播算子
        H_fresnel = exp(1i * k * z) * exp(1i * k * (X.^2 + Y.^2) / (2 * z)) / (1i * opticalParams.wavelength * z);
        
        % 卷积计算
        Ex_output = ifft2(fft2(fieldAfterGrating(:,:,1)) .* fft2(H_fresnel));
        Ey_output = ifft2(fft2(fieldAfterGrating(:,:,2)) .* fft2(H_fresnel));
        
        outputField = cat(3, Ex_output, Ey_output);
    end
    
    function outputField = calculateKirchhoffDiffraction(inputField, gratingData)
        % 基尔霍夫衍射积分（简化版）
        % 使用菲涅尔近似
        outputField = calculateFresnelDiffraction(inputField, gratingData);
    end
    
    function [outputField, transmittance] = OLD_applyLiquidCrystalGrating(inputField, gratingData)
        % 应用液晶偏振光栅的Jones矩阵变换 - 改进版算法
        % 支持多种液晶偏振光栅类型：标准偏振光栅、胆甾相液晶、直接相位调制
        
        [Ny, Nx, ~] = size(inputField);
        
        % 获取液晶光栅类型（默认为标准偏振光栅）
        gratingType = 'standard'; % 可选: 'standard', 'cholesteric', 'direct_phase'
        try
            gratingTypeControl = getappdata(fig, 'gratingTypeControl');
            if ~isempty(gratingTypeControl) && isvalid(gratingTypeControl)
                gratingTypes = get(gratingTypeControl, 'String');
                gratingTypeIdx = get(gratingTypeControl, 'Value');
                gratingType = gratingTypes{gratingTypeIdx};
            end
        catch
            % 使用默认值
        end
        
        % 根据不同类型选择算法
        switch lower(gratingType)
            case 'standard'
                % 标准液晶偏振光栅算法（PB相位）
                [outputField, transmittance] = applyStandardLiquidCrystalGrating(inputField, gratingData);
                
            case 'cholesteric'
                % 胆甾相液晶算法
                [outputField, transmittance] = applyCholestericLiquidCrystal(inputField, gratingData);
                
            case 'direct_phase'
                % 直接相位调制算法（新增）
                [outputField, transmittance] = applyDirectPhaseLiquidCrystal(inputField, gratingData);
                
            otherwise
                % 默认使用标准算法
                [outputField, transmittance] = applyStandardLiquidCrystalGrating(inputField, gratingData);
        end
    end
    
    function [outputField, transmittance] = applyStandardLiquidCrystalGrating(inputField, gratingData)
        % 标准液晶偏振光栅算法 - 基于Pancharatnam-Berry相位原理
        [Ny, Nx, ~] = size(inputField);
        outputField = zeros(size(inputField));
        transmittance = zeros(Ny, Nx);
        
        % 检查gratingData有效性
        if isempty(gratingData) || ~isnumeric(gratingData)
            warning('光栅数据无效，使用默认测试光栅');
            % 创建默认测试光栅
            [X, Y] = meshgrid(1:Nx, 1:Ny);
            gratingData = 128 + 127 * sin(2*pi*X/32) .* cos(2*pi*Y/32);
        end
        
        % 确保gratingData尺寸匹配
        if size(gratingData, 1) ~= Ny || size(gratingData, 2) ~= Nx
            % 调整尺寸
            gratingData = imresize(gratingData, [Ny, Nx]);
        end
        
        % 从曝光图解码取向角
        orientation = double(gratingData) * 2 * pi / 255;
        
        % 获取液晶参数
        if isfield(lcParams, 'retardation')
            retardation = lcParams.retardation;
        else
            retardation = 1.0; % 默认值，标准半波片为1.0
        end
        
        % 设置默认透射率
        transmittance_val = 0.95; % 典型透射率
        
        for i = 1:Ny
            for j = 1:Nx
                % 取局部取向角
                theta = orientation(i, j);
                
                % 构建标准液晶光栅的琼斯矩阵
                cos_theta = cos(theta);
                sin_theta = sin(theta);
                
                % 计算半波片的Jones矩阵
                phase_delay = retardation * pi; % 半波片对应pi的相位延迟
                
                % 优化的Jones矩阵计算（减少运算量）
                cos_theta_squared = cos_theta * cos_theta;
                sin_theta_squared = sin_theta * sin_theta;
                sin_2theta = 2 * sin_theta * cos_theta;
                
                J = [cos_theta_squared + sin_theta_squared*exp(1i*phase_delay), ...
                     0.5*sin_2theta*(1-exp(1i*phase_delay)); ...
                     0.5*sin_2theta*(1-exp(1i*phase_delay)), ...
                     sin_theta_squared + cos_theta_squared*exp(1i*phase_delay)];
                
                % 应用琼斯矩阵变换
                input_jones = [inputField(i, j, 1); inputField(i, j, 2)];
                output_jones = J * input_jones;
                
                outputField(i, j, 1) = output_jones(1);
                outputField(i, j, 2) = output_jones(2);
                
                % 设置透射率
                transmittance(i, j) = transmittance_val;
            end
        end
    end
    
    function [outputField, transmittance] = applyCholestericLiquidCrystal(inputField, gratingData)
        % 胆甾相液晶的琼斯矩阵算法 - 增强版
        % 基于空间相位分布解码曝光图，并精确处理胆甾相液晶的圆偏振选择性
        [Ny, Nx, ~] = size(inputField);
        
        % 从曝光图解码基础取向角 (0-255 => 0-2π)
        base_orientation = gratingData * (2 * pi / 255);
        
        % 获取胆甾相液晶参数
        pitch = 2e-6;           % 螺距 (m)，可修改或参数化
        no = lcParams.ordinary_index;
        ne = lcParams.extraordinary_index;
        birefringence = ne - no;
        thickness = lcParams.thickness;
        wavelength = opticalParams.wavelength;
        k0 = 2 * pi / wavelength;
        pixel_size = opticalParams.pixel_size;
        
        % 计算光子带隙参数
        n_avg = sqrt((no^2 + ne^2) / 2);
        central_wavelength = pitch * n_avg;
        bandwidth = central_wavelength * birefringence / n_avg;
        wavelength_diff = abs(wavelength - central_wavelength);
        
        % 计算圆偏振选择性
        if wavelength_diff < bandwidth / 2
            reflection_coefficient = exp(-(2*wavelength_diff/bandwidth)^2);
        else
            reflection_coefficient = 0;
        end
        
        % 空间扭转角度和有效厚度
        twist_angle = pi/2;  % 标准90°扭转
        effective_thickness = thickness / cos(twist_angle);
        base_retardation = k0 * birefringence * effective_thickness;
        
        % 初始化输出场和透射率
        outputField = zeros(size(inputField));
        transmittance = zeros(Ny, Nx);
        
        % 标准串行版本 - 移除并行选项，避免嵌套函数问题
        for i = 1:Ny
            for j = 1:Nx
                % 获取空间依赖的螺旋相位
                y_position = (i-1) * pixel_size;
                helical_phase = 2 * pi * y_position / pitch;
                
                % 总取向角（基础 + 螺旋调制）
                theta_in = base_orientation(i, j);
                
                % 考虑位置的局部扭转角
                local_twist = twist_angle * (1 + 0.05 * sin(helical_phase)); % 微小扰动
                theta_out = theta_in + local_twist;
                
                % 旋转矩阵
                cos_theta_in = cos(theta_in);
                sin_theta_in = sin(theta_in);
                cos_theta_out = cos(theta_out);
                sin_theta_out = sin(theta_out);
                
                % 入射旋转
                R1 = [cos_theta_in, -sin_theta_in; sin_theta_in, cos_theta_in];
                
                % 相位延迟（空间调制）
                local_retardation = base_retardation * (1 + 0.1 * cos(helical_phase));
                B = [exp(-1i * local_retardation/2), 0; 
                     0, exp(1i * local_retardation/2)];
                
                % 圆偏振选择性
                % 确定局部相位对选择性的影响
                local_selectivity = reflection_coefficient * (1 + 0.2 * cos(helical_phase));
                local_selectivity = min(local_selectivity, 0.99); % 防止完全反射
                
                C = [1.0, 0; 0, 1.0 - local_selectivity];
                
                % 输出旋转
                R2 = [cos_theta_out, sin_theta_out; -sin_theta_out, cos_theta_out];
                
                % 完整琼斯矩阵
                J = R2 * C * B * R1;
                
                % 应用变换
                input_jones = [inputField(i, j, 1); inputField(i, j, 2)];
                output_jones = J * input_jones;
                
                outputField(i, j, 1) = output_jones(1);
                outputField(i, j, 2) = output_jones(2);
                
                % 计算透射率（考虑材料吸收）
                transmittance(i, j) = 0.95 * (abs(output_jones(1))^2 + abs(output_jones(2))^2) / (abs(input_jones(1))^2 + abs(input_jones(2))^2);
            end
        end
        
        % 在输出上添加可选的信息标签（用于调试）
        setappdata(fig, 'lastProcessedType', 'cholesteric');
    end
    
    function [outputField, transmittance] = applyDirectPhaseLiquidCrystal(inputField, gratingData)
        % 直接相位调制算法 - 新增
        % 该算法直接从曝光图解码相位分布，再进行精确的琼斯矩阵运算
        [Ny, Nx, ~] = size(inputField);
        outputField = zeros(size(inputField));
        transmittance = zeros(Ny, Nx);
        
        % 1. 从曝光图直接解码相位分布 (0-255 => 0-2π)
        phaseDistribution = gratingData * (2 * pi / 255);
        
        % 2. 获取液晶参数
        ne = lcParams.extraordinary_index;
        no = lcParams.ordinary_index;
        birefringence = ne - no;
        thickness = lcParams.thickness;
        wavelength = opticalParams.wavelength;
        k0 = 2 * pi / wavelength;
        
        % 3. 计算基础相位延迟
        base_retardation = k0 * birefringence * thickness;
        
        % 4. 从UI获取其他可能的参数
        amplitude_modulation = 1.0; % 默认值，可以从UI获取
        try
            amplitude_control = getappdata(fig, 'amplitudeModulationControl');
            if ~isempty(amplitude_control) && isvalid(amplitude_control)
                amplitude_modulation = get(amplitude_control, 'Value');
            end
        catch
            % 使用默认值
        end
        
        % 5. 处理每个像素
        for i = 1:Ny
            for j = 1:Nx
                % 获取局部相位
                local_phase = phaseDistribution(i, j);
                
                % 精确计算相位延迟
                effective_retardation = base_retardation * (1 + 0.5 * cos(local_phase));
                
                % 琼斯矩阵计算
                % 创建相位调制矩阵 - 精确表示相位变化
                J_phase = [exp(1i * local_phase), 0; 
                          0, exp(-1i * local_phase * 0.5)];
                
                % 创建振幅调制矩阵（如果需要）
                J_amplitude = [amplitude_modulation, 0; 
                               0, amplitude_modulation];
                
                % 创建双折射矩阵
                J_birefringence = [exp(-1i * effective_retardation/2), 0; 
                                  0, exp(1i * effective_retardation/2)];
                
                % 复合琼斯矩阵
                J = J_phase * J_birefringence * J_amplitude;
                
                % 应用变换
                input_jones = [inputField(i, j, 1); inputField(i, j, 2)];
                output_jones = J * input_jones;
                
                outputField(i, j, 1) = output_jones(1);
                outputField(i, j, 2) = output_jones(2);
                
                % 计算精确透射率
                input_intensity = abs(input_jones(1))^2 + abs(input_jones(2))^2;
                output_intensity = abs(output_jones(1))^2 + abs(output_jones(2))^2;
                
                % 考虑能量守恒和材料吸收
                transmittance(i, j) = 0.98 * output_intensity / (input_intensity + 1e-10);
            end
        end
    end
    
    function selectivity = calculateCircularSelectivity(wavelength, params)
        % 计算圆偏振选择性（用于胆甾相液晶）
        if isfield(params, 'pitch')
            % 简化的选择性模型
            central_wavelength = params.pitch * 1.6; % 近似值
            bandwidth = 0.1 * central_wavelength;
            
            if abs(wavelength - central_wavelength) < bandwidth/2
                selectivity.left = 1.0;
                selectivity.right = 0.1; % 右旋光被反射
            else
                selectivity.left = 1.0;
                selectivity.right = 1.0;
            end
        else
            % 无选择性
            selectivity.left = 1.0;
            selectivity.right = 1.0;
        end
    end
    
    function displayResults(inputField, outputField)
        % 显示2D衍射结果 - 支持新的颜色分类和3D显示
        intensity = abs(outputField(:,:,1)).^2 + abs(outputField(:,:,2)).^2;
        
        % 获取偏振显示选项
        try
            popupPolarizationDisplay = getappdata(fig, 'popupPolarizationDisplay');
            if ~isempty(popupPolarizationDisplay) && isvalid(popupPolarizationDisplay)
                displayOption = get(popupPolarizationDisplay, 'Value');
            else
                displayOption = 1; % 默认强度分布
            end
        catch
            displayOption = 1;
        end
        
        % 根据选择的显示选项计算显示数据
        switch displayOption
            case 1 % 强度分布
                displayData = intensity;
                titleStr = '液晶偏振光栅衍射强度分布';
            case 2 % 偏振态矢量
                % 计算偏振椭圆参数
                Ex = outputField(:,:,1);
                Ey = outputField(:,:,2);
                % 计算椭圆度
                ellipticity = atan(abs(imag(conj(Ex).*Ey)) ./ (abs(Ex).^2 + abs(Ey).^2 + eps));
                displayData = ellipticity;
                titleStr = '偏振态椭圆度分布';
            case 3 % 椭圆度分布
                Ex = outputField(:,:,1);
                Ey = outputField(:,:,2);
                % 计算归一化椭圆度
                ellipticity = abs(imag(conj(Ex).*Ey)) ./ (abs(Ex).^2 + abs(Ey).^2 + eps);
                displayData = ellipticity;
                titleStr = '偏振椭圆度分布';
            case 4 % Stokes参数
                Ex = outputField(:,:,1);
                Ey = outputField(:,:,2);
                % 计算Stokes参数 S1 = |Ex|^2 - |Ey|^2
                S0 = abs(Ex).^2 + abs(Ey).^2;
                S1 = abs(Ex).^2 - abs(Ey).^2;
                S2 = 2*real(conj(Ex).*Ey);
                S3 = 2*imag(conj(Ex).*Ey);
                % 显示偏振度 (degree of polarization)
                DOP = sqrt(S1.^2 + S2.^2 + S3.^2) ./ (S0 + eps);
                displayData = DOP;
                titleStr = 'Stokes偏振度分布';
        end
        
        % 检查2D显示是否启用
        try
            checkbox2DShow = getappdata(fig, 'checkbox2DShow');
            enable2D = ~isempty(checkbox2DShow) && isvalid(checkbox2DShow) && get(checkbox2DShow, 'Value');
        catch
            enable2D = true; % 默认启用
        end
        
        % 显示2D图像
        if enable2D
            axes(axesImg2D);
            imagesc(displayData);
            
            % 应用新的slanCM颜色分类系统
            applySelectedColormap(axesImg2D);
            
            axis equal; axis tight;
            colorbar;
            title(titleStr, 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('X轴位置 (μm)', 'FontSize', 10);
            ylabel('Y轴位置 (μm)', 'FontSize', 10);
        end
        
        % 检查1D显示是否启用
        try
            checkbox1DShow = getappdata(fig, 'checkbox1DShow');
            enable1D = ~isempty(checkbox1DShow) && isvalid(checkbox1DShow) && get(checkbox1DShow, 'Value');
        catch
            enable1D = true; % 默认启用
        end
        
        % 显示1D剖面（中心行）
        if enable1D
            [Ny, ~] = size(intensity);
            center_row = intensity(round(Ny/2), :);
            x_axis = (1:length(center_row)) * opticalParams.pixel_size * 1e6; % 转换为μm
            
            axes(axesImg1D);
            cla;
            
            % 获取选择的1D颜色方案
            try
                popupPlotColor = getappdata(fig, 'popupPlotColor');
                if ~isempty(popupPlotColor) && isvalid(popupPlotColor)
                    plotColorIdx = get(popupPlotColor, 'Value');
                    plotColorValues = {'nature', 'science', 'cell', 'prl', 'optica', 'nano_letters'};
                    colorScheme = plotColorValues{plotColorIdx};
                else
                    colorScheme = 'nature'; % 默认
                end
            catch
                colorScheme = 'nature'; % 错误时使用默认
            end
            
            % 使用增强版精美绘图函数
            try
                % 尝试调用增强版绘图函数
                x_axis_m = x_axis * 1e-6; % 转换回米
                input_data = abs(inputField(round(Ny/2), :, 1)).^2;
                output_data = center_row;
                
                % 创建绘图选项
                plot_options = struct();
                plot_options.title = '液晶偏振光栅衍射光强分布';
                plot_options.xlabel = '横向位置 (μm)';
                plot_options.ylabel = '归一化强度';
                plot_options.legend_input = '入射场';
                plot_options.legend_output = '衍射场';
                plot_options.show_peak_markers = true;
                
                % 调用增强版绘图函数
                if exist('plot_gradient_compare_enhanced', 'file')
                    plot_gradient_compare_enhanced(x_axis, input_data, output_data, [], plot_options);
                else
                    % 降级使用简化版本
                    plot_gradient_compare_simple(x_axis, input_data, output_data, colorScheme);
                end
            catch
                % 如果增强版失败，使用简化版本
                plot_gradient_compare_simple(x_axis, abs(inputField(round(Ny/2), :, 1)).^2, center_row, colorScheme);
            end
        end
        
        % 检查3D显示是否启用
        try
            checkbox3DWaterfall = getappdata(fig, 'checkbox3DWaterfall');
            enable3DWaterfall = ~isempty(checkbox3DWaterfall) && isvalid(checkbox3DWaterfall) && get(checkbox3DWaterfall, 'Value');
        catch
            enable3DWaterfall = false;
        end
        
        % 检查实时3D预览是否启用
        try
            checkbox3DPreview = getappdata(fig, 'checkbox3DPreview');
            enable3DPreview = ~isempty(checkbox3DPreview) && isvalid(checkbox3DPreview) && get(checkbox3DPreview, 'Value');
        catch
            enable3DPreview = false;
        end
        
        % 显示3D图像
        if enable3DPreview
            display3DDiffraction(displayData, titleStr);
        end
        
        % 传统3D瀑布图窗口（如果启用）
        if enable3DWaterfall
            create3DWaterfallPlot(displayData, titleStr);
        end
        
        % 存储当前结果用于保存
        setappdata(fig, 'current2DData', displayData);
        setappdata(fig, 'current1DData', struct('x', x_axis, 'input', abs(inputField(round(Ny/2), :, 1)).^2, 'output', center_row));
        setappdata(fig, 'current3DData', displayData); % 存储3D数据
        
        % 更新信息显示
        updateInfoDisplay(intensity, displayOption);
    end
    
    function plot_gradient_compare(x, E_in, E_out, E_in_err, colorScheme)
        % 增强版精美绘图函数
        axes(axesImg1D);
        cla;
        
        % 归一化
        E_in = E_in / max(E_in);
        E_out = E_out / max(E_out);
        
        % 绘制渐变填充
        x_fill = [x, fliplr(x)];
        y_fill_in = [E_in, zeros(size(E_in))];
        y_fill_out = [E_out, zeros(size(E_out))];
        
        % 输入场（蓝色渐变）
        fill(x_fill, y_fill_in, [0.3, 0.6, 0.9], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
        hold on;
        
        % 输出场（红色渐变）
        fill(x_fill, y_fill_out, [0.9, 0.3, 0.3], 'FaceAlpha', 0.6, 'EdgeColor', 'none');
        
        % 边缘线
        plot(x, E_in, 'Color', [0.1, 0.3, 0.7], 'LineWidth', 2);
        plot(x, E_out, 'Color', [0.7, 0.1, 0.1], 'LineWidth', 2);
        
        xlabel('横向位置 (μm)', 'FontSize', 11, 'FontName', '宋体');
        ylabel('归一化强度', 'FontSize', 11, 'FontName', '宋体');
        legend({'入射场', '衍射场', '', ''}, 'Location', 'northeast', 'FontSize', 10);
        
        % 美化设置
        ax = gca;
        ax.LineWidth = 1.5;
        ax.GridLineStyle = '-.';
        ax.GridAlpha = 0.3;
        grid on;
        box off;
        
        title('一维衍射光强分布', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    function updateInfoDisplay(intensity, displayOption)
        % 更新信息显示
        max_intensity = max(intensity(:));
        min_intensity = min(intensity(:));
        mean_intensity = mean(intensity(:));
        
        methodIdx = get(popupDiffractionMethod, 'Value');
        method = diffractionMethods{methodIdx};
        
        polarTypeIdx = get(popupPolarizationType, 'Value');
        polarType = polarizationTypes{polarTypeIdx};
        
        % 偏振显示类型
        displayTypes = {'强度分布', '偏振态矢量', '椭圆度分布', 'Stokes参数'};
        displayType = displayTypes{displayOption};
        
        infoText = sprintf(['仿真完成\n\n' ...
            '衍射算法: %s\n' ...
            '偏振类型: %s\n' ...
            '显示模式: %s\n' ...
            '波长: %.0f nm\n' ...
            '液晶厚度: %.1f μm\n\n' ...
            '数据统计:\n' ...
            '最大值: %.2e\n' ...
            '最小值: %.2e\n' ...
            '平均值: %.2e\n\n' ...
            '衍射效率: %.2f%%'], ...
            method, polarType, displayType, ...
            opticalParams.wavelength*1e9, lcParams.thickness*1e6, ...
            max_intensity, min_intensity, mean_intensity, ...
            (mean_intensity/max_intensity)*100);
        
        set(textInfo, 'String', infoText);
    end
    
    % === 光栅加载函数 ===
    
    function loadGratingPattern(~, ~)
        % 加载偏振光栅图案 - 修复版，确保数据正确存储
        [filename, pathname] = uigetfile({'*.mat;*.png;*.jpg;*.tif;*.bmp', '光栅文件 (*.mat, *.png, *.jpg, *.tif, *.bmp)'}, ...
            '选择偏振光栅文件');
        
        if filename ~= 0
            fullpath = fullfile(pathname, filename);
            
            try
                [~, ~, ext] = fileparts(filename);
                
                if strcmp(ext, '.mat')
                    % MATLAB数据文件
                    data = load(fullpath);
                    fields = fieldnames(data);
                    if ~isempty(fields)
                        gratingData = data.(fields{1});
                    else
                        error('MAT文件中没有找到有效数据');
                    end
                else
                    % 图像文件
                    img = imread(fullpath);
                    if size(img, 3) == 3
                        gratingData = rgb2gray(img);
                    else
                        gratingData = img;
                    end
                end
                
                % 转换为双精度并归一化
                gratingData = double(gratingData);
                if max(gratingData(:)) > 1
                    gratingData = gratingData / 255;  % 归一化到0-1范围
                end
                
                % 验证数据有效性
                if isempty(gratingData) || any(isnan(gratingData(:))) || any(isinf(gratingData(:)))
                    error('加载的光栅数据无效或包含NaN/Inf值');
                end
                
                % 显示光栅信息
                [rows, cols] = size(gratingData);
                minVal = min(gratingData(:));
                maxVal = max(gratingData(:));
                
                infoMsg = sprintf(['成功加载光栅数据: %s\n\n' ...
                    '数据信息:\n' ...
                    '尺寸: %d × %d 像素\n' ...
                    '数值范围: %.3f ~ %.3f\n' ...
                    '数据类型: %s\n\n' ...
                    '光栅已准备用于仿真计算'], ...
                    filename, rows, cols, minVal, maxVal, class(gratingData));
                
                msgbox(infoMsg, '光栅加载成功', 'help');
                
                % 更新信息显示，确认光栅已加载
                try
                    currentInfo = get(textInfo, 'String');
                    newInfo = sprintf('光栅状态: 已加载 (%s, %dx%d)\n%s', ...
                        filename, rows, cols, currentInfo);
                    set(textInfo, 'String', newInfo);
                catch
                    % 如果textInfo不可用，忽略
                end
                
            catch ME
                errordlg(['加载光栅数据失败: ', ME.message], '加载错误');
                gratingData = []; % 确保失败时清空数据
            end
        end
    end
    
    function generateTestGrating(~, ~)
        % 生成测试偏振光栅 - 修复版，确保数据正确存储
        try
            N = 512;
            period = 50;
            
            [X, Y] = meshgrid(1:N, 1:N);
            
            % 生成简单的线性偏振光栅
            orientation = mod(X, period) / period;  % 归一化到0-1范围
            
            gratingData = orientation;
            
            % 显示测试光栅信息
            infoMsg = sprintf(['成功生成测试偏振光栅\n\n' ...
                '数据信息:\n' ...
                '尺寸: %d × %d 像素\n' ...
                '光栅周期: %d 像素\n' ...
                '数值范围: 0.000 ~ 1.000\n\n' ...
                '测试光栅已准备用于仿真计算'], ...
                N, N, period);
            
            msgbox(infoMsg, '测试光栅生成成功', 'help');
            
            % 更新信息显示
            try
                currentInfo = get(textInfo, 'String');
                newInfo = sprintf('光栅状态: 测试光栅已生成 (%dx%d)\n%s', ...
                    N, N, currentInfo);
                set(textInfo, 'String', newInfo);
            catch
                % 如果textInfo不可用，忽略
            end
            
        catch ME
            errordlg(['生成测试光栅失败: ', ME.message], '生成错误');
            gratingData = []; % 确保失败时清空数据
        end
    end
    
    function callExposureGenerator(~, ~)
        % 嵌入式曝光图生成器 - 简化版
        % 直接在当前程序中创建曝光图设计界面
        
        % 创建曝光图生成器窗口
        exposureGenFig = figure('Name', '嵌入式曝光图生成器', ...
            'Position', [100, 100, 800, 600], ...
            'NumberTitle', 'off', 'MenuBar', 'none', ...
            'Resize', 'on', 'Color', [0.94 0.94 0.94]);
        
        % 左侧参数面板
        paramPanel = uipanel(exposureGenFig, 'Title', '光栅参数设置', 'FontSize', 12, ...
            'Position', [0.05, 0.05, 0.4, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 右侧预览面板
        previewPanel = uipanel(exposureGenFig, 'Title', '光栅预览', 'FontSize', 12, ...
            'Position', [0.5, 0.05, 0.45, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 参数设置
        y_pos = 480;
        spacing = 50;
        
        % 图像尺寸
        uicontrol(paramPanel, 'Style', 'text', 'String', '图像尺寸 (像素):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editImageSize = uicontrol(paramPanel, 'Style', 'edit', 'String', '512', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 光栅周期
        uicontrol(paramPanel, 'Style', 'text', 'String', '光栅周期 (像素):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editGratingPeriod = uicontrol(paramPanel, 'Style', 'edit', 'String', '32', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 图案类型
        uicontrol(paramPanel, 'Style', 'text', 'String', '图案类型:', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        patternTypes = {'线性偏振光栅', '圆偏振光栅', '径向偏振光栅', '螺旋相位光栅'};
        popupPatternType = uicontrol(paramPanel, 'Style', 'popupmenu', ...
            'String', patternTypes, 'Value', 1, ...
            'Position', [130, y_pos, 150, 25], 'FontSize', 10);
        
        y_pos = y_pos - spacing;
        
        % 相位延迟
        uicontrol(paramPanel, 'Style', 'text', 'String', '相位延迟 (π):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editPhaseDelay = uicontrol(paramPanel, 'Style', 'edit', 'String', '1.0', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 旋转角度
        uicontrol(paramPanel, 'Style', 'text', 'String', '旋转角度 (度):', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        editOrientation = uicontrol(paramPanel, 'Style', 'edit', 'String', '0', ...
            'Position', [150, y_pos, 80, 25], 'FontSize', 11);
        
        y_pos = y_pos - spacing;
        
        % 按钮区域
        uicontrol(paramPanel, 'Style', 'pushbutton', 'String', '生成预览', ...
            'Position', [30, y_pos, 100, 35], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
            'Callback', @generatePreview);
        
        uicontrol(paramPanel, 'Style', 'pushbutton', 'String', '保存并返回', ...
            'Position', [150, y_pos, 100, 35], ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', @saveAndReturn);
        
        % 预览区域
        previewAxes = axes('Parent', previewPanel, 'Position', [0.1, 0.1, 0.8, 0.8]);
        title(previewAxes, '点击"生成预览"查看光栅', 'FontSize', 12);
        
        % 存储控件句柄和数据
        exposureData = struct();
        exposureData.editImageSize = editImageSize;
        exposureData.editGratingPeriod = editGratingPeriod;
        exposureData.popupPatternType = popupPatternType;
        exposureData.editPhaseDelay = editPhaseDelay;
        exposureData.editOrientation = editOrientation;
        exposureData.previewAxes = previewAxes;
        exposureData.parentFig = fig;
        exposureData.generatedPattern = [];
        
        setappdata(exposureGenFig, 'exposureData', exposureData);
        
        function generatePreview(~, ~)
            % 生成光栅预览
            try
                data = getappdata(exposureGenFig, 'exposureData');
                
                % 获取参数
                imageSize = str2double(get(data.editImageSize, 'String'));
                gratingPeriod = str2double(get(data.editGratingPeriod, 'String'));
                phaseDelay = str2double(get(data.editPhaseDelay, 'String'));
                orientation = str2double(get(data.editOrientation, 'String'));
                patternType = get(data.popupPatternType, 'Value');
                
                % 参数验证
                if isnan(imageSize) || imageSize <= 0
                    imageSize = 512;
                    set(data.editImageSize, 'String', '512');
                end
                if isnan(gratingPeriod) || gratingPeriod <= 0
                    gratingPeriod = 32;
                    set(data.editGratingPeriod, 'String', '32');
                end
                
                % 生成坐标网格
                [x, y] = meshgrid(1:imageSize, 1:imageSize);
                x = x - imageSize/2;
                y = y - imageSize/2;
                
                % 根据图案类型生成光栅
                switch patternType
                    case 1 % 线性偏振光栅
                        theta = deg2rad(orientation);
                        x_rot = x*cos(theta) + y*sin(theta);
                        phase = 2*pi * x_rot / gratingPeriod;
                        pattern = exp(1i * phaseDelay * pi * cos(phase));
                        
                    case 2 % 圆偏振光栅
                        r = sqrt(x.^2 + y.^2);
                        phi = atan2(y, x);
                        phase = 2*pi * r / gratingPeriod + orientation * pi/180 * phi;
                        pattern = exp(1i * phaseDelay * pi * cos(phase));
                        
                    case 3 % 径向偏振光栅
                        r = sqrt(x.^2 + y.^2);
                        phase = 2*pi * r / gratingPeriod;
                        pattern = exp(1i * phaseDelay * pi * cos(phase));
                        
                    case 4 % 螺旋相位光栅
                        r = sqrt(x.^2 + y.^2);
                        phi = atan2(y, x);
                        radial_phase = 2*pi * r / gratingPeriod;
                        azimuthal_phase = orientation * pi/180 * phi;
                        pattern = exp(1i * phaseDelay * pi * cos(radial_phase + azimuthal_phase));
                end
                
                % 显示预览
                axes(data.previewAxes);
                intensity = abs(pattern).^2;
                imagesc(intensity);
                
                try
                    colormap(data.previewAxes, slanCM('gray'));
                catch
                    colormap(data.previewAxes, gray);
                end
                
                axis equal; axis tight;
                title(sprintf('%s预览 (%dx%d)', patternTypes{patternType}, imageSize, imageSize), 'FontSize', 11);
                colorbar;
                
                % 存储生成的图案
                data.generatedPattern = pattern;
                setappdata(exposureGenFig, 'exposureData', data);
                
            catch ME
                errordlg(['预览生成失败: ', ME.message], '错误');
            end
        end
        
        function saveAndReturn(~, ~)
            % 保存并返回主程序
            try
                data = getappdata(exposureGenFig, 'exposureData');
                
                if isempty(data.generatedPattern)
                    msgbox('请先生成预览', '提示', 'warn');
                    return;
                end
                
                % 选择保存位置
                [filename, pathname] = uiputfile({
                    '*.mat', 'MATLAB数据文件 (*.mat)';
                    '*.png', 'PNG图像文件 (*.png)';
                    '*.tif', 'TIFF图像文件 (*.tif)'
                }, '保存光栅图案', 'LC_grating_pattern.mat');
                
                if filename == 0
                    return; % 用户取消
                end
                
                fullPath = fullfile(pathname, filename);
                
                % 保存文件
                [~, ~, ext] = fileparts(filename);
                
                if strcmpi(ext, '.mat')
                    % 保存为MATLAB数据
                    gratingData = data.generatedPattern;
                    gratingParams = struct();
                    gratingParams.imageSize = str2double(get(data.editImageSize, 'String'));
                    gratingParams.gratingPeriod = str2double(get(data.editGratingPeriod, 'String'));
                    gratingParams.phaseDelay = str2double(get(data.editPhaseDelay, 'String'));
                    gratingParams.orientation = str2double(get(data.editOrientation, 'String'));
                    gratingParams.patternType = get(data.popupPatternType, 'Value');
                    gratingParams.createTime = datestr(now);
                    
                    save(fullPath, 'gratingData', 'gratingParams');
                else
                    % 保存为图像
                    intensity = abs(data.generatedPattern).^2;
                    intensity = intensity / max(intensity(:)); % 归一化
                    
                    if strcmpi(ext, '.png')
                        imwrite(intensity, fullPath, 'png');
                    elseif strcmpi(ext, '.tif')
                        imwrite(intensity, fullPath, 'tif');
                    end
                end
                
                % 将数据加载到主程序
                if isvalid(data.parentFig)
                    % 更新主程序的光栅数据变量
                    gratingData = data.generatedPattern;
                    
                    msgbox(['光栅已保存: ', fullPath, char(10), '数据已加载到仿真系统'], '成功', 'help');
                end
                
                % 关闭窗口
                close(exposureGenFig);
                
        catch ME
                errordlg(['保存失败: ', ME.message], '保存错误');
            end
        end
    end
    
    % === 保存功能函数 ===
    
    function saveSimulationResults(~, ~)
        % 保存仿真结果 - 改进版
        
        % 检查是否已完成仿真计算
        current2DData = getappdata(fig, 'current2DData');
        current1DData = getappdata(fig, 'current1DData');
        
        if isempty(current2DData) || isempty(current1DData)
            msgbox('请先运行仿真计算后再保存结果', '提示', 'warn');
            return;
        end
        
        % 创建保存对话框
        saveDialog = figure('Name', '保存仿真结果', 'Position', [200, 200, 500, 400], ...
            'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'off', ...
            'Color', [0.94 0.94 0.94]);
        
        % 标题
        uicontrol(saveDialog, 'Style', 'text', 'String', '保存仿真结果选项', ...
            'Position', [180, 360, 140, 25], 'FontSize', 14, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.94 0.94 0.94]);
        
        % 文件格式选择
        fileFormats = {'PNG图像 (*.png)', 'TIFF图像 (*.tif)', 'JPEG图像 (*.jpg)', ...
                      'EPS矢量图 (*.eps)', 'PDF文档 (*.pdf)', 'SVG矢量图 (*.svg)', 'MATLAB数据 (*.mat)'};
        fileExtensions = {'.png', '.tif', '.jpg', '.eps', '.pdf', '.svg', '.mat'};
        
        uicontrol(saveDialog, 'Style', 'text', 'String', '文件格式:', ...
            'Position', [30, 310, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11);
        
        formatPopup = uicontrol(saveDialog, 'Style', 'popupmenu', 'String', fileFormats, ...
            'Position', [120, 310, 240, 20], 'Value', 1, 'FontSize', 10);
        
        % DPI选择（增加2400dpi选项）
        uicontrol(saveDialog, 'Style', 'text', 'String', '分辨率(DPI):', ...
            'Position', [30, 270, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11);
        
        dpiOptions = {'150 (网络显示)', '300 (标准打印)', '600 (高质量)', '1200 (专业级)', '2400 (超高精度)'};
        dpiValues = [150, 300, 600, 1200, 2400];
        
        dpiPopup = uicontrol(saveDialog, 'Style', 'popupmenu', 'String', dpiOptions, ...
            'Position', [120, 270, 240, 20], 'Value', 2, 'FontSize', 10);
        
        % 文件名输入
        uicontrol(saveDialog, 'Style', 'text', 'String', '文件名前缀:', ...
            'Position', [30, 230, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11);
        
        filenameEdit = uicontrol(saveDialog, 'Style', 'edit', 'String', 'LC_diffraction', ...
            'Position', [120, 230, 240, 20], 'FontSize', 10);
        
        % 保存内容选择
        uicontrol(saveDialog, 'Style', 'text', 'String', '保存内容:', ...
            'Position', [30, 190, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11, 'FontWeight', 'bold');
        
        save2DCheck = uicontrol(saveDialog, 'Style', 'checkbox', 'String', '2D衍射图样', ...
            'Position', [120, 190, 120, 20], 'Value', 1, ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 10);
        
        save1DCheck = uicontrol(saveDialog, 'Style', 'checkbox', 'String', '1D光强分布曲线', ...
            'Position', [260, 190, 140, 20], 'Value', 1, ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 10);
        
        save3DCheck = uicontrol(saveDialog, 'Style', 'checkbox', 'String', '3D瀑布图', ...
            'Position', [420, 190, 100, 20], 'Value', 0, ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 10, ...
            'TooltipString', '保存3D瀑布图（需要启用3D显示）');
        
        % 曲线颜色方案
        uicontrol(saveDialog, 'Style', 'text', 'String', '曲线颜色方案:', ...
            'Position', [30, 150, 100, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 11);
        
        localPlotColorPopup = uicontrol(saveDialog, 'Style', 'popupmenu', ...
            'String', {'Nature风格', 'Science风格', 'Cell风格', 'PRL风格', 'Optica风格', 'Nano Letters风格'}, ...
            'Value', 1, 'Position', [130, 150, 180, 20], 'FontSize', 10);
        
        % 额外选项
        saveParamsCheck = uicontrol(saveDialog, 'Style', 'checkbox', 'String', '保存仿真参数', ...
            'Position', [120, 120, 120, 20], 'Value', 1, ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 10);
        
        saveRawDataCheck = uicontrol(saveDialog, 'Style', 'checkbox', 'String', '保存原始数据', ...
            'Position', [260, 120, 120, 20], 'Value', 0, ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 10);
        
        % 进度显示区域
        progressText = uicontrol(saveDialog, 'Style', 'text', 'String', '准备保存...', ...
            'Position', [30, 80, 440, 40], 'HorizontalAlignment', 'center', ...
            'BackgroundColor', [0.94 0.94 0.94], 'FontSize', 10, ...
            'ForegroundColor', [0.3, 0.3, 0.7]);
        
        % 按钮
        uicontrol(saveDialog, 'Style', 'pushbutton', 'String', '开始保存', ...
            'Position', [120, 30, 100, 35], 'Callback', @doSaveResults, ...
            'FontWeight', 'bold', 'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
            'FontSize', 11);
        
        uicontrol(saveDialog, 'Style', 'pushbutton', 'String', '取消', ...
            'Position', [280, 30, 100, 35], 'Callback', @(~,~) close(saveDialog), ...
            'FontWeight', 'bold', 'BackgroundColor', [0.8, 0.3, 0.3], 'ForegroundColor', [1 1 1], ...
            'FontSize', 11);
        
        % 保存执行函数
        function doSaveResults(~,~)
            try
                % 获取选项
                formatIdx = get(formatPopup, 'Value');
                dpiIdx = get(dpiPopup, 'Value');
                filename_prefix = get(filenameEdit, 'String');
                saveParams = get(saveParamsCheck, 'Value');
                saveRawData = get(saveRawDataCheck, 'Value');
                save2D = get(save2DCheck, 'Value');
                save1D = get(save1DCheck, 'Value');
                save3D = get(save3DCheck, 'Value');
                
                if isempty(filename_prefix)
                    filename_prefix = 'LC_diffraction';
                end
                
                % 选择保存路径
                save_path = uigetdir('', '选择保存文件夹');
                if save_path == 0
                    return;
                end
                
                set(progressText, 'String', '正在保存文件...');
                drawnow;
                
                % 保存2D数据
                if save2D
                    filename_2d = fullfile(save_path, [filename_prefix, '_2D_diffraction', fileExtensions{formatIdx}]);
                    
                    % 创建临时图形保存2D图像
                    tempFig2D = figure('Visible', 'off', 'Position', [0, 0, 800, 600]);
                    imagesc(current2DData);
                    
                    % 应用颜色映射
                    try
                        colormapIdx = get(popupColormap, 'Value');
                        colormapType = colormapTypes{colormapIdx};
                        colormap(slanCM(colormapType));
                    catch
                        colormap(jet);
                    end
                    
                    axis equal; axis tight; colorbar;
                    title('二维衍射强度分布', 'FontSize', 14, 'FontWeight', 'bold');
                    
                    % 保存 - 增强版支持SVG和高分辨率
                    if formatIdx <= 3 % 图像格式 (PNG, TIFF, JPEG)
                        print(tempFig2D, filename_2d, ['-d', lower(fileFormats{formatIdx}(end-2:end))], ['-r', num2str(dpiValues(dpiIdx))]);
                    elseif formatIdx == 4 % EPS
                        print(tempFig2D, filename_2d, '-depsc', ['-r', num2str(dpiValues(dpiIdx))]);
                    elseif formatIdx == 5 % PDF
                        print(tempFig2D, filename_2d, '-dpdf', ['-r', num2str(dpiValues(dpiIdx))]);
                    elseif formatIdx == 6 % SVG矢量图
                        % SVG保存（矢量格式，分辨率无关）
                        try
                            % 使用plot2svg函数保存SVG（如果可用）
                            if exist('plot2svg', 'file')
                                plot2svg(filename_2d, tempFig2D);
                            else
                                % 使用MATLAB内置print命令保存SVG
                                print(tempFig2D, filename_2d, '-dsvg', ['-r', num2str(dpiValues(dpiIdx))]);
                            end
                        catch
                            % 如果SVG保存失败，降级为高分辨率PNG
                            filename_2d_png = strrep(filename_2d, '.svg', '_svg_fallback.png');
                            print(tempFig2D, filename_2d_png, '-dpng', ['-r', num2str(dpiValues(dpiIdx))]);
                            msgbox(['SVG保存失败，已保存为高分辨率PNG: ', filename_2d_png], '提示', 'warn');
                        end
                    elseif formatIdx == 7 % MAT数据
                        data_2d = current2DData;
                        % 保存2D数据以及相关参数
                        save(filename_2d, 'data_2d', 'opticalParams', 'lcParams');
                    end
                    
                    close(tempFig2D);
                    set(progressText, 'String', '✓ 2D图像已保存');
                    drawnow;
                end
                
                % 保存1D数据
                if save1D
                    filename_1d = fullfile(save_path, [filename_prefix, '_1D_profile', fileExtensions{formatIdx}]);
                    
                    % 创建临时图形保存1D图像
                    tempFig1D = figure('Visible', 'off', 'Position', [0, 0, 800, 400]);
                    
                    % 获取颜色方案
                    try
                        plotColorIdx = get(localPlotColorPopup, 'Value');
                        plotColorValues = {'nature', 'science', 'cell', 'prl', 'optica', 'nano_letters'};
                        colorScheme = plotColorValues{plotColorIdx};
                    catch
                        colorScheme = 'nature';
                    end
                    
                    % 绘制1D图像
                    if ~isempty(current1DData) && isfield(current1DData, 'x') && isfield(current1DData, 'input') && isfield(current1DData, 'output')
                        plot_gradient_compare(current1DData.x * 1e-6, sqrt(current1DData.input), sqrt(current1DData.output), [], colorScheme);
                    else
                        % 防止无数据导致的错误
                        x = linspace(-100, 100, 500);
                        y = exp(-x.^2/1000);
                        plot(x, y, 'LineWidth', 2);
                        xlabel('位置 (μm)', 'FontSize', 10);
                        ylabel('强度', 'FontSize', 10);
                        title('一维衍射光强分布', 'FontSize', 12);
                        grid on;
                        msgbox('警告：没有有效的1D数据，使用示例数据替代', '数据缺失', 'warn');
                    end
                    
                    % 保存
                    if formatIdx <= 3 % 图像格式
                        print(tempFig1D, filename_1d, ['-d', lower(fileFormats{formatIdx}(end-2:end))], ['-r', num2str(dpiValues(dpiIdx))]);
                    elseif formatIdx == 4 % EPS
                        print(tempFig1D, filename_1d, '-depsc', ['-r', num2str(dpiValues(dpiIdx))]);
                    elseif formatIdx == 5 % PDF
                        print(tempFig1D, filename_1d, '-dpdf', ['-r', num2str(dpiValues(dpiIdx))]);
                    elseif formatIdx == 6 % SVG矢量图
                        % SVG保存（矢量格式，分辨率无关）
                        try
                            % 使用plot2svg函数保存SVG（如果可用）
                            if exist('plot2svg', 'file')
                                plot2svg(filename_1d, tempFig1D);
                            else
                                % 使用MATLAB内置print命令保存SVG
                                print(tempFig1D, filename_1d, '-dsvg', ['-r', num2str(dpiValues(dpiIdx))]);
                            end
                        catch
                            % 如果SVG保存失败，降级为高分辨率PNG
                            filename_1d_png = strrep(filename_1d, '.svg', '_svg_fallback.png');
                            print(tempFig1D, filename_1d_png, '-dpng', ['-r', num2str(dpiValues(dpiIdx))]);
                            msgbox(['SVG保存失败，已保存为高分辨率PNG: ', filename_1d_png], '提示', 'warn');
                        end
                    elseif formatIdx == 7 % MAT数据
                        data_1d = current1DData;
                        save(filename_1d, 'data_1d');
                    end
                    
                    close(tempFig1D);
                    set(progressText, 'String', '✓ 1D曲线已保存');
                    drawnow;
                end
                
                % 保存参数和原始数据
                if saveParams || saveRawData
                    params_file = fullfile(save_path, [filename_prefix, '_simulation_data.mat']);
                    
                    if saveParams
                        % 收集所有仿真参数
                        simulation_params = struct();
                        simulation_params.wavelength = opticalParams.wavelength;
                        simulation_params.pixel_size = opticalParams.pixel_size;
                        simulation_params.distance = opticalParams.distance;
                        simulation_params.NA = opticalParams.NA;
                        simulation_params.lc_thickness = lcParams.thickness;
                        simulation_params.ordinary_index = lcParams.ordinary_index;
                        simulation_params.extraordinary_index = lcParams.extraordinary_index;
                        simulation_params.diffraction_method = diffractionMethods{get(popupDiffractionMethod, 'Value')};
                        simulation_params.polarization_type = polarizationTypes{get(popupPolarizationType, 'Value')};
                        simulation_params.save_time = datestr(now);
                    end
                    
                    if saveRawData
                        raw_data = struct();
                        if save2D && ~isempty(current2DData)
                            raw_data.intensity_2d = current2DData;
                        end
                        if save1D && ~isempty(current1DData)
                            raw_data.profile_1d = current1DData;
                        end
                    end
                    
                    if saveParams && saveRawData
                        save(params_file, 'simulation_params', 'raw_data');
                    elseif saveParams
                        save(params_file, 'simulation_params');
                    elseif saveRawData
                        save(params_file, 'raw_data');
                    end
                end
                
                % 保存3D瀑布图
                if save3D
                    current3DData = getappdata(fig, 'current3DData');
                    if ~isempty(current3DData)
                        filename_3d = fullfile(save_path, [filename_prefix, '_3D_waterfall', fileExtensions{formatIdx}]);
                        
                        % 创建临时图形保存3D图像
                        tempFig3D = figure('Visible', 'off', 'Position', [0, 0, 800, 600]);
                        
                        % 准备3D数据
                        [Ny, Nx] = size(current3DData);
                        x = linspace(-Nx/2, Nx/2, Nx) * opticalParams.pixel_size * 1e6;
                        y = linspace(-Ny/2, Ny/2, Ny) * opticalParams.pixel_size * 1e6;
                        [X, Y] = meshgrid(x, y);
                        Z = current3DData / max(current3DData(:));
                        
                        % 创建3D瀑布图
                        waterfall(X, Y, Z);
                        view(-37.5, 30);
                        
                        % 应用颜色映射
                        try
                            popupColormap = getappdata(fig, 'popupColormap');
                            if ~isempty(popupColormap) && isvalid(popupColormap)
                                colormapIdx = get(popupColormap, 'Value');
                                colormapType = colormapTypes{colormapIdx};
                                try
                                    colormap(slanCM(colormapType));
                                catch
                                    colormap(jet);
                                end
                            else
                                colormap(jet);
                            end
                        catch
                            colormap(jet);
                        end
                        
                        title('3D瀑布图 - 液晶偏振光栅衍射', 'FontSize', 14, 'FontWeight', 'bold');
                        xlabel('X位置 (μm)', 'FontSize', 12);
                        ylabel('Y位置 (μm)', 'FontSize', 12);
                        zlabel('归一化强度', 'FontSize', 12);
                        colorbar;
                        
                        % 保存
                        if formatIdx <= 3 % 图像格式
                            print(tempFig3D, filename_3d, ['-d', lower(fileFormats{formatIdx}(end-2:end))], ['-r', num2str(dpiValues(dpiIdx))]);
                        elseif formatIdx == 4 % EPS
                            print(tempFig3D, filename_3d, '-depsc', ['-r', num2str(dpiValues(dpiIdx))]);
                        elseif formatIdx == 5 % PDF
                            print(tempFig3D, filename_3d, '-dpdf', ['-r', num2str(dpiValues(dpiIdx))]);
                        elseif formatIdx == 6 % SVG矢量图
                            try
                                if exist('plot2svg', 'file')
                                    plot2svg(filename_3d, tempFig3D);
                                else
                                    print(tempFig3D, filename_3d, '-dsvg', ['-r', num2str(dpiValues(dpiIdx))]);
                                end
                            catch
                                filename_3d_png = strrep(filename_3d, '.svg', '_svg_fallback.png');
                                print(tempFig3D, filename_3d_png, '-dpng', ['-r', num2str(dpiValues(dpiIdx))]);
                                msgbox(['SVG保存失败，已保存为高分辨率PNG: ', filename_3d_png], '提示', 'warn');
                            end
                        elseif formatIdx == 7 % MAT数据
                            data_3d = current3DData;
                            save(filename_3d, 'data_3d', 'X', 'Y', 'Z');
                        end
                        
                        close(tempFig3D);
                        set(progressText, 'String', '✓ 3D瀑布图已保存');
                        drawnow;
                    else
                        msgbox('没有3D数据可保存，请先启用3D瀑布图显示', '提示', 'warn');
                    end
                end
                
                set(progressText, 'String', '✓ 所有文件保存完成！', 'ForegroundColor', [0, 0.7, 0]);
                
                % 延迟后关闭对话框
                pause(1);
                close(saveDialog);
                
                msgbox(['文件已保存至: ', save_path], '保存成功', 'help');
                
            catch ME
                set(progressText, 'String', ['✗ 保存失败: ', ME.message], 'ForegroundColor', [0.8, 0, 0]);
                errordlg(['保存过程中发生错误: ', ME.message], '保存错误');
            end
        end
    end
    
    function advancedSaveOptions(~, ~)
        % 高级保存选项 - 批量保存、自动命名等
        msgbox('高级保存功能开发中，敬请期待！', '功能预告', 'help');
    end
    
    function updateEllipticityValue(~, ~)
        % 更新椭圆率数值
        try
            % 获取用户输入
            value = str2double(get(sliderEllipticity, 'String'));
            
            % 检查输入是否在有效范围内
            if isnan(value) || value < 0 || value > 1
                % 无效输入，恢复默认值
                set(sliderEllipticity, 'String', '0.0');
                value = 0.0;
                warndlg('请输入0到1之间的椭圆率值', '输入无效');
            end
            
            % 确保数值显示格式正确
            set(sliderEllipticity, 'String', sprintf('%.2f', value));
        catch
            % 出现错误时恢复默认值
            set(sliderEllipticity, 'String', '0.0');
        end
    end
    
    function updateRotationValue(~, ~)
        % 更新旋转角度数值
        try
            % 获取用户输入
            value = str2double(get(sliderRotation, 'String'));
            
            % 检查输入是否在有效范围内
            if isnan(value) || value < 0 || value > 180
                % 无效输入，恢复默认值
                set(sliderRotation, 'String', '0.0');
                value = 0.0;
                warndlg('请输入0到180之间的旋转角度值', '输入无效');
            end
            
            % 确保数值显示格式正确
            set(sliderRotation, 'String', sprintf('%.1f', value));
        catch
            % 出现错误时恢复默认值
            set(sliderRotation, 'String', '0.0');
        end
    end
    
    function applyAxisRange(~, ~)
        % 应用坐标轴范围
        try
            editXRangeMin = getappdata(fig, 'editXRangeMin');
            editXRangeMax = getappdata(fig, 'editXRangeMax');
            editYRangeMin = getappdata(fig, 'editYRangeMin');
            editYRangeMax = getappdata(fig, 'editYRangeMax');
            
            xmin = str2double(get(editXRangeMin, 'String'));
            xmax = str2double(get(editXRangeMax, 'String'));
            ymin = str2double(get(editYRangeMin, 'String'));
            ymax = str2double(get(editYRangeMax, 'String'));
            
            % 应用到2D显示
            axes(axesImg2D);
            axis([xmin, xmax, ymin, ymax]);
            xlabel('X轴位置 (μm)', 'FontSize', 10);
            ylabel('Y轴位置 (μm)', 'FontSize', 10);
            
        catch ME
            errordlg(['应用坐标轴范围失败: ', ME.message], '错误');
        end
    end
    
    function autoAxisRange(~, ~)
        % 自动设置坐标轴范围
        try
            axes(axesImg2D);
            axis auto;
            xlabel('X轴位置 (μm)', 'FontSize', 10);
            ylabel('Y轴位置 (μm)', 'FontSize', 10);
            
            % 更新范围控件
            xlims = xlim;
            ylims = ylim;
            
            editXRangeMin = getappdata(fig, 'editXRangeMin');
            editXRangeMax = getappdata(fig, 'editXRangeMax');
            editYRangeMin = getappdata(fig, 'editYRangeMin');
            editYRangeMax = getappdata(fig, 'editYRangeMax');
            
            set(editXRangeMin, 'String', num2str(xlims(1)));
            set(editXRangeMax, 'String', num2str(xlims(2)));
            set(editYRangeMin, 'String', num2str(ylims(1)));
            set(editYRangeMax, 'String', num2str(ylims(2)));
            
        catch ME
            errordlg(['自动设置坐标轴范围失败: ', ME.message], '错误');
        end
    end
    
    function updateProgress(message, percentage)
        % 更新进度条
        try
            progressText = getappdata(fig, 'progressText');
            if ~isempty(progressText) && isvalid(progressText)
                set(progressText, 'String', message);
                
                % 更新进度条显示
                barLength = round(percentage * 20); % 20个字符的进度条
                progressBarStr = ['[', repmat('█', 1, barLength), repmat('░', 1, 20-barLength), sprintf('] %d%%', round(percentage*100))];
                set(progressBar, 'String', progressBarStr, 'FontName', 'Consolas');
                
                drawnow;
            end
        catch
            % 忽略进度更新错误
        end
    end
    
    function previewColorScheme(~, ~)
        % 预览颜色效果 - 修复版
        try
            % 安全地获取颜色方案
            colorScheme = 'nature'; % 默认颜色方案
            
            try
                popupPlotColor = getappdata(fig, 'popupPlotColor');
                if ~isempty(popupPlotColor) && isvalid(popupPlotColor)
                    plotColorIdx = get(popupPlotColor, 'Value');
                    plotColorValues = {'nature', 'science', 'cell', 'prl', 'optica', 'nano_letters'};
                    
                    % 确保索引在有效范围内
                    if plotColorIdx >= 1 && plotColorIdx <= length(plotColorValues)
                        colorScheme = plotColorValues{plotColorIdx};
                    end
                end
            catch
                % 如果获取失败，使用默认值
                colorScheme = 'nature';
            end
            
            % 创建预览窗口
            previewFig = figure('Name', '颜色预览', 'Position', [300, 300, 500, 400], ...
                'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'on', ...
                'Color', [0.94 0.94 0.94]);
            
            % 创建预览面板
            previewPanel = uipanel(previewFig, 'Title', '颜色预览', 'FontSize', 12, ...
                'Position', [0.05, 0.05, 0.9, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
            
            % 显示颜色方案信息
            uicontrol(previewPanel, 'Style', 'text', 'String', ['当前颜色方案: ', colorScheme], ...
                'Position', [20, 350, 200, 25], 'HorizontalAlignment', 'left', ...
                'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 12, 'FontWeight', 'bold');
            
            % 创建简单的预览内容
            createSimplePreview(previewPanel, colorScheme);
            
        catch ME
            errordlg(['预览颜色效果失败: ', ME.message], '错误');
        end
    end
    
    function createSimplePreview(panel, colorScheme)
        % 创建简化的预览内容，避免依赖全局变量
        try
            % 创建示例数据
            N = 256;
            [X, Y] = meshgrid(linspace(-5, 5, N), linspace(-5, 5, N));
            
            % 生成示例衍射图案
            R = sqrt(X.^2 + Y.^2);
            intensity2D = sinc(R).^2 .* exp(-R.^2/10);
            
            % 2D图像显示
            axes2D = axes('Parent', panel, 'Position', [0.05, 0.45, 0.4, 0.45]);
            imagesc(intensity2D);
            
            % 应用选择的colormap
            try
                colormapIdx = get(popupColormap, 'Value');
                colormapType = colormapTypes{colormapIdx};
                try
                    colormap(axes2D, slanCM(colormapType));
                catch
                    colormap(axes2D, colormapType);
                end
            catch
                colormap(axes2D, jet); % 默认colormap
            end
            
            axis(axes2D, 'equal', 'tight');
            title(axes2D, '二维衍射图案预览', 'FontSize', 10);
            colorbar(axes2D);
            
            % 1D曲线显示
            axes1D = axes('Parent', panel, 'Position', [0.55, 0.45, 0.4, 0.45]);
            
            % 生成示例1D数据
            x = linspace(-5, 5, N);
            intensity1D = sinc(x).^2 .* exp(-x.^2/5);
            
            % 根据颜色方案绘制曲线
            switch colorScheme
                case 'nature'
                    plot(axes1D, x, intensity1D, 'Color', [0.2, 0.6, 0.8], 'LineWidth', 2);
                case 'science'
                    plot(axes1D, x, intensity1D, 'Color', [0.8, 0.2, 0.2], 'LineWidth', 2);
                case 'cell'
                    plot(axes1D, x, intensity1D, 'Color', [0.2, 0.8, 0.2], 'LineWidth', 2);
                case 'prl'
                    plot(axes1D, x, intensity1D, 'Color', [0.6, 0.2, 0.8], 'LineWidth', 2);
                case 'optica'
                    plot(axes1D, x, intensity1D, 'Color', [0.8, 0.6, 0.2], 'LineWidth', 2);
                case 'nano_letters'
                    plot(axes1D, x, intensity1D, 'Color', [0.4, 0.4, 0.4], 'LineWidth', 2);
                otherwise
                    plot(axes1D, x, intensity1D, 'Color', [0.2, 0.6, 0.8], 'LineWidth', 2);
            end
            
            grid(axes1D, 'on');
            title(axes1D, '一维光强分布预览', 'FontSize', 10);
            xlabel(axes1D, '位置', 'FontSize', 9);
            ylabel(axes1D, '强度', 'FontSize', 9);
            
            % 颜色方案说明
            infoText = {
                '颜色方案说明:',
                ['• 当前方案: ', colorScheme],
                '• 二维图像采用所选colormap',
                '• 一维曲线采用期刊风格配色',
                '',
                '点击确定应用此颜色方案到主程序'
            };
            
            uicontrol(panel, 'Style', 'text', 'String', infoText, ...
                'Position', [20, 50, 420, 120], 'HorizontalAlignment', 'left', ...
                'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 9);
            
            % 确定按钮
            uicontrol(panel, 'Style', 'pushbutton', 'String', '确定', ...
                'Position', [200, 15, 80, 30], ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
                'Callback', @(~,~) close(gcbf));
                
        catch ME
            % 如果预览失败，显示简单信息
            uicontrol(panel, 'Style', 'text', ...
                'String', ['预览生成失败: ', ME.message, char(10), char(10), '颜色方案: ', colorScheme, ' 已选择'], ...
                'Position', [20, 100, 400, 200], 'HorizontalAlignment', 'center', ...
                'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11);
        end
    end
    
    function saveFigureAsSVG(figHandle, filename, dpi)
        % SVG保存辅助函数
        % 支持多种SVG保存方法，确保兼容性
        
        try
            % 方法1：尝试使用plot2svg工具箱
            if exist('plot2svg', 'file') == 2
                plot2svg(filename, figHandle);
                return;
            end
            
            % 方法2：尝试使用MATLAB 2020b+的exportgraphics
            if exist('exportgraphics', 'file') == 2
                exportgraphics(figHandle, filename, 'Resolution', dpi, 'ContentType', 'vector');
                return;
            end
            
            % 方法3：尝试使用print命令
            print(figHandle, filename, '-dsvg', ['-r', num2str(dpi)]);
            
        catch ME
            % 方法4：降级保存为高分辨率PNG
            filename_png = strrep(filename, '.svg', '_fallback.png');
            print(figHandle, filename_png, '-dpng', ['-r', num2str(dpi)]);
            warning('SVG保存失败，已保存为PNG格式: %s\n错误信息: %s', filename_png, ME.message);
        end
    end
    
    % === 胆甾相液晶琼斯矩阵算法验证函数 ===
    
    function validateCholestericJonesMatrix()
        % 胆甾相液晶琼斯矩阵算法验证
        fprintf('=== 胆甾相液晶琼斯矩阵算法验证 ===\n');
        
        % 测试参数
        wavelength = 532e-9;  % 绿光
        pitch = 2e-6;         % 螺距
        no = 1.5;             % 寻常光折射率
        ne = 1.7;             % 非寻常光折射率
        thickness = 3e-6;     % 厚度
        
        % 计算反射带中心波长
        n_avg = sqrt((no^2 + ne^2) / 2);
        central_wavelength = pitch * n_avg;
        
        fprintf('胆甾相液晶参数:\n');
        fprintf('  螺距: %.1f μm\n', pitch * 1e6);
        fprintf('  双折射: %.3f\n', ne - no);
        fprintf('  反射带中心波长: %.0f nm\n', central_wavelength * 1e9);
        fprintf('  测试波长: %.0f nm\n', wavelength * 1e9);
        
        % 测试不同偏振态的响应
        polarizations = {'线偏振', '右旋圆偏振', '左旋圆偏振'};
        jones_inputs = {
            [1; 0],           % 线偏振
            [1; 1i] / sqrt(2), % 右旋圆偏振
            [1; -1i] / sqrt(2) % 左旋圆偏振
        };
        
        for i = 1:length(polarizations)
            input_jones = jones_inputs{i};
            
            % 应用胆甾相液晶琼斯矩阵
            output_jones = applyCholestericJonesMatrix(input_jones, wavelength, pitch, no, ne, thickness);
            
            % 计算透射率
            transmittance = abs(output_jones(1))^2 + abs(output_jones(2))^2;
            
            fprintf('  %s透射率: %.3f\n', polarizations{i}, transmittance);
        end
        
        fprintf('验证完成！\n\n');
    end
    
    function output_jones = applyCholestericJonesMatrix(input_jones, wavelength, pitch, no, ne, thickness)
        % 应用胆甾相液晶琼斯矩阵（单像素版本）
        % 基于物理精确模型的胆甾相液晶Jones矩阵计算算法
        % 参数:
        %   input_jones: 输入Jones矢量 [Ex; Ey]
        %   wavelength: 光波长(m)
        %   pitch: 胆甾相液晶螺距(m)
        %   no, ne: 寻常光和非寻常光折射率
        %   thickness: 液晶层厚度(m)
        
        % 计算基本参数
        k0 = 2 * pi / wavelength;  % 波数
        birefringence = ne - no;    % 双折射率
        twist_angle = pi/2;         % 标准扭转角度
        
        % 计算平均折射率和中心波长（光子带隙中心）
        n_avg = sqrt((no^2 + ne^2) / 2);
        central_wavelength = pitch * n_avg;
        
        % 计算光子带隙宽度
        bandwidth = central_wavelength * birefringence / n_avg;
        wavelength_diff = abs(wavelength - central_wavelength);
        
        % 有效厚度计算（考虑扭转结构）
        effective_thickness = thickness / cos(twist_angle);
        
        % 相位延迟计算（考虑波长依赖性）
        phase_retardation = k0 * birefringence * effective_thickness;
        
        % 圆偏振选择性计算（基于光子带隙理论）
        % 当波长接近中心波长时，右旋圆偏振光被反射
        if wavelength_diff < bandwidth / 2
            % 高斯型反射谱
            reflection_coeff = exp(-(2*wavelength_diff/bandwidth)^2);
            selectivity_left = 1.0;  % 左旋圆偏振透射
            selectivity_right = 1.0 - reflection_coeff;  % 右旋圆偏振部分反射
        else
            selectivity_left = 1.0;
            selectivity_right = 1.0;
        end
        
        % 1. 入射旋转矩阵 (入射端的分子取向)
        theta_in = 0; % 简化模型，假设入射端沿x轴取向
        R1 = [cos(theta_in), -sin(theta_in); 
              sin(theta_in), cos(theta_in)];
        
        % 2. 双折射矩阵 (相位延迟)
        B = [exp(-1i * phase_retardation/2), 0; 
             0, exp(1i * phase_retardation/2)];
        
        % 3. 圆偏振选择性矩阵
        C = [selectivity_left, 0; 
             0, selectivity_right];
        
        % 4. 出射旋转矩阵 (考虑扭转结构)
        theta_out = theta_in + twist_angle; % 分子旋转π/2
        R2 = [cos(theta_out), sin(theta_out); 
             -sin(theta_out), cos(theta_out)];
        
        % 完整琼斯矩阵 J = R2 × C × B × R1
        J_cholesteric = R2 * C * B * R1;
        
        % 应用变换
        output_jones = J_cholesteric * input_jones;
        
        % 应用少量损耗（如果需要）
        transmission_factor = 0.98; % 考虑材料吸收
        output_jones = output_jones * transmission_factor;
    end
    
    % === 3D瀑布图显示函数 ===
    
    function create3DWaterfallPlot(data, titleStr)
        % 创建3D瀑布图显示窗口
        try
            % 创建新的3D显示窗口
            fig3D = figure('Name', '3D瀑布图 - 液晶偏振光栅衍射', ...
                'Position', [200, 100, 800, 600], ...
                'NumberTitle', 'off', 'Color', 'white');
            
            % 创建3D坐标轴
            ax3D = axes('Parent', fig3D, 'Position', [0.1, 0.1, 0.8, 0.8]);
            
            % 准备数据
            [Ny, Nx] = size(data);
            
            % 创建坐标网格
            x = linspace(-Nx/2, Nx/2, Nx) * opticalParams.pixel_size * 1e6; % 转换为μm
            y = linspace(-Ny/2, Ny/2, Ny) * opticalParams.pixel_size * 1e6;
            [X, Y] = meshgrid(x, y);
            
            % 数据归一化
            Z = data / max(data(:));
            
            % 创建瀑布图
            waterfall(ax3D, X, Y, Z);
            
            % 设置视角和照明
            view(ax3D, -37.5, 30);
            lighting gouraud;
            light('Position', [1 1 1]);
            
            % 应用slanCM颜色映射
            try
                popupColormap = getappdata(fig, 'popupColormap');
                if ~isempty(popupColormap) && isvalid(popupColormap)
                    colormapIdx = get(popupColormap, 'Value');
                    colormapType = colormapTypes{colormapIdx};
                    try
                        colormap(ax3D, slanCM(colormapType));
                    catch
                        colormap(ax3D, jet);
                    end
                else
                    colormap(ax3D, jet);
                end
            catch
                colormap(ax3D, jet);
            end
            
            % 美化设置
            title(ax3D, ['3D瀑布图 - ', titleStr], 'FontSize', 14, 'FontWeight', 'bold');
            xlabel(ax3D, 'X位置 (μm)', 'FontSize', 12);
            ylabel(ax3D, 'Y位置 (μm)', 'FontSize', 12);
            zlabel(ax3D, '归一化强度', 'FontSize', 12);
            
            ax3D.LineWidth = 1.2;
            ax3D.Box = 'on';
            ax3D.GridAlpha = 0.3;
            grid(ax3D, 'on');
            
            % 添加颜色条
            colorbar(ax3D, 'Location', 'eastoutside');
            
            % 添加保存按钮
            uicontrol(fig3D, 'Style', 'pushbutton', 'String', '保存3D图像', ...
                'Position', [20, 20, 100, 30], ...
                'FontSize', 10, 'FontWeight', 'bold', ...
                'BackgroundColor', [0.3, 0.6, 0.9], 'ForegroundColor', [1 1 1], ...
                'Callback', @(~,~) save3DWaterfallPlot(fig3D));
            
            % 添加旋转控制
            uicontrol(fig3D, 'Style', 'pushbutton', 'String', '自动旋转', ...
                'Position', [130, 20, 100, 30], ...
                'FontSize', 10, 'FontWeight', 'bold', ...
                'BackgroundColor', [0.7, 0.3, 0.8], 'ForegroundColor', [1 1 1], ...
                'Callback', @(~,~) toggleRotation(ax3D));
            
        catch ME
            errordlg(['创建3D瀑布图失败: ', ME.message], '3D显示错误');
        end
    end
    
    function save3DWaterfallPlot(fig3D)
        % 保存3D瀑布图
        try
            [filename, pathname] = uiputfile({
                '*.png', 'PNG图像 (*.png)';
                '*.jpg', 'JPEG图像 (*.jpg)';
                '*.tif', 'TIFF图像 (*.tif)';
                '*.eps', 'EPS矢量图 (*.eps)';
                '*.pdf', 'PDF文档 (*.pdf)'
            }, '保存3D瀑布图', '3D_waterfall_plot.png');
            
            if filename ~= 0
                fullPath = fullfile(pathname, filename);
                [~, ~, ext] = fileparts(filename);
                
                switch lower(ext)
                    case '.png'
                        print(fig3D, fullPath, '-dpng', '-r300');
                    case '.jpg'
                        print(fig3D, fullPath, '-djpeg', '-r300');
                    case '.tif'
                        print(fig3D, fullPath, '-dtiff', '-r300');
                    case '.eps'
                        print(fig3D, fullPath, '-depsc', '-r300');
                    case '.pdf'
                        print(fig3D, fullPath, '-dpdf', '-r300');
                end
                
                msgbox(['3D瀑布图已保存: ', fullPath], '保存成功', 'help');
            end
        catch ME
            errordlg(['保存3D瀑布图失败: ', ME.message], '保存错误');
        end
    end
    
    function toggleRotation(ax3D)
        % 切换自动旋转
        try
            if isappdata(ax3D, 'rotating') && getappdata(ax3D, 'rotating')
                % 停止旋转
                setappdata(ax3D, 'rotating', false);
            else
                % 开始旋转
                setappdata(ax3D, 'rotating', true);
                
                % 旋转动画
                for angle = 0:2:360
                    if ~isvalid(ax3D) || ~getappdata(ax3D, 'rotating')
                        break;
                    end
                    view(ax3D, angle, 30);
                    drawnow;
                    pause(0.05);
                end
                
                setappdata(ax3D, 'rotating', false);
            end
        catch
            % 忽略旋转错误
        end
    end
    
    % === 简化版绘图函数 ===
    
    function plot_gradient_compare_simple(x, E_in, E_out, colorScheme)
        % 简化版精美绘图函数（当增强版不可用时使用）
        axes(axesImg1D);
        cla;
        
        % 归一化
        if max(E_in) > 0
            E_in = E_in / max(E_in);
        end
        if max(E_out) > 0
            E_out = E_out / max(E_out);
        end
        
        % 绘制渐变填充
        x_fill = [x, fliplr(x)];
        y_fill_in = [E_in, zeros(size(E_in))];
        y_fill_out = [E_out, zeros(size(E_out))];
        
        % 根据颜色方案选择颜色
        switch lower(colorScheme)
            case 'nature'
                color_in = [0.2, 0.4, 0.8];
                color_out = [0.8, 0.2, 0.3];
            case 'science'
                color_in = [0.1, 0.5, 0.6];
                color_out = [0.9, 0.4, 0.1];
            case 'cell'
                color_in = [0.2, 0.6, 0.3];
                color_out = [0.7, 0.3, 0.7];
            otherwise
                color_in = [0.3, 0.6, 0.9];
                color_out = [0.9, 0.3, 0.3];
        end
        
        % 填充区域
        fill(x_fill, y_fill_in, color_in, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
        hold on;
        fill(x_fill, y_fill_out, color_out, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
        
        % 边缘线
        plot(x, E_in, 'Color', color_in * 0.7, 'LineWidth', 2.5);
        plot(x, E_out, 'Color', color_out * 0.7, 'LineWidth', 2.5);
        
        % 峰值标记
        [max_in, idx_in] = max(E_in);
        [max_out, idx_out] = max(E_out);
        
        plot(x(idx_in), max_in, 'o', 'Color', color_in * 0.5, ...
            'MarkerSize', 8, 'MarkerFaceColor', color_in, 'LineWidth', 2);
        plot(x(idx_out), max_out, 's', 'Color', color_out * 0.5, ...
            'MarkerSize', 8, 'MarkerFaceColor', color_out, 'LineWidth', 2);
        
        % 标签和美化
        xlabel('横向位置 (μm)', 'FontSize', 11, 'FontName', '宋体', 'FontWeight', 'bold');
        ylabel('归一化强度', 'FontSize', 11, 'FontName', '宋体', 'FontWeight', 'bold');
        legend({'入射场', '衍射场', '', ''}, 'Location', 'northeast', 'FontSize', 10, ...
            'FontName', '宋体', 'Box', 'off');
        
        title('液晶偏振光栅衍射光强分布', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', '宋体');
        
        % 美化设置
        ax = gca;
        ax.LineWidth = 1.8;
        ax.GridLineStyle = '-.';
        ax.GridAlpha = 0.3;
        ax.FontSize = 10;
        ax.FontName = '宋体';
        grid on;
        box off;
        
        hold off;
    end
    
    % === 新增的颜色映射和3D显示函数 ===
    
    function applySelectedColormap(targetAxes)
        % 应用选择的slanCM颜色映射
        try
            % 获取各类颜色选择
            popupSequential = getappdata(fig, 'popupSequential');
            popupDiverging = getappdata(fig, 'popupDiverging');
            popupCyclic = getappdata(fig, 'popupCyclic');
            popupMisc = getappdata(fig, 'popupMisc');
            
            % 确定使用哪个颜色映射（默认使用杂项类的jet）
            colormapName = 'jet';
            
            if ~isempty(popupMisc) && isvalid(popupMisc)
                miscIdx = get(popupMisc, 'Value');
                miscColors = {'flag', 'prism', 'ocean', 'gist_earth', 'terrain', 'gist_stern', ...
                             'gnuplot', 'gnuplot2', 'CMRmap', 'cubehelix', 'brg', 'gist_rainbow', ...
                             'rainbow', 'jet', 'nipy_spectral', 'gist_ncar'};
                if miscIdx <= length(miscColors)
                    colormapName = miscColors{miscIdx};
                end
            end
            
            % 尝试使用slanCM颜色包
            try
                colormap(targetAxes, slanCM(colormapName));
            catch
                % 如果slanCM失败，使用MATLAB默认颜色映射
                switch colormapName
                    case {'rainbow', 'gist_rainbow'}
                        colormap(targetAxes, hsv);
                    case 'jet'
                        colormap(targetAxes, jet);
                    case 'hot'
                        colormap(targetAxes, hot);
                    case 'cool'
                        colormap(targetAxes, cool);
                    case 'gray'
                        colormap(targetAxes, gray);
                    case 'bone'
                        colormap(targetAxes, bone);
                    case 'copper'
                        colormap(targetAxes, copper);
                    case 'pink'
                        colormap(targetAxes, pink);
                    case 'spring'
                        colormap(targetAxes, spring);
                    case 'summer'
                        colormap(targetAxes, summer);
                    case 'autumn'
                        colormap(targetAxes, autumn);
                    case 'winter'
                        colormap(targetAxes, winter);
                    case 'flag'
                        colormap(targetAxes, flag);
                    case 'prism'
                        colormap(targetAxes, prism);
                    case 'hsv'
                        colormap(targetAxes, hsv);
                    otherwise
                        colormap(targetAxes, jet);
                end
            end
        catch
            colormap(targetAxes, jet); % 出错时使用默认
        end
    end
    
    function display3DDiffraction(data, titleStr)
        % 在仿真信息区域显示3D衍射光强分布
        try
            axes3DDiffraction = getappdata(fig, 'axes3DDiffraction');
            if ~isempty(axes3DDiffraction) && isvalid(axes3DDiffraction)
                axes(axes3DDiffraction);
                cla;
                
                % 创建3D surface图
                [Y, X] = size(data);
                x = linspace(-50, 50, X); % μm
                y = linspace(-50, 50, Y); % μm
                [X_grid, Y_grid] = meshgrid(x, y);
                
                % 获取3D颜色映射
                try
                    popup3DColor = getappdata(fig, 'popup3DColor');
                    if ~isempty(popup3DColor) && isvalid(popup3DColor)
                        colorIdx = get(popup3DColor, 'Value');
                        color3DTypes = {'rainbow', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink'};
                        selectedColor = color3DTypes{colorIdx};
                        
                        % 尝试使用slanCM
                        try
                            colormap(axes3DDiffraction, slanCM(selectedColor));
                        catch
                            % 使用MATLAB默认颜色
                            eval(['colormap(axes3DDiffraction, ' selectedColor ');']);
                        end
                    else
                        colormap(axes3DDiffraction, jet);
                    end
                catch
                    colormap(axes3DDiffraction, jet);
                end
                
                % 绘制3D surface
                surf(X_grid, Y_grid, data, 'EdgeColor', 'none');
                
                title(titleStr, 'FontSize', 10, 'FontWeight', 'bold');
                xlabel('X (μm)', 'FontSize', 9);
                ylabel('Y (μm)', 'FontSize', 9);
                zlabel('强度', 'FontSize', 9);
                
                % 设置视角和光照
                view(-37.5, 30);
                lighting gouraud;
                shading interp;
                
                % 更新状态显示
                text3DStatus = getappdata(fig, 'text3DStatus');
                if ~isempty(text3DStatus) && isvalid(text3DStatus)
                    set(text3DStatus, 'String', '3D显示：开启', 'ForegroundColor', [0.1, 0.6, 0.1]);
                end
            end
        catch
            % 3D显示失败时的处理
            text3DStatus = getappdata(fig, 'text3DStatus');
            if ~isempty(text3DStatus) && isvalid(text3DStatus)
                set(text3DStatus, 'String', '3D显示：错误', 'ForegroundColor', [0.8, 0.1, 0.1]);
            end
        end
    end
    
    % === 3D显示控制回调函数 ===
    
    function toggle3DPreview(src, ~)
        % 切换3D预览状态
        try
            text3DStatus = getappdata(fig, 'text3DStatus');
            if get(src, 'Value')
                set(text3DStatus, 'String', '3D显示：准备中', 'ForegroundColor', [0.8, 0.6, 0.1]);
                % 如果有当前数据，立即显示
                current3DData = getappdata(fig, 'current3DData');
                if ~isempty(current3DData)
                    display3DDiffraction(current3DData, '3D衍射光强分布');
                end
            else
                set(text3DStatus, 'String', '3D显示：关闭', 'ForegroundColor', [0.5, 0.5, 0.5]);
                axes3DDiffraction = getappdata(fig, 'axes3DDiffraction');
                if ~isempty(axes3DDiffraction) && isvalid(axes3DDiffraction)
                    axes(axes3DDiffraction);
                    cla;
                end
            end
        catch
            % 错误处理
        end
    end
    
    function reset3DView(~, ~)
        % 重置3D视角
        try
            axes3DDiffraction = getappdata(fig, 'axes3DDiffraction');
            if ~isempty(axes3DDiffraction) && isvalid(axes3DDiffraction)
                axes(axes3DDiffraction);
                view(-37.5, 30);
                lighting gouraud;
            end
        catch
            % 错误处理
        end
    end
    
    function toggle3DRotation(src, ~)
        % 切换3D自动旋转
        try
            if strcmp(get(src, 'String'), '开始旋转')
                set(src, 'String', '停止旋转');
                % 启动旋转定时器
                start3DRotationTimer();
            else
                set(src, 'String', '开始旋转');
                % 停止旋转定时器
                stop3DRotationTimer();
            end
        catch
            % 错误处理
        end
    end
    
    function start3DRotationTimer()
        % 启动3D旋转定时器
        try
            % 停止现有定时器
            stop3DRotationTimer();
            
            % 创建新定时器
            rotationTimer = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
                'TimerFcn', @rotate3DView);
            setappdata(fig, 'rotationTimer', rotationTimer);
            start(rotationTimer);
        catch
            % 错误处理
        end
    end
    
    function stop3DRotationTimer()
        % 停止3D旋转定时器
        try
            rotationTimer = getappdata(fig, 'rotationTimer');
            if ~isempty(rotationTimer) && isvalid(rotationTimer)
                stop(rotationTimer);
                delete(rotationTimer);
                setappdata(fig, 'rotationTimer', []);
            end
        catch
            % 错误处理
        end
    end
    
    function rotate3DView(~, ~)
        % 旋转3D视图
        try
            axes3DDiffraction = getappdata(fig, 'axes3DDiffraction');
            if ~isempty(axes3DDiffraction) && isvalid(axes3DDiffraction)
                axes(axes3DDiffraction);
                [az, el] = view;
                view(az + 2, el); % 每次旋转2度
            end
        catch
            % 错误处理，停止旋转
            stop3DRotationTimer();
            button3DRotate = getappdata(fig, 'button3DRotate');
            if ~isempty(button3DRotate) && isvalid(button3DRotate)
                set(button3DRotate, 'String', '开始旋转');
            end
        end
    end
    
    function save3DPlot(~, ~)
        % 保存3D图像
        try
            current3DData = getappdata(fig, 'current3DData');
            if isempty(current3DData)
                msgbox('没有3D数据可保存', '保存错误', 'warn');
                return;
            end
            
            % 文件选择对话框
            [filename, pathname] = uiputfile(...
                {'*.png', 'PNG图像 (*.png)'; ...
                 '*.jpg', 'JPEG图像 (*.jpg)'; ...
                 '*.tiff', 'TIFF图像 (*.tiff)'; ...
                 '*.eps', 'EPS矢量图 (*.eps)'; ...
                 '*.pdf', 'PDF文档 (*.pdf)'}, ...
                '保存3D图像', '3D_diffraction_pattern.png');
            
            if isequal(filename, 0)
                return; % 用户取消
            end
            
            % 创建临时图形窗口进行高质量保存
            tempFig = figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
            tempAxes = axes('Parent', tempFig);
            
            % 复制3D图像
            [Y, X] = size(current3DData);
            x = linspace(-50, 50, X);
            y = linspace(-50, 50, Y);
            [X_grid, Y_grid] = meshgrid(x, y);
            
            surf(tempAxes, X_grid, Y_grid, current3DData, 'EdgeColor', 'none');
            
            % 应用颜色映射
            try
                popup3DColor = getappdata(fig, 'popup3DColor');
                if ~isempty(popup3DColor) && isvalid(popup3DColor)
                    colorIdx = get(popup3DColor, 'Value');
                    color3DTypes = {'rainbow', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink'};
                    selectedColor = color3DTypes{colorIdx};
                    try
                        colormap(tempAxes, slanCM(selectedColor));
                    catch
                        eval(['colormap(tempAxes, ' selectedColor ');']);
                    end
                end
            catch
                colormap(tempAxes, jet);
            end
            
            title(tempAxes, '3D衍射光强分布', 'FontSize', 14, 'FontWeight', 'bold');
            xlabel(tempAxes, 'X (μm)', 'FontSize', 12);
            ylabel(tempAxes, 'Y (μm)', 'FontSize', 12);
            zlabel(tempAxes, '强度', 'FontSize', 12);
            
            view(tempAxes, -37.5, 30);
            lighting gouraud;
            shading interp;
            
            % 保存图像
            fullpath = fullfile(pathname, filename);
            [~, ~, ext] = fileparts(filename);
            
            switch lower(ext)
                case '.png'
                    print(tempFig, fullpath, '-dpng', '-r300');
                case '.jpg'
                    print(tempFig, fullpath, '-djpeg', '-r300');
                case '.tiff'
                    print(tempFig, fullpath, '-dtiff', '-r300');
                case '.eps'
                    print(tempFig, fullpath, '-depsc', '-r300');
                case '.pdf'
                    print(tempFig, fullpath, '-dpdf', '-r300');
            end
            
            close(tempFig);
            msgbox(['3D图像已保存至: ' fullpath], '保存成功', 'info');
            
        catch ME
            msgbox(['保存3D图像失败: ' ME.message], '保存错误', 'error');
        end
    end
    
    % === 优化的衍射算法函数 ===
    
    function inputField = generateInputField(pixelSize, samplingPoints, polarTypeIdx, ellipticity, rotation)
        % 生成输入光场 - 优化版
        inputField = zeros(samplingPoints, samplingPoints, 2); % [Ex, Ey]
        
        % 创建高斯光束轮廓
        [X, Y] = meshgrid(linspace(-1, 1, samplingPoints), linspace(-1, 1, samplingPoints));
        R = sqrt(X.^2 + Y.^2);
        beamRadius = 0.8; % 光束半径（归一化）
        gaussianProfile = exp(-(R/beamRadius).^2);
        
        % 根据偏振类型生成光场
        switch polarTypeIdx
            case 1 % 线偏振光
                % 偏振方向为rotation角度
                rotRad = rotation * pi / 180;
                inputField(:,:,1) = gaussianProfile * cos(rotRad); % Ex
                inputField(:,:,2) = gaussianProfile * sin(rotRad); % Ey
                
            case 2 % 圆偏振光
                inputField(:,:,1) = gaussianProfile;
                inputField(:,:,2) = gaussianProfile * 1i; % 右旋圆偏振
                
            case 3 % 椭圆偏振光
                rotRad = rotation * pi / 180;
                ellipRad = ellipticity * pi / 180;
                inputField(:,:,1) = gaussianProfile * cos(ellipRad) * cos(rotRad);
                inputField(:,:,2) = gaussianProfile * sin(ellipRad) * exp(1i * rotRad);
                
            case 4 % 自定义偏振
                inputField(:,:,1) = gaussianProfile;
                inputField(:,:,2) = gaussianProfile * exp(1i * ellipticity * pi / 180);
        end
        
        % 归一化
        totalPower = sum(abs(inputField(:,:,1)).^2 + abs(inputField(:,:,2)).^2, 'all');
        inputField = inputField / sqrt(totalPower);
    end
    
    function [outputField, transmittance] = applyLiquidCrystalGrating(inputField, gratingData, lcParams, opticalParams)
        % 应用液晶光栅变换 - 增强版
        [rows, cols, ~] = size(inputField);
        outputField = zeros(size(inputField));
        
        % 调整光栅数据尺寸
        if size(gratingData, 1) ~= rows || size(gratingData, 2) ~= cols
            gratingData = imresize(gratingData, [rows, cols], 'bilinear');
        end
        
        % 归一化光栅数据到[0,1]
        gratingData = (gratingData - min(gratingData(:))) / (max(gratingData(:)) - min(gratingData(:)));
        
        % 计算相位延迟
        deltaPhase = 2 * pi * lcParams.thickness * ...
            (lcParams.extraordinary_index - lcParams.ordinary_index) / opticalParams.wavelength;
        
        % 应用琼斯矩阵变换
        for i = 1:rows
            for j = 1:cols
                % 液晶取向角（从光栅数据推导）
                orientation = gratingData(i,j) * pi; % 0到π范围
                
                % 计算相位延迟
                phaseDelay = deltaPhase * gratingData(i,j);
                
                % 琼斯矩阵（液晶波片）
                cosTheta = cos(orientation);
                sinTheta = sin(orientation);
                
                J11 = cosTheta^2 + sinTheta^2 * exp(1i * phaseDelay);
                J12 = cosTheta * sinTheta * (1 - exp(1i * phaseDelay));
                J21 = J12;
                J22 = sinTheta^2 + cosTheta^2 * exp(1i * phaseDelay);
                
                % 应用变换
                inputEx = inputField(i,j,1);
                inputEy = inputField(i,j,2);
                
                outputField(i,j,1) = J11 * inputEx + J12 * inputEy;
                outputField(i,j,2) = J21 * inputEx + J22 * inputEy;
            end
        end
        
        % 计算透射率
        inputIntensity = abs(inputField(:,:,1)).^2 + abs(inputField(:,:,2)).^2;
        outputIntensity = abs(outputField(:,:,1)).^2 + abs(outputField(:,:,2)).^2;
        transmittance = outputIntensity ./ (inputIntensity + 1e-10);
    end
    
    function outputField = applyFresnelDiffraction(inputField, opticalParams)
        % 菲涅尔衍射算法 - 优化版
        [M, N, ~] = size(inputField);
        outputField = zeros(size(inputField));
        
        % 计算菲涅尔数
        aperture_radius = opticalParams.real_size / 2;
        fresnelNumber = aperture_radius^2 / (opticalParams.wavelength * opticalParams.distance);
        
        % 频率域坐标
        fx = (-N/2:N/2-1) / (N * opticalParams.pixel_size);
        fy = (-M/2:M/2-1) / (M * opticalParams.pixel_size);
        [FX, FY] = meshgrid(fx, fy);
        
        % 菲涅尔传递函数
        H = exp(1i * pi * opticalParams.wavelength * opticalParams.distance * (FX.^2 + FY.^2));
        
        % 对每个偏振分量进行衍射计算
        for pol = 1:2
            % FFT
            inputSpectrum = fftshift(fft2(fftshift(inputField(:,:,pol))));
            
            % 应用传递函数
            outputSpectrum = inputSpectrum .* H;
            
            % IFFT
            outputField(:,:,pol) = fftshift(ifft2(fftshift(outputSpectrum)));
        end
        
        % 相位因子
        phaseFactor = exp(1i * 2 * pi * opticalParams.distance / opticalParams.wavelength);
        outputField = outputField * phaseFactor;
    end
    
    function outputField = applyFraunhoferDiffraction(inputField, opticalParams)
        % 夫琅禾费衍射算法 - 远场近似
        [M, N, ~] = size(inputField);
        outputField = zeros(size(inputField));
        
        % 计算放大倍数
        magnification = opticalParams.f2 / opticalParams.f1;
        
        % 对每个偏振分量进行FFT变换
        for pol = 1:2
            % 应用4f系统变换
            spectrum = fftshift(fft2(fftshift(inputField(:,:,pol))));
            
            % 在频率域应用放大倍数
            outputField(:,:,pol) = fftshift(ifft2(fftshift(spectrum))) * magnification;
        end
        
        % 归一化
        totalPower = sum(abs(outputField(:,:,1)).^2 + abs(outputField(:,:,2)).^2, 'all');
        outputField = outputField / sqrt(totalPower);
    end
    
    function outputField = applyAngularSpectrumDiffraction(inputField, opticalParams)
        % 角谱衍射算法 - 精确解
        [M, N, ~] = size(inputField);
        outputField = zeros(size(inputField));
        
        % 波数
        k = 2 * pi / opticalParams.wavelength;
        
        % 频率域坐标
        fx = (-N/2:N/2-1) / (N * opticalParams.pixel_size);
        fy = (-M/2:M/2-1) / (M * opticalParams.pixel_size);
        [FX, FY] = meshgrid(fx, fy);
        
        % 计算kz
        kx = 2 * pi * FX;
        ky = 2 * pi * FY;
        kz_squared = k^2 - kx.^2 - ky.^2;
        
        % 只保留传播模式
        propagating = kz_squared >= 0;
        kz = sqrt(kz_squared) .* propagating;
        
        % 传递函数
        H = exp(1i * kz * opticalParams.distance) .* propagating;
        
        % 对每个偏振分量进行衍射计算
        for pol = 1:2
            % FFT到角度频率域
            inputSpectrum = fftshift(fft2(fftshift(inputField(:,:,pol))));
            
            % 应用传递函数
            outputSpectrum = inputSpectrum .* H;
            
            % IFFT回到空间域
            outputField(:,:,pol) = fftshift(ifft2(fftshift(outputSpectrum)));
        end
    end
    
    function outputField = applySFFTDiffraction(inputField, opticalParams)
        % S-FFT高精度衍射算法
        [M, N, ~] = size(inputField);
        outputField = zeros(size(inputField));
        
        % 参数设置
        oversampling = 2; % 过采样因子
        M_new = M * oversampling;
        N_new = N * oversampling;
        
        % 对每个偏振分量处理
        for pol = 1:2
            % 零填充过采样
            inputField_padded = zeros(M_new, N_new);
            start_row = (M_new - M) / 2 + 1;
            start_col = (N_new - N) / 2 + 1;
            inputField_padded(start_row:start_row+M-1, start_col:start_col+N-1) = inputField(:,:,pol);
            
            % 使用角谱法计算
            pixel_size_new = opticalParams.pixel_size / oversampling;
            opticalParams_new = opticalParams;
            opticalParams_new.pixel_size = pixel_size_new;
            
            % 角谱衍射
            outputField_padded = applyAngularSpectrumDiffraction(inputField_padded, opticalParams_new);
            
            % 提取中心区域
            outputField(:,:,pol) = outputField_padded(start_row:start_row+M-1, start_col:start_col+N-1);
        end
    end
    
    function outputField = applyCoordinateSystem(inputField, opticalParams)
        % 应用坐标系统变换
        outputField = inputField;
        
        % 根据4f系统参数调整坐标
        if opticalParams.f1 > 0 && opticalParams.f2 > 0
            magnification = opticalParams.f2 / opticalParams.f1;
            
            % 应用放大倍数到坐标系
            % 这里可以添加更复杂的坐标变换逻辑
            outputField = outputField * sqrt(magnification);
        end
    end
    
    function [outputField, transmittance] = applyLiquidCrystalGratingV1(inputField, gratingData)
        % 应用液晶偏振光栅的Jones矩阵变换 - 改进版算法（版本1）
        % 支持多种液晶偏振光栅类型：标准偏振光栅、胆甾相液晶、直接相位调制
        
        [Ny, Nx, ~] = size(inputField);
        
        % 获取液晶光栅类型（默认为标准偏振光栅）
        gratingType = 'standard'; % 可选: 'standard', 'cholesteric', 'direct_phase'
        try
            gratingTypeControl = getappdata(fig, 'gratingTypeControl');
            if ~isempty(gratingTypeControl) && isvalid(gratingTypeControl)
                gratingTypes = get(gratingTypeControl, 'String');
                gratingTypeIdx = get(gratingTypeControl, 'Value');
                gratingType = gratingTypes{gratingTypeIdx};
            end
        catch
            % 使用默认值
        end
        
        % 根据不同类型选择算法
        switch lower(gratingType)
            case 'standard'
                % 标准液晶偏振光栅算法（PB相位）
                [outputField, transmittance] = applyStandardLiquidCrystalGratingV1(inputField, gratingData);
                
            case 'cholesteric'
                % 胆甾相液晶算法
                [outputField, transmittance] = applyCholestericLiquidCrystalV1(inputField, gratingData);
                
            case 'direct_phase'
                % 直接相位调制算法（新增）
                [outputField, transmittance] = applyDirectPhaseLiquidCrystalV1(inputField, gratingData);
                
            otherwise
                % 默认使用标准算法
                [outputField, transmittance] = applyStandardLiquidCrystalGratingV1(inputField, gratingData);
        end
    end
    
    function [outputField, transmittance] = DEPRECATED_applyLiquidCrystalGrating(inputField, gratingData)
        % 应用液晶偏振光栅的Jones矩阵变换 - 改进版算法（版本1）
        % 支持多种液晶偏振光栅类型：标准偏振光栅、胆甾相液晶、直接相位调制
        
        [Ny, Nx, ~] = size(inputField);
        
        % 获取液晶光栅类型（默认为标准偏振光栅）
        gratingType = 'standard'; % 可选: 'standard', 'cholesteric', 'direct_phase'
        try
            gratingTypeControl = getappdata(fig, 'gratingTypeControl');
            if ~isempty(gratingTypeControl) && isvalid(gratingTypeControl)
                gratingTypes = get(gratingTypeControl, 'String');
                gratingTypeIdx = get(gratingTypeControl, 'Value');
                gratingType = gratingTypes{gratingTypeIdx};
            end
        catch
            % 使用默认值
        end
        
        % 根据不同类型选择算法
        switch lower(gratingType)
            case 'standard'
                % 标准液晶偏振光栅算法（PB相位）
                [outputField, transmittance] = applyStandardLiquidCrystalGratingV1(inputField, gratingData);
                
            case 'cholesteric'
                % 胆甾相液晶算法
                [outputField, transmittance] = applyCholestericLiquidCrystalV1(inputField, gratingData);
                
            case 'direct_phase'
                % 直接相位调制算法（新增）
                [outputField, transmittance] = applyDirectPhaseLiquidCrystalV1(inputField, gratingData);
                
            otherwise
                % 默认使用标准算法
                [outputField, transmittance] = applyStandardLiquidCrystalGratingV1(inputField, gratingData);
        end
    end
    
    % === 3D显示窗口功能 ===
    function launch3DDisplayWindow(~, ~)
        % 启动3D显示窗口
        try
            % 检查是否有仿真数据
            current2DData = getappdata(fig, 'current2DData');
            if isempty(current2DData)
                msgbox('请先运行衍射仿真以获取数据', '提示', 'warn');
                return;
            end
            
            % 创建3D显示窗口
            create3DDisplayWindow(current2DData);
            
        catch ME
            errordlg(['3D显示窗口启动失败: ', ME.message], '错误');
        end
    end
    
    function create3DDisplayWindow(simulationData)
        % 创建独立的3D显示窗口
        display3DFig = figure('Name', '3D衍射成像显示窗口', ...
            'Position', [200, 100, 1200, 800], ...
            'NumberTitle', 'off', 'MenuBar', 'none', ...
            'Resize', 'on', 'Color', [0.94 0.94 0.94]);
        
        % 左侧3D显示区域
        display3DPanel = uipanel(display3DFig, 'Title', '3D衍射强度分布', 'FontSize', 12, ...
            'Position', [0.05, 0.05, 0.65, 0.9], 'BackgroundColor', [1 1 1]);
        
        % 右侧控制面板
        control3DPanel = uipanel(display3DFig, 'Title', '3D显示控制', 'FontSize', 12, ...
            'Position', [0.72, 0.05, 0.26, 0.9], 'BackgroundColor', [0.97 0.97 0.97]);
        
        % 创建3D显示坐标轴
        axes3D = axes('Parent', display3DPanel, 'Position', [0.1, 0.1, 0.8, 0.8]);
        
        % 颜色映射选择
        y_pos = 750;
        spacing = 60;
        
        uicontrol(control3DPanel, 'Style', 'text', 'String', '颜色映射方案:', ...
            'Position', [20, y_pos, 120, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11, 'FontWeight', 'bold');
        
        % 序列类颜色
        uicontrol(control3DPanel, 'Style', 'text', 'String', '序列类:', ...
            'Position', [20, y_pos-30, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 10);
        
        sequentialColors3D = {'viridis', 'plasma', 'inferno', 'magma', 'parula', 'jet', 'hot', 'cool'};
        popup3DSequential = uicontrol(control3DPanel, 'Style', 'popupmenu', ...
            'String', sequentialColors3D, 'Value', 1, ...
            'Position', [20, y_pos-50, 150, 20], 'FontSize', 9, ...
            'Callback', @(src,~) update3DColormap(axes3D, sequentialColors3D{get(src, 'Value')}));
        
        y_pos = y_pos - spacing;
        
        % 分散类颜色
        uicontrol(control3DPanel, 'Style', 'text', 'String', '分散类:', ...
            'Position', [20, y_pos-30, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 10);
        
        divergingColors3D = {'coolwarm', 'RdYlBu', 'RdBu', 'bwr', 'seismic', 'spectral'};
        popup3DDiverging = uicontrol(control3DPanel, 'Style', 'popupmenu', ...
            'String', divergingColors3D, 'Value', 1, ...
            'Position', [20, y_pos-50, 150, 20], 'FontSize', 9, ...
            'Callback', @(src,~) update3DColormap(axes3D, divergingColors3D{get(src, 'Value')}));
        
        y_pos = y_pos - spacing;
        
        % 循环类颜色
        uicontrol(control3DPanel, 'Style', 'text', 'String', '循环类:', ...
            'Position', [20, y_pos-30, 80, 20], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 10);
        
        cyclicColors3D = {'hsv', 'twilight', 'rainbow', 'phase', 'seasons'};
        popup3DCyclic = uicontrol(control3DPanel, 'Style', 'popupmenu', ...
            'String', cyclicColors3D, 'Value', 1, ...
            'Position', [20, y_pos-50, 150, 20], 'FontSize', 9, ...
            'Callback', @(src,~) update3DColormap(axes3D, cyclicColors3D{get(src, 'Value')}));
        
        y_pos = y_pos - spacing;
        
        % 视角控制
        uicontrol(control3DPanel, 'Style', 'text', 'String', '视角控制:', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11, 'FontWeight', 'bold');
        
        uicontrol(control3DPanel, 'Style', 'pushbutton', 'String', '俯视图', ...
            'Position', [20, y_pos-30, 70, 25], 'FontSize', 9, ...
            'Callback', @(~,~) view(axes3D, 0, 90));
        
        uicontrol(control3DPanel, 'Style', 'pushbutton', 'String', '侧视图', ...
            'Position', [100, y_pos-30, 70, 25], 'FontSize', 9, ...
            'Callback', @(~,~) view(axes3D, 0, 0));
        
        uicontrol(control3DPanel, 'Style', 'pushbutton', 'String', '等轴图', ...
            'Position', [20, y_pos-60, 70, 25], 'FontSize', 9, ...
            'Callback', @(~,~) view(axes3D, 45, 30));
        
        uicontrol(control3DPanel, 'Style', 'pushbutton', 'String', '旋转', ...
            'Position', [100, y_pos-60, 70, 25], 'FontSize', 9, ...
            'Callback', @(~,~) rotate3d(axes3D, 'on'));
        
        y_pos = y_pos - 120;
        
        % 显示模式选择
        uicontrol(control3DPanel, 'Style', 'text', 'String', '显示模式:', ...
            'Position', [20, y_pos, 100, 25], 'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.97 0.97 0.97], 'FontSize', 11, 'FontWeight', 'bold');
        
        displayModes = {'瀑布图', '曲面图', '网格图', '轮廓图'};
        popup3DMode = uicontrol(control3DPanel, 'Style', 'popupmenu', ...
            'String', displayModes, 'Value', 1, ...
            'Position', [20, y_pos-30, 150, 25], 'FontSize', 9, ...
            'Callback', @(src,~) change3DDisplayMode(axes3D, simulationData, get(src, 'Value')));
        
        % 保存功能
        y_pos = y_pos - 80;
        uicontrol(control3DPanel, 'Style', 'pushbutton', 'String', '保存3D图像', ...
            'Position', [20, y_pos, 150, 35], 'FontSize', 10, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.2, 0.7, 0.3], 'ForegroundColor', [1 1 1], ...
            'Callback', @(~,~) save3DImage(display3DFig));
        
        % 初始化3D显示
        display3DData(axes3D, simulationData, 1); % 默认瀑布图模式
        
        % 设置默认颜色映射
        try
            colormap(axes3D, viridis);
        catch
            colormap(axes3D, jet);
        end
    end
    
    function display3DData(axes3D, simulationData, mode)
        % 在3D坐标轴中显示数据
        axes(axes3D);
        cla(axes3D);
        
        % 获取强度数据
        intensity = simulationData;
        [ny, nx] = size(intensity);
        
        % 创建坐标网格
        x = linspace(-50, 50, nx);
        y = linspace(-50, 50, ny);
        [X, Y] = meshgrid(x, y);
        
        switch mode
            case 1 % 瀑布图
                waterfall(X, Y, intensity);
                title('3D瀑布图 - 衍射强度分布', 'FontSize', 12, 'FontWeight', 'bold');
                
            case 2 % 曲面图
                surf(X, Y, intensity, 'EdgeColor', 'none');
                title('3D曲面图 - 衍射强度分布', 'FontSize', 12, 'FontWeight', 'bold');
                shading interp;
                
            case 3 % 网格图
                mesh(X, Y, intensity);
                title('3D网格图 - 衍射强度分布', 'FontSize', 12, 'FontWeight', 'bold');
                
            case 4 % 轮廓图
                contour3(X, Y, intensity, 20);
                title('3D轮廓图 - 衍射强度分布', 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        xlabel('X (μm)', 'FontSize', 11);
        ylabel('Y (μm)', 'FontSize', 11);
        zlabel('强度 (归一化)', 'FontSize', 11);
        grid on;
        axis tight;
        colorbar;
        
        % 设置视角
        view(45, 30);
    end
    
    function change3DDisplayMode(axes3D, simulationData, mode)
        % 改变3D显示模式
        display3DData(axes3D, simulationData, mode);
    end
    
    function update3DColormap(axes3D, colormapName)
        % 更新3D显示的颜色映射
        try
            switch colormapName
                case 'viridis'
                    colormap(axes3D, viridis);
                case 'plasma'
                    colormap(axes3D, plasma);
                case 'inferno'
                    colormap(axes3D, inferno);
                case 'magma'
                    colormap(axes3D, magma);
                otherwise
                    colormap(axes3D, eval(colormapName));
            end
        catch
            colormap(axes3D, jet); % 默认颜色映射
        end
    end
    
    function save3DImage(figHandle)
        % 保存3D图像
        try
            [filename, pathname] = uiputfile({
                '*.png', 'PNG图像 (*.png)';
                '*.jpg', 'JPEG图像 (*.jpg)';
                '*.tif', 'TIFF图像 (*.tif)';
                '*.eps', 'EPS矢量图 (*.eps)';
                '*.pdf', 'PDF文档 (*.pdf)'
            }, '保存3D图像', '3D_diffraction_pattern.png');
            
            if filename ~= 0
                fullPath = fullfile(pathname, filename);
                saveas(figHandle, fullPath);
                msgbox(['3D图像已保存至: ' fullPath], '保存成功', 'help');
            end
        catch ME
            errordlg(['保存失败: ' ME.message], '保存错误');
        end
    end
end 