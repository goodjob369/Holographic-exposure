<p align="center">
  <img src="https://img.shields.io/badge/MATLAB-R2020b+-orange?style=for-the-badge&logo=mathworks" alt="MATLAB">
  <img src="https://img.shields.io/badge/Version-5.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey?style=for-the-badge" alt="Platform">
</p>

<h1 align="center">🔬 全息曝光图生成器</h1>
<h3 align="center">Holographic Exposure Pattern Generator</h3>

<p align="center">
  <strong>专业的光学曝光图案生成工具，支持多种偏振光栅和液晶光学元件设计</strong>
</p>

<p align="center">
  <a href="#-功能特性">功能特性</a> •
  <a href="#-快速开始">快速开始</a> •
  <a href="#-目录结构">目录结构</a> •
  <a href="#-使用指南">使用指南</a> •
  <a href="#-matlab封装">MATLAB封装</a> •
  <a href="#-许可证">许可证</a>
</p>

---

## 📋 项目简介

**全息曝光图生成器** 是一款专业的MATLAB GUI应用程序，用于生成各类光学曝光图案。该工具广泛应用于：

- 🔹 **液晶光学元件制造** - 偏振光栅、液晶透镜
- 🔹 **全息光学研究** - 全息光栅、衍射光学元件
- 🔹 **SLM空间光调制** - 相位调制、偏振控制
- 🔹 **科学研究** - 涡旋光束、矢量光束生成

### 👨‍🔬 作者信息

| 项目 | 信息 |
|------|------|
| **作者** | Y.Z |
| **单位** | 西北工业大学 |
| **邮箱** | yangzhen2971@mail.nwpu.edu.cn |
| **版本** | V5.0 |

---

## ✨ 功能特性

### 🎯 核心功能模块

<table>
<tr>
<td width="50%">

#### 1️⃣ Ronchi光栅生成
- ✅ 水平/垂直方向光栅
- ✅ 可调周期参数
- ✅ 实时预览

#### 2️⃣ 灰度图生成 (7种类型)
- ✅ 水平梯度
- ✅ 垂直梯度
- ✅ 径向梯度
- ✅ 同心圆梯度
- ✅ 棋盘格图案
- ✅ 随机噪声
- ✅ 固定灰度

#### 3️⃣ 图像处理
- ✅ 灰度化处理
- ✅ 二值化处理
- ✅ 反色处理
- ✅ 直方图均衡化

</td>
<td width="50%">

#### 4️⃣ 偏振光栅生成 (6种类型)
- ✅ 线性偏振光栅
- ✅ 圆偏振光栅
- ✅ 涡旋光束光栅
- ✅ 径向偏振光栅
- ✅ 角向偏振光栅
- ✅ 二维光栅

#### 5️⃣ 个性化偏振光栅 (15种)
- ✅ 矩形9点阵列
- ✅ 六边形9点阵列
- ✅ 相位光栅
- ✅ Pancharatnam-Berry光栅
- ✅ 可调谐液晶聚合物
- ✅ 带宽展宽光栅
- ✅ 大角度光栅
- ✅ 闪耀光栅
- ✅ 涡旋光栅
- ✅ 手性光子晶体
- ✅ 超材料光栅
- ✅ 全息光栅
- ✅ 自适应可调光栅
- ✅ 多波长光栅
- ✅ 梯度折射率光栅

</td>
</tr>
</table>

### 🔧 高级功能

| 功能 | 描述 |
|------|------|
| **SLM灰度转换** | 灰度值与偏振角度线性关系校准<br>`灰度值 = 斜率系数 × 角度 + 截距` |
| **边界设置** | 可调边界宽度和灰度值 |
| **多单位支持** | 像素尺寸: nm, μm, mm<br>波长: nm, μm, mm |
| **多格式保存** | PNG, TIFF, BMP, JPEG, EPS, PDF, SVG, FIG |
| **参数信息导出** | 自动保存生成参数到文本文件 |

---

## 🚀 快速开始

### 系统要求

- **MATLAB版本**: R2020b 或更高版本
- **必需工具箱**: Image Processing Toolbox
- **操作系统**: Windows / macOS / Linux

### 安装步骤

```bash
# 1. 克隆仓库
git clone https://github.com/your-username/HolographicExposureGenerator.git

# 2. 进入目录
cd HolographicExposureGenerator
```

### 启动程序

**方法一：使用启动脚本（推荐）**
```matlab
% 在MATLAB中运行
cd 'path/to/Holographic exposure'
start_holographic_exposure
```

**方法二：直接运行主程序**
```matlab
% 在MATLAB中运行
ExposureGenerator_Complete_Final
```

---

## 📁 目录结构

