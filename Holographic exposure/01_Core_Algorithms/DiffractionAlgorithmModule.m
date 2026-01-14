function DiffractionAlgorithmModule()
% 液晶衍射仿真系统 - 算法模块
% 基于最新的光学成像理论，包含RCWA、琼斯矩阵、角谱理论等算法
% 作者：光学算法工程师 & 衍射光学成像设计师
% 版本：v2.0 专业版

fprintf('液晶衍射算法模块已加载\n');
fprintf('支持的算法类别：\n');
fprintf('  1. 液晶偏振光栅专用算法\n');
fprintf('  2. 标量衍射理论算法\n');
fprintf('  3. 矢量衍射理论算法\n');
fprintf('  4. 机器学习与优化算法\n');
fprintf('  5. 多尺度分析算法\n');
fprintf('  6. 相干层析成像算法\n');
fprintf('  7. 超分辨重构算法\n');
fprintf('  8. 自适应光学算法\n');

end

% === 算法类别切换回调函数 ===
function algorithmCategoryChanged(src, event)
    try
        selectedCategory = get(event.NewValue, 'String');
        updateAlgorithmList(selectedCategory);
    catch ME
        fprintf('算法类别切换错误: %s\n', ME.message);
    end
end

% === 算法列表更新函数 ===
function updateAlgorithmList(category)
    try
        % 获取当前图形句柄
        fig = gcf;
        handles = guidata(fig);
        
        % 清空现有算法列表
        if isfield(handles, 'algorithmListPanel') && ishandle(handles.algorithmListPanel)
            delete(get(handles.algorithmListPanel, 'Children'));
        end
        
        % 根据类别更新算法列表
        switch category
            case '液晶偏振光栅'
                createLiquidCrystalAlgorithms(handles);
            case '标量衍射理论'
                createScalarDiffractionAlgorithms(handles);
            case '矢量衍射理论'
                createVectorDiffractionAlgorithms(handles);
            case '机器学习算法'
                createMLAlgorithms(handles);
            case '多尺度分析'
                createMultiscaleAlgorithms(handles);
            case '相干层析成像'
                createCoherentTomographyAlgorithms(handles);
            case '超分辨重构'
                createSuperResolutionAlgorithms(handles);
            case '自适应光学'
                createAdaptiveOpticsAlgorithms(handles);
        end
    catch ME
        fprintf('算法列表更新错误: %s\n', ME.message);
    end
end

% === 液晶偏振光栅算法创建 ===
function createLiquidCrystalAlgorithms(handles)
    algorithms = {
        {'琼斯矩阵RCWA算法', '基于琼斯矩阵和严格耦合波分析的液晶偏振光栅衍射计算', 'jones_rcwa', true};
        {'扩展琼斯矩阵方法', '考虑非理想液晶取向的扩展琼斯矩阵算法', 'extended_jones', true};
        {'修正角谱传播', '考虑液晶双折射效应的修正角谱算法', 'modified_angular_spectrum', true};
        {'琼斯矩阵级联算法', '多层液晶结构的琼斯矩阵级联计算', 'jones_cascade', true};
        {'相位调制优化算法', '基于相位分布优化的液晶光栅设计算法', 'phase_optimization', false};
        {'液晶分子动力学', '考虑液晶分子运动的动态仿真算法', 'molecular_dynamics', false};
    };
    
    createAlgorithmButtons(handles, algorithms, '液晶偏振光栅专用算法');
end

% === 标量衍射理论算法创建 ===
function createScalarDiffractionAlgorithms(handles)
    algorithms = {
        {'菲涅尔衍射算法', '基于菲涅尔积分的近场衍射计算', 'fresnel_diffraction', true};
        {'夫琅禾费衍射算法', '远场衍射的夫琅禾费近似算法', 'fraunhofer_diffraction', true};
        {'角谱传播算法', '基于角谱理论的衍射传播算法', 'angular_spectrum', true};
        {'瑞利-索默菲尔德算法', '严格的标量衍射积分算法', 'rayleigh_sommerfeld', true};
        {'基尔霍夫衍射算法', '基于基尔霍夫积分的衍射计算', 'kirchhoff_diffraction', true};
        {'分步傅里叶算法', '考虑色散效应的分步傅里叶方法', 'split_step_fourier', false};
    };
    
    createAlgorithmButtons(handles, algorithms, '标量衍射理论算法');
