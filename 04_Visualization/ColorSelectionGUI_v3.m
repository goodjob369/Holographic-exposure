function ColorSelectionGUI_v3(parent_figure)
    % 🎨 液晶衍射仿真系统专业颜色选择界面 v3.0
    % 集成slanCM科学色彩包和增强绘图功能
    % 
    % 版权所有 © 个人(Z.Y)团队(Y.M)
    % 创建日期: 2025-06-03
    % 版本: v3.0 Professional Enhanced
    
    if nargin < 1
        parent_figure = [];
    end
    
    % 创建颜色选择窗口
    color_fig = figure('Name', '🎨 专业颜色选择控制台', ...
                      'Position', [100, 100, 800, 600], ...
                      'NumberTitle', 'off', ...
                      'MenuBar', 'none', ...
                      'ToolBar', 'none', ...
                      'Resize', 'on', ...
                      'Color', [0.95, 0.95, 0.95], ...
                      'CloseRequestFcn', @closeColorGUI);
    
    % 界面组件句柄
    handles = struct();
    
    % 初始化界面
    initializeColorGUI();
    
    % 加载slanCM科学色彩包
    load_slanCM_colormap();
    
    %% === 界面初始化 ===
    function initializeColorGUI()
        % 创建主要面板
        createMainPanels();
        
        % 创建颜色选择控件
        createColorControls();
        
        % 创建预览区域
        createPreviewArea();
        
        % 设置默认值
        setDefaultColors();
        
        fprintf('🎨 专业颜色选择界面已启动\n');
    end
    
    function createMainPanels()
        % 左侧控制面板
        handles.leftPanel = uipanel(color_fig, ...
            'Title', '🎨 颜色方案选择', ...
            'Position', [0.02, 0.02, 0.48, 0.96], ...
            'FontSize', 12, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.97, 0.97, 0.97]);
        
        % 右侧预览面板
        handles.rightPanel = uipanel(color_fig, ...
            'Title', '👁️ 实时预览效果', ...
            'Position', [0.52, 0.02, 0.46, 0.96], ...
            'FontSize', 12, 'FontWeight', 'bold', ...
            'BackgroundColor', [1, 1, 1]);
    end
    
    function createColorControls()
        % === 2D强度分布颜色设置 ===
        handles.group2D = uipanel(handles.leftPanel, ...
            'Title', '📊 二维强度分布颜色', ...
            'Position', [0.05, 0.7, 0.9, 0.25], ...
            'BackgroundColor', [0.98, 0.98, 0.98]);
        
        % slanCM色彩方案下拉菜单
        uicontrol(handles.group2D, 'Style', 'text', ...
            'String', '科学色彩方案:', ...
            'Position', [10, 80, 100, 20], ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.98, 0.98, 0.98], ...
            'FontSize', 10);
        
        handles.colormap2D = uicontrol(handles.group2D, 'Style', 'popupmenu', ...
            'String', {'jet', 'hot', 'cool', 'parula', 'viridis', 'plasma', 'inferno', ...
                      'turbo', 'slanCM-batlow', 'slanCM-roma', 'slanCM-vik', 'slanCM-cork'}, ...
            'Position', [120, 80, 150, 25], ...
            'FontSize', 10, ...
            'Callback', @updateColorPreview);
        
        % === 1D光强曲线颜色设置 ===
        handles.group1D = uipanel(handles.leftPanel, ...
            'Title', '📈 一维光强分布颜色', ...
            'Position', [0.05, 0.4, 0.9, 0.25], ...
            'BackgroundColor', [0.98, 0.98, 0.98]);
        
        % 序列类颜色设置
        uicontrol(handles.group1D, 'Style', 'text', ...
            'String', '序列类颜色:', ...
            'Position', [10, 80, 80, 20], ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.98, 0.98, 0.98], ...
            'FontSize', 9);
        
        handles.colorSeq = uicontrol(handles.group1D, 'Style', 'pushbutton', ...
            'String', '■', ...
            'Position', [100, 80, 30, 20], ...
            'BackgroundColor', [0.2, 0.6, 0.8], ...
            'Callback', @selectSequentialColor);
        
        % 分散类颜色设置  
        uicontrol(handles.group1D, 'Style', 'text', ...
            'String', '分散类颜色:', ...
            'Position', [150, 80, 80, 20], ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.98, 0.98, 0.98], ...
            'FontSize', 9);
        
        handles.colorDiv = uicontrol(handles.group1D, 'Style', 'pushbutton', ...
            'String', '■', ...
            'Position', [240, 80, 30, 20], ...
            'BackgroundColor', [0.8, 0.2, 0.3], ...
            'Callback', @selectDivergingColor);
        
        % 循环类颜色设置
        uicontrol(handles.group1D, 'Style', 'text', ...
            'String', '循环类颜色:', ...
            'Position', [10, 40, 80, 20], ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.98, 0.98, 0.98], ...
            'FontSize', 9);
        
        handles.colorCyc = uicontrol(handles.group1D, 'Style', 'pushbutton', ...
            'String', '■', ...
            'Position', [100, 40, 30, 20], ...
            'BackgroundColor', [0.3, 0.7, 0.2], ...
            'Callback', @selectCyclicColor);
        
        % === 高级设置 ===
        handles.groupAdv = uipanel(handles.leftPanel, ...
            'Title', '⚙️ 高级颜色设置', ...
            'Position', [0.05, 0.05, 0.9, 0.3], ...
            'BackgroundColor', [0.98, 0.98, 0.98]);
        
        % 透明度控制
        uicontrol(handles.groupAdv, 'Style', 'text', ...
            'String', '透明度:', ...
            'Position', [10, 100, 60, 20], ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', [0.98, 0.98, 0.98], ...
            'FontSize', 10);
        
        handles.alphaSlider = uicontrol(handles.groupAdv, 'Style', 'slider', ...
            'Position', [80, 100, 150, 20], ...
            'Min', 0, 'Max', 1, 'Value', 0.7, ...
            'Callback', @updateAlpha);
        
        handles.alphaValue = uicontrol(handles.groupAdv, 'Style', 'text', ...
            'String', '0.7', ...
            'Position', [240, 100, 40, 20], ...
            'HorizontalAlignment', 'center', ...
            'BackgroundColor', [0.98, 0.98, 0.98], ...
            'FontSize', 10);
        
        % 应用按钮
        uicontrol(handles.groupAdv, 'Style', 'pushbutton', ...
            'String', '✅ 应用颜色方案', ...
            'Position', [50, 20, 150, 35], ...
            'FontSize', 12, 'FontWeight', 'bold', ...
            'BackgroundColor', [0.1, 0.7, 0.1], ...
            'ForegroundColor', [1, 1, 1], ...
            'Callback', @applyColorScheme);
    end
    
    function createPreviewArea()
        % 创建预览区域
        handles.previewAxes2D = axes('Parent', handles.rightPanel, ...
            'Position', [0.1, 0.55, 0.8, 0.4]);
        title(handles.previewAxes2D, '2D强度分布预览', 'FontSize', 11);
        
        handles.previewAxes1D = axes('Parent', handles.rightPanel, ...
            'Position', [0.1, 0.05, 0.8, 0.4]);
        title(handles.previewAxes1D, '1D光强分布预览', 'FontSize', 11);
        
        % 生成预览数据
        generatePreviewData();
    end
    
    function generatePreviewData()
        % 生成示例数据用于预览
        [X, Y] = meshgrid(-10:0.5:10, -10:0.5:10);
        handles.preview2DData = exp(-(X.^2 + Y.^2)/10) .* cos(X) .* cos(Y);
        
        x = -10:0.1:10;
        handles.preview1DData1 = exp(-x.^2/5);
        handles.preview1DData2 = 0.8 * exp(-(x-2).^2/3) + 0.6 * exp(-(x+2).^2/4);
        handles.previewX = x;
        
        updateColorPreview();
    end
    
    %% === 回调函数 ===
    function updateColorPreview(~, ~)
        % 更新颜色预览
        
        % 更新2D预览
        axes(handles.previewAxes2D);
        imagesc(handles.preview2DData);
        axis equal; axis tight;
        
        % 获取选择的色彩方案
        colormap_names = get(handles.colormap2D, 'String');
        selected_idx = get(handles.colormap2D, 'Value');
        selected_colormap = colormap_names{selected_idx};
        
        % 应用色彩方案
        if contains(selected_colormap, 'slanCM')
            % 使用slanCM色彩
            colormap_name = strrep(selected_colormap, 'slanCM-', '');
            try
                cm = slanCM(colormap_name);
                colormap(handles.previewAxes2D, cm);
            catch
                colormap(handles.previewAxes2D, jet);
            end
        else
            % 使用MATLAB内置色彩
            colormap(handles.previewAxes2D, selected_colormap);
        end
        
        colorbar;
        title('2D强度分布预览', 'FontSize', 11);
        
        % 更新1D预览
        updatePreview1D();
    end
    
    function updatePreview1D()
        % 更新1D预览
        axes(handles.previewAxes1D);
        cla;
        
        % 获取颜色设置
        color1 = get(handles.colorSeq, 'BackgroundColor');
        color2 = get(handles.colorDiv, 'BackgroundColor');
        alpha_val = get(handles.alphaSlider, 'Value');
        
        % 使用增强绘图函数
        try
            plot_options = struct();
            plot_options.color_input = color1;
            plot_options.color_output = color2;
            plot_options.alpha = alpha_val;
            plot_options.title = '一维光强分布预览';
            plot_options.show_peak_markers = true;
            plot_options.use_gradient = true;
            
            plot_gradient_compare_enhanced(handles.previewX, ...
                handles.preview1DData1, handles.preview1DData2, ...
                [-10, 10], plot_options);
        catch
            % 简单绘图作为备选
            hold on;
            plot(handles.previewX, handles.preview1DData1, 'Color', color1, 'LineWidth', 2);
            plot(handles.previewX, handles.preview1DData2, 'Color', color2, 'LineWidth', 2);
            legend({'入射光场', '衍射光场'}, 'Location', 'best');
            title('一维光强分布预览', 'FontSize', 11);
            grid on;
            hold off;
        end
    end
    
    function selectSequentialColor(~, ~)
        % 选择序列类颜色
        color = uisetcolor(get(handles.colorSeq, 'BackgroundColor'), '选择序列类颜色');
        if length(color) == 3
            set(handles.colorSeq, 'BackgroundColor', color);
            updatePreview1D();
        end
    end
    
    function selectDivergingColor(~, ~)
        % 选择分散类颜色
        color = uisetcolor(get(handles.colorDiv, 'BackgroundColor'), '选择分散类颜色');
        if length(color) == 3
            set(handles.colorDiv, 'BackgroundColor', color);
            updatePreview1D();
        end
    end
    
    function selectCyclicColor(~, ~)
        % 选择循环类颜色
        color = uisetcolor(get(handles.colorCyc, 'BackgroundColor'), '选择循环类颜色');
        if length(color) == 3
            set(handles.colorCyc, 'BackgroundColor', color);
            updatePreview1D();
        end
    end
    
    function updateAlpha(~, ~)
        % 更新透明度
        alpha_val = get(handles.alphaSlider, 'Value');
        set(handles.alphaValue, 'String', sprintf('%.2f', alpha_val));
        updatePreview1D();
    end
    
    function applyColorScheme(~, ~)
        % 应用颜色方案到主程序
        if ~isempty(parent_figure) && isvalid(parent_figure)
            % 获取当前颜色设置
            color_scheme = struct();
            color_scheme.colormap_2d = getSelectedColormap();
            color_scheme.color_sequential = get(handles.colorSeq, 'BackgroundColor');
            color_scheme.color_diverging = get(handles.colorDiv, 'BackgroundColor');
            color_scheme.color_cyclic = get(handles.colorCyc, 'BackgroundColor');
            color_scheme.alpha = get(handles.alphaSlider, 'Value');
            
            % 通过应用数据传递颜色方案
            setappdata(parent_figure, 'color_scheme', color_scheme);
            
            % 触发主界面更新
            notify_main_gui_update(parent_figure);
            
            msgbox('✅ 颜色方案已成功应用到主界面！', '应用成功', 'help');
        else
            msgbox('⚠️ 未找到主界面连接，请确保从主程序启动', '连接错误', 'warn');
        end
    end
    
    function closeColorGUI(~, ~)
        % 关闭颜色选择界面
        delete(color_fig);
    end
    
    %% === 辅助函数 ===
    function load_slanCM_colormap()
        % 加载slanCM科学色彩包
        try
            % 检查slanCM是否可用
            if exist('slanCM', 'file') == 2
                fprintf('✅ slanCM科学色彩包已加载\n');
            else
                warning('⚠️ slanCM色彩包未找到，将使用MATLAB内置色彩');
            end
        catch ME
            warning('slanCM加载失败: %s', ME.message);
        end
    end
    
    function setDefaultColors()
        % 设置默认颜色
        set(handles.colormap2D, 'Value', 1);  % 默认jet
        set(handles.colorSeq, 'BackgroundColor', [0.2, 0.6, 0.8]);
        set(handles.colorDiv, 'BackgroundColor', [0.8, 0.2, 0.3]);
        set(handles.colorCyc, 'BackgroundColor', [0.3, 0.7, 0.2]);
        set(handles.alphaSlider, 'Value', 0.7);
        set(handles.alphaValue, 'String', '0.7');
    end
    
    function colormap_name = getSelectedColormap()
        % 获取选择的色彩方案名称
        colormap_names = get(handles.colormap2D, 'String');
        selected_idx = get(handles.colormap2D, 'Value');
        colormap_name = colormap_names{selected_idx};
    end
    
    function notify_main_gui_update(parent_fig)
        % 通知主界面更新颜色方案
        try
            % 寻找主界面的颜色更新函数
            if isappdata(parent_fig, 'update_colors_callback')
                update_func = getappdata(parent_fig, 'update_colors_callback');
                if isa(update_func, 'function_handle')
                    update_func();
                end
            end
        catch ME
            fprintf('主界面更新通知失败: %s\n', ME.message);
        end
    end
    
end 