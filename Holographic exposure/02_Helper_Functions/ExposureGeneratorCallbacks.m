% 回调函数实现部分

% Ronchi光栅生成函数
function generateRonchi(hObject, eventdata, handles)
    % 获取当前参数
    params = getCurrentParams(handles);
    
    % 获取Ronchi特定参数
    period = str2double(get(handles.editRonchiPeriod, 'String'));
    direction = get(get(handles.bgDirection, 'SelectedObject'), 'Tag');
    
    % 验证周期有效性
    if isnan(period) || period <= 0
        period = 50;
        set(handles.editRonchiPeriod, 'String', '50');
    end
    
    % 创建空白图像
    img = zeros(params.height, params.width);
    
    % 生成Ronchi光栅图案
    if strcmp(direction, 'horizontal')
        for i = 1:params.height
            for j = 1:params.width
                if mod(j, period) < period/2
                    img(i, j) = 255;
                else
                    img(i, j) = 0;
                end
            end
        end
    else % 垂直方向
        for i = 1:params.height
            for j = 1:params.width
                if mod(i, period) < period/2
                    img(i, j) = 255;
                else
                    img(i, j) = 0;
                end
            end
        end
    end
    
    % 显示图像
    axes(handles.axesImg);
    imshow(uint8(img));
    title('Ronchi光栅', 'FontSize', 12);
    
    % 存储当前图像
    setappdata(handles.fig, 'currentImage', img);
    
    % 计算物理周期 (考虑单位)
    physical_period = params.grating_width_mm / (params.width / period); % mm
    
    % 更新图像信息
    updateImageInfo(handles.textInfo, 'Ronchi光栅', params, sprintf('周期: %d 像素 (%.6f mm)', period, physical_period));
end

% 灰度图生成函数
function generateGray(hObject, eventdata, handles)
    % 获取当前参数
    params = getCurrentParams(handles);
    
    % 获取灰度图类型
    grayType = get(get(handles.bgGrayType, 'SelectedObject'), 'Tag');
    
    % 创建图像
    img = zeros(params.height, params.width);
    
    % 根据选择的类型生成不同的灰度图
    switch grayType
        case 'horizontal' % 水平渐变
            for j = 1:params.width
                img(:, j) = (j-1) * 255 / (params.width-1);
            end
            
        case 'vertical' % 垂直渐变
            for i = 1:params.height
                img(i, :) = (i-1) * 255 / (params.height-1);
            end
            
        case 'radial' % 径向渐变
            [X, Y] = meshgrid(1:params.width, 1:params.height);
            centerX = params.width/2;
            centerY = params.height/2;
            R = sqrt((X - centerX).^2 + (Y - centerY).^2);
            maxR = max(R(:));
            img = R / maxR * 255;
            
        case 'concentric' % 同心圆渐变
            [X, Y] = meshgrid(1:params.width, 1:params.height);
            centerX = params.width/2;
            centerY = params.height/2;
            R = sqrt((X - centerX).^2 + (Y - centerY).^2);
            % 确保合理的周期性
            scaleFactor = 255 / (min(params.width, params.height)/8);
            img = mod(R * scaleFactor, 256);
            
        case 'checkerboard' % 棋盘格
            checkerSize = min(params.width, params.height) / 20;
            [X, Y] = meshgrid(1:params.width, 1:params.height);
            img = mod(floor(X/checkerSize) + floor(Y/checkerSize), 2) * 255;
            
        case 'noise' % 随机噪声
            img = rand(params.height, params.width) * 255;
            
        case 'constant' % 固定灰度值
            grayValue = str2double(get(handles.editGrayValue, 'String'));
            
            % 验证灰度值有效性
            if isnan(grayValue) || grayValue < 0 || grayValue > 255
                grayValue = 128;
                set(handles.editGrayValue, 'String', '128');
            end
            
            img(:,:) = grayValue;
    end
    
    % 显示图像
    axes(handles.axesImg);
    imshow(uint8(img));
    title(['灰度图 (', grayType, ')'], 'FontSize', 12);
    
    % 存储当前图像
    setappdata(handles.fig, 'currentImage', img);
    
    % 更新图像信息
    updateImageInfo(handles.textInfo, ['灰度图 (', grayType, ')'], params, '');
end