end

% === 矢量衍射理论算法创建 ===
function createVectorDiffractionAlgorithms(handles)
    algorithms = {
        {'严格耦合波分析', '基于RCWA的矢量衍射严格计算', 'rcwa_vector', true};
        {'时域有限差分法', '全矢量电磁场FDTD仿真', 'fdtd_vector', false};
        {'有限元方法', '基于FEM的矢量衍射计算', 'fem_vector', false};
        {'矩量法算法', '基于MoM的表面积分方程求解', 'mom_vector', false};
        {'多极展开法', '基于多极展开的矢量散射算法', 'multipole_expansion', false};
        {'T矩阵方法', '基于T矩阵的粒子散射算法', 't_matrix_method', false};
    };
    
    createAlgorithmButtons(handles, algorithms, '矢量衍射理论算法');
end

% === 创建算法按钮通用函数 ===
function createAlgorithmButtons(handles, algorithms, categoryTitle)
    try
        % 更新算法描述
        if isfield(handles, 'algorithmDescriptionText') && ishandle(handles.algorithmDescriptionText)
            set(handles.algorithmDescriptionText, 'String', [categoryTitle '：选择一个算法查看详细信息']);
        end
        
        % 创建算法选择按钮组
        algorithmGroup = uibuttongroup(handles.algorithmListPanel, ...
            'Position', [0, 0, 1, 1], ...
            'BackgroundColor', [0.98 0.98 0.96], ...
            'BorderType', 'none', ...
            'SelectionChangedFcn', @algorithmSelectionChanged);
        
        % 计算按钮布局
        numAlgorithms = length(algorithms);
        buttonHeight = 25;
        spacing = 5;
        
        % 创建算法按钮
        for i = 1:numAlgorithms
            algorithm = algorithms{i};
            name = algorithm{1};
            description = algorithm{2};
            code = algorithm{3};
            available = algorithm{4};
            
            yPos = 150 - i * (buttonHeight + spacing);
            
            % 创建单选按钮
            btn = uicontrol(algorithmGroup, 'Style', 'radiobutton', ...
                'String', name, ...
                'Position', [10, yPos, 300, buttonHeight], ...
                'BackgroundColor', [0.98 0.98 0.96], ...
                'FontSize', 9, ...
                'Enable', iif(available, 'on', 'off'), ...
                'TooltipString', description, ...
                'UserData', struct('code', code, 'description', description, 'available', available));
            
            % 第一个可用算法默认选中
            if i == 1 && available
                set(btn, 'Value', 1);
                updateAlgorithmParameters(code);
            end
        end
        
        % 存储算法组引用
        setappdata(gcf, 'currentAlgorithmGroup', algorithmGroup);
        
    catch ME
        fprintf('创建算法按钮错误: %s\n', ME.message);
    end
end

% === 算法选择改变回调 ===
function algorithmSelectionChanged(src, event)
    try
        if ~isempty(event.NewValue)
            userData = get(event.NewValue, 'UserData');
            if userData.available
                updateAlgorithmParameters(userData.code);
                
                % 更新算法描述
                fig = gcf;
                handles = guidata(fig);
                if isfield(handles, 'algorithmDescriptionText') && ishandle(handles.algorithmDescriptionText)
                    set(handles.algorithmDescriptionText, 'String', userData.description);
                end
            end
        end
    catch ME
        fprintf('算法选择错误: %s\n', ME.message);
    end
end

