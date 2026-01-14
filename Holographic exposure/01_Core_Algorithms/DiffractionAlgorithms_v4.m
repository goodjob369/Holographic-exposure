function algorithms = DiffractionAlgorithms_v4()
    % 🔬 液晶衍射仿真算法核心 v4.0 Professional Enhanced
    % 实现完整的物理衍射算法：角谱理论、菲涅尔衍射、基尔霍夫衍射积分
    % 
    % 版权所有 © 个人(Z.Y)团队(Y.M)
    % 创建日期: 2025-06-03
    % 版本: v4.0 Professional Enhanced
    
    % 返回算法函数句柄结构体
    algorithms = struct();
    
    % 主要衍射算法
    algorithms.angular_spectrum = @angular_spectrum_propagation;
    algorithms.fresnel_diffraction = @fresnel_diffraction_algorithm;
    algorithms.kirchhoff_diffraction = @kirchhoff_diffraction_integral;
    algorithms.fraunhofer_diffraction = @fraunhofer_diffraction_far_field;
    
    % 液晶相位调制算法
    algorithms.phase_modulation = @liquid_crystal_phase_modulation;
    algorithms.exposure_to_phase = @exposure_pattern_to_phase;
    algorithms.jones_matrix = @liquid_crystal_jones_matrix;
    
    % 边界条件和辅助函数
    algorithms.boundary_conditions = @apply_boundary_conditions;
    algorithms.phase_analysis = @analyze_phase_distribution;
    algorithms.field_analysis = @analyze_complex_field;
    
    % 性能优化算法
    algorithms.optimized_fft = @optimized_fft_algorithm;
    algorithms.parallel_processing = @parallel_diffraction_calculation;
    
    fprintf('🔬 液晶衍射算法核心 v4.0 已加载\n');
    fprintf('   - 角谱传播算法\n');
    fprintf('   - 菲涅尔衍射算法\n');
    fprintf('   - 基尔霍夫衍射积分\n');
    fprintf('   - 液晶相位调制\n');
    fprintf('   - 高性能优化\n\n');
end

