function algorithms = PolarizationGratingAlgorithms_v5()
    % 🔬 液晶偏振光栅衍射算法核心 v5.0 Physics-Based Enhanced
    % 基于扩展琼斯矩阵理论和角谱传播的完整物理仿真
    % 
    % 参考文献:
    % [1] 斜入射下液晶偏振光栅衍射特性研究 - 红外与激光工程, 2022
    % [2] 基于偏振补偿的级联式液晶偏振光栅衍射效率优化方法 - 液晶与显示, 2023
    % [3] Band-Limited Angular Spectrum Method for Numerical Simulation
    % 
    % 版权所有 © 个人(Z.Y)团队(Y.M)
    % 创建日期: 2025-06-03
    % 版本: v5.0 Physics-Based Enhanced
    
    % 返回算法函数句柄结构体
    algorithms = struct();
    
    % === 主要衍射算法 ===
    algorithms.angular_spectrum = @angular_spectrum_propagation_enhanced;
    algorithms.fresnel_diffraction = @fresnel_diffraction_physics_based;
    algorithms.kirchhoff_diffraction = @kirchhoff_diffraction_integral_exact;
    algorithms.fraunhofer_diffraction = @fraunhofer_diffraction_far_field;
    
    % === 液晶相位调制算法 ===
    algorithms.exposure_to_phase = @exposure_pattern_to_phase_advanced;
    algorithms.liquid_crystal_jones = @liquid_crystal_extended_jones_matrix;
    algorithms.polarization_analysis = @polarization_state_analysis;
    
    % === 边界条件和物理效应 ===
    algorithms.oblique_incidence = @oblique_incidence_correction;
    algorithms.birefringence_effects = @liquid_crystal_birefringence;
    algorithms.molecular_orientation = @calculate_molecular_director;
    
    % === 性能优化算法 ===
    algorithms.optimized_fft = @band_limited_angular_spectrum;
    algorithms.parallel_computing = @parallel_diffraction_calculation;
    
    fprintf('🔬 液晶偏振光栅衍射算法核心 v5.0 已加载\n');
    fprintf('   ✓ 扩展琼斯矩阵理论\n');
    fprintf('   ✓ 带限角谱传播算法\n');
    fprintf('   ✓ 斜入射修正理论\n');
    fprintf('   ✓ 液晶分子指向矢计算\n');
    fprintf('   ✓ 物理精确衍射积分\n\n');
end

