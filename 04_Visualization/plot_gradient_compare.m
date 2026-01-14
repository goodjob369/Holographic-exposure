%% 自定义渐变绘图函数
function plot_gradient_compare(x, E_in, E, xlim_range)
    % 定义颜色梯度（修正linspace参数错误）
    % 蓝渐变：分别对RGB通道插值
    start_blue = [0.2, 0.4, 0.8];  % 起始颜色
    end_blue = [0.8, 0.9, 1];      % 终止颜色
    red = linspace(start_blue(1), end_blue(1), 4);
    green = linspace(start_blue(2), end_blue(2), 4);
    blue = linspace(start_blue(3), end_blue(3), 4);
    color_blue = [red', green', blue'];
    
    % 红渐变：分别对RGB通道插值
    start_red = [1, 0.4, 0.4];    % 起始颜色
    end_red = [0.8, 0.2, 0.2];    % 终止颜色
    red = linspace(start_red(1), end_red(1), 4);
    green = linspace(start_red(2), end_red(2), 4);
    blue = linspace(start_red(3), end_red(3), 4);
    color_red = [red', green', blue'];
    
    % 绘制初始场
    for i = 1:4
        area(x*1e6, abs(E_in).^2,...
            'FaceColor', color_blue(i,:),...
            'FaceAlpha', 1-0.25*i,...
            'EdgeColor','none');
        hold on;
    end
    
    % 绘制出射场
    for i = 1:4
        area(x*1e6, abs(E).^2,...
            'FaceColor', color_red(i,:),...
            'FaceAlpha', 1-0.25*i,...
            'EdgeColor','none');
    end
    
    % 图形美化
    xlim(xlim_range);
    xlabel('横向位置 x(\mum)','FontName','宋体');
    ylabel('归一化强度','FontName','宋体');
    legend({'初始场','','','','出射场','','',''},...
           'FontName','宋体','Location','northeastoutside');
     % 坐标轴与网格优化
    ax = gca;
    ax.XMinorTick = 'on';        % 显示次要刻度
    ax.YMinorTick = 'on';
    ax.LineWidth = 1.5;          % 坐标轴线宽
    ax.GridLineStyle = '-.';      % 网格线型
    ax.GridAlpha = 0.3;           % 网格透明度
    grid on;
    box off;
    set(gca,'FontName','宋体','FontSize',11,'Layer','top');
end