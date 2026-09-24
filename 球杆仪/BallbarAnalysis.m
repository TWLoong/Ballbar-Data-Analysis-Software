classdef BallbarAnalysis < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        TabGroup          matlab.ui.container.TabGroup
        Tab               matlab.ui.container.Tab
        UIAxes_2          matlab.ui.control.UIAxes
        UIAxes_5          matlab.ui.control.UIAxes  
        Tab_2             matlab.ui.container.Tab
        UIAxes_4          matlab.ui.control.UIAxes
        UIAxes_3          matlab.ui.control.UIAxes
        Tab_3             matlab.ui.container.Tab
        Label_18          matlab.ui.control.Label
        Panel             matlab.ui.container.Panel
        Panel_5           matlab.ui.container.Panel
        Label_17          matlab.ui.control.Label
        Label_16          matlab.ui.control.Label
        umEditField       matlab.ui.control.NumericEditField
        umLabel           matlab.ui.control.Label
        EditField_7       matlab.ui.control.NumericEditField
        EditField_7Label  matlab.ui.control.Label
        EditField_6       matlab.ui.control.NumericEditField
        EditField_6Label  matlab.ui.control.Label
        Button_13         matlab.ui.control.Button
        Label_15          matlab.ui.control.Label
        Button_12         matlab.ui.control.Button
        UITable_3         matlab.ui.control.Table
        Panel_3           matlab.ui.container.Panel
        Label_12          matlab.ui.control.Label
        Label_11          matlab.ui.control.Label
        umEditField_2     matlab.ui.control.NumericEditField
        mmLabel           matlab.ui.control.Label
        EditField_5       matlab.ui.control.NumericEditField
        EditField_5Label  matlab.ui.control.Label
        EditField_4       matlab.ui.control.NumericEditField
        EditField_4Label  matlab.ui.control.Label
        Button_5          matlab.ui.control.Button
        Label_6           matlab.ui.control.Label
        Button_4          matlab.ui.control.Button
        Label_14          matlab.ui.control.Label
        UITable_2         matlab.ui.control.Table
        Panel_4           matlab.ui.container.Panel
        Button_11         matlab.ui.control.Button
        Button_10         matlab.ui.control.Button
        Button_8          matlab.ui.control.Button
        Button_9          matlab.ui.control.Button
        Button_7          matlab.ui.control.Button
        Button_6          matlab.ui.control.Button
        Label_7           matlab.ui.control.Label
        EditField         matlab.ui.control.NumericEditField
        EditFieldLabel    matlab.ui.control.Label
        mmEditField       matlab.ui.control.NumericEditField
        mmEditFieldLabel  matlab.ui.control.Label
    end

    % ===== 数据存储 =====
    properties (Access = private)
        upData            table         % 上半圆筛选后的数据
        lowData           table         % 下半圆筛选后的数据
        fullData          table         % 合并后的完整圆数据
        R                 double = 2    % 标准半径（mm）
        K                 double = 1    % 误差放大系数
        sampledPoints     double = 5    % 反向间隙采样点数
        upZero_um         double = 0    % 上半圆零点偏移（um）
        lowZero_um        double = 0    % 下半圆零点偏移（um）
    end

    % ===== 构造函数 =====
    methods (Access = public)
        function app = BallbarAnalysis
            createComponents(app)
            registerApp(app, app.UIFigure)

            app.UITable_2.Data = table({''},{''},{''},'VariableNames',{'序号','测量值','误差'});
            app.UITable_3.Data = table({''},{''},{''},'VariableNames',{'序号','测量值','误差'});
            app.Label_12.Text = '未导入';
            app.Label_17.Text = '未导入';
            app.Label_18.Text = '结果输出：';

            app.Button_13.ButtonPushedFcn = createCallbackFcn(app, @importUpperData, true);
            app.Button_5.ButtonPushedFcn = createCallbackFcn(app, @importLowerData, true);
            app.Button_12.ButtonPushedFcn = createCallbackFcn(app, @filterUpperData, true);
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @filterLowerData, true);
            app.Button_6.ButtonPushedFcn = createCallbackFcn(app, @generateRoundness, true);
            app.Button_7.ButtonPushedFcn = createCallbackFcn(app, @clearRoundness, true);
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @generateHarmonics, true);
            app.Button_8.ButtonPushedFcn = createCallbackFcn(app, @clearHarmonics, true);
            app.Button_10.ButtonPushedFcn = createCallbackFcn(app, @showAnalysisResult, true);
            app.Button_11.ButtonPushedFcn = createCallbackFcn(app, @clearAllResults, true);

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end

    % ===== 界面创建 =====
    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 893 664];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Scrollable = 'on';

            app.Panel = uipanel(app.UIFigure);
            app.Panel.Title = '控制面板';
            app.Panel.Position = [9 9 375 648];

            app.mmEditFieldLabel = uilabel(app.Panel);
            app.mmEditFieldLabel.HorizontalAlignment = 'right';
            app.mmEditFieldLabel.Position = [5 601 97 22];
            app.mmEditFieldLabel.Text = '标准半径（mm）';
            app.mmEditField = uieditfield(app.Panel, 'numeric');
            app.mmEditField.Position = [100 601 66 22];
            app.mmEditField.Value = 2;

            app.EditFieldLabel = uilabel(app.Panel);
            app.EditFieldLabel.HorizontalAlignment = 'right';
            app.EditFieldLabel.Position = [202 601 77 22];
            app.EditFieldLabel.Text = '误差放大系数';
            app.EditField = uieditfield(app.Panel, 'numeric');
            app.EditField.Position = [294 601 61 22];
            app.EditField.Value = 1;

            app.Label_7 = uilabel(app.Panel);
            app.Label_7.FontSize = 18;
            app.Label_7.Position = [41 223 93 34];
            app.Label_7.Text = '上半圆';

            app.Panel_4 = uipanel(app.Panel);
            app.Panel_4.Title = '运行控制';
            app.Panel_4.Position = [8 257 359 98];

            app.Button_6 = uibutton(app.Panel_4, 'push');
            app.Button_6.Position = [14 39 100 23];
            app.Button_6.Text = '生成圆度分析';
            app.Button_7 = uibutton(app.Panel_4, 'push');
            app.Button_7.Position = [12 8 100 23];
            app.Button_7.Text = '清空圆度分析';
            app.Button_9 = uibutton(app.Panel_4, 'push');
            app.Button_9.Position = [139 39 100 23];
            app.Button_9.Text = '生成谐波分析';
            app.Button_8 = uibutton(app.Panel_4, 'push');
            app.Button_8.Position = [139 8 100 23];
            app.Button_8.Text = '清空谐波分析';
            app.Button_10 = uibutton(app.Panel_4, 'push');
            app.Button_10.Position = [252 39 100 23];
            app.Button_10.Text = '分析结果';
            app.Button_11 = uibutton(app.Panel_4, 'push');
            app.Button_11.Position = [252 8 100 23];
            app.Button_11.Text = '清空结果';

            app.UITable_2 = uitable(app.Panel);
            app.UITable_2.ColumnName = {'序号'; '测量值'; '误差'};
            app.UITable_2.RowName = {};
            app.UITable_2.Position = [103 131 264 122];

            app.Label_14 = uilabel(app.Panel);
            app.Label_14.FontSize = 18;
            app.Label_14.Position = [39 98 93 34];
            app.Label_14.Text = '下半圆';

            app.Panel_3 = uipanel(app.Panel);
            app.Panel_3.Title = '下半圆参数设置';
            app.Panel_3.Position = [8 357 359 120];

            app.Button_4 = uibutton(app.Panel_3, 'push');
            app.Button_4.Position = [12 6 100 23];
            app.Button_4.Text = '筛选下半圆数据';
            app.Label_6 = uilabel(app.Panel_3);
            app.Label_6.Position = [14 37 101 22];
            app.Label_6.Text = '数据选择（行）：';
            app.Button_5 = uibutton(app.Panel_3, 'push');
            app.Button_5.Position = [12 65 100 23];
            app.Button_5.Text = '导入下半圆数据';
            app.EditField_4Label = uilabel(app.Panel_3);
            app.EditField_4Label.HorizontalAlignment = 'right';
            app.EditField_4Label.Position = [126 37 41 22];
            app.EditField_4Label.Text = '开始：';
            app.EditField_4 = uieditfield(app.Panel_3, 'numeric');
            app.EditField_4.Position = [165 37 50 22];
            app.EditField_5Label = uilabel(app.Panel_3);
            app.EditField_5Label.HorizontalAlignment = 'right';
            app.EditField_5Label.Position = [230 37 41 22];
            app.EditField_5Label.Text = '结束：';
            app.EditField_5 = uieditfield(app.Panel_3, 'numeric');
            app.EditField_5.Position = [269 37 50 22];
            app.mmLabel = uilabel(app.Panel_3);
            app.mmLabel.HorizontalAlignment = 'right';
            app.mmLabel.Position = [115 65 130 22];
            app.mmLabel.Text = '下半圆零点误差（um）';
            app.umEditField_2 = uieditfield(app.Panel_3, 'numeric');
            app.umEditField_2.Position = [264 65 83 22];
            app.Label_11 = uilabel(app.Panel_3);
            app.Label_11.FontSize = 14;
            app.Label_11.Position = [124 1 93 34];
            app.Label_11.Text = '下半圆数据：';
            app.Label_12 = uilabel(app.Panel_3);
            app.Label_12.FontSize = 14;
            app.Label_12.Position = [204 1 93 34];
            app.Label_12.Text = '未导入';
            app.UITable_3 = uitable(app.Panel);
            app.UITable_3.ColumnName = {'序号'; '测量值'; '误差'};
            app.UITable_3.RowName = {};
            app.UITable_3.Position = [103 6 264 122];

            app.Panel_5 = uipanel(app.Panel);
            app.Panel_5.Title = '上半圆参数设置';
            app.Panel_5.Position = [8 479 359 120];

            app.Button_12 = uibutton(app.Panel_5, 'push');
            app.Button_12.Position = [12 13 100 23];
            app.Button_12.Text = '筛选上半圆数据';
            app.Label_15 = uilabel(app.Panel_5);
            app.Label_15.Position = [14 44 101 22];
            app.Label_15.Text = '数据选择（行）：';
            app.Button_13 = uibutton(app.Panel_5, 'push');
            app.Button_13.Position = [12 72 100 23];
            app.Button_13.Text = '导入上半圆数据';
            app.EditField_6Label = uilabel(app.Panel_5);
            app.EditField_6Label.HorizontalAlignment = 'right';
            app.EditField_6Label.Position = [126 44 41 22];
            app.EditField_6Label.Text = '开始：';
            app.EditField_6 = uieditfield(app.Panel_5, 'numeric');
            app.EditField_6.Position = [165 44 50 22];
            app.EditField_7Label = uilabel(app.Panel_5);
            app.EditField_7Label.HorizontalAlignment = 'right';
            app.EditField_7Label.Position = [230 44 41 22];
            app.EditField_7Label.Text = '结束：';
            app.EditField_7 = uieditfield(app.Panel_5, 'numeric');
            app.EditField_7.Position = [269 44 50 22];
            app.umLabel = uilabel(app.Panel_5);
            app.umLabel.HorizontalAlignment = 'right';
            app.umLabel.Position = [115 72 130 22];
            app.umLabel.Text = '上半圆零点误差（um）';
            app.umEditField = uieditfield(app.Panel_5, 'numeric');
            app.umEditField.Position = [264 72 83 22];
            app.Label_16 = uilabel(app.Panel_5);
            app.Label_16.FontSize = 14;
            app.Label_16.Position = [124 8 93 34];
            app.Label_16.Text = '上半圆数据：';
            app.Label_17 = uilabel(app.Panel_5);
            app.Label_17.FontSize = 14;
            app.Label_17.Position = [204 8 93 34];
            app.Label_17.Text = '未导入';

            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [390 10 491 647];
            app.Tab = uitab(app.TabGroup);
            app.Tab.Title = '圆度分析';

            app.UIAxes_2 = uiaxes(app.Tab);
            title(app.UIAxes_2, '直角坐标系');
            xlabel(app.UIAxes_2, '角度（°）');
            ylabel(app.UIAxes_2, '偏差（um）');
            app.UIAxes_2.Position = [55 329 379 274];

            app.UIAxes_5 = uiaxes(app.Tab);
            title(app.UIAxes_5, '极坐标系');
            app.UIAxes_5.Position = [55 46 379 274];

            app.Tab_2 = uitab(app.TabGroup);
            app.Tab_2.Title = '谐波分析';
            app.UIAxes_3 = uiaxes(app.Tab_2);
            title(app.UIAxes_3, '谐波分析图');
            xlabel(app.UIAxes_3, '角度（°）');
            ylabel(app.UIAxes_3, '偏差（um）');
            app.UIAxes_3.Position = [55 329 379 274];
            app.UIAxes_4 = uiaxes(app.Tab_2);
            title(app.UIAxes_4, '谐波组成');
            xlabel(app.UIAxes_4, '阶次');
            ylabel(app.UIAxes_4, '占比');
            app.UIAxes_4.Position = [54 46 379 274];

            app.Tab_3 = uitab(app.TabGroup);
            app.Tab_3.Title = '分析结果';
            app.Label_18 = uilabel(app.Tab_3);
            app.Label_18.VerticalAlignment = 'top';
            app.Label_18.FontSize = 18;
            app.Label_18.Position = [13 127 464 485];
            app.Label_18.Text = '结果输出：';

            app.UIFigure.Visible = 'on';
        end
    end

    % ===== 功能实现 =====
    methods (Access = private)

        % --- 读取 Excel 文件 ---
        function T = readExcelFile(~)
            [file, path] = uigetfile('*.xlsx');
            if isequal(file, 0)
                T = [];
                return;
            end
            fullPath = fullfile(path, file);
            opts = detectImportOptions(fullPath);
            opts.VariableNamingRule = 'preserve';
            T = readtable(fullPath, opts);
            T = T(:, 1:3);
            T.Properties.VariableNames = {'SeqNum','MeasVal','Error'};
            if iscell(T.SeqNum)
                T.SeqNum = str2double(T.SeqNum);
            end
        end

        % --- 导入上半圆数据 ---
        function importUpperData(app, ~)
            T = readExcelFile(app);
            if isempty(T); return; end
            app.upData = T;
            app.UITable_2.Data = app.upData;
            app.UITable_2.ColumnName = {'序号','测量值','误差'};
            app.EditField_6.Value = 1;
            app.EditField_7.Value = height(app.upData);
            app.Label_17.Text = '已导入';
        end

        % --- 导入下半圆数据 ---
        function importLowerData(app, ~)
            T = readExcelFile(app);
            if isempty(T); return; end
            app.lowData = T;
            app.UITable_3.Data = app.lowData;
            app.UITable_3.ColumnName = {'序号','测量值','误差'};
            app.EditField_4.Value = 1;
            app.EditField_5.Value = height(app.lowData);
            app.Label_12.Text = '已导入';
        end

        % --- 筛选上半圆数据---
        function filterUpperData(app, ~)
            if isempty(app.upData)
                uialert(app.UIFigure, '请先导入上半圆数据', '提示');
                return;
            end
            s = round(app.EditField_6.Value);
            e = round(app.EditField_7.Value);
            app.upData = app.upData(s:e, {'SeqNum','MeasVal','Error'});
            app.UITable_2.Data = app.upData;
            app.UITable_2.ColumnName = {'序号','测量值','误差'};
        end

        % --- 筛选下半圆数据---
        function filterLowerData(app, ~)
            if isempty(app.lowData)
                uialert(app.UIFigure, '请先导入下半圆数据', '提示');
                return;
            end
            s = round(app.EditField_4.Value);
            e = round(app.EditField_5.Value);
            app.lowData = app.lowData(s:e, {'SeqNum','MeasVal','Error'});
            app.UITable_3.Data = app.lowData;
            app.UITable_3.ColumnName = {'序号','测量值','误差'};
        end

        % --- 准备完整数据---
        function [angles, dev_um, r_mm_actual, r_mm_plot] = prepareFullData(app)
            angles = []; dev_um = []; r_mm_actual = []; r_mm_plot = [];
            if isempty(app.upData) || isempty(app.lowData)
                uialert(app.UIFigure, '请先导入并筛选上下半圆数据', '提示');
                return;
            end

            app.upZero_um = app.umEditField.Value;
            app.lowZero_um = app.umEditField_2.Value;
            app.R = app.mmEditField.Value;
            app.K = app.EditField.Value;

            % 1. 计算微米偏差
            upperMeas_um = app.upData.MeasVal;
            lowerMeas_um = app.lowData.MeasVal;
            upperDiff_um = upperMeas_um - app.upZero_um;
            lowerDiff_um = lowerMeas_um - app.lowZero_um;
            
            % 2. 转换为毫米偏差
            upperDiff_mm = upperDiff_um / 1000;
            lowerDiff_mm = lowerDiff_um / 1000;

            % 3. 生成各个测量点对应的角度
            N = length(upperDiff_mm);
            M = length(lowerDiff_mm);
            angles = [linspace(0, 180, N)'; linspace(180, 360, M)'];
            dev_um = [upperDiff_um; lowerDiff_um];
            
            % 4. 计算实际矢径
            r_mm_actual = app.R + 1 * [upperDiff_mm; lowerDiff_mm];
            r_mm_plot = app.R + app.K * [upperDiff_mm; lowerDiff_mm];

            % 5. 合并后存入数据
            app.fullData = table(angles, dev_um, r_mm_actual, r_mm_plot, ...
                'VariableNames', {'Angle','Dev_um','r_mm_actual','r_mm_plot'});
        end

        % --- 最小二乘圆拟合 ---
        function [cx, cy, fittedR] = fitLeastSquaresCircle(~, angles_deg, r_mm)
            theta = deg2rad(angles_deg);
            x = r_mm .* cos(theta);
            y = r_mm .* sin(theta);
            n = length(x);
            
            sumX = sum(x); sumY = sum(y);
            sumX2 = sum(x.^2); sumY2 = sum(y.^2);
            sumXY = sum(x.*y);
            sumX3 = sum(x.^3); sumY3 = sum(y.^3);
            sumXY2 = sum(x.*y.^2); sumX2Y = sum(x.^2.*y);
            A = [sumX2, sumXY, sumX; sumXY, sumY2, sumY; sumX, sumY, n];
            B = [sumX3 + sumXY2; sumX2Y + sumY3; sumX2 + sumY2];
            coeffs = A \ B;
            
            cx = coeffs(1)/2; 
            cy = coeffs(2)/2; 
            fittedR = sqrt(cx^2 + cy^2 - coeffs(3));
        end

        % --- 计算圆度误差---
        function [roundness_um, residuals_um] = computeRoundness(app, angles_deg, r_mm)
            [cx, cy, fittedR] = fitLeastSquaresCircle(app, angles_deg, r_mm);
            theta = deg2rad(angles_deg);
            dist = sqrt((r_mm .* cos(theta) - cx).^2 + (r_mm .* sin(theta) - cy).^2);
            residuals_um = (dist - fittedR) * 1000;
            roundness_um = max(residuals_um) - min(residuals_um);
        end

        % --- 计算基准偏差---
        function baseDiff_um = computePrecisionError(app)
            if isempty(app.upData) || isempty(app.lowData)
                baseDiff_um = 0;
                return;
            end
            nU = height(app.upData);
            nL = height(app.lowData);
            pts = app.sampledPoints;
            if nU < pts*2 || nL < pts*2
                baseDiff_um = 0;
                return;
            end

            indicesY_upper = 1:pts;
            indicesY_lower = 1:pts;

            midU = floor(nU / 2);
            halfPts = floor(pts / 2);
            indicesX_upper = (midU - halfPts) : (midU + halfPts);
            indicesX_upper = indicesX_upper(indicesX_upper >= 1 & indicesX_upper <= nU);

            midL = floor(nL / 2);
            indicesX_lower = (midL - halfPts) : (midL + halfPts);
            indicesX_lower = indicesX_lower(indicesX_lower >= 1 & indicesX_lower <= nL);

            all_indices = false(nU + nL, 1);
            all_indices(indicesY_upper) = true;
            all_indices(nU + indicesY_lower) = true;
            all_indices(indicesX_upper) = true;
            all_indices(nU + indicesX_lower) = true;

            app.upZero_um = app.umEditField.Value;
            app.lowZero_um = app.umEditField_2.Value;
            upperDiff_um = app.upData.MeasVal - app.upZero_um;
            lowerDiff_um = app.lowData.MeasVal - app.lowZero_um;
            allDiff_um = [upperDiff_um; lowerDiff_um];

            remainingDiff_um = allDiff_um(~all_indices);
            if isempty(remainingDiff_um)
                baseDiff_um = 0;
            else
                baseDiff_um = mean(remainingDiff_um);
            end
        end

        % --- 计算 X 轴和 Y 轴的真正反向间隙---
        function [backX_um, backY_um] = computeBacklash(app)
            backX_um = NaN; backY_um = NaN;
            if isempty(app.upData) || isempty(app.lowData)
                return;
            end
            nU = height(app.upData);
            nL = height(app.lowData);
            pts = app.sampledPoints;
            if nU < pts || nL < pts
                uialert(app.UIFigure, ['数据点不足 ', num2str(pts), ' 个'], '警告');
                return;
            end

            app.upZero_um = app.umEditField.Value;
            app.lowZero_um = app.umEditField_2.Value;
            upperDiff_um = app.upData.MeasVal - app.upZero_um;
            lowerDiff_um = app.lowData.MeasVal - app.lowZero_um;

            % Y轴：计算 0°之后 和 180°之后 的点均值
            y_upper_um = upperDiff_um(1:pts);
            y_lower_um = lowerDiff_um(1:pts);
            rawY_um = (mean(y_upper_um) + mean(y_lower_um)) / 2;

            % X轴：计算 90°两侧 和 270°两侧 的点均值
            midU = floor(nU / 2);
            halfPts = floor(pts / 2);
            indicesX_upper = (midU - halfPts) : (midU + halfPts);
            indicesX_upper = indicesX_upper(indicesX_upper >= 1 & indicesX_upper <= nU);
            x_upper_um = upperDiff_um(indicesX_upper);

            midL = floor(nL / 2);
            indicesX_lower = (midL - halfPts) : (midL + halfPts);
            indicesX_lower = indicesX_lower(indicesX_lower >= 1 & indicesX_lower <= nL);
            x_lower_um = lowerDiff_um(indicesX_lower);

            rawX_um = (mean(x_upper_um) + mean(x_lower_um)) / 2;

            % 减去基准偏差得到真实反向间隙
            baseDiff_um = computePrecisionError(app);
            backY_um = abs(rawY_um - baseDiff_um);
            backX_um = abs(rawX_um - baseDiff_um);
        end

        % --- 谐波分析---
        function [orders, amps, ratios] = harmonicAnalysis(~, dev_um)
            N = length(dev_um);
            Y = fft(dev_um - mean(dev_um));
            P2 = abs(Y/N);
            P1 = P2(1:floor(N/2)+1);
            P1(2:end-1) = 2*P1(2:end-1);
            orders = (1:length(P1)-1)';
            amps = P1(2:end);
            total = sum(amps);
            if total == 0
                ratios = zeros(size(amps));
            else
                ratios = amps / total * 100;
            end
            if length(orders) > 10
                orders = orders(1:10);
                amps = amps(1:10);
                ratios = ratios(1:10);
            end
        end

        % --- 生成圆度分析---
        function generateRoundness(app, ~)
            [angles, dev_um, r_mm_actual, r_mm_plot] = prepareFullData(app);
            if isempty(angles)
                return;
            end

            % 1. 绘制直角坐标系
            ax = app.UIAxes_2;
            cla(ax); hold(ax, 'on');
            plot(ax, angles, dev_um, 'b-', 'LineWidth', 1.5);
            xlabel(ax, '角度（°）'); ylabel(ax, '偏差（um）');
            title(ax, '直角坐标系'); grid(ax, 'on');
            hold(ax, 'off');

            % 2. 绘制极坐标系
            ax_polar = app.UIAxes_5;
            cla(ax_polar);
            hold(ax_polar, 'on');

            [roundness_um, ~] = computeRoundness(app, angles, r_mm_actual);
            [backX_um, backY_um] = computeBacklash(app);
            app.fullData.Properties.UserData.Roundness = roundness_um;
            app.fullData.Properties.UserData.BacklashX = backX_um;
            app.fullData.Properties.UserData.BacklashY = backY_um;

            theta = deg2rad(angles);
            x_polar = r_mm_plot .* cos(theta);
            y_polar = r_mm_plot .* sin(theta);
            x_polar_closed = [x_polar; x_polar(1)];
            y_polar_closed = [y_polar; y_polar(1)];
            plot(ax_polar, x_polar_closed, y_polar_closed, 'r-', 'LineWidth', 1.5);
            viscircles(ax_polar, [0, 0], app.R, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.5);
            axis(ax_polar, 'equal');
            title(ax_polar, '极坐标系');
            grid(ax_polar, 'on');
            hold(ax_polar, 'off');
        end

        % --- 生成谐波分析---
        function generateHarmonics(app, ~)
            if isempty(app.fullData)
                uialert(app.UIFigure, '请先生成圆度分析', '提示');
                return;
            end
            dev_um = app.fullData.Dev_um;
            [orders, amps, ratios] = harmonicAnalysis(app, dev_um);

            % 1. 绘制各阶波形图
            ax3 = app.UIAxes_3;
            cla(ax3); hold(ax3, 'on');
            angles = app.fullData.Angle;
            t = deg2rad(angles);
            maxOrders = min(5, length(orders));
            colors = lines(maxOrders);
            for i = 1:maxOrders
                wave = amps(i) * cos(orders(i) * t);
                plot(ax3, angles, wave, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', sprintf('%d阶', orders(i)));
            end
            xlabel(ax3, '角度（°）'); ylabel(ax3, '偏差（um）');
            title(ax3, '谐波波形'); grid(ax3, 'on'); legend(ax3, 'show');

            % 2. 绘制各阶谐波占比柱状图
            ax4 = app.UIAxes_4;
            cla(ax4);
            bar(ax4, orders, ratios, 'FaceColor', [0.2,0.6,0.8]);
            xlabel(ax4, '阶次'); ylabel(ax4, '占比（%）'); title(ax4, '谐波组成'); grid(ax4, 'on');

            app.fullData.Properties.UserData.Harmonics = table(orders, amps, ratios, 'VariableNames', {'Order','Amp','Ratio'});
        end

        % --- 清空圆度分析图像 ---
        function clearRoundness(app, ~)
            cla(app.UIAxes_2);
            cla(app.UIAxes_5);
        end

        % --- 清空谐波分析图像 ---
        function clearHarmonics(app, ~)
            cla(app.UIAxes_3); cla(app.UIAxes_4);
        end

        % --- 清空结果输出文本 ---
        function clearAllResults(app, ~)
            app.Label_18.Text = '结果输出：';
        end

        % --- 显示分析结果---
        function showAnalysisResult(app, ~)
            if isempty(app.fullData) || ~isfield(app.fullData.Properties.UserData, 'Roundness')
                uialert(app.UIFigure, '请先执行圆度分析', '提示');
                return;
            end
            roundness_um = app.fullData.Properties.UserData.Roundness;
            backX_um = app.fullData.Properties.UserData.BacklashX;
            backY_um = app.fullData.Properties.UserData.BacklashY;
            str = sprintf('\n       圆度误差：%.2f um\n       X轴反向间隙：%.2f um\n       Y轴反向间隙：%.2f um', roundness_um, backX_um, backY_um);
            if isfield(app.fullData.Properties.UserData, 'Harmonics')
                harm = app.fullData.Properties.UserData.Harmonics;
                str = [str, sprintf('\n谐波组成：\n')];
                num_harm = height(harm);
                harm_strs = cell(num_harm, 1);
                for i = 1:num_harm
                    harm_strs{i} = sprintf('      %d阶: %.1f%%', harm.Order(i), harm.Ratio(i));
                end
                str = [str, strjoin(harm_strs, '\n')];
            end
            app.Label_18.Text = ['结果输出:', str];
        end
    end
end