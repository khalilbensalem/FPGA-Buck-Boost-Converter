classdef Dashboard_App_buck_FPGA < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        MainGrid                    matlab.ui.container.GridLayout

        TitleLabel                  matlab.ui.control.Label
        StatusLabel                 matlab.ui.control.Label

        RunButton                   matlab.ui.control.Button
        StopButton                  matlab.ui.control.Button
        ResetButton                 matlab.ui.control.Button
        InitButton                  matlab.ui.control.Button

        EnableSwitchLabel           matlab.ui.control.Label
        EnableSwitch                matlab.ui.control.ToggleSwitch

        ModeSwitchLabel             matlab.ui.control.Label
        ModeSwitch                  matlab.ui.control.Switch

        DutyKnobLabel               matlab.ui.control.Label
        DutyKnob                    matlab.ui.control.Knob
        DutyValueLabel              matlab.ui.control.Label

        FreqKnobLabel               matlab.ui.control.Label
        FreqKnob                    matlab.ui.control.Knob
        FreqValueLabel              matlab.ui.control.Label

        VrefSliderLabel             matlab.ui.control.Label
        VrefSlider                  matlab.ui.control.Slider
        VrefValueLabel              matlab.ui.control.Label

        LampLabel                   matlab.ui.control.Label
        RunningLamp                 matlab.ui.control.Lamp

        ScopeSectionLabel           matlab.ui.control.Label
        ScopeOutputButton           matlab.ui.control.Button
        ScopePWMButton              matlab.ui.control.Button
        ScopeControllerButton       matlab.ui.control.Button
    end

    properties (Access = private)
        MODEL_NAME = 'gm_gmStateSpaceHDL_buck_convert_test1_fixpt_test_registr_interface'
    end

    methods (Access = private)

        function p = blk(app, name)
            p = [app.MODEL_NAME '/' name];
        end

        function applyEnableColor(app)
            if strcmp(app.EnableSwitch.Value, 'On')
                app.EnableSwitch.FontColor = [0.10 0.85 0.10];
            else
                app.EnableSwitch.FontColor = [0.90 0.20 0.20];
            end
        end

        function applyModeColor(app)
            app.ModeSwitch.FontColor = [1.00 0.85 0.10];
        end

        function setBlock(app, blockName, value)
            switch blockName
                case 'duty',            strVal = num2str(value, '%.6f');
                case 'freq',            strVal = num2str(value, '%.2f');
                case 'en',              strVal = num2str(uint32(value));
                case 'mode_controller', strVal = num2str(uint32(value));
                case 'vout_ref',        strVal = num2str(value, '%.4f');
                case 'rst',             strVal = num2str(uint32(value));
                otherwise,              strVal = num2str(value);
            end
            try
                set_param(app.blk(blockName), 'Value', strVal);
            catch
                assignin('base', blockName, value);
            end
        end

        function openScope(app, scopeName)
            try
                app.loadModelIfNeeded();
                open_system(app.blk(scopeName));
            catch ME
                uialert(app.UIFigure, ME.message, ['Scope Error: ' scopeName]);
            end
        end

        function initializeWorkspaceVariables(app)
            app.loadModelIfNeeded();

            duty = 0.5;
            freq = 40000;   % Buck : 40 kHz
            vref = 5.0;

            app.setBlock('duty',            duty);
            app.setBlock('freq',            freq);
            app.setBlock('vout_ref',        vref);
            app.setBlock('en',              1);
            app.setBlock('mode_controller', 0);
            app.setBlock('rst',             0);

            app.DutyKnob.Value     = duty;
            app.FreqKnob.Value     = freq;
            app.VrefSlider.Value   = vref;
            app.EnableSwitch.Value = 'On';
            app.ModeSwitch.Value   = 'Open';

            app.updateDisplayedValues();
            app.applyEnableColor();
            app.applyModeColor();
        end

        function updateDisplayedValues(app)
            app.DutyValueLabel.Text = sprintf('Duty = %.3f', app.DutyKnob.Value);
            app.FreqValueLabel.Text = sprintf('Freq = %.0f Hz', app.FreqKnob.Value);
            app.VrefValueLabel.Text = sprintf('Vout ref = %.2f V', app.VrefSlider.Value);
        end

        function loadModelIfNeeded(app)
            if ~bdIsLoaded(app.MODEL_NAME)
                load_system(app.MODEL_NAME);
            end
        end

        function refreshStatus(app)
            if bdIsLoaded(app.MODEL_NAME)
                try
                    simStatus = get_param(app.MODEL_NAME, 'SimulationStatus');
                    switch simStatus
                        case 'running'
                            app.StatusLabel.Text  = 'Status : Running';
                            app.RunningLamp.Color = 'green';
                        case 'paused'
                            app.StatusLabel.Text  = 'Status : Paused';
                            app.RunningLamp.Color = 'yellow';
                        otherwise
                            app.StatusLabel.Text  = 'Status : Stopped';
                            app.RunningLamp.Color = [0.8 0.8 0.8];
                    end
                catch
                    app.StatusLabel.Text  = 'Status : Model loaded';
                    app.RunningLamp.Color = [0.8 0.8 0.8];
                end
            else
                app.StatusLabel.Text  = 'Status : Model not loaded';
                app.RunningLamp.Color = [0.8 0.8 0.8];
            end
        end

        function DutyKnobValueChanged(app, ~)
            v = max(0, min(1, app.DutyKnob.Value));
            app.DutyKnob.Value = v;
            app.setBlock('duty', v);
            app.updateDisplayedValues();
        end

        function FreqKnobValueChanged(app, ~)
            v = max(1e4, min(1.5e5, app.FreqKnob.Value));
            app.FreqKnob.Value = v;
            app.setBlock('freq', v);
            app.updateDisplayedValues();
        end

        function VrefSliderValueChanged(app, ~)
            v = max(0, min(12, app.VrefSlider.Value));
            app.VrefSlider.Value = v;
            app.setBlock('vout_ref', v);
            app.updateDisplayedValues();
        end

        function EnableSwitchValueChanged(app, ~)
            if strcmp(app.EnableSwitch.Value, 'On')
                app.setBlock('en', 1);
            else
                app.setBlock('en', 0);
            end
            app.applyEnableColor();
        end

        function ModeSwitchValueChanged(app, ~)
            if strcmp(app.ModeSwitch.Value, 'Closed')
                app.setBlock('mode_controller', 1);
            else
                app.setBlock('mode_controller', 0);
            end
            app.applyModeColor();
        end

        function ResetButtonPushed(app, ~)
            app.setBlock('rst', 1);
            pause(0.1);
            app.setBlock('rst', 0);
        end

        function InitButtonPushed(app, ~)
            app.initializeWorkspaceVariables();
            app.refreshStatus();
        end

        function RunButtonPushed(app, ~)
            try
                app.loadModelIfNeeded();
                app.setBlock('duty',     app.DutyKnob.Value);
                app.setBlock('freq',     app.FreqKnob.Value);
                app.setBlock('vout_ref', app.VrefSlider.Value);
                app.setBlock('rst',      0);
                if strcmp(app.EnableSwitch.Value, 'On')
                    app.setBlock('en', 1);
                else
                    app.setBlock('en', 0);
                end
                if strcmp(app.ModeSwitch.Value, 'Closed')
                    app.setBlock('mode_controller', 1);
                else
                    app.setBlock('mode_controller', 0);
                end
                set_param(app.MODEL_NAME, 'SimulationCommand', 'start');
                pause(0.3);
                app.refreshStatus();
                app.updateDisplayedValues();
            catch ME
                uialert(app.UIFigure, ME.message, 'Run Error');
            end
        end

        function StopButtonPushed(app, ~)
            try
                app.loadModelIfNeeded();
                set_param(app.MODEL_NAME, 'SimulationCommand', 'stop');
                pause(0.2);
                app.refreshStatus();
            catch ME
                uialert(app.UIFigure, ME.message, 'Stop Error');
            end
        end

        function ScopeOutputButtonPushed(app, ~)
            app.openScope('Scope_Output');
        end

        function ScopePWMButtonPushed(app, ~)
            app.openScope('Scope_PWM');
        end

        function ScopeControllerButtonPushed(app, ~)
            app.openScope('Scope_controller');
        end

        function createComponents(app)

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 980 660];
            app.UIFigure.Name = 'Control Dashboard Buck FPGA';
            app.UIFigure.Color = [0.13 0.13 0.15];

            % GRILLE 9 x 4
            % Row 1 : Titre / Status
            % Row 2 : Run+Lamp | Stop | Reset | Init
            % Row 3 : Labels knobs/slider/enable
            % Row 4 : DutyKnob | FreqKnob | VrefSlider | EnableSwitch
            % Row 5 : Value labels col 1-3
            % Row 6 : ModeSwitchLabel col 4
            % Row 7 : ModeSwitch col 4
            % Row 8 : Separateur Scopes
            % Row 9 : 3 boutons Scope
            app.MainGrid = uigridlayout(app.UIFigure, [9 4]);
            app.MainGrid.RowHeight    = {40, 55, 28, 150, 28, 28, 50, 30, 55};
            app.MainGrid.ColumnWidth  = {'1x','1x','1x','1x'};
            app.MainGrid.Padding      = [20 20 20 20];
            app.MainGrid.RowSpacing   = 6;
            app.MainGrid.ColumnSpacing = 12;
            app.MainGrid.BackgroundColor = [0.13 0.13 0.15];

            % Row 1 : Titre / Status
            app.TitleLabel = uilabel(app.MainGrid);
            app.TitleLabel.Text = 'Control Dashboard Buck FPGA';
            app.TitleLabel.FontSize = 19;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.FontColor = [0.95 0.95 0.95];
            app.TitleLabel.Layout.Row = 1;
            app.TitleLabel.Layout.Column = [1 3];

            app.StatusLabel = uilabel(app.MainGrid);
            app.StatusLabel.Text = 'Status : Not initialized';
            app.StatusLabel.HorizontalAlignment = 'right';
            app.StatusLabel.FontSize = 12;
            app.StatusLabel.FontColor = [0.65 0.65 0.65];
            app.StatusLabel.Layout.Row = 1;
            app.StatusLabel.Layout.Column = 4;

            % Row 2 : Run+Lamp | Stop | Reset | Init
            RunPanel = uigridlayout(app.MainGrid, [1 3]);
            RunPanel.ColumnWidth = {'1x', 55, 22};
            RunPanel.RowHeight = {'1x'};
            RunPanel.ColumnSpacing = 8;
            RunPanel.Padding = [0 0 0 0];
            RunPanel.BackgroundColor = [0.13 0.13 0.15];
            RunPanel.Layout.Row = 2;
            RunPanel.Layout.Column = 1;

            app.RunButton = uibutton(RunPanel, 'push');
            app.RunButton.Text = 'Run';
            app.RunButton.FontSize = 15;
            app.RunButton.FontWeight = 'bold';
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.BackgroundColor = [0.10 0.50 0.10];
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Layout.Row = 1;
            app.RunButton.Layout.Column = 1;

            app.LampLabel = uilabel(RunPanel);
            app.LampLabel.Text = 'Run';
            app.LampLabel.HorizontalAlignment = 'right';
            app.LampLabel.FontWeight = 'bold';
            app.LampLabel.FontSize = 11;
            app.LampLabel.FontColor = [0.85 0.85 0.85];
            app.LampLabel.Layout.Row = 1;
            app.LampLabel.Layout.Column = 2;

            app.RunningLamp = uilamp(RunPanel);
            app.RunningLamp.Color = [0.8 0.8 0.8];
            app.RunningLamp.Layout.Row = 1;
            app.RunningLamp.Layout.Column = 3;

            app.StopButton = uibutton(app.MainGrid, 'push');
            app.StopButton.Text = 'Stop';
            app.StopButton.FontSize = 15;
            app.StopButton.FontWeight = 'bold';
            app.StopButton.FontColor = [1 1 1];
            app.StopButton.BackgroundColor = [0.60 0.10 0.10];
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Layout.Row = 2;
            app.StopButton.Layout.Column = 2;

            app.ResetButton = uibutton(app.MainGrid, 'push');
            app.ResetButton.Text = 'Reset Pulse';
            app.ResetButton.FontSize = 14;
            app.ResetButton.FontWeight = 'bold';
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.BackgroundColor = [0.55 0.35 0.05];
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.Layout.Row = 2;
            app.ResetButton.Layout.Column = 3;

            app.InitButton = uibutton(app.MainGrid, 'push');
            app.InitButton.Text = 'Initialize';
            app.InitButton.FontSize = 14;
            app.InitButton.FontWeight = 'bold';
            app.InitButton.FontColor = [1 1 1];
            app.InitButton.BackgroundColor = [0.15 0.30 0.65];
            app.InitButton.ButtonPushedFcn = createCallbackFcn(app, @InitButtonPushed, true);
            app.InitButton.Layout.Row = 2;
            app.InitButton.Layout.Column = 4;

            % Row 3 : Labels
            app.DutyKnobLabel = uilabel(app.MainGrid);
            app.DutyKnobLabel.Text = 'Duty Cycle';
            app.DutyKnobLabel.HorizontalAlignment = 'center';
            app.DutyKnobLabel.FontWeight = 'bold';
            app.DutyKnobLabel.FontSize = 13;
            app.DutyKnobLabel.FontColor = [0.9 0.9 0.9];
            app.DutyKnobLabel.Layout.Row = 3;
            app.DutyKnobLabel.Layout.Column = 1;

            app.FreqKnobLabel = uilabel(app.MainGrid);
            app.FreqKnobLabel.Text = 'Frequency (Hz)';
            app.FreqKnobLabel.HorizontalAlignment = 'center';
            app.FreqKnobLabel.FontWeight = 'bold';
            app.FreqKnobLabel.FontSize = 13;
            app.FreqKnobLabel.FontColor = [0.9 0.9 0.9];
            app.FreqKnobLabel.Layout.Row = 3;
            app.FreqKnobLabel.Layout.Column = 2;

            app.VrefSliderLabel = uilabel(app.MainGrid);
            app.VrefSliderLabel.Text = 'Vout Reference (V)';
            app.VrefSliderLabel.HorizontalAlignment = 'center';
            app.VrefSliderLabel.FontWeight = 'bold';
            app.VrefSliderLabel.FontSize = 13;
            app.VrefSliderLabel.FontColor = [0.9 0.9 0.9];
            app.VrefSliderLabel.Layout.Row = 3;
            app.VrefSliderLabel.Layout.Column = 3;

            app.EnableSwitchLabel = uilabel(app.MainGrid);
            app.EnableSwitchLabel.Text = 'Enable  (Off / On)';
            app.EnableSwitchLabel.HorizontalAlignment = 'center';
            app.EnableSwitchLabel.FontWeight = 'bold';
            app.EnableSwitchLabel.FontSize = 13;
            app.EnableSwitchLabel.FontColor = [0.9 0.9 0.9];
            app.EnableSwitchLabel.Layout.Row = 3;
            app.EnableSwitchLabel.Layout.Column = 4;

            % Row 4 : Knobs / Slider / EnableSwitch
            app.DutyKnob = uiknob(app.MainGrid, 'continuous');
            app.DutyKnob.Limits = [0 1];
            app.DutyKnob.MajorTicks = 0:0.1:1;
            app.DutyKnob.Value = 0.5;
            app.DutyKnob.ValueChangedFcn = createCallbackFcn(app, @DutyKnobValueChanged, true);
            app.DutyKnob.Layout.Row = 4;
            app.DutyKnob.Layout.Column = 1;

            app.FreqKnob = uiknob(app.MainGrid, 'continuous');
            app.FreqKnob.Limits = [1e4 1.5e5];
            app.FreqKnob.MajorTicks = [1e4 4e4 7e4 1e5 1.5e5];
            app.FreqKnob.Value = 40000;
            app.FreqKnob.ValueChangedFcn = createCallbackFcn(app, @FreqKnobValueChanged, true);
            app.FreqKnob.Layout.Row = 4;
            app.FreqKnob.Layout.Column = 2;

            app.VrefSlider = uislider(app.MainGrid);
            app.VrefSlider.Limits = [0 12];
            app.VrefSlider.MajorTicks = 0:1:12;
            app.VrefSlider.Value = 5;
            app.VrefSlider.ValueChangedFcn = createCallbackFcn(app, @VrefSliderValueChanged, true);
            app.VrefSlider.Layout.Row = 4;
            app.VrefSlider.Layout.Column = 3;

            app.EnableSwitch = uiswitch(app.MainGrid, 'toggle');
            app.EnableSwitch.Items = {'Off', 'On'};
            app.EnableSwitch.Value = 'On';
            app.EnableSwitch.FontColor = [0.10 0.85 0.10];
            app.EnableSwitch.ValueChangedFcn = createCallbackFcn(app, @EnableSwitchValueChanged, true);
            app.EnableSwitch.Layout.Row = 4;
            app.EnableSwitch.Layout.Column = 4;

            % Row 5 : Value labels
            app.DutyValueLabel = uilabel(app.MainGrid);
            app.DutyValueLabel.Text = 'Duty = 0.500';
            app.DutyValueLabel.HorizontalAlignment = 'center';
            app.DutyValueLabel.FontSize = 12;
            app.DutyValueLabel.FontColor = [0.35 0.80 0.35];
            app.DutyValueLabel.Layout.Row = 5;
            app.DutyValueLabel.Layout.Column = 1;

            app.FreqValueLabel = uilabel(app.MainGrid);
            app.FreqValueLabel.Text = 'Freq = 40000 Hz';
            app.FreqValueLabel.HorizontalAlignment = 'center';
            app.FreqValueLabel.FontSize = 12;
            app.FreqValueLabel.FontColor = [0.35 0.80 0.35];
            app.FreqValueLabel.Layout.Row = 5;
            app.FreqValueLabel.Layout.Column = 2;

            app.VrefValueLabel = uilabel(app.MainGrid);
            app.VrefValueLabel.Text = 'Vout ref = 5.00 V';
            app.VrefValueLabel.HorizontalAlignment = 'center';
            app.VrefValueLabel.FontSize = 12;
            app.VrefValueLabel.FontColor = [0.35 0.80 0.35];
            app.VrefValueLabel.Layout.Row = 5;
            app.VrefValueLabel.Layout.Column = 3;

            % Row 6 : Mode label
            app.ModeSwitchLabel = uilabel(app.MainGrid);
            app.ModeSwitchLabel.Text = 'Mode  (Open / Closed)';
            app.ModeSwitchLabel.HorizontalAlignment = 'center';
            app.ModeSwitchLabel.FontWeight = 'bold';
            app.ModeSwitchLabel.FontSize = 13;
            app.ModeSwitchLabel.FontColor = [0.9 0.9 0.9];
            app.ModeSwitchLabel.Layout.Row = 6;
            app.ModeSwitchLabel.Layout.Column = 4;

            % Row 7 : ModeSwitch
            app.ModeSwitch = uiswitch(app.MainGrid, 'slider');
            app.ModeSwitch.Items = {'Open', 'Closed'};
            app.ModeSwitch.Value = 'Open';
            app.ModeSwitch.FontColor = [1.00 0.85 0.10];
            app.ModeSwitch.ValueChangedFcn = createCallbackFcn(app, @ModeSwitchValueChanged, true);
            app.ModeSwitch.Layout.Row = 7;
            app.ModeSwitch.Layout.Column = 4;

            % Row 8 : Separateur Scopes
            app.ScopeSectionLabel = uilabel(app.MainGrid);
            app.ScopeSectionLabel.Text = '────────────────────────────── Scopes ──────────────────────────────';
            app.ScopeSectionLabel.HorizontalAlignment = 'left';
            app.ScopeSectionLabel.FontSize = 13;
            app.ScopeSectionLabel.FontWeight = 'bold';
            app.ScopeSectionLabel.FontColor = [0.55 0.75 1.00];
            app.ScopeSectionLabel.Layout.Row = 8;
            app.ScopeSectionLabel.Layout.Column = [1 4];

            % Row 9 : 3 boutons Scope
            app.ScopeOutputButton = uibutton(app.MainGrid, 'push');
            app.ScopeOutputButton.Text = 'Scope Output';
            app.ScopeOutputButton.FontSize = 14;
            app.ScopeOutputButton.FontWeight = 'bold';
            app.ScopeOutputButton.FontColor = [1 1 1];
            app.ScopeOutputButton.BackgroundColor = [0.10 0.35 0.60];
            app.ScopeOutputButton.ButtonPushedFcn = createCallbackFcn(app, @ScopeOutputButtonPushed, true);
            app.ScopeOutputButton.Layout.Row = 9;
            app.ScopeOutputButton.Layout.Column = 1;

            app.ScopePWMButton = uibutton(app.MainGrid, 'push');
            app.ScopePWMButton.Text = 'Scope PWM';
            app.ScopePWMButton.FontSize = 14;
            app.ScopePWMButton.FontWeight = 'bold';
            app.ScopePWMButton.FontColor = [1 1 1];
            app.ScopePWMButton.BackgroundColor = [0.08 0.42 0.08];
            app.ScopePWMButton.ButtonPushedFcn = createCallbackFcn(app, @ScopePWMButtonPushed, true);
            app.ScopePWMButton.Layout.Row = 9;
            app.ScopePWMButton.Layout.Column = 2;

            app.ScopeControllerButton = uibutton(app.MainGrid, 'push');
            app.ScopeControllerButton.Text = 'Scope Controller';
            app.ScopeControllerButton.FontSize = 14;
            app.ScopeControllerButton.FontWeight = 'bold';
            app.ScopeControllerButton.FontColor = [1 1 1];
            app.ScopeControllerButton.BackgroundColor = [0.45 0.12 0.12];
            app.ScopeControllerButton.ButtonPushedFcn = createCallbackFcn(app, @ScopeControllerButtonPushed, true);
            app.ScopeControllerButton.Layout.Row = 9;
            app.ScopeControllerButton.Layout.Column = 3;

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = Dashboard_App_buck_FPGA
            createComponents(app)
            registerApp(app, app.UIFigure)
            app.initializeWorkspaceVariables();
            app.refreshStatus();
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            try
                if isvalid(app.UIFigure)
                    delete(app.UIFigure)
                end
            catch
            end
        end
    end
end