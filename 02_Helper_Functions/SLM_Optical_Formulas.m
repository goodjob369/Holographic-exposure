function SLM_Optical_Formulas()
% SLM液晶曝光系统 - 光学原理与公式集合
% 版权所有 © 个人Z.Y团队Y.M

    % 创建公式帮助窗口
    formulaFig = figure('Name', 'SLM光学原理与公式', 'NumberTitle', 'off', ...
        'Position', [200, 200, 800, 600], 'MenuBar', 'none', 'ToolBar', 'none', ...
        'Resize', 'on', 'WindowStyle', 'normal');
    
    % 创建选项卡组
    tabGroup = uitabgroup(formulaFig, 'Position', [0.02, 0.02, 0.96, 0.96]);
    
    % 创建各个选项卡
    createBasicTheoryTab(tabGroup);
    createPolarizationTab(tabGroup);
    createDiffractionTab(tabGroup);
    createSLMParametersTab(tabGroup);
    createApplicationsTab(tabGroup);
end

% 基础理论选项卡
function createBasicTheoryTab(tabGroup)
    tab = uitab(tabGroup, 'Title', '基础理论');
    
    % 创建滚动面板
    panel = uipanel(tab, 'Position', [0.02, 0.02, 0.96, 0.96], ...
        'BorderType', 'none', 'BackgroundColor', [1 1 1]);
    
    % 理论内容
    theoryText = {
        '=== SLM液晶空间光调制器基础理论 ==='
        ''
        '1. 液晶双折射原理'
        '   • 寻常光折射率: n_o'
        '   • 非寻常光折射率: n_e'  
        '   • 双折射率: Δn = n_e - n_o'
        ''
        '2. 相位调制原理'
        '   相位延迟: δ = (2π/λ) × Δn × d'
        '   其中: λ - 光波长, d - 液晶厚度'
        ''
        '3. 电控双折射效应'
        '   Δn(V) = Δn_0 × [1 - (V/V_π)²]^(1/2)'
        '   其中: V_π - 半波电压'
        ''
        '4. 琼斯矩阵表示'
        '   液晶器件: J = R(-θ) × [e^(iδ_x), 0; 0, e^(iδ_y)] × R(θ)'
        '   其中: R(θ) - 旋转矩阵, θ - 液晶光轴角度'
        ''
        '5. 空间分辨率'
        '   最小特征尺寸: d_min ≈ λ/(2×NA)'
        '   其中: NA - 数值孔径'
        ''
        '6. 时间响应'
        '   上升时间: τ_on ∝ γ×d²/(K×π²)'
        '   下降时间: τ_off ∝ γ×d²/(K×π²×V²)'
        '   其中: γ - 旋转粘滞系数, K - 弹性常数'
    };
    
    % 显示理论文本
    uicontrol(panel, 'Style', 'text', 'String', theoryText, ...
        'Position', [20, 50, 740, 480], 'HorizontalAlignment', 'left', ...
        'FontSize', 11, 'FontName', 'Courier New', ...
        'BackgroundColor', [1 1 1], 'VerticalAlignment', 'top');
    
    % 添加参考文献按钮
    uicontrol(panel, 'Style', 'pushbutton', 'String', '查看参考文献', ...
        'Position', [20, 10, 120, 30], 'Callback', @showReferences);
end

% 偏振理论选项卡
function createPolarizationTab(tabGroup)
    tab = uitab(tabGroup, 'Title', '偏振理论');
    
    panel = uipanel(tab, 'Position', [0.02, 0.02, 0.96, 0.96], ...
        'BorderType', 'none', 'BackgroundColor', [1 1 1]);
    
    polarizationText = {
        '=== 偏振光栅理论与公式 ==='
        ''
        '1. 几何相位 (Pancharatnam-Berry Phase)'
        '   φ_PB = 2α'
        '   其中: α - 液晶分子取向角'
        ''
        '2. 偏振光栅衍射效率'
        '   η = sin²(πΔnd/λ) × sinc²(πΔφ/π)'
        '   其中: Δφ - 相位调制深度'
        ''
        '3. 线性偏振光栅'
        '   偏振角: θ(x) = πx/Λ + θ₀'
        '   琼斯向量: |E⟩ = [cos(θ), sin(θ)]^T'
        ''
        '4. 圆偏振光栅'
        '   左旋: |L⟩ = (1/√2)[1, -i]^T'
        '   右旋: |R⟩ = (1/√2)[1, +i]^T'
        '   椭圆度: χ = (1/2)arctan(b/a)'
        ''
        '5. 涡旋偏振光栅'
        '   相位: φ(θ) = lθ + φ₀'
        '   其中: l - 拓扑荷数, θ - 方位角'
        ''
        '6. 径向/方位偏振'
        '   径向: θ_r(θ) = θ'
        '   方位: θ_a(θ) = θ + π/2'
        ''
        '7. HSV色彩编码'
        '   色调(H): 偏振方向 θ/π'
        '   饱和度(S): 椭圆度 |sin(2χ)|'  
        '   明度(V): 强度 I/I_max'
        ''
        '8. 斯托克斯参数'
        '   S₀ = I_x + I_y (总强度)'
        '   S₁ = I_x - I_y (线性偏振度)'
        '   S₂ = I₄₅ - I₁₃₅ (±45°偏振差)'
        '   S₃ = I_R - I_L (圆偏振度)'
    };
    
    uicontrol(panel, 'Style', 'text', 'String', polarizationText, ...
        'Position', [20, 50, 740, 480], 'HorizontalAlignment', 'left', ...
        'FontSize', 11, 'FontName', 'Courier New', ...
        'BackgroundColor', [1 1 1], 'VerticalAlignment', 'top');
    
    % 添加偏振计算器按钮
    uicontrol(panel, 'Style', 'pushbutton', 'String', '偏振计算器', ...
        'Position', [20, 10, 120, 30], 'Callback', @openPolarizationCalculator);