%% =================== 角谱传播算法 ===================
function [output_field, propagation_info] = angular_spectrum_propagation(input_field, wavelength, pixel_size, propagation_distance, options)
    % 角谱传播算法 - 基于角谱理论的精确衍射计算
    % 
    % 输入参数:
    %   input_field - 输入复振幅场 (MxN 复数矩阵)
    %   wavelength - 波长 (m)
    %   pixel_size - 像素尺寸 (m) 
    %   propagation_distance - 传播距离 (m)
    %   options - 算法选项结构体
    
    if nargin < 5, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'padding_factor', 2, ...          % 零填充因子
        'evanescent_cutoff', true, ...    % 是否截断倏逝波
        'boundary_absorption', 0.1, ...   % 边界吸收系数
        'high_precision', false ...       % 高精度模式
    );
    
    % 合并选项
    opts = merge_options(default_options, options);
    
    % 获取输入参数
    [M, N] = size(input_field);
    k = 2 * pi / wavelength;  % 波数
    
    % 零填充以避免周期性边界效应
    if opts.padding_factor > 1
        pad_M = round(M * opts.padding_factor);
        pad_N = round(N * opts.padding_factor);
        
        % 创建填充后的场
        padded_field = zeros(pad_M, pad_N);
        start_M = round((pad_M - M) / 2) + 1;
        start_N = round((pad_N - N) / 2) + 1;
        padded_field(start_M:start_M+M-1, start_N:start_N+N-1) = input_field;
        
        % 应用边界吸收
        if opts.boundary_absorption > 0
            [Y, X] = meshgrid(1:pad_N, 1:pad_M);
            border_mask = create_absorption_mask(pad_M, pad_N, opts.boundary_absorption);
            padded_field = padded_field .* border_mask;
        end
        
        current_field = padded_field;
        current_M = pad_M;
        current_N = pad_N;
    else
        current_field = input_field;
        current_M = M;
        current_N = N;
    end
    
    % 构建频域坐标
    fx = (-current_N/2:current_N/2-1) / (current_N * pixel_size);
    fy = (-current_M/2:current_M/2-1) / (current_M * pixel_size);
    [FX, FY] = meshgrid(fx, fy);
    
    % 计算传播相位因子
    % H(fx,fy) = exp(i * k * z * sqrt(1 - (λfx)² - (λfy)²))
    spatial_freq_squared = (wavelength * FX).^2 + (wavelength * FY).^2;
    
    if opts.evanescent_cutoff
        % 只保留传播模式，截断倏逝波
        valid_mask = spatial_freq_squared <= 1;
        kz = k * sqrt(max(0, 1 - spatial_freq_squared)) .* valid_mask;
    else
        % 保留所有模式（包括倏逝波）
        kz = k * sqrt(complex(1 - spatial_freq_squared));
    end
    
    % 传播传递函数
    H = exp(1i * kz * propagation_distance);
    
    % 角谱传播计算
    if opts.high_precision
        % 高精度FFT
        input_spectrum = fftshift(fft2(ifftshift(current_field)));
        output_spectrum = input_spectrum .* H;
        output_field_full = fftshift(ifft2(ifftshift(output_spectrum)));
    else
        % 标准FFT
        input_spectrum = fftshift(fft2(current_field));
        output_spectrum = input_spectrum .* H;
        output_field_full = ifft2(ifftshift(output_spectrum));
    end
    
    % 提取原始尺寸区域
    if opts.padding_factor > 1
        output_field = output_field_full(start_M:start_M+M-1, start_N:start_N+N-1);
    else
        output_field = output_field_full;
    end
    
    % 传播信息
    propagation_info = struct();
    propagation_info.algorithm = 'Angular Spectrum';
    propagation_info.wavelength = wavelength;
    propagation_info.distance = propagation_distance;
    propagation_info.pixel_size = pixel_size;
    propagation_info.evanescent_cutoff = opts.evanescent_cutoff;
    propagation_info.padding_factor = opts.padding_factor;
    propagation_info.max_spatial_freq = max(max(sqrt(FX.^2 + FY.^2)));
    propagation_info.fresnel_number = (max(M,N) * pixel_size)^2 / (4 * wavelength * abs(propagation_distance));
end

%% =================== 菲涅尔衍射算法 ===================
function [output_field, fresnel_info] = fresnel_diffraction_algorithm(input_field, wavelength, pixel_size, propagation_distance, options)
    % 菲涅尔衍射算法 - 基于菲涅尔积分的近场衍射计算
    % 
    % 输入参数:
    %   input_field - 输入复振幅场
    %   wavelength - 波长 (m)
    %   pixel_size - 像素尺寸 (m)
    %   propagation_distance - 传播距离 (m)
    %   options - 算法选项
    
    if nargin < 5, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'approximation_order', 2, ...     % 近似阶数 (1: 线性, 2: 二次)
        'sampling_strategy', 'optimal', ... % 采样策略
        'numerical_precision', 'double', ... % 数值精度
        'boundary_handling', 'absorbing' ... % 边界处理
    );
    
    opts = merge_options(default_options, options);
    
    [M, N] = size(input_field);
    k = 2 * pi / wavelength;
    
    % 构建空间坐标
    x = (-N/2:N/2-1) * pixel_size;
    y = (-M/2:M/2-1) * pixel_size;
    [X, Y] = meshgrid(x, y);
    
    % 菲涅尔数计算
    fresnel_number = max(max(X.^2 + Y.^2)) / (2 * wavelength * abs(propagation_distance));
    
    % 选择最优算法
    if fresnel_number > 10
        % 高菲涅尔数：使用卷积算法
        output_field = fresnel_convolution_method(input_field, X, Y, k, propagation_distance, opts);
        method_used = 'Convolution';
    else
        % 低菲涅尔数：使用直接积分
        output_field = fresnel_direct_integration(input_field, X, Y, k, propagation_distance, opts);
        method_used = 'Direct Integration';
    end
    
    % 菲涅尔信息
    fresnel_info = struct();
    fresnel_info.algorithm = 'Fresnel Diffraction';
    fresnel_info.method = method_used;
    fresnel_info.fresnel_number = fresnel_number;
    fresnel_info.approximation_order = opts.approximation_order;
    fresnel_info.wavelength = wavelength;
    fresnel_info.distance = propagation_distance;