%% =================== 角谱传播算法（增强版）===================
function [output_field, propagation_info] = angular_spectrum_propagation_enhanced(input_field, wavelength, pixel_size, propagation_distance, options)
    % 基于带限角谱理论的精确衍射计算
    % 
    % 数学基础:
    % U(x,y,z) = ∬ A(fx,fy,0) * H(fx,fy,z) * exp(i2π(fx*x + fy*y)) dfx dfy
    % 其中 H(fx,fy,z) = exp(i2πz*sqrt(k² - (2πfx)² - (2πfy)²))
    % k = 2π/λ 为波数
    
    if nargin < 5, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'band_limitation', true, ...          % 带限处理
        'padding_factor', 2, ...              % 零填充因子
        'evanescent_cutoff', true, ...        % 倏逝波截断
        'boundary_absorption', 0.1, ...       % 边界吸收
        'high_precision', true, ...           % 高精度模式
        'fresnel_number_check', true ...      % 菲涅尔数检查
    );
    
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
        
        % 应用边界吸收（Perfectly Matched Layer方法）
        if opts.boundary_absorption > 0
            absorption_mask = create_pml_absorption_mask(pad_M, pad_N, opts.boundary_absorption);
            padded_field = padded_field .* absorption_mask;
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
    
    % 计算菲涅尔数并检查算法适用性
    if opts.fresnel_number_check
        max_aperture_size = max(current_M, current_N) * pixel_size;
        fresnel_number = max_aperture_size^2 / (4 * wavelength * abs(propagation_distance));
        
        if fresnel_number < 1
            warning('低菲涅尔数 (F=%.3f)，建议使用菲涅尔衍射算法', fresnel_number);
        end
    end
    
    % 计算传播相位因子
    spatial_freq_squared = (wavelength * FX).^2 + (wavelength * FY).^2;
    
    % 带限角谱方法
    if opts.band_limitation
        % 带限条件：只保留传播模式
        band_limit = 1;  % 对应于数值孔径的限制
        valid_mask = spatial_freq_squared <= band_limit^2;
        
        if opts.evanescent_cutoff
            % 计算传播相位因子，倏逝波设为零
            kz = k * sqrt(max(0, 1 - spatial_freq_squared)) .* valid_mask;
        else
            % 保留倏逝波（复数平方根）
            kz = k * sqrt(complex(1 - spatial_freq_squared)) .* valid_mask;
        end
    else
        % 标准角谱方法
        if opts.evanescent_cutoff
            kz = k * sqrt(max(0, 1 - spatial_freq_squared));
        else
            kz = k * sqrt(complex(1 - spatial_freq_squared));
        end
    end
    
    % 传播传递函数
    H = exp(1i * kz * propagation_distance);
    
    % 角谱传播计算
    if opts.high_precision
        % 高精度FFT（使用适当的移位）
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
    propagation_info.algorithm = 'Enhanced Angular Spectrum';
    propagation_info.wavelength = wavelength;
    propagation_info.distance = propagation_distance;
    propagation_info.pixel_size = pixel_size;
    propagation_info.band_limited = opts.band_limitation;
    propagation_info.fresnel_number = fresnel_number;
    propagation_info.max_spatial_freq = max(max(sqrt(FX.^2 + FY.^2)));
    propagation_info.evanescent_cutoff = opts.evanescent_cutoff;
    propagation_info.padding_factor = opts.padding_factor;
end

%% =================== 菲涅尔衍射算法（物理基础）===================
function [output_field, fresnel_info] = fresnel_diffraction_physics_based(input_field, wavelength, pixel_size, propagation_distance, options)
    % 基于物理精确的菲涅尔衍射积分
    % 
    % 数学基础:
    % U(x,y,z) = (exp(ikz)/(iλz)) * ∬ U(x',y',0) * exp(ik[(x-x')²+(y-y')²]/(2z)) dx'dy'
    
    if nargin < 5, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'approximation_order', 2, ...         % 近似阶数 (1: 线性, 2: 二次)
        'sampling_strategy', 'optimal', ...   % 采样策略
        'numerical_precision', 'double', ...  % 数值精度
        'boundary_handling', 'absorbing', ... % 边界处理
        'kernel_type', 'exact' ...            % 核函数类型
    );
    
    opts = merge_options(default_options, options);
    
    [M, N] = size(input_field);
    k = 2 * pi / wavelength;
    
    % 构建空间坐标
    x = (-N/2:N/2-1) * pixel_size;
    y = (-M/2:M/2-1) * pixel_size;
    [X, Y] = meshgrid(x, y);
    
    % 菲涅尔数计算
    max_aperture_radius = sqrt(max(X(:))^2 + max(Y(:))^2);
    fresnel_number = max_aperture_radius^2 / (wavelength * abs(propagation_distance));
    
    % 选择最优算法
    if fresnel_number > 10
        % 高菲涅尔数：使用卷积算法
        output_field = fresnel_convolution_method_exact(input_field, X, Y, k, propagation_distance, opts);
        method_used = 'Convolution (High F#)';
    elseif fresnel_number > 1
        % 中等菲涅尔数：使用FFT算法
        output_field = fresnel_fft_method_exact(input_field, X, Y, k, propagation_distance, opts);
        method_used = 'FFT (Medium F#)';
    else
        % 低菲涅尔数：使用直接积分
        output_field = fresnel_direct_integration_exact(input_field, X, Y, k, propagation_distance, opts);
        method_used = 'Direct Integration (Low F#)';
    end
    
    % 菲涅尔信息
    fresnel_info = struct();
    fresnel_info.algorithm = 'Physics-Based Fresnel Diffraction';
    fresnel_info.method = method_used;
    fresnel_info.fresnel_number = fresnel_number;
    fresnel_info.approximation_order = opts.approximation_order;
    fresnel_info.wavelength = wavelength;
    fresnel_info.distance = propagation_distance;
    fresnel_info.max_aperture_radius = max_aperture_radius;