% 浏览图像文件函数
function browseImage(hObject, eventdata, handles)
    % 打开文件浏览对话框
    [filename, pathname] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', '图像文件 (*.png, *.jpg, *.jpeg, *.bmp, *.tif)'}, '选择图像文件');
    
    if filename ~= 0
        % 显示选择的文件路径
        fullpath = fullfile(pathname, filename);
        set(handles.editImagePath, 'String', fullpath);
        setappdata(handles.fig, 'imagePath', fullpath);
        
        % 自动选择"从本地文件载入"选项
        set(findobj(handles.bgImageSource, 'Tag', 'local'), 'Value', 1);
    end
end

% 图像处理函数
function processImage(hObject, eventdata, handles)
    % 获取当前参数
    params = getCurrentParams(handles);
    
    % 获取图像来源和处理选项
    imageSource = get(get(handles.bgImageSource, 'SelectedObject'), 'Tag');
    processingType = get(get(handles.bgImageProcessing, 'SelectedObject'), 'Tag');
    
    % 根据来源获取图像
    if strcmp(imageSource, 'local')
        imagePath = get(handles.editImagePath, 'String');
        
        if isempty(imagePath) || ~exist(imagePath, 'file')
            errordlg('请先选择一个有效的图像文件。', '错误');
            return;
        end
        
        try
            % 读取图像
            img = imread(imagePath);
            sourceLabel = '本地图像';
        catch
            errordlg(['无法读取文件: ', imagePath], '错误');
            return;
        end
    else % 使用示例图像
        % 使用示例图像（可以是之前的校徽或其他示例图像）
        try
            img = imread('西北工业大学-logo-2048px.png');
            sourceLabel = '示例图像';
        catch
            % 如果找不到示例图像，创建一个简单的测试图像
            [X, Y] = meshgrid(linspace(-5, 5, params.width), linspace(-5, 5, params.height));
            R = sqrt(X.^2 + Y.^2);
            img = sin(R) .* exp(-0.1*R);
            img = (img - min(img(:))) / (max(img(:)) - min(img(:))) * 255;
            img = uint8(img);
            sourceLabel = '生成的示例图像';
        end
    end
    
    % 调整图像大小
    img = imresize(img, [params.height, params.width]);
    
    % 如果是彩色图像，先转为灰度图
    if size(img, 3) == 3
        grayImg = rgb2gray(img);
    else
        grayImg = img;
    end
    
    % 根据选择的处理选项处理图像
    switch processingType
        case 'grayscale'
            processedImg = grayImg;
            processLabel = '灰度转换';
            
        case 'binary'
            % 获取二值化阈值
            threshold = str2double(get(handles.editThreshold, 'String'));
            
            % 验证阈值有效性
            if isnan(threshold) || threshold < 0 || threshold > 1
                threshold = 0.5;
                set(handles.editThreshold, 'String', '0.5');
            end
            
            processedImg = imbinarize(grayImg, threshold) * 255;
            processLabel = ['二值化 (阈值=', num2str(threshold), ')'];
            
        case 'invert'
            processedImg = 255 - grayImg;
            processLabel = '反相';
            
        case 'histeq'
            processedImg = histeq(grayImg) * 255;
            processLabel = '直方图均衡化';
    end
    
    % 显示图像
    axes(handles.axesImg);
    imshow(uint8(processedImg));
    title(['图像处理: ', processLabel], 'FontSize', 12);
    
    % 存储当前图像
    setappdata(handles.fig, 'currentImage', processedImg);
    
    % 更新图像信息
    updateImageInfo(handles.textInfo, ['图像处理 (', processLabel, ')'], params, ['来源: ', sourceLabel]);
end

% 保存图像函数
function saveImage(hObject, eventdata, handles)
    % 获取当前图像
    currentImage = getappdata(handles.fig, 'currentImage');
    
    if ~isempty(currentImage)
        % 打开保存对话框
        [filename, pathname] = uiputfile({'*.png', 'PNG图像'; '*.tif', 'TIFF图像'; '*.bmp', 'BMP图像'}, '保存图像');
        
        if filename ~= 0
            % 保存图像
            imwrite(uint8(currentImage), fullfile(pathname, filename));
            msgbox(['图像已保存至: ', fullfile(pathname, filename)], '保存成功');
        end
    else
        msgbox('没有可保存的图像', '错误');
    end
end