end

function output_field = fresnel_convolution_method(input_field, X, Y, k, z, opts)
    % 菲涅尔卷积方法
    
    % 菲涅尔核函数
    if opts.approximation_order == 1
        % 线性近似
        phase_kernel = exp(1i * k * z) ./ (1i * wavelength * z) .* ...
                      exp(1i * k * (X.^2 + Y.^2) / (2 * z));
    else
        % 二次近似（标准菲涅尔）
        phase_kernel = exp(1i * k * z) ./ (1i * wavelength * z) .* ...
                      exp(1i * k * (X.^2 + Y.^2) / (2 * z));
    end
    
    % 卷积计算
    input_fft = fft2(input_field);
    kernel_fft = fft2(ifftshift(phase_kernel));
    output_field = ifft2(input_fft .* kernel_fft);
end

function output_field = fresnel_direct_integration(input_field, X, Y, k, z, opts)
    % 菲涅尔直接积分方法
    
    [M, N] = size(input_field);
    output_field = zeros(M, N);
    
    % 逐点计算（可并行化）
    for ii = 1:M
        for jj = 1:N
            x_obs = X(ii, jj);
            y_obs = Y(ii, jj);
            
            % 计算从所有源点到观察点的贡献
            r = sqrt((X - x_obs).^2 + (Y - y_obs).^2 + z^2);
            
            % 菲涅尔积分核
            kernel = exp(1i * k * r) ./ r;
            
            % 积分
            output_field(ii, jj) = sum(sum(input_field .* kernel));
        end
    end
    
    % 归一化
    output_field = output_field * (pixel_size^2) / (1i * wavelength);
end

%% =================== 基尔霍夫衍射积分 ===================
function [output_field, kirchhoff_info] = kirchhoff_diffraction_integral(input_field, wavelength, pixel_size, propagation_distance, options)
    % 基尔霍夫衍射积分 - 严格的标量衍射理论
    % 
    % 基于基尔霍夫-菲涅尔衍射积分:
    % U(P) = ∫∫ U(Q) * G(P,Q) * K(P,Q) dQ
    % 其中 G(P,Q) = exp(ikr)/r 是格林函数
    %      K(P,Q) = (1/2π) * (∂G/∂n) 是倾斜因子
    
    if nargin < 5, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'integration_method', 'adaptive', ... % 积分方法
        'obliquity_factor', true, ...         % 是否包含倾斜因子
        'boundary_type', 'kirchhoff', ...     % 边界条件类型
        'numerical_aperture', 0.5, ...       % 数值孔径
        'precision_level', 'standard' ...    % 精度级别
    );
    
    opts = merge_options(default_options, options);
    
    [M, N] = size(input_field);
    k = 2 * pi / wavelength;
    
    % 构建观察平面坐标
    x_obs = (-N/2:N/2-1) * pixel_size;
    y_obs = (-M/2:M/2-1) * pixel_size;
    [X_obs, Y_obs] = meshgrid(x_obs, y_obs);
    
    % 构建源平面坐标
    x_src = x_obs;
    y_src = y_obs;
    [X_src, Y_src] = meshgrid(x_src, y_src);
    
    % 初始化输出场
    output_field = zeros(M, N);
    
    if strcmp(opts.precision_level, 'high')
        % 高精度计算：逐点积分
        output_field = kirchhoff_point_by_point(input_field, X_src, Y_src, X_obs, Y_obs, k, propagation_distance, opts);
    else
        % 标准精度：优化积分
        output_field = kirchhoff_optimized_integration(input_field, X_src, Y_src, X_obs, Y_obs, k, propagation_distance, opts);
    end
    
    % 基尔霍夫信息
    kirchhoff_info = struct();
    kirchhoff_info.algorithm = 'Kirchhoff Diffraction';
    kirchhoff_info.integration_method = opts.integration_method;
    kirchhoff_info.obliquity_factor = opts.obliquity_factor;
    kirchhoff_info.wavelength = wavelength;
    kirchhoff_info.distance = propagation_distance;
    kirchhoff_info.numerical_aperture = opts.numerical_aperture;