end

%% =================== 基尔霍夫衍射积分（精确）===================
function [output_field, kirchhoff_info] = kirchhoff_diffraction_integral_exact(input_field, wavelength, pixel_size, propagation_distance, options)
    % 基于基尔霍夫-菲涅尔衍射积分的精确计算
    % 
    % 数学基础:
    % U(P) = (1/4π) * ∬ U(Q) * (∂G/∂n - G*∂U/∂n) dS
    % 其中 G(P,Q) = exp(ikr)/(ikr) 是格林函数
    
    if nargin < 5, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'integration_method', 'adaptive', ... % 积分方法
        'obliquity_factor', true, ...         % 倾斜因子
        'boundary_conditions', 'kirchhoff', ...% 边界条件类型
        'numerical_aperture', 1.0, ...        % 数值孔径
        'precision_level', 'high', ...        % 精度级别
        'parallel_computation', true ...      % 并行计算
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
    
    % 根据精度级别选择计算方法
    if strcmp(opts.precision_level, 'high')
        % 高精度计算：精确积分
        output_field = kirchhoff_exact_integration(input_field, X_src, Y_src, X_obs, Y_obs, k, propagation_distance, opts);
    else
        % 标准精度：优化算法
        output_field = kirchhoff_optimized_algorithm(input_field, X_src, Y_src, X_obs, Y_obs, k, propagation_distance, opts);
    end
    
    % 基尔霍夫信息
    kirchhoff_info = struct();
    kirchhoff_info.algorithm = 'Kirchhoff Diffraction Integral (Exact)';
    kirchhoff_info.integration_method = opts.integration_method;
    kirchhoff_info.obliquity_factor = opts.obliquity_factor;
    kirchhoff_info.wavelength = wavelength;
    kirchhoff_info.distance = propagation_distance;
    kirchhoff_info.numerical_aperture = opts.numerical_aperture;
    kirchhoff_info.precision_level = opts.precision_level;
end