```
Holographic exposure/
│
├── 📄 ExposureGenerator_Complete_Final.m    # 🎯 主程序文件 (V4.0.0完整功能版)
├── 📄 start_holographic_exposure.m          # 🚀 启动脚本 (自动添加路径)
├── 📄 README.md                             # 📖 项目说明文档
│
├── 📂 01_Core_Algorithms/                   # 🧮 核心算法模块
│   ├── AdvancedPolarizationGratingAlgorithms.m
│   │   └── 高级偏振光栅算法库 (17种SCI期刊级算法)
│   │       - Dammann光栅、Fibonacci光栅
│   │       - 圆形Dammann光栅、PB相位光栅
│   │       - 聚合物稳定胆甾相光栅等
│   │
│   ├── DiffractionAlgorithmModule.m
│   │   └── 衍射算法模块
│   │       - 菲涅尔衍射、夫琅禾费衍射
│   │       - 角谱传播算法
│   │
│   ├── DiffractionAlgorithms_v4.m
│   │   └── 衍射算法V4版本
│   │       - 优化的FFT计算
│   │       - 多层介质传播
│   │
│   ├── LCDiffractionAlgorithms.m
│   │   └── 液晶衍射算法
│   │       - 琼斯矩阵计算
│   │       - 液晶分子取向模拟
│   │
│   └── PolarizationGratingAlgorithms_v5.m
│       └── 偏振光栅算法V5版本
│           - 几何相位计算
│           - 偏振态转换
│
├── 📂 02_Helper_Functions/                  # 🔧 辅助函数模块
│   ├── ExposureGeneratorHelpers.m
│   │   └── 曝光图生成器辅助函数
│   │       - getCurrentParams(): 获取当前参数
│   │       - updateImageInfo(): 更新图像信息
│   │       - showRonchiHelp(): 显示帮助信息
│   │
│   ├── ExposureGeneratorCallbacks.m
│   │   └── UI回调函数集合
│   │       - 按钮点击响应
│   │       - 参数变更处理
│   │
│   ├── PolarizationGratingAlgorithms_Enhanced.m
│   │   └── 增强版偏振光栅算法
│   │
│   ├── ProfessionalSaveInterface.m
│   │   └── 专业保存界面
│   │       - 多格式支持
│   │       - 分辨率设置
│   │       - 质量控制
│   │
│   ├── ProfessionalSystemInfoGUI.m
│   │   └── 系统信息GUI
│   │
│   ├── SLM_Optical_Formulas.m
│   │   └── SLM光学公式库
│   │       - 相位-灰度转换
│   │       - 衍射效率计算
│   │
│   └── SLM_Polarization_Algorithms.m
│       └── SLM偏振算法
│           - 偏振态控制
│           - 琼斯矢量计算
│
├── 📂 03_ColorMaps/                         # 🎨 颜色映射模块
│   └── slanCM.m
│       └── 轻量级科学颜色映射函数
│           - batlow: 科学可视化推荐
│           - viridis: 感知均匀色彩
│           - turbo: 彩虹改进版
│           - plasma/inferno/magma: 热力图色彩
│
├── 📂 04_Visualization/                     # 📊 可视化工具模块
│   ├── plot_gradient_compare.m
│   │   └── 梯度对比绘图工具
│   │
│   ├── plot_gradient_compare_enhanced.m
│   │   └── 增强版梯度对比绘图
│   │
│   ├── ProfessionalColorSelectorGUI.m
│   │   └── 专业颜色选择器GUI
│   │
│   └── ColorSelectionGUI_v3.m
│       └── 颜色选择GUI V3
│           - 预设色彩方案
│           - 自定义颜色
│
└── 📂 05_LiquidCrystal_Algorithms/          # 💧 液晶算法模块
    ├── LiquidCrystalDiffractionSimulator.m
    │   └── 液晶衍射模拟器
    │       - 完整的液晶光学模拟
    │       - 多层结构支持
    │
    ├── LiquidCrystalDiffractionAlgorithms.m
    │   └── 液晶衍射算法库
    │       - 胆甾相液晶
    │       - 向列相液晶
    │
    └── LiquidCrystalDiffractionSimulator_Enhanced_v5_Final.m
        └── 增强版液晶衍射模拟器V5
            - 高精度计算
            - GPU加速支持
```

---

## 📖 使用指南

### 基本操作流程

```mermaid
graph LR
    A[启动程序] --> B[设置参数]
    B --> C[选择功能]
    C --> D[生成图像]
    D --> E[预览调整]
    E --> F[保存导出]
```

### 参数设置说明

#### 通用参数

| 参数 | 说明 | 默认值 | 范围 |
|------|------|--------|------|
| 宽度 | 图像宽度（像素） | 1920 | 1-10000 |
| 高度 | 图像高度（像素） | 2000 | 1-10000 |
| 像素尺寸 | 单个像素物理尺寸 | 8 μm | 0.1-1000 |
| 波长 | 照射光波长 | 450 nm | 100-2000 |

#### SLM转换参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| 斜率系数 | 灰度-角度转换斜率 | 1.3047 |
| 截距 | 灰度-角度转换截距 | 133.85 |

> **公式**: `灰度值 = 斜率系数 × 偏振角度(°) + 截距`

### 代码示例

#### 示例1：生成线性偏振光栅

```matlab
% 启动程序
ExposureGenerator_Complete_Final

% 在GUI中:
% 1. 设置图像尺寸: 1920 x 2000
% 2. 选择"偏振光栅"选项卡
% 3. 选择类型: 线性偏振
% 4. 设置周期: 20像素
% 5. 点击"生成偏振光栅"
```

