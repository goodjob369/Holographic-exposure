%=============================================================
% start_holographic_exposure.m - 全息曝光图生成器启动脚本
% 版本: V5.0
%
% 版权所有 © 西北工业大学 Y.Z
% 联系邮箱: yangzhen2971@mail.nwpu.edu.cn
%=============================================================

function start_holographic_exposure()
    % 清理环境
    clc;
    close all;

    % 获取当前脚本路径
    scriptPath = fileparts(mfilename('fullpath'));

    % 添加所有子目录到路径
    addpath(genpath(scriptPath));

    fprintf('=============================================================\n');
    fprintf('    全息曝光图生成器 V5.0\n');
    fprintf('=============================================================\n');
    fprintf('版权所有 © 西北工业大学 Y.Z\n');
    fprintf('联系邮箱: yangzhen2971@mail.nwpu.edu.cn\n');
    fprintf('\n');
    fprintf('已加载路径:\n');
    fprintf('  - 01_Core_Algorithms (核心算法)\n');
    fprintf('  - 02_Helper_Functions (辅助函数)\n');
    fprintf('  - 03_ColorMaps (颜色映射)\n');
    fprintf('  - 04_Visualization (可视化工具)\n');
    fprintf('  - 05_LiquidCrystal_Algorithms (液晶算法)\n');
    fprintf('\n');
    fprintf('正在启动主程序...\n');
    fprintf('=============================================================\n');

    % 启动主程序
    ExposureGenerator_Complete_Final();
end
