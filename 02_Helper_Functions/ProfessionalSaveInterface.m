% 专业保存界面 V4.0
% 带参数信息保存的专业保存界面
% 版权所有 © 个人Z.Y团队Y.M
% 更新日期：2024年12月31日

function ProfessionalSaveInterface(imageData, imageInfo, params)
    % 创建专业的保存界面
    % imageData: 要保存的图像数据
    % imageInfo: 图像信息
    % params: 参数结构体
    
    if nargin < 3
        params = struct();
    end
    
    % 创建保存对话框
    saveFig = figure('Name', '专业保存界面 - V4.0', ...
        'Position', [200, 200, 800, 600], ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'off', ...
        'Color', [0.95 0.95 0.95], 'WindowStyle', 'modal');
    
    % 标题
    uicontrol(saveFig, 'Style', 'text', ...
        'String', '全息曝光图像专业保存系统', ...
        'Position', [50, 550, 700, 30], 'FontSize', 16, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.95 0.95 0.95], 'ForegroundColor', [0.2 0.2 0.7]);
    
    % 文件保存选项面板
    filePanel = uipanel(saveFig, 'Title', '文件保存选项', ...
        'Position', [0.05, 0.65, 0.9, 0.3], 'FontSize', 12, ...
        'BackgroundColor', [0.98 0.98 0.98]);
    
    % 文件名输入
    uicontrol(filePanel, 'Style', 'text', 'String', '文件名:', ...
        'Position', [20, 130, 80, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    editFilename = uicontrol(filePanel, 'Style', 'edit', ...
        'String', generateDefaultFilename(), ...
        'Position', [100, 130, 300, 25], 'FontSize', 10);
    
    % 保存路径
    uicontrol(filePanel, 'Style', 'text', 'String', '保存路径:', ...
        'Position', [20, 100, 80, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    editSavePath = uicontrol(filePanel, 'Style', 'edit', ...
        'String', pwd, ...
        'Position', [100, 100, 300, 25], 'FontSize', 10);
    uicontrol(filePanel, 'Style', 'pushbutton', 'String', '浏览...', ...
        'Position', [410, 100, 60, 25], 'Callback', @browsePath);
    
    % 文件格式选择
    uicontrol(filePanel, 'Style', 'text', 'String', '图像格式:', ...
        'Position', [20, 70, 80, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    popupFormat = uicontrol(filePanel, 'Style', 'popupmenu', ...
        'String', {'PNG (推荐)', 'TIFF (高质量)', 'JPEG', 'BMP', 'MAT (MATLAB)'}, ...
        'Position', [100, 70, 150, 25], 'Value', 1);
    
    % 图像质量设置
    uicontrol(filePanel, 'Style', 'text', 'String', '图像质量:', ...
        'Position', [270, 70, 80, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    popupQuality = uicontrol(filePanel, 'Style', 'popupmenu', ...
        'String', {'最高质量', '高质量', '标准质量', '压缩质量'}, ...
        'Position', [350, 70, 120, 25], 'Value', 1);
    
    % 保存选项
    checkSaveParams = uicontrol(filePanel, 'Style', 'checkbox', ...
        'String', '保存参数信息文件 (.txt)', 'Value', 1, ...
        'Position', [20, 40, 200, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    
    checkSaveMatlab = uicontrol(filePanel, 'Style', 'checkbox', ...
        'String', '保存MATLAB数据文件 (.mat)', 'Value', 1, ...
        'Position', [230, 40, 200, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    
    checkOpenAfterSave = uicontrol(filePanel, 'Style', 'checkbox', ...
        'String', '保存后打开文件夹', 'Value', 0, ...
        'Position', [20, 10, 150, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    
    % 预览面板
    previewPanel = uipanel(saveFig, 'Title', '图像预览', ...
        'Position', [0.05, 0.35, 0.45, 0.28], 'FontSize', 12, ...
        'BackgroundColor', [0.98 0.98 0.98]);
    
    % 预览图像
    previewAxes = axes('Parent', previewPanel, 'Position', [0.1, 0.1, 0.8, 0.8]);
    if ~isempty(imageData)
        if size(imageData, 3) == 1
            imshow(imageData, [], 'Parent', previewAxes);
        else
            imshow(imageData, 'Parent', previewAxes);
        end
    end
    title(previewAxes, '图像预览', 'FontSize', 10);
    
    % 参数信息面板
    infoPanel = uipanel(saveFig, 'Title', '参数信息', ...
        'Position', [0.52, 0.35, 0.43, 0.28], 'FontSize', 12, ...
        'BackgroundColor', [0.98 0.98 0.98]);
    
    % 参数信息文本
    infoText = generateParameterInfo(imageInfo, params);
    uicontrol(infoPanel, 'Style', 'text', 'String', infoText, ...
        'Position', [10, 10, 300, 140], 'FontSize', 9, ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.98 0.98 0.98]);
    
    % 高级选项面板
    advancedPanel = uipanel(saveFig, 'Title', '高级选项', ...
        'Position', [0.05, 0.15, 0.9, 0.18], 'FontSize', 12, ...
        'BackgroundColor', [0.98 0.98 0.98]);
    
    % 水印选项
    checkWatermark = uicontrol(advancedPanel, 'Style', 'checkbox', ...
        'String', '添加版权水印', 'Value', 1, ...
        'Position', [20, 70, 150, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    
    % 批量保存选项
    checkBatchSave = uicontrol(advancedPanel, 'Style', 'checkbox', ...
        'String', '启用批量保存模式', 'Value', 0, ...
        'Position', [180, 70, 150, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    
    % 自动备份
    checkAutoBackup = uicontrol(advancedPanel, 'Style', 'checkbox', ...
        'String', '自动创建备份', 'Value', 1, ...
        'Position', [340, 70, 150, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    
    % 文件命名规则
    uicontrol(advancedPanel, 'Style', 'text', 'String', '命名规则:', ...
        'Position', [20, 40, 80, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    popupNaming = uicontrol(advancedPanel, 'Style', 'popupmenu', ...
        'String', {'时间戳', '序号递增', '参数标识', '自定义'}, ...
        'Position', [100, 40, 120, 25], 'Value', 1, ...
        'Callback', @updateFilename);
    
    % 压缩选项
    uicontrol(advancedPanel, 'Style', 'text', 'String', '压缩级别:', ...
        'Position', [240, 40, 80, 20], 'BackgroundColor', [0.98 0.98 0.98]);
    sliderCompression = uicontrol(advancedPanel, 'Style', 'slider', ...
        'Min', 0, 'Max', 9, 'Value', 3, ...
        'Position', [320, 40, 100, 20]);
    
    % 进度条
    progressBar = uicontrol(advancedPanel, 'Style', 'text', ...
        'String', '准备就绪', ...
        'Position', [20, 10, 400, 20], 'BackgroundColor', [0.9 0.9 0.9], ...
        'ForegroundColor', [0.2 0.6 0.2]);
    
    % 按钮面板
    buttonPanel = uipanel(saveFig, 'Position', [0.05, 0.02, 0.9, 0.1], ...
        'BorderType', 'none', 'BackgroundColor', [0.95 0.95 0.95]);
    
    % 保存按钮
    uicontrol(buttonPanel, 'Style', 'pushbutton', 'String', '保存', ...
        'Position', [200, 20, 100, 35], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2, 0.7, 0.2], 'ForegroundColor', [1 1 1], ...
        'Callback', @saveImage);
    
    % 预览按钮
    uicontrol(buttonPanel, 'Style', 'pushbutton', 'String', '预览', ...
        'Position', [320, 20, 100, 35], ...
        'FontSize', 12, 'Callback', @previewImage);
    
    % 取消按钮
    uicontrol(buttonPanel, 'Style', 'pushbutton', 'String', '取消', ...
        'Position', [440, 20, 100, 35], ...
        'FontSize', 12, 'Callback', @cancelSave);
    
    % 帮助按钮
    uicontrol(buttonPanel, 'Style', 'pushbutton', 'String', '帮助', ...
        'Position', [560, 20, 80, 35], ...
        'FontSize', 12, 'Callback', @showHelp);
    
    % 回调函数
    function browsePath(~, ~)
        selectedPath = uigetdir(get(editSavePath, 'String'), '选择保存路径');
        if selectedPath ~= 0
            set(editSavePath, 'String', selectedPath);
        end
    end
    
    function updateFilename(~, ~)
        namingIdx = get(popupNaming, 'Value');
        switch namingIdx
            case 1 % 时间戳
                filename = ['ExposurePattern_', datestr(now, 'yyyymmdd_HHMMSS')];
            case 2 % 序号递增
                filename = getNextSequentialFilename();
            case 3 % 参数标识
                filename = generateParameterBasedFilename(params);
            case 4 % 自定义
                filename = 'CustomPattern';
        end
        set(editFilename, 'String', filename);
    end
    
    function saveImage(~, ~)
        try
            % 更新进度
            set(progressBar, 'String', '正在保存...', 'BackgroundColor', [1 1 0.8]);
            drawnow;
            
            % 获取保存参数
            filename = get(editFilename, 'String');
            savePath = get(editSavePath, 'String');
            formatIdx = get(popupFormat, 'Value');
            qualityIdx = get(popupQuality, 'Value');
            
            % 确定文件扩展名
            formats = {'.png', '.tiff', '.jpg', '.bmp', '.mat'};
            ext = formats{formatIdx};
            
            % 完整文件路径
            fullPath = fullfile(savePath, [filename, ext]);
            
            % 处理图像数据
            processedImage = imageData;
            
            % 添加水印
            if get(checkWatermark, 'Value')
                processedImage = addWatermark(processedImage);
            end
            
            % 保存图像
            saveImageWithQuality(processedImage, fullPath, formatIdx, qualityIdx);
            
            % 保存参数文件
            if get(checkSaveParams, 'Value')
                saveParameterFile(fullPath, imageInfo, params);
            end
            
            % 保存MATLAB文件
            if get(checkSaveMatlab, 'Value')
                saveMatlabFile(fullPath, imageData, imageInfo, params);
            end
            
            % 创建备份
            if get(checkAutoBackup, 'Value')
                createBackup(fullPath);
            end
            
            % 更新进度
            set(progressBar, 'String', '保存成功！', 'BackgroundColor', [0.8 1 0.8]);
            
            % 打开文件夹
            if get(checkOpenAfterSave, 'Value')
                if ispc
                    winopen(savePath);
                elseif ismac
                    system(['open "' savePath '"']);
                else
                    system(['xdg-open "' savePath '"']);
                end
            end
            
            % 显示成功消息
            msgbox(['文件已成功保存到: ', fullPath], '保存成功', 'help');
            
            pause(1);
            close(saveFig);
            
        catch ME
            set(progressBar, 'String', ['保存失败: ', ME.message], 'BackgroundColor', [1 0.8 0.8]);
            errordlg(['保存失败: ', ME.message], '错误');
        end
    end
    
    function previewImage(~, ~)
        % 预览功能
        previewFig = figure('Name', '图像预览', 'Position', [300, 300, 600, 500]);
        imshow(imageData, []);
        title(['预览: ', get(editFilename, 'String')], 'FontSize', 12);
    end
    
    function cancelSave(~, ~)
        close(saveFig);
    end
    
    function showHelp(~, ~)
        helpText = sprintf(['保存界面帮助:\n\n', ...
            '1. 文件名: 输入要保存的文件名（不含扩展名）\n', ...
            '2. 保存路径: 选择文件保存位置\n', ...
            '3. 图像格式: 选择保存的图像格式\n', ...
            '4. 图像质量: 设置图像压缩质量\n', ...
            '5. 参数信息: 自动保存图像参数到txt文件\n', ...
            '6. MATLAB文件: 保存原始数据到mat文件\n', ...
            '7. 版权水印: 在图像上添加版权信息\n', ...
            '8. 自动备份: 创建文件备份\n\n', ...
            '版权所有 © 个人Z.Y团队Y.M']);
        
        msgbox(helpText, '帮助信息', 'help');
    end
end

% 辅助函数
function filename = generateDefaultFilename()
    filename = ['HolographicPattern_', datestr(now, 'yyyymmdd_HHMMSS')];
end

function filename = getNextSequentialFilename()
    % 获取下一个序号文件名
    baseDir = pwd;
    pattern = 'ExposurePattern_';
    files = dir(fullfile(baseDir, [pattern, '*.png']));
    
    if isempty(files)
        num = 1;
    else
        nums = [];
        for i = 1:length(files)
            name = files(i).name;
            numStr = regexp(name, [pattern, '(\d+)'], 'tokens');
            if ~isempty(numStr)
                nums(end+1) = str2double(numStr{1}{1});
            end
        end
        num = max(nums) + 1;
    end
    
    filename = sprintf('%s%04d', pattern, num);
end

function filename = generateParameterBasedFilename(params)
    % 基于参数生成文件名
    if isfield(params, 'width') && isfield(params, 'height')
        filename = sprintf('Pattern_%dx%d_%s', params.width, params.height, datestr(now, 'HHMMSS'));
    else
        filename = ['Pattern_', datestr(now, 'yyyymmdd_HHMMSS')];
    end
end

function infoText = generateParameterInfo(imageInfo, params)
    % 生成参数信息文本
    infoText = sprintf(['图像信息:\n', ...
        '生成时间: %s\n', ...
        '图像类型: %s\n', ...
        '版权信息: © 个人Z.Y团队Y.M\n\n'], ...
        datestr(now), imageInfo);
    
    if isfield(params, 'width')
        infoText = [infoText, sprintf('宽度: %d 像素\n', params.width)];
    end
    if isfield(params, 'height')
        infoText = [infoText, sprintf('高度: %d 像素\n', params.height)];
    end
    if isfield(params, 'wavelength')
        infoText = [infoText, sprintf('波长: %.1f nm\n', params.wavelength)];
    end
end

function processedImage = addWatermark(image)
    % 添加版权水印
    processedImage = image;
    if size(image, 3) == 1
        % 灰度图像
        watermarkText = '© 个人Z.Y团队Y.M';
        processedImage = insertText(processedImage, [10, size(image,1)-30], watermarkText, ...
            'FontSize', 12, 'BoxColor', 'white', 'BoxOpacity', 0.7);
    end
end

function saveImageWithQuality(image, filepath, formatIdx, qualityIdx)
    % 根据格式和质量保存图像
    
    qualityValues = [100, 95, 85, 75]; % 质量级别
    quality = qualityValues(qualityIdx);
    
    switch formatIdx
        case 1 % PNG
            imwrite(image, filepath, 'png');
        case 2 % TIFF
            imwrite(image, filepath, 'tiff', 'Compression', 'none');
        case 3 % JPEG
            imwrite(image, filepath, 'jpg', 'Quality', quality);
        case 4 % BMP
            imwrite(image, filepath, 'bmp');
        case 5 % MAT
            imageData = image;
            save(filepath, 'imageData');
    end
end

function saveParameterFile(imagePath, imageInfo, params)
    % 保存参数信息文件
    [pathStr, name, ~] = fileparts(imagePath);
    paramPath = fullfile(pathStr, [name, '_parameters.txt']);
    
    fid = fopen(paramPath, 'w');
    if fid ~= -1
        fprintf(fid, '全息曝光图像参数文件\n');
        fprintf(fid, '版权所有 © 个人Z.Y团队Y.M\n');
        fprintf(fid, '生成时间: %s\n\n', datestr(now));
        fprintf(fid, '图像信息: %s\n\n', imageInfo);
        
        if isstruct(params)
            fields = fieldnames(params);
            for i = 1:length(fields)
                fprintf(fid, '%s: %s\n', fields{i}, num2str(params.(fields{i})));
            end
        end
        
        fclose(fid);
    end
end

function saveMatlabFile(imagePath, imageData, imageInfo, params)
    % 保存MATLAB数据文件
    [pathStr, name, ~] = fileparts(imagePath);
    matPath = fullfile(pathStr, [name, '_data.mat']);
    
    save(matPath, 'imageData', 'imageInfo', 'params');
end

function createBackup(filepath)
    % 创建备份文件
    [pathStr, name, ext] = fileparts(filepath);
    backupPath = fullfile(pathStr, [name, '_backup_', datestr(now, 'HHMMSS'), ext]);
    copyfile(filepath, backupPath);
end