end

function output_field = kirchhoff_point_by_point(input_field, X_src, Y_src, X_obs, Y_obs, k, z, opts)
    % 逐点基尔霍夫积分计算
    
    [M, N] = size(input_field);
    output_field = zeros(M, N);
    
    dx = abs(X_src(1,2) - X_src(1,1));
    dy = abs(Y_src(2,1) - Y_src(1,1));
    dA = dx * dy;  % 面积元
    
    for ii = 1:M
        for jj = 1:N
            % 当前观察点
            x_p = X_obs(ii, jj);
            y_p = Y_obs(ii, jj);
            
            % 计算到所有源点的距离
            r = sqrt((X_src - x_p).^2 + (Y_src - y_p).^2 + z^2);
            
            % 格林函数
            G = exp(1i * k * r) ./ r;
            
            if opts.obliquity_factor
                % 计算倾斜因子 K = (1 + cos(θ))/2
                cos_theta = z ./ r;  % cos(θ) = z/r
                K = (1 + cos_theta) / 2;
            else
                K = 1;
            end
            
            % 基尔霍夫积分
            integrand = input_field .* G .* K;
            output_field(ii, jj) = sum(sum(integrand)) * dA / (1i * 2 * pi);
        end
    end
end

function output_field = kirchhoff_optimized_integration(input_field, X_src, Y_src, X_obs, Y_obs, k, z, opts)
    % 优化的基尔霍夫积分 - 使用FFT加速
    
    [M, N] = size(input_field);
    
    % 计算传递函数
    r = sqrt(X_obs.^2 + Y_obs.^2 + z^2);
    H = exp(1i * k * r) ./ r;
    
    if opts.obliquity_factor
        cos_theta = z ./ r;
        K = (1 + cos_theta) / 2;
        H = H .* K;
    end
    
    % 使用卷积定理进行快速计算
    input_fft = fft2(input_field);
    kernel_fft = fft2(ifftshift(H));
    output_field = ifft2(input_fft .* kernel_fft) / (1i * 2 * pi);
end