#### 示例2：使用核心算法库

```matlab
% 添加路径
addpath(genpath('Holographic exposure'));

% 使用高级偏振光栅算法
[X, Y] = meshgrid(1:1920, 1:2000);
period = 100;

% 生成Dammann光栅相位
dammannPhase = AdvancedPolarizationGratingAlgorithms.generateDammannGrating(1920, 2000, period);

% 生成PB相位光栅
pbPhase = AdvancedPolarizationGratingAlgorithms.generatePancharatnamBerryGrating(X-960, Y-1000, period);

% 显示结果
figure;
subplot(1,2,1); imagesc(dammannPhase); title('Dammann光栅');
subplot(1,2,2); imagesc(pbPhase); title('PB相位光栅');
colormap(slanCM('viridis'));
```

---

## 📦 MATLAB封装

### 将项目封装为独立可执行程序

本项目可以使用MATLAB Application Compiler封装为独立的可执行程序（.exe），无需MATLAB即可运行。

### 封装步骤

#### 步骤1：打开Application Compiler

```matlab
% 方法一：命令行
deploytool

% 方法二：菜单
% APPS选项卡 -> Application Compiler
```

#### 步骤2：配置项目

1. **选择主文件**
   ```
   点击 "+" 按钮，选择:
   ExposureGenerator_Complete_Final.m
   ```

2. **设置应用信息**
   | 设置项 | 值 |
   |--------|-----|
   | Application name | ExposureGenerator_Complete_Final |
   | Version | 5.0 |
   | Author name | Y.Z |
   | Summary | 加入SLM曲线校准，图像拟合以及保存图像 |

3. **添加依赖文件**
   ```
   点击 "Add files" 添加以下目录:
   ├── 01_Core_Algorithms/
   ├── 02_Helper_Functions/
   ├── 03_ColorMaps/
   ├── 04_Visualization/
   └── 05_LiquidCrystal_Algorithms/
   ```

#### 步骤3：配置运行时选项

```
☑ Runtime downloaded from web (推荐，安装包更小)
☐ Runtime included in package (离线安装，包更大)
```

#### 步骤4：打包

```matlab
% 点击 "Package" 按钮
% 等待编译完成...
```

#### 输出目录结构

```
ExposureGenerator_5.0/
├── for_redistribution/
│   └── MyAppInstaller_web.exe    # 在线安装程序
├── for_redistribution_files_only/
│   └── ExposureGenerator_Complete_Final.exe  # 可执行文件
├── for_testing/
│   ├── ExposureGenerator_Complete_Final.exe
│   ├── readme.txt
│   └── splash.png
└── PackagingLog.html             # 打包日志
```

### 使用.prj项目文件封装

也可以使用项目文件进行封装：

```matlab
% 创建项目文件
prj = matlab.project.createProject('ExposureGenerator_5.0.prj');

% 或使用现有项目文件
open('ExposureGenerator_Final_3.0.prj');

% 命令行编译
mcc -m ExposureGenerator_Complete_Final.m -d output_folder
```

### 封装注意事项

> ⚠️ **重要提示**

1. **工具箱依赖**
   - 确保目标机器安装了MATLAB Runtime
   - Image Processing Toolbox功能已包含在编译文件中

2. **路径问题**
   - 编译后的程序使用相对路径
   - 确保所有依赖文件都已添加

3. **中文支持**
   - 确保源文件使用UTF-8编码
   - 避免路径中包含特殊字符

4. **测试建议**
   ```matlab
   % 编译前测试
   cd 'Holographic exposure'
   start_holographic_exposure

   % 确保所有功能正常后再进行封装
   ```

---

## 🔬 技术规格

### 算法原理

#### 偏振光栅相位计算

```
线性偏振:    φ(x,y) = 2πx/Λ + φ₀
圆偏振:      φ(r,θ) = ±θ + φ₀
涡旋光束:    φ(r,θ) = lθ (l为拓扑荷数)
PB相位:      φ(r) = π(r²)/(λf)
```

#### 液晶分子取向

```
胆甾相液晶取向角: θ(z) = 2πz/P
其中P为螺距，z为厚度方向坐标
```

### 性能指标

| 指标 | 数值 |
|------|------|
| 最大图像尺寸 | 10000 × 10000 像素 |
| 灰度级数 | 256级 (8-bit) |
| 相位精度 | 0.01° |
| 生成速度 | < 1秒 (1920×2000) |

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

```
MIT License

Copyright (c) 2024-2025 Y.Z, Northwestern Polytechnical University

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 致谢

- 感谢西北工业大学提供的研究支持
- 感谢MATLAB社区的开源贡献

---

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 📧 **Email**: yangzhen2971@mail.nwpu.edu.cn
- 🏫 **单位**: 西北工业大学

---

<p align="center">
  <strong>⭐ 如果这个项目对您有帮助，请给一个Star！⭐</strong>
</p>

<p align="center">
  Made with ❤️ by Y.Z @ NPU
</p>