% === 更新算法参数界面 ===
function updateAlgorithmParameters(algorithmCode)
    try
        fig = gcf;
        handles = guidata(fig);
        
        % 清空现有参数界面
        if isfield(handles, 'paramsContentPanel') && ishandle(handles.paramsContentPanel)
            delete(get(handles.paramsContentPanel, 'Children'));
        end
        
        switch algorithmCode
            case 'jones_rcwa'
                createJonesRCWAParameters(handles);
            case 'extended_jones'
                createExtendedJonesParameters(handles);
            case 'modified_angular_spectrum'
                createModifiedAngularSpectrumParameters(handles);
            case 'jones_cascade'
                createJonesCascadeParameters(handles);
            case 'fresnel_diffraction'
                createFresnelParameters(handles);
            case 'fraunhofer_diffraction'
                createFraunhoferParameters(handles);
            case 'angular_spectrum'
                createAngularSpectrumParameters(handles);
            case 'rayleigh_sommerfeld'
                createRayleighSommerfeldParameters(handles);
            case 'kirchhoff_diffraction'
                createKirchhoffParameters(handles);
            case 'rcwa_vector'
                createRCWAVectorParameters(handles);
            otherwise
                createDefaultParameters(handles, algorithmCode);
        end
    catch ME
        fprintf('参数更新错误: %s\n', ME.message);
    end
end