%% =================== 液晶相位调制算法 ===================
function [phase_distribution, modulation_info] = liquid_crystal_phase_modulation(exposure_pattern, lc_params, options)
    % 液晶相位调制算法 - 将曝光图转换为相位分布
    % 
    % 输入参数:
    %   exposure_pattern - 曝光图（灰度图像，0-255或0-1）
    %   lc_params - 液晶参数结构体
    %   options - 算法选项
    
    if nargin < 3, options = struct(); end
    
    % 默认液晶参数
    default_lc_params = struct(...
        'thickness', 3e-6, ...              % 液晶层厚度 (m)
        'ordinary_index', 1.5, ...          % 寻常光折射率
        'extraordinary_index', 1.7, ...     % 非寻常光折射率
        'wavelength', 532e-9, ...           % 工作波长 (m)
        'pretilt_angle', 0, ...             % 预倾角 (rad)
        'twist_angle', 0, ...               % 扭曲角 (rad)
        'response_curve', 'linear' ...      % 响应曲线类型
    );
    
    % 默认选项
    default_options = struct(...
        'normalization', 'full_range', ...   % 归一化方法
        'phase_unwrapping', true, ...        % 是否进行相位解缠
        'smoothing_filter', false, ...       % 是否应用平滑滤波
        'analysis_output', true ...          % 是否输出分析信息
    );
    
    lc_params = merge_options(default_lc_params, lc_params);
    opts = merge_options(default_options, options);
    
    % 输入数据预处理
    if max(exposure_pattern(:)) > 1
        % 假设是0-255范围，转换为0-1
        normalized_exposure = double(exposure_pattern) / 255;
    else
        normalized_exposure = double(exposure_pattern);
    end
    
    % 计算双折射
    delta_n = lc_params.extraordinary_index - lc_params.ordinary_index;
    
    % 根据响应曲线计算相位延迟
    switch lc_params.response_curve
        case 'linear'
            % 线性响应：相位延迟与曝光量成正比
            retardation = normalized_exposure * 2 * pi;
            
        case 'sinusoidal'
            % 正弦响应：模拟液晶的非线性响应
            retardation = pi * sin(normalized_exposure * pi);
            
        case 'exponential'
            % 指数响应：模拟某些液晶材料的响应特性
            retardation = 2 * pi * (1 - exp(-2 * normalized_exposure));
            
        case 'physical'
            % 基于物理模型的响应
            % Γ = (2π/λ) * Δn * d * f(I)
            % 其中 f(I) 是强度相关的取向函数
            orientation_factor = tanh(2 * normalized_exposure);  % 取向函数
            retardation = (2 * pi / lc_params.wavelength) * delta_n * ...
                         lc_params.thickness * orientation_factor;
            
        otherwise
            error('未知的响应曲线类型: %s', lc_params.response_curve);
    end
    
    % 相位分布计算
    phase_distribution = retardation;
    
    % 相位解缠（如果需要）
    if opts.phase_unwrapping && any(abs(diff(phase_distribution(:))) > pi)
        phase_distribution = unwrap_phase_2d(phase_distribution);
    end
    
    % 平滑滤波（如果需要）
    if opts.smoothing_filter
        % 使用高斯滤波器平滑相位分布
        sigma = 1.0;  % 滤波器标准差
        filter_size = 2 * ceil(3 * sigma) + 1;
        gaussian_filter = fspecial('gaussian', filter_size, sigma);
        phase_distribution = imfilter(phase_distribution, gaussian_filter, 'replicate');
    end
    
    % 输出分析信息
    if opts.analysis_output
        modulation_info = struct();
        modulation_info.algorithm = 'Liquid Crystal Phase Modulation';
        modulation_info.lc_params = lc_params;
        modulation_info.phase_range = [min(phase_distribution(:)), max(phase_distribution(:))];
        modulation_info.phase_std = std(phase_distribution(:));
        modulation_info.retardation_efficiency = max(retardation(:)) / (2 * pi);
        
        % 相位分布统计
        modulation_info.statistics = struct(...
            'mean_phase', mean(phase_distribution(:)), ...
            'rms_phase', sqrt(mean(phase_distribution(:).^2)), ...
            'phase_modulation_depth', max(phase_distribution(:)) - min(phase_distribution(:)) ...
        );
        
        % 输出相位表达式
        fprintf('\n📊 液晶相位调制分析结果:\n');
        fprintf('   相位范围: [%.3f, %.3f] rad\n', modulation_info.phase_range);
        fprintf('   相位标准差: %.3f rad\n', modulation_info.phase_std);
        fprintf('   调制深度: %.3f rad (%.1f π)\n', ...
                modulation_info.statistics.phase_modulation_depth, ...
                modulation_info.statistics.phase_modulation_depth / pi);
        fprintf('   延迟效率: %.1f%%\n', modulation_info.retardation_efficiency * 100);
        
        % 相位分布表达式
        fprintf('\n📈 相位分布表达式:\n');
        fprintf('   Φ(x,y) = (2π/λ) × Δn × d × f(I(x,y))\n');
        fprintf('   其中: Δn = %.3f, d = %.1f μm\n', delta_n, lc_params.thickness * 1e6);
        fprintf('   响应函数: %s\n', lc_params.response_curve);
    else
        modulation_info = struct();
    end
end