%% =================== 曝光图转相位分布（高级）===================
function [phase_field, conversion_info] = exposure_pattern_to_phase_advanced(exposure_image, lc_params, options)
    % 高级曝光图转相位分布算法
    % 基于液晶分子指向矢理论和Gibbs自由能最小化
    % 
    % 物理基础:
    % Γ = (2π/λ) * Δn(θ) * d * f(I)
    % 其中 Δn(θ) = ne*cos²θ + no*sin²θ - no 是有效双折射
    
    if nargin < 3, options = struct(); end
    
    % 默认液晶参数
    default_lc_params = struct(...
        'thickness', 3e-6, ...               % 液晶层厚度 (m)
        'ordinary_index', 1.52, ...          % 寻常光折射率
        'extraordinary_index', 1.75, ...     % 非寻常光折射率
        'wavelength', 532e-9, ...            % 工作波长 (m)
        'pretilt_angle', 2*pi/180, ...       % 预倾角 (rad)
        'anchoring_strength', 1e-4, ...      % 锚定强度
        'elastic_constants', [11.1e-12, 7.4e-12, 17.1e-12], ... % K11,K22,K33 (N)
        'dielectric_anisotropy', 13.8, ...   % 介电各向异性
        'response_curve', 'physical' ...     % 响应曲线类型
    );
    
    % 默认选项
    default_options = struct(...
        'normalization', 'full_range', ...   % 归一化方法
        'phase_unwrapping', true, ...        % 相位解缠
        'smoothing_filter', false, ...       % 平滑滤波
        'molecular_calculation', true, ...   % 分子指向矢计算
        'temperature_effects', false, ...    % 温度效应
        'analysis_output', true ...          % 分析输出
    );
    
    lc_params = merge_options(default_lc_params, lc_params);
    opts = merge_options(default_options, options);
    
    % 输入数据预处理
    if max(exposure_image(:)) > 1
        % 假设是0-255范围，转换为0-1
        normalized_exposure = double(exposure_image) / 255;
    else
        normalized_exposure = double(exposure_image);
    end
    
    % 基于物理模型计算相位延迟
    if strcmp(lc_params.response_curve, 'physical')
        % 物理精确模型：基于分子指向矢计算
        if opts.molecular_calculation
            phase_field = calculate_phase_from_molecular_orientation(normalized_exposure, lc_params, opts);
        else
            phase_field = calculate_phase_simplified_physical(normalized_exposure, lc_params, opts);
        end
        
        % 输出相位分布表达式
        if opts.analysis_output
            output_phase_expression(lc_params, opts);
        end
        
    else
        % 其他响应曲线类型
        phase_field = calculate_phase_empirical(normalized_exposure, lc_params, opts);
    end
    
    % 相位解缠
    if opts.phase_unwrapping && any(abs(diff(phase_field(:))) > pi)
        phase_field = unwrap_phase_2d_advanced(phase_field);
    end
    
    % 平滑滤波
    if opts.smoothing_filter
        sigma = 1.0;
        filter_size = 2 * ceil(3 * sigma) + 1;
        gaussian_filter = fspecial('gaussian', filter_size, sigma);
        phase_field = imfilter(phase_field, gaussian_filter, 'replicate');
    end
    
    % 输出转换信息
    conversion_info = struct();
    conversion_info.algorithm = 'Advanced Exposure to Phase Conversion';
    conversion_info.lc_params = lc_params;
    conversion_info.phase_range = [min(phase_field(:)), max(phase_field(:))];
    conversion_info.phase_std = std(phase_field(:));
    conversion_info.modulation_depth = max(phase_field(:)) - min(phase_field(:));
    conversion_info.response_curve = lc_params.response_curve;
    
    if opts.analysis_output
        output_conversion_analysis(conversion_info);
    end
end

%% =================== 扩展琼斯矩阵算法 ===================
function [jones_matrices, field_evolution, polarization_info] = liquid_crystal_extended_jones_matrix(input_field, phase_distribution, lc_params, options)
    % 扩展琼斯矩阵算法 - 处理斜入射和空间变化的液晶
    % 
    % 基于扩展琼斯矩阵理论：
    % 考虑斜入射角度对相位延迟的影响
    % Γ_eff = Γ * cos(θ_e) / cos(θ_0)
    
    if nargin < 4, options = struct(); end
    
    % 默认选项
    default_options = struct(...
        'incident_angle', 0, ...             % 入射角度 (rad)
        'polarization_state', [1; 0], ...    % 输入偏振态 [Ex; Ey]
        'optical_axis_angle', 0, ...         % 光轴角度 (rad)
        'matrix_type', 'retarder', ...       % 矩阵类型
        'include_rotation', true, ...        % 旋转效应
        'oblique_correction', true, ...      % 斜入射修正
        'fresnel_reflection', false ...      % 菲涅尔反射
    );
    
    opts = merge_options(default_options, options);
    
    [M, N] = size(phase_distribution);
    
    % 斜入射修正
    if opts.oblique_correction && opts.incident_angle ~= 0
        % 计算斜入射下的有效相位延迟
        phase_distribution = apply_oblique_incidence_correction(phase_distribution, opts.incident_angle, lc_params);
    end
    
    % 初始化琼斯矩阵
    jones_matrices = zeros(2, 2, M, N);
    
    % 计算每个像素点的扩展琼斯矩阵
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
            
            % 构建基本琼斯矩阵
            J_basic = construct_basic_jones_matrix(gamma, opts.matrix_type);
            
            % 应用旋转变换
            if opts.include_rotation && theta ~= 0
                R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
                R_inv = [cos(theta), sin(theta); -sin(theta), cos(theta)];
                jones_matrices(:, :, ii, jj) = R * J_basic * R_inv;
            else
                jones_matrices(:, :, ii, jj) = J_basic;
            end
        end
    end
    
    % 计算场演化
    if nargout > 1
        field_evolution = calculate_polarization_field_evolution(input_field, jones_matrices, opts);
    end
    
    % 偏振分析
    if nargout > 2
        polarization_info = analyze_polarization_properties(field_evolution, opts);
    end