end

% 衍射理论选项卡
function createDiffractionTab(tabGroup)
    tab = uitab(tabGroup, 'Title', '衍射理论');
    
    panel = uipanel(tab, 'Position', [0.02, 0.02, 0.96, 0.96], ...
        'BorderType', 'none', 'BackgroundColor', [1 1 1]);
    
    diffractionText = {
        '=== 光栅衍射理论与公式 ==='
        ''
        '1. 光栅方程'
        '   d(sinθ_m - sinθ_i) = mλ'
        '   其中: d - 光栅常数, m - 衍射级次'
        ''
        '2. 布拉格衍射条件'
        '   2n_eff Λ cos(φ) = λ'
        '   其中: n_eff - 有效折射率, Λ - 光栅周期, φ - 倾斜角'
        ''
        '3. 衍射效率'
        '   η_m = (I_m/I_0) × 100%'
        '   其中: I_m - m级衍射光强度, I_0 - 入射光强度'
        ''
        '4. Ronchi光栅'
        '   透射函数: t(x) = (1/2)[1 + sgn(cos(2πx/Λ))]'
        '   傅里叶级数: t(x) = (1/2) + (2/π)∑[sin(2πnx/Λ)/n]'
        ''
        '5. 正弦光栅'
        '   透射函数: t(x) = (1/2)[1 + m×cos(2πx/Λ + φ)]'
        '   其中: m - 调制度'
        ''
        '6. 相位光栅'
        '   透射函数: t(x) = exp[iφ(x)]'
        '   相位函数: φ(x) = φ₀ cos(2πx/Λ)'
        ''
        '7. 衍射角计算'
        '   θ_m = arcsin(mλ/Λ + sinθ_i)'
        '   最大衍射级次: m_max = floor(Λ/λ)'
        ''
        '8. 数值孔径与分辨率'
        '   NA = n×sinθ_max'
        '   瑞利判据: Δx = 0.61λ/NA'
        '   艾比判据: Δx = λ/(2×NA)'
        ''
        '9. 菲涅尔数'
        '   F = a²/(λz)'
        '   其中: a - 孔径半径, z - 传播距离'
    };
    
    uicontrol(panel, 'Style', 'text', 'String', diffractionText, ...
        'Position', [20, 50, 740, 480], 'HorizontalAlignment', 'left', ...
        'FontSize', 11, 'FontName', 'Courier New', ...
        'BackgroundColor', [1 1 1], 'VerticalAlignment', 'top');
    
    % 添加衍射计算器按钮
    uicontrol(panel, 'Style', 'pushbutton', 'String', '衍射计算器', ...
        'Position', [20, 10, 120, 30], 'Callback', @openDiffractionCalculator);
end

% SLM参数选项卡
function createSLMParametersTab(tabGroup)
    tab = uitab(tabGroup, 'Title', 'SLM参数');
    
    panel = uipanel(tab, 'Position', [0.02, 0.02, 0.96, 0.96], ...
        'BorderType', 'none', 'BackgroundColor', [1 1 1]);
    
    slmText = {
        '=== SLM设备参数与规格 ==='
        ''
        '1. 标准SLM规格 (0.7英寸)'
        '   分辨率: 1920 × 1200 像素'
        '   像素尺寸: 8.0 μm × 8.0 μm'
        '   有效面积: 15.36 mm × 9.60 mm'
        '   对角线: 18.1 mm (0.7")'
        ''
        '2. 物理参数计算'
        '   物理宽度: W = N_x × p_x'
        '   物理高度: H = N_y × p_y'
        '   其中: N - 像素数, p - 像素尺寸'
        ''
        '3. 分辨率与采样'
        '   空间频率: f_s = 1/p'
        '   奈奎斯特频率: f_N = 1/(2p)'
        '   最小周期: Λ_min = 2p'
        ''
        '4. 相位调制范围'
        '   相位调制深度: Δφ = 2π × Δn × d / λ'
        '   灰度级数: N_gray = 2^n (n为位深度)'
        '   相位精度: δφ = 2π/N_gray'
        ''
        '5. 时间特性'
        '   帧频: f_frame (Hz)'
        '   响应时间: τ_response (ms)'
        '   切换时间: τ_switch (ms)'
        ''
        '6. 光学参数'
        '   工作波长: λ = 532 nm (绿光典型)'
        '   偏振比: PER > 1000:1'
        '   填充因子: FF > 93%'
        '   衍射效率: η > 90%'
        ''
        '7. 环境参数'
        '   工作温度: 0°C ~ 40°C'
        '   存储温度: -20°C ~ 60°C'
        '   相对湿度: < 80% (无凝露)'
        ''
        '8. 曝光参数'
        '   曝光功率密度: P_density (mW/cm²)'
        '   曝光时间: t_exp (s)'
        '   曝光剂量: D = P_density × t_exp (mJ/cm²)'
    };
    
    uicontrol(panel, 'Style', 'text', 'String', slmText, ...
        'Position', [20, 50, 740, 480], 'HorizontalAlignment', 'left', ...
        'FontSize', 11, 'FontName', 'Courier New', ...
        'BackgroundColor', [1 1 1], 'VerticalAlignment', 'top');
    
    % 添加参数计算器按钮
    uicontrol(panel, 'Style', 'pushbutton', 'String', 'SLM计算器', ...
        'Position', [20, 10, 120, 30], 'Callback', @openSLMCalculator);