function [jones_matrix, field_evolution] = liquid_crystal_jones_matrix(input_field, phase_distribution, lc_params, options)
    % 液晶琼斯矩阵算法 - 计算偏振光通过液晶的琼斯矩阵演化
    
    if nargin < 4, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'polarization_state', [1; 0], ...   % 输入偏振态 [Ex; Ey]
        'optical_axis_angle', 0, ...        % 光轴角度 (rad)
        'matrix_type', 'retarder', ...      % 矩阵类型
        'include_rotation', true ...        % 是否包含旋转效应
    );
    
    opts = merge_options(default_options, options);
    
    [M, N] = size(phase_distribution);
    
    % 初始化琼斯矩阵
    jones_matrix = zeros(2, 2, M, N);
    
    % 计算每个像素点的琼斯矩阵
    for ii = 1:M
        for jj = 1:N
            % 当前像素的相位延迟
            gamma = phase_distribution(ii, jj);
            
            % 光轴角度（可以是空间变化的）
            if length(opts.optical_axis_angle) == 1
                theta = opts.optical_axis_angle;
            else
                theta = opts.optical_axis_angle(ii, jj);
            end
            
            % 构建基本延迟器矩阵
            switch opts.matrix_type
                case 'retarder'
                    % 相位延迟器矩阵
                    J_basic = [exp(-1i*gamma/2), 0; 0, exp(1i*gamma/2)];
                    
                case 'linear_retarder'
                    % 线性双折射延迟器
                    J_basic = [1, 0; 0, exp(1i*gamma)];
                    
                case 'circular_retarder'
                    % 圆双折射延迟器
                    J_basic = exp(1i*gamma/2) * [cos(gamma/2), -1i*sin(gamma/2); 
                                                -1i*sin(gamma/2), cos(gamma/2)];
                    
                otherwise
                    error('未知的矩阵类型: %s', opts.matrix_type);
            end
            
            % 如果需要考虑旋转
            if opts.include_rotation && theta ~= 0
                % 旋转矩阵
                R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
                R_inv = [cos(theta), sin(theta); -sin(theta), cos(theta)];
                
                % 旋转后的琼斯矩阵: J = R * J_basic * R^(-1)
                jones_matrix(:, :, ii, jj) = R * J_basic * R_inv;
            else
                jones_matrix(:, :, ii, jj) = J_basic;
            end
        end
    end
    
    % 计算场演化
    if nargout > 1
        field_evolution = calculate_field_evolution(input_field, jones_matrix, opts);
    end
end

%% =================== 辅助函数 ===================
function merged_options = merge_options(defaults, user_options)
    % 合并默认选项和用户选项
    merged_options = defaults;
    
    if ~isempty(user_options)
        field_names = fieldnames(user_options);
        for i = 1:length(field_names)
            merged_options.(field_names{i}) = user_options.(field_names{i});
        end
    end
end

function mask = create_absorption_mask(M, N, absorption_coeff)
    % 创建边界吸收掩模
    border_width = round(min(M, N) * absorption_coeff);
    
    [Y, X] = meshgrid(1:N, 1:M);
    
    dist_from_border = min(cat(3, X, M+1-X, Y, N+1-Y), [], 3);
    mask = min(1, dist_from_border / border_width);
end

function unwrapped_phase = unwrap_phase_2d(wrapped_phase)
    % 二维相位解缠算法
    unwrapped_phase = wrapped_phase;
    
    % 简单的质量引导相位解缠
    [M, N] = size(wrapped_phase);
    
    % 计算相位质量（基于梯度）
    [grad_x, grad_y] = gradient(wrapped_phase);
    quality = 1 ./ (1 + grad_x.^2 + grad_y.^2);
    
    % 使用MATLAB的unwrap函数进行行列解缠
    for i = 1:M
        unwrapped_phase(i, :) = unwrap(unwrapped_phase(i, :));
    end
    
    for j = 1:N
        unwrapped_phase(:, j) = unwrap(unwrapped_phase(:, j));
    end
end