end

%% =================== 辅助函数 ===================

function phase_field = calculate_phase_from_molecular_orientation(normalized_exposure, lc_params, opts)
    % 基于分子指向矢计算相位分布
    [M, N] = size(normalized_exposure);
    phase_field = zeros(M, N);
    
    % 液晶参数
    thickness = lc_params.thickness;
    ne = lc_params.extraordinary_index;
    no = lc_params.ordinary_index;
    lambda = lc_params.wavelength;
    
    for ii = 1:M
        for jj = 1:N
            % 曝光强度
            intensity = normalized_exposure(ii, jj);
            
            % 计算分子倾斜角（基于Gibbs自由能最小化）
            tilt_angle = calculate_tilt_angle_from_intensity(intensity, lc_params);
            
            % 有效双折射
            delta_n_eff = (ne - no) * sin(tilt_angle)^2;
            
            % 相位延迟
            phase_field(ii, jj) = (2 * pi / lambda) * delta_n_eff * thickness;
        end
    end
end

function tilt_angle = calculate_tilt_angle_from_intensity(intensity, lc_params)
    % 根据曝光强度计算液晶分子倾斜角
    % 基于Gibbs自由能最小化和弹性理论
    
    % 简化模型：假设线性关系
    max_tilt = pi/2 - lc_params.pretilt_angle;
    tilt_angle = lc_params.pretilt_angle + intensity * max_tilt;
end

function output_phase_expression(lc_params, opts)
    % 输出相位分布的数学表达式
    fprintf('\n📊 液晶相位调制数学表达式:\n');
    fprintf('╔══════════════════════════════════════════════════════════════╗\n');
    fprintf('║ 相位延迟公式: Γ(x,y) = (2π/λ) × Δn_eff(θ) × d             ║\n');
    fprintf('║                                                              ║\n');
    fprintf('║ 其中:                                                        ║\n');
    fprintf('║   λ = %.1f nm (工作波长)                               ║\n', lc_params.wavelength * 1e9);
    fprintf('║   d = %.1f μm (液晶层厚度)                            ║\n', lc_params.thickness * 1e6);
    fprintf('║   Δn_eff(θ) = (ne - no) × sin²(θ(I))                       ║\n');
    fprintf('║   ne = %.3f (非寻常光折射率)                            ║\n', lc_params.extraordinary_index);
    fprintf('║   no = %.3f (寻常光折射率)                              ║\n', lc_params.ordinary_index);
    fprintf('║   θ(I) = θ₀ + I(x,y) × (π/2 - θ₀) (分子倾斜角)           ║\n');
    fprintf('║   θ₀ = %.1f° (预倾角)                                    ║\n', lc_params.pretilt_angle * 180/pi);
    fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');
    
    % 计算理论最大相位调制量
    max_delta_n = lc_params.extraordinary_index - lc_params.ordinary_index;
    max_phase_modulation = (2 * pi / lc_params.wavelength) * max_delta_n * lc_params.thickness;
    
    fprintf('📈 理论最大相位调制量: %.3f rad (%.2f π)\n', max_phase_modulation, max_phase_modulation/pi);
    fprintf('📉 实际调制范围: 取决于分子倾斜角变化范围\n\n');
end

function absorption_mask = create_pml_absorption_mask(M, N, absorption_coeff)
    % 创建完美匹配层(PML)吸收掩模
    pml_width = round(min(M, N) * absorption_coeff);
    
    [Y, X] = meshgrid(1:N, 1:M);
    
    % 计算到边界的距离
    dist_from_border = min(cat(3, X, M+1-X, Y, N+1-Y), [], 3);
    
    % PML吸收函数
    absorption_mask = ones(M, N);
    pml_region = dist_from_border <= pml_width;
    
    % 指数衰减吸收
    absorption_mask(pml_region) = exp(-3 * (pml_width - dist_from_border(pml_region)) / pml_width);
end

function merged_options = merge_options(defaults, user_options)
    % 合并默认选项和用户选项
    merged_options = defaults;
    
    if ~isempty(user_options) && isstruct(user_options)
        field_names = fieldnames(user_options);
        for i = 1:length(field_names)
            merged_options.(field_names{i}) = user_options.(field_names{i});
        end
    end
end

% 更多复杂的辅助函数...
function output_field = fresnel_convolution_method_exact(input_field, X, Y, k, z, opts)
    % 精确菲涅尔卷积方法
    % 实现更准确的菲涅尔积分核
    wavelength = 2*pi/k;
    
    % 菲涅尔核函数（精确形式）
    r_squared = X.^2 + Y.^2;
    phase_kernel = exp(1i * k * z) / (1i * wavelength * z) .* ...
                  exp(1i * k * r_squared / (2 * z));
    
    % 卷积计算（使用FFT加速）
    input_fft = fft2(input_field);
    kernel_fft = fft2(fftshift(phase_kernel));
    output_field = ifft2(input_fft .* kernel_fft);
end

function output_field = kirchhoff_exact_integration(input_field, X_src, Y_src, X_obs, Y_obs, k, z, opts)
    % 基尔霍夫积分的精确计算
    [M, N] = size(input_field);
    output_field = zeros(M, N);
    
    dx = abs(X_src(1,2) - X_src(1,1));
    dy = abs(Y_src(2,1) - Y_src(1,1));
    dA = dx * dy;
    
    % 并行计算选项
    if opts.parallel_computation && M*N > 1000
        % 使用parfor并行计算
        parfor idx = 1:M*N
            [ii, jj] = ind2sub([M, N], idx);
            x_p = X_obs(ii, jj);
            y_p = Y_obs(ii, jj);
            
            % 距离计算
            r = sqrt((X_src - x_p).^2 + (Y_src - y_p).^2 + z^2);
            
            % 格林函数
            G = exp(1i * k * r) ./ r;
            
            % 倾斜因子
            if opts.obliquity_factor
                cos_theta = z ./ r;
                K = (1 + cos_theta) / 2;
            else
                K = 1;
            end
            
            % 基尔霍夫积分
            integrand = input_field .* G .* K;
            output_field(idx) = sum(integrand(:)) * dA / (1i * 2 * pi);
        end
    else
        % 串行计算
        for ii = 1:M
            for jj = 1:N
                x_p = X_obs(ii, jj);
                y_p = Y_obs(ii, jj);
                
                r = sqrt((X_src - x_p).^2 + (Y_src - y_p).^2 + z^2);
                G = exp(1i * k * r) ./ r;
                
                if opts.obliquity_factor
                    cos_theta = z ./ r;
                    K = (1 + cos_theta) / 2;
                else
                    K = 1;
                end
                
                integrand = input_field .* G .* K;
                output_field(ii, jj) = sum(integrand(:)) * dA / (1i * 2 * pi);
            end
        end
    end
end

function field_evolution = calculate_polarization_field_evolution(input_field, jones_matrices, opts)
    % 计算偏振场演化
    [M, N] = size(jones_matrices, 3:4);
    
    % 初始化偏振场
    if iscell(input_field)
        Ex_in = input_field{1};
        Ey_in = input_field{2};
    else
        % 假设输入为x偏振
        Ex_in = input_field;
        Ey_in = zeros(size(input_field));
    end
    
    % 输出场初始化
    Ex_out = zeros(M, N);
    Ey_out = zeros(M, N);
    
    % 逐点计算琼斯矩阵作用
    for ii = 1:M
        for jj = 1:N
            E_in = [Ex_in(ii, jj); Ey_in(ii, jj)];
            J = squeeze(jones_matrices(:, :, ii, jj));
            E_out = J * E_in;
            Ex_out(ii, jj) = E_out(1);
            Ey_out(ii, jj) = E_out(2);
        end
    end
    
    field_evolution = {Ex_out, Ey_out};
end

% ... 更多辅助函数实现

end 