% === 琼斯矩阵RCWA算法参数 ===
function createJonesRCWAParameters(handles)
    if ~isfield(handles, 'paramsContentPanel') || ~ishandle(handles.paramsContentPanel)
        return;
    end
    
    panel = handles.paramsContentPanel;
    
    % 标题
    uicontrol(panel, 'Style', 'text', ...
        'String', '琼斯矩阵RCWA算法参数', ...
        'Position', [10, 130, 200, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left');
    
    % 截断阶数
    uicontrol(panel, 'Style', 'text', ...
        'String', '截断阶数:', ...
        'Position', [10, 100, 80, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 9, 'HorizontalAlignment', 'left');
    
    uicontrol(panel, 'Style', 'edit', ...
        'String', '31', ...
        'Position', [100, 100, 60, 20], ...
        'FontSize', 9, ...
        'TooltipString', '傅里叶级数展开的截断阶数（奇数）');
    
    % 层数
    uicontrol(panel, 'Style', 'text', ...
        'String', '层数:', ...
        'Position', [170, 100, 40, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 9, 'HorizontalAlignment', 'left');
    
    uicontrol(panel, 'Style', 'edit', ...
        'String', '10', ...
        'Position', [220, 100, 60, 20], ...
        'FontSize', 9, ...
        'TooltipString', '液晶层分层数目');
    
    % 收敛精度
    uicontrol(panel, 'Style', 'text', ...
        'String', '收敛精度:', ...
        'Position', [10, 70, 80, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 9, 'HorizontalAlignment', 'left');
    
    uicontrol(panel, 'Style', 'edit', ...
        'String', '1e-6', ...
        'Position', [100, 70, 80, 20], ...
        'FontSize', 9, ...
        'TooltipString', '迭代计算的收敛精度');
    
    % 考虑损耗
    uicontrol(panel, 'Style', 'checkbox', ...
        'String', '考虑材料损耗', ...
        'Position', [10, 40, 120, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 9, 'Value', 0);
    
    % 偏振耦合
    uicontrol(panel, 'Style', 'checkbox', ...
        'String', '偏振耦合效应', ...
        'Position', [140, 40, 120, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 9, 'Value', 1);
    
    % 优化选项
    uicontrol(panel, 'Style', 'text', ...
        'String', '计算优化:', ...
        'Position', [10, 10, 80, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 9, 'HorizontalAlignment', 'left');
    
    uicontrol(panel, 'Style', 'popupmenu', ...
        'String', {'标准计算', '并行计算', 'GPU加速', '自适应网格'}, ...
        'Position', [100, 10, 100, 20], ...
        'FontSize', 9, 'Value', 2);
end

% === 扩展琼斯矩阵算法参数 ===
function createExtendedJonesParameters(handles)
    createSimpleParameters(handles, '扩展琼斯矩阵算法参数', ...
        {'取向缺陷强度', '0.1'; '温度系数', '0'; '厚度变化补偿', '1'});
end

% === 修正角谱传播算法参数 ===
function createModifiedAngularSpectrumParameters(handles)
    createSimpleParameters(handles, '修正角谱传播算法参数', ...
        {'双折射补偿', '1'; '偏振态追踪', '1'; '传播步长', '1e-6'});
end

% === 其他算法参数创建函数（简化版） ===
function createJonesCascadeParameters(handles)
    createSimpleParameters(handles, '琼斯矩阵级联算法参数', ...
        {'级联层数', '10'; '界面反射', '1'; '相干性', '1'});
end

function createFresnelParameters(handles)
    createSimpleParameters(handles, '菲涅尔衍射算法参数', ...
        {'采样点数', '1024'; '传播距离', '0.1'; '数值孔径', '0.1'});
end

function createFraunhoferParameters(handles)
    createSimpleParameters(handles, '夫琅禾费衍射算法参数', ...
        {'角度范围', '30'; 'FFT尺寸', '1024'; '零填充', '1'});
end

function createAngularSpectrumParameters(handles)
    createSimpleParameters(handles, '角谱传播算法参数', ...
        {'传播距离', '0.1'; '采样密度', '512'; '抗混叠', '1'});
end

function createRayleighSommerfeldParameters(handles)
    createSimpleParameters(handles, '瑞利-索默菲尔德算法参数', ...
        {'积分精度', '1e-6'; '边界条件', '1'; '数值积分', '自适应'});
end

function createKirchhoffParameters(handles)
    createSimpleParameters(handles, '基尔霍夫衍射算法参数', ...
        {'倾斜因子', '1'; '几何修正', '1'; '阴影效应', '1'});
end

function createRCWAVectorParameters(handles)
    createSimpleParameters(handles, 'RCWA矢量算法参数', ...
        {'截断阶数', '41'; 'TE/TM耦合', '1'; '数值稳定化', '1'});
end

function createDefaultParameters(handles, algorithmCode)
    createSimpleParameters(handles, [algorithmCode '算法参数'], ...
        {'参数1', '默认值1'; '参数2', '默认值2'; '参数3', '默认值3'});
end

% === 简化参数创建函数 ===
function createSimpleParameters(handles, title, params)
    if ~isfield(handles, 'paramsContentPanel') || ~ishandle(handles.paramsContentPanel)
        return;
    end
    
    panel = handles.paramsContentPanel;
    
    uicontrol(panel, 'Style', 'text', ...
        'String', title, ...
        'Position', [10, 130, 200, 20], ...
        'BackgroundColor', [0.96 0.98 0.96], ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left');
    
    for i = 1:size(params, 1)
        yPos = 100 - (i-1) * 30;
        
        uicontrol(panel, 'Style', 'text', ...
            'String', [params{i,1} ':'], ...
            'Position', [10, yPos, 80, 20], ...
            'BackgroundColor', [0.96 0.98 0.96], ...
            'FontSize', 9, 'HorizontalAlignment', 'left');
        
        if strcmp(params{i,2}, '1') || strcmp(params{i,2}, '0')
            uicontrol(panel, 'Style', 'checkbox', ...
                'String', '', ...
                'Position', [100, yPos, 20, 20], ...
                'BackgroundColor', [0.96 0.98 0.96], ...
                'FontSize', 9, 'Value', str2double(params{i,2}));
        else
            uicontrol(panel, 'Style', 'edit', ...
                'String', params{i,2}, ...
                'Position', [100, yPos, 80, 20], ...
                'FontSize', 9);
        end
    end
end

% === 辅助函数 ===
function result = iif(condition, trueValue, falseValue)
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end 