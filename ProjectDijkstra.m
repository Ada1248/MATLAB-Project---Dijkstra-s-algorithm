classdef ProjectDijkstra_e < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        UITable             matlab.ui.control.Table
        EditFieldLabel      matlab.ui.control.Label
        EditField           matlab.ui.control.NumericEditField
        CreateGraphButton   matlab.ui.control.Button
        SpinnerLabel        matlab.ui.control.Label
        Spinner             matlab.ui.control.Spinner
        Spinner2Label       matlab.ui.control.Label
        Spinner2            matlab.ui.control.Spinner
        ShortestPathButton  matlab.ui.control.Button
        UIAxes              matlab.ui.control.UIAxes
    end

    properties (Access = public)
        A = zeros % Adj matrix
        G = graph % Graph
        p
        nodesNum = 0
    end   

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            value = app.EditField.Value;
            app.nodesNum(1) = value; 
            app.UITable.Data = zeros(value, value); 
            app.UITable.ColumnName = 1:value;
            app.UITable.RowName = 1:value;
            app.UITable.ColumnWidth = {30, 30, 30, 30, 30, 30, 30, 30, 30, 30};
            app.UITable.Visible = "on";
            app.UITable.Enable = "on";

            app.A = zeros(value);
        end

        % Cell edit callback: UITable
        function UITableCellEdit(app, event)
            row = event.Indices(1);
            col = event.Indices(2);
          
            newData = event.NewData;
            
            if (row == col)
                uialert(app.UIFigure, "The diagonal weights must be 0", "Title", "Icon", "info")
                app.A(row, col) = 0;
            else
                app.A(row, col) = newData;
                app.A(col, row) = newData;
            end
            
            app.UITable.Data = app.A;             
        end

        % Button pushed function: CreateGraphButton
        function CreateGraphButtonPushed(app, event)
            app.G = graph(app.A);
            plot(app.UIAxes, app.G,'EdgeLabel', app.G.Edges.Weight);
            %fplot(app.UIAxes, app.G);
        end

        % Callback function
        function Spinner2ValueChanged(app, event)
            
        end

        % Button pushed function: ShortestPathButton
        function ShortestPathButtonPushed(app, event)
            startNode = app.Spinner.Value;
            endNode = app.Spinner2.Value; 
            [path,distance] = dijkstra(app.G,startNode,endNode, app.nodesNum);
            app.p = plot(app.UIAxes, app.G,'EdgeLabel', app.G.Edges.Weight);
            highlight(app.p,path,'EdgeColor','g')
            disp(distance);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1022 556];
            app.UIFigure.Name = 'UI Figure';

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.ColumnName = {''};
            app.UITable.RowName = {''};
            app.UITable.ColumnEditable = true;
            app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
            app.UITable.Tooltip = {''; ''; ''};
            app.UITable.Enable = 'off';
            app.UITable.Position = [24 177 342 300];

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.UIFigure);
            app.EditFieldLabel.HorizontalAlignment = 'right';
            app.EditFieldLabel.Position = [43 486 55 22];
            app.EditFieldLabel.Text = 'Edit Field';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'numeric');
            app.EditField.Limits = [0 10];
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Position = [113 486 100 22];

            % Create CreateGraphButton
            app.CreateGraphButton = uibutton(app.UIFigure, 'push');
            app.CreateGraphButton.ButtonPushedFcn = createCallbackFcn(app, @CreateGraphButtonPushed, true);
            app.CreateGraphButton.Position = [79 67 100 22];
            app.CreateGraphButton.Text = 'Create Graph';

            % Create SpinnerLabel
            app.SpinnerLabel = uilabel(app.UIFigure);
            app.SpinnerLabel.HorizontalAlignment = 'right';
            app.SpinnerLabel.Position = [453 66 47 22];
            app.SpinnerLabel.Text = 'Spinner';

            % Create Spinner
            app.Spinner = uispinner(app.UIFigure);
            app.Spinner.Position = [515 66 100 22];

            % Create Spinner2Label
            app.Spinner2Label = uilabel(app.UIFigure);
            app.Spinner2Label.HorizontalAlignment = 'right';
            app.Spinner2Label.Position = [446 28 54 22];
            app.Spinner2Label.Text = 'Spinner2';

            % Create Spinner2
            app.Spinner2 = uispinner(app.UIFigure);
            app.Spinner2.Position = [515 28 100 22];

            % Create ShortestPathButton
            app.ShortestPathButton = uibutton(app.UIFigure, 'push');
            app.ShortestPathButton.ButtonPushedFcn = createCallbackFcn(app, @ShortestPathButtonPushed, true);
            app.ShortestPathButton.Position = [657 49 100 22];
            app.ShortestPathButton.Text = 'ShortestPath';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Weighted graph')
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [377 109 544 399];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ProjectDijkstra_e

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end