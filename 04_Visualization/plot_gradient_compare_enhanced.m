function plot_gradient_compare_enhanced(x, E_in, E_out, xlim_range, options)
    % 增强版精美绘图函数 - 专用于液晶偏振光栅衍射仿真
    % 输入参数:
    %   x: 横向位置坐标 (μm)
    %   E_in: 入射场强度分布
    %   E_out: 衍射场强度分布
    %   xlim_range: x轴显示范围 [可选]
    %   options: 绘图选项结构体 [可选]
    
    if nargin < 3
        error('至少需要3个输入参数: x, E_in, E_out');
    end
    
    if nargin < 4 || isempty(xlim_range)
        xlim_range = [min(x), max(x)];
    end
    
    if nargin < 5 || isempty(options)
        options = struct();
    end
    
    % 默认绘图选项
    default_options = struct(...
        'title', '液晶偏振光栅衍射光强分布', ...
        'xlabel', '横向位置 x (μm)', ...
        'ylabel', '归一化强度', ...
        'legend_input', '入射光场', ...
        'legend_output', '衍射光场', ...
        'color_input', [0.2, 0.4, 0.8], ...
        'color_output', [0.8, 0.2, 0.3], ...
        'alpha', 0.7, ...
        'linewidth', 2.5, ...
        'fontsize', 12, ...
        'grid_style', '-.', ...
        'grid_alpha', 0.3, ...
        'use_gradient', true, ...
        'show_peak_markers', true, ...
        'normalization', true ...
    );
    
    % 合并用户选项和默认选项
    fields = fieldnames(default_options);
    for i = 1:length(fields)
        if ~isfield(options, fields{i})
            options.(fields{i}) = default_options.(fields{i});
        end
    end
    
    % 数据预处理
    if options.normalization
        % 归一化处理
        E_in = E_in / max(abs(E_in(:)));
        E_out = E_out / max(abs(E_out(:)));
    end
    
    % 如果是复数，取模
    if ~isreal(E_in)
        E_in = abs(E_in);
    end
    if ~isreal(E_out)
        E_out = abs(E_out);
    end
    
    % 创建渐变颜色
    n_colors = 5;
    
    % 输入场渐变色（蓝色系）
    color_input_light = options.color_input + (1 - options.color_input) * 0.6;
    color_input_dark = options.color_input * 0.7;
    colors_input = zeros(n_colors, 3);
    for i = 1:3
        colors_input(:, i) = linspace(color_input_light(i), color_input_dark(i), n_colors);
    end
    
    % 输出场渐变色（红色系）
    color_output_light = options.color_output + (1 - options.color_output) * 0.6;
    color_output_dark = options.color_output * 0.7;
    colors_output = zeros(n_colors, 3);
    for i = 1:3
        colors_output(:, i) = linspace(color_output_light(i), color_output_dark(i), n_colors);
    end
    
    % 清除当前轴
    hold off;
    
    if options.use_gradient
        % 绘制渐变填充效果
        % 输入场多层渐变
        for layer = n_colors:-1:1
            alpha_val = options.alpha * (layer / n_colors) * 0.8;
            scale_factor = layer / n_colors;
            
            x_fill = [x, fliplr(x)];
            y_fill_in = [E_in * scale_factor, zeros(size(E_in))];
            
            fill(x_fill, y_fill_in, colors_input(layer, :), ...
                'FaceAlpha', alpha_val, 'EdgeColor', 'none');
            hold on;
        end
        
        % 输出场多层渐变
        for layer = n_colors:-1:1
            alpha_val = options.alpha * (layer / n_colors) * 0.8;
            scale_factor = layer / n_colors;
            
            x_fill = [x, fliplr(x)];
            y_fill_out = [E_out * scale_factor, zeros(size(E_out))];
            
            fill(x_fill, y_fill_out, colors_output(layer, :), ...
                'FaceAlpha', alpha_val, 'EdgeColor', 'none');
        end
    else
        % 简单填充
        x_fill = [x, fliplr(x)];
        y_fill_in = [E_in, zeros(size(E_in))];
        y_fill_out = [E_out, zeros(size(E_out))];
        
        fill(x_fill, y_fill_in, options.color_input, ...
            'FaceAlpha', options.alpha, 'EdgeColor', 'none');
        hold on;
        fill(x_fill, y_fill_out, options.color_output, ...
            'FaceAlpha', options.alpha, 'EdgeColor', 'none');
    end
    
    % 绘制边界线
    plot(x, E_in, 'Color', color_input_dark, 'LineWidth', options.linewidth);
    plot(x, E_out, 'Color', color_output_dark, 'LineWidth', options.linewidth);
    
    % 峰值标记
    if options.show_peak_markers
        [max_in, idx_in] = max(E_in);
        [max_out, idx_out] = max(E_out);
        
        plot(x(idx_in), max_in, 'o', 'Color', color_input_dark, ...
            'MarkerSize', 8, 'MarkerFaceColor', options.color_input, ...
            'LineWidth', 2);
        
        plot(x(idx_out), max_out, 's', 'Color', color_output_dark, ...
            'MarkerSize', 8, 'MarkerFaceColor', options.color_output, ...
            'LineWidth', 2);
        
        % 峰值标注
        text(x(idx_in), max_in + 0.05, sprintf('%.3f', max_in), ...
            'HorizontalAlignment', 'center', 'FontSize', options.fontsize-2, ...
            'Color', color_input_dark, 'FontWeight', 'bold');
        
        text(x(idx_out), max_out + 0.05, sprintf('%.3f', max_out), ...
            'HorizontalAlignment', 'center', 'FontSize', options.fontsize-2, ...
            'Color', color_output_dark, 'FontWeight', 'bold');
    end
    
    % 设置图形属性
    xlim(xlim_range);
    ylim([0, max([max(E_in), max(E_out)]) * 1.1]);
    
    xlabel(options.xlabel, 'FontSize', options.fontsize, 'FontName', '宋体', 'FontWeight', 'bold');
    ylabel(options.ylabel, 'FontSize', options.fontsize, 'FontName', '宋体', 'FontWeight', 'bold');
    
    % 图例
    legend({options.legend_input, options.legend_output}, ...
        'Location', 'northeast', 'FontSize', options.fontsize-1, ...
        'FontName', '宋体', 'Box', 'off', 'Color', 'white', ...
        'EdgeColor', 'none');
    
    % 标题
    title(options.title, 'FontSize', options.fontsize+2, 'FontName', '宋体', ...
        'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
    
    % 坐标轴美化
    ax = gca;
    ax.LineWidth = 1.8;
    ax.XMinorTick = 'on';
    ax.YMinorTick = 'on';
    ax.GridLineStyle = options.grid_style;
    ax.GridAlpha = options.grid_alpha;
    ax.FontSize = options.fontsize - 1;
    ax.FontName = '宋体';
    ax.Layer = 'top';
    ax.Box = 'off';
    
    % 添加精美的背景渐变
    ax.Color = [0.98, 0.98, 0.98];
    
    % 网格设置
    grid on;
    
    % 添加小的装饰线
    y_max = max([max(E_in), max(E_out)]);
    line([xlim_range(1), xlim_range(2)], [y_max, y_max], ...
        'Color', [0.7, 0.7, 0.7], 'LineStyle', '--', 'LineWidth', 0.8);
    
    % 添加颜色条（可选）
    if isfield(options, 'show_colorbar') && options.show_colorbar
        colorbar('Location', 'eastoutside', 'FontSize', options.fontsize-2);
    end
    
    % 设置图形窗口属性
    set(gcf, 'Color', 'white');
    
    hold off;
end 