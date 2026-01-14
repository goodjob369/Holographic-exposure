# 全息曝光图生成器 (Holographic Exposure Generator)

## 版本: V5.0
## 版权所有 © 西北工业大学 Y.Z
## 联系邮箱: yangzhen2971@mail.nwpu.edu.cn

---

## 目录结构

```
Holographic exposure/
├── ExposureGenerator_Complete_Final.m    # 主程序 (V4.0.0完整功能版)
├── start_holographic_exposure.m          # 启动脚本
├── README.md                             # 本说明文件
│
├── 01_Core_Algorithms/                   # 核心算法模块
│   ├── AdvancedPolarizationGratingAlgorithms.m  # 高级偏振光栅算法(17种)
│   ├── DiffractionAlgorithmModule.m             # 衍射算法模块
│   ├── DiffractionAlgorithms_v4.m               # 衍射算法V4
│   ├── LCDiffractionAlgorithms.m                # 液晶衍射算法
│   └── PolarizationGratingAlgorithms_v5.m       # 偏振光栅算法V5
│
├── 02_Helper_Functions/                  # 辅助函数模块
│   ├── ExposureGeneratorHelpers.m        # 曝光图生成器辅助函数
│   ├── ExposureGeneratorCallbacks.m      # 回调函数
│   ├── PolarizationGratingAlgorithms_Enhanced.m  # 增强偏振光栅算法
│   ├── ProfessionalSaveInterface.m       # 专业保存界面
│   ├── ProfessionalSystemInfoGUI.m       # 系统信息GUI
│   ├── SLM_Optical_Formulas.m            # SLM光学公式
│   └── SLM_Polarization_Algorithms.m     # SLM偏振算法
│
├── 03_ColorMaps/                         # 颜色映射模块
│   ├── slanCM.m                          # 颜色映射函数
│   └── slanCM_Data.mat                   # 颜色映射数据
│
├── 04_Visualization/                     # 可视化工具模块
│   ├── plot_gradient_compare.m           # 梯度对比绘图
│   ├── plot_gradient_compare_enhanced.m  # 增强梯度对比绘图
│   ├── ProfessionalColorSelectorGUI.m    # 专业颜色选择器
│   └── ColorSelectionGUI_v3.m            # 颜色选择GUI V3
│
└── 05_LiquidCrystal_Algorithms/          # 液晶算法模块
    ├── LiquidCrystalDiffractionSimulator.m           # 液晶衍射模拟器
    ├── LiquidCrystalDiffractionAlgorithms.m          # 液晶衍射算法
    └── LiquidCrystalDiffractionSimulator_Enhanced_v5_Final.m  # 增强版V5
```

---

## 快速启动

在MATLAB中运行:
```matlab
cd 'E:\OPTIC sumulation\Exposure\ExposureGenerator_Final\Holographic exposure'
start_holographic_exposure
```

或直接运行主程序:
```matlab
ExposureGenerator_Complete_Final
```

---

## 主要功能

### 1. Ronchi光栅生成
- 水平/垂直方向光栅
- 可调周期

### 2. 灰度图生成 (7种类型)
- 水平梯度、垂直梯度、径向梯度
- 同心圆梯度、棋盘格、随机噪声、固定灰度

### 3. 图像处理
- 灰度化、二值化、反色、直方图均衡

### 4. 偏振光栅生成 (6种类型)
- 线性偏振、圆偏振、涡旋光束
- 径向偏振、角向偏振、二维光栅

### 5. 个性化偏振光栅 (15种科学研究类型)
- 矩形9点阵列、六边形9点阵列
- 相位光栅、Pancharatnam-Berry光栅
- 可调谐液晶聚合物、带宽展宽光栅
- 大角度光栅、闪耀光栅、涡旋光栅
- 手性光子晶体、超材料光栅、全息光栅
- 自适应可调光栅、多波长光栅、梯度折射率光栅

### 6. SLM转换功能
- 灰度值与偏振角度线性关系校准
- 公式: 灰度值 = 斜率系数 × 角度 + 截距

### 7. 边界设置
- 可调边界宽度和灰度值

### 8. 多单位支持
- 像素尺寸: nm, μm, mm
- 波长: nm, μm, mm

---

## 技术规格

- MATLAB版本: R2020b及以上
- 依赖工具箱: Image Processing Toolbox

---

## 更新历史

- V5.0 - 2025.06.30 - 加入SLM曲线校准，图像拟合以及保存图像
- V4.0.0 - 2024.12.15 - 完整功能版本，包含所有原始功能