end

% 应用实例选项卡
function createApplicationsTab(tabGroup)
    tab = uitab(tabGroup, 'Title', '应用实例');
    
    panel = uipanel(tab, 'Position', [0.02, 0.02, 0.96, 0.96], ...
        'BorderType', 'none', 'BackgroundColor', [1 1 1]);
    
    applicationsText = {
        '=== SLM液晶曝光系统应用实例 ==='
        ''
        '1. 全息光刻'
        '   • 亚波长结构制备'
        '   • 周期性纳米结构'
        '   • 光子晶体制造'
        '   特征尺寸: λ/4 ~ λ/2'
        ''
        '2. 光学器件制造'
        '   • 衍射光学元件 (DOE)'
        '   • 计算全息图 (CGH)'  
        '   • 菲涅尔透镜'
        '   • 光栅耦合器'
        ''
        '3. 微纳加工'
        '   • 激光直写光刻'
        '   • 多光束干涉光刻'
        '   • 三维微结构'
        '   精度: < 100 nm'
        ''
        '4. 偏振器件'
        '   • 偏振光栅'
        '   • 波片阵列'
        '   • 偏振转换器'
        '   • 液晶取向层'
        ''
        '5. 光通信器件'
        '   • 波分复用器件'
        '   • 光开关'
        '   • 可调光衰减器'
        '   • 偏振控制器'
        ''
        '6. 显示技术'
        '   • 全息显示'
        '   • 3D显示'
        '   • 增强现实 (AR)'
        '   • 虚拟现实 (VR)'
        ''
        '7. 生物医学'
        '   • 光镊技术'
        '   • 光学相干断层扫描 (OCT)'
        '   • 荧光显微镜'
        '   • 激光治疗'
        ''
        '8. 科学研究'
        '   • 原子光学'
        '   • 量子光学'
        '   • 非线性光学'
        '   • 等离激元学'
    };
    
    uicontrol(panel, 'Style', 'text', 'String', applicationsText, ...
        'Position', [20, 50, 740, 480], 'HorizontalAlignment', 'left', ...
        'FontSize', 11, 'FontName', 'Courier New', ...
        'BackgroundColor', [1 1 1], 'VerticalAlignment', 'top');
    
    % 添加应用案例按钮
    uicontrol(panel, 'Style', 'pushbutton', 'String', '查看案例', ...
        'Position', [20, 10, 120, 30], 'Callback', @showApplicationCases);
end

% 回调函数
function showReferences(~,~)
    refText = {
        '主要参考文献:'
        ''
        '1. Yariv, A. & Yeh, P. Optical Waves in Crystals. Wiley (2003)'
        '2. Goodman, J. W. Introduction to Fourier Optics. McGraw-Hill (2005)'  
        '3. Born, M. & Wolf, E. Principles of Optics. Cambridge (1999)'
        '4. Saleh, B. & Teich, M. Fundamentals of Photonics. Wiley (2007)'
        '5. Yu, F. T. S. & Yang, X. Introduction to Optical Engineering. Cambridge (1997)'
        ''
        '液晶与SLM专业文献:'
        '6. Khoo, I. C. Liquid Crystals. Wiley (2007)'
        '7. Collings, P. J. Liquid Crystals. Princeton (2002)'
        '8. Lazarev, G. et al. Beyond the display. Optica 6, 1528-1540 (2019)'
        '9. Maurer, C. et al. What spatial light modulators can do for optical microscopy. Laser Photon. Rev. 5, 81-101 (2011)'
    };
    
    msgbox(refText, '参考文献', 'help');
end

function openPolarizationCalculator(~,~)
    msgbox('偏振计算器功能开发中...', '提示');
end

function openDiffractionCalculator(~,~)
    msgbox('衍射计算器功能开发中...', '提示');
end

function openSLMCalculator(~,~)
    msgbox('SLM参数计算器功能开发中...', '提示');
end

function showApplicationCases(~,~)
    msgbox('应用案例库功能开发中...', '提示');
end