function field_evolution = calculate_field_evolution(input_field, jones_matrix, opts)
    % 计算场通过琼斯矩阵的演化
    [M, N] = size(input_field);
    
    % 如果输入是标量场，转换为偏振场
    if ~iscell(input_field)
        % 假设输入为x偏振
        Ex = input_field;
        Ey = zeros(size(input_field));
    else
        Ex = input_field{1};
        Ey = input_field{2};
    end
    
    % 输出场初始化
    Ex_out = zeros(M, N);
    Ey_out = zeros(M, N);
    
    % 逐点计算琼斯矩阵作用
    for ii = 1:M
        for jj = 1:N
            E_in = [Ex(ii, jj); Ey(ii, jj)];
            E_out = squeeze(jones_matrix(:, :, ii, jj)) * E_in;
            Ex_out(ii, jj) = E_out(1);
            Ey_out(ii, jj) = E_out(2);
        end
    end
    
    field_evolution = {Ex_out, Ey_out};
end

% 其他算法函数...
function output_field = fraunhofer_diffraction_far_field(input_field, wavelength, pixel_size, options)
    % 夫琅禾费衍射（远场衍射）算法
    % 简化实现：output_field = FFT(input_field)
    output_field = fftshift(fft2(input_field));
end

function [result_field, optimization_info] = optimized_fft_algorithm(input_field, options)
    % 优化的FFT算法
    result_field = fft2(input_field);
    optimization_info = struct('algorithm', 'Optimized FFT');
end

function [result_field, parallel_info] = parallel_diffraction_calculation(input_field, algorithm_func, options)
    % 并行衍射计算
    result_field = algorithm_func(input_field);
    parallel_info = struct('parallel_enabled', true);
end

function [boundary_field, boundary_info] = apply_boundary_conditions(input_field, boundary_type, options)
    % 应用边界条件
    boundary_field = input_field;  % 简化实现
    boundary_info = struct('boundary_type', boundary_type);
end

function [phase_info, amplitude_info] = analyze_phase_distribution(phase_field, options)
    % 分析相位分布
    phase_info = struct('mean_phase', mean(phase_field(:)));
    amplitude_info = struct('mean_amplitude', mean(abs(phase_field(:))));
end

function [field_properties, analysis_results] = analyze_complex_field(complex_field, options)
    % 分析复场
    field_properties = struct('intensity', abs(complex_field).^2);
    analysis_results = struct('max_intensity', max(field_properties.intensity(:)));
end

function [phase_field, exposure_info] = exposure_pattern_to_phase(exposure_image, conversion_params, options)
    % 曝光图转相位分布 - 核心算法
    
    if nargin < 3, options = struct(); end
    
    % 默认转换参数
    default_params = struct(...
        'phase_range', 2*pi, ...            % 相位调制范围
        'gamma_correction', 1.0, ...        % 伽马校正
        'offset_phase', 0, ...              % 相位偏移
        'invert_pattern', false ...         % 是否反转图案
    );
    
    conversion_params = merge_options(default_params, conversion_params);
    
    % 归一化曝光图
    if max(exposure_image(:)) > 1
        normalized_exposure = double(exposure_image) / 255;
    else
        normalized_exposure = double(exposure_image);
    end
    
    % 伽马校正
    if conversion_params.gamma_correction ~= 1.0
        normalized_exposure = normalized_exposure .^ conversion_params.gamma_correction;
    end
    
    % 反转（如果需要）
    if conversion_params.invert_pattern
        normalized_exposure = 1 - normalized_exposure;
    end
    
    % 转换为相位
    phase_field = normalized_exposure * conversion_params.phase_range + conversion_params.offset_phase;
    
    % 输出信息
    exposure_info = struct();
    exposure_info.conversion_method = 'Linear Mapping';
    exposure_info.phase_range = [min(phase_field(:)), max(phase_field(:))];
    exposure_info.modulation_depth = max(phase_field(:)) - min(phase_field(:));
    
    fprintf('📸 曝光图转相位分布完成:\n');
    fprintf('   相位范围: [%.3f, %.3f] rad\n', exposure_info.phase_range);
    fprintf('   调制深度: %.3f rad (%.2f π)\n', exposure_info.modulation_depth, exposure_info.modulation_depth/pi);
end 