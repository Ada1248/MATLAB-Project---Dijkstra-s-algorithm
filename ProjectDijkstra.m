classdef ProjectDijkstra < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        UIAxes                        matlab.ui.control.UIAxes
        UITableAdjMatrix              matlab.ui.control.Table
        SizeofthegraphEditFieldLabel  matlab.ui.control.Label
        SizeEditField                 matlab.ui.control.NumericEditField
        CreateGraphButton             matlab.ui.control.Button
        StartnodeLabel                matlab.ui.control.Label
        SpinnerStart                  matlab.ui.control.Spinner
        EndnodeLabel                  matlab.ui.control.Label
        SpinnerEnd                    matlab.ui.control.Spinner
        ShortestPathButton            matlab.ui.control.Button
        TextArea                      matlab.ui.control.TextArea
        RestartButton                 matlab.ui.control.Button
        UITableDistMatrix             matlab.ui.control.Table
    end

    properties (Access = public)
        A = zeros % Adjacency matrix
        G = graph % Graph
        p
        matrixOfDistance
        matrixOfPath
    end
    
    methods (Access = private)
 
        function [prev, d] = dijkstra(app, source)
            n = numnodes(app.G);
            d = ones(1, n) * Inf;     % array of the shortest distnaces to source node 
            d(source) = 0;            % the distance from source node to source node is 0
            prev = zeros(1, n);       % array of previous nodes 
            visited = zeros(1, n);	  % array of visited nodes, when value is 0 - node has not been visited yet, otherwise value is Inf  
            count = 0;                % counter of visited nodes 
            
            while count < n
                tmp = ones(1, n) * Inf; % temporary array of distances to nodes 
                for i = 1:n
                    if visited(i) == 0  % if the i'th node has not been visited yet
                        tmp(i) = d(i);   % assign actual distance to this node to the tmp array   
                    end
                end
                
                [~, node_idx] = min(tmp); % get the index of closest unvisited node (node with minimum distance)
                visited(node_idx) = Inf;  
                neighbours = neighbors(app.G, node_idx); % get all neighbours of node
                
                for i = 1:size(neighbours, 1)
                    w = neighbours(i); 
                    if visited(w) == 0  
                        weight = app.G.Edges.Weight(findedge(app.G, node_idx, w));  
                        if d(w) > d(node_idx) + weight
                            d(w) = d(node_idx) + weight;
                            prev(w) = node_idx;
                        end
                    end
                end
                
                count = count + 1; 
            end
        end

        
        function graphPlot = drawGraph(app)
            graphPlot = plot(app.UIAxes, app.G, 'EdgeLabel', app.G.Edges.Weight);
        end
       
        
        function matrixOfDistance = calculateMatrixOfDistance(app)
            n = numnodes(app.G);
            matrixOfDistance = zeros(n, n);
            for i = 1:n
                [~, matrixOfDistance(i, :)] = dijkstra(app, i);
            end
        end
        
        function matrixOfPath = calculateMatrixOfPath(app)
            n = numnodes(app.G);
            matrixOfPath = zeros(n, n);
            for i = 1:n
                [matrixOfPath(i, :), ~] = dijkstra(app, i);
            end
        end
        
        function shortest_path = findShortestPath(app, startNode, endNode)
            path = [];
            tmp = endNode;            
            while tmp ~= startNode
                if(tmp == 0)
                    uialert(app.UIFigure, "Try to create connected graph", "Title", "Icon", "info");
                    shortest_path = null(1);
                    return;
                else
                    path(end+1) = tmp;
                    tmp = app.matrixOfPath(startNode, tmp);
                end
            end 
            path(end+1) = startNode;
            shortest_path = path;            
        end
    end   

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.A = zeros;
            app.G = graph;
            delete(app.p);
            
            app.UITableAdjMatrix.Visible = "off";
            app.UITableAdjMatrix.Enable = "off";
            
            app.CreateGraphButton.Visible = "off";
            app.CreateGraphButton.Enable = "off";  
            
            app.UIAxes.Visible = "off";
           
            app.UITableDistMatrix.Visible = "off";
            app.UITableDistMatrix.Enable = "off";
            removeStyle(app.UITableDistMatrix);

            
            app.SpinnerStart.Visible = "off";
            app.SpinnerStart.Enable = "off";
            app.SpinnerStart.Editable = "off";
            app.SpinnerStart.Value = 1;
            app.StartnodeLabel.Visible = "off";
            
            app.SpinnerEnd.Visible = "off";
            app.SpinnerEnd.Enable = "off";
            app.SpinnerEnd.Editable = "off";
            app.SpinnerEnd.Value = 1;
            app.EndnodeLabel.Visible = "off";
            
            app.ShortestPathButton.Visible = "off";
            app.ShortestPathButton.Enable = "off";
        end

        % Value changed function: SizeEditField
        function SizeEditFieldValueChanged(app, event)
            app.startupFcn()
            value = app.SizeEditField.Value;
            app.UITableAdjMatrix.Data = zeros(value, value); 
 
            width = 33 * (value + 2);
            height = 24 * (value + 2);
            
            app.UITableAdjMatrix.ColumnName = 1:value;
            app.UITableAdjMatrix.RowName = 1:value;
            app.UITableAdjMatrix.ColumnWidth = {33, 33, 33, 33, 33, 33, 33, 33, 33, 33};
            app.UITableAdjMatrix.Position = [app.UIFigure.Position(3)/4 - width/2, app.UIFigure.Position(4)*2/3 - height, width, height];
            
            app.UITableDistMatrix.ColumnName = 1:value;
            app.UITableDistMatrix.RowName = 1:value;
            app.UITableDistMatrix.ColumnWidth = {33, 33, 33, 33, 33, 33, 33, 33, 33, 33};
            app.UITableDistMatrix.Position = [510, 280 - height, width, height];
            
            app.UITableAdjMatrix.Visible = "on";
            app.UITableAdjMatrix.Enable = "on";
            
            app.CreateGraphButton.Visible = "on";
            app.CreateGraphButton.Enable = "on";
            
            app.A = zeros(value);
        end

        % Cell edit callback: UITableAdjMatrix
        function UITableAdjMatrixCellEdit(app, event)
            row = event.Indices(1);
            col = event.Indices(2);
            newData = event.NewData;
            if (isnan(newData))
                uialert(app.UIFigure, "Weights must be numbers", "Title", "Icon", "info");
                app.UITableAdjMatrix.Data = app.A;             
                return;
            elseif (newData < 0)
                uialert(app.UIFigure, "Weights must be greater than zero", "Title", "Icon", "info");
                app.UITableAdjMatrix.Data = app.A;             
                return;
            end
            
            if (row == col)
                uialert(app.UIFigure, "The diagonal weights must be 0", "Title", "Icon", "info");
                app.A(row, col) = 0;
            else
                app.A(row, col) = newData;
                app.A(col, row) = newData;
            end
            
            app.UITableAdjMatrix.Data = app.A;             
        end

        % Button pushed function: CreateGraphButton
        function CreateGraphButtonPushed(app, event)
            app.G = graph(app.A);
            app.p = app.drawGraph();

            app.UIAxes.Visible = "on";
            
            app.SpinnerStart.Visible = "on";
            app.SpinnerStart.Enable = "on";
            app.SpinnerStart.Editable = "on";
            app.StartnodeLabel.Visible = "on";
            app.SpinnerStart.Limits = [0, numnodes(app.G)];

            app.SpinnerEnd.Visible = "on";
            app.SpinnerEnd.Enable = "on";
            app.SpinnerEnd.Editable = "on";
            app.EndnodeLabel.Visible = "on";
            app.SpinnerEnd.Limits = [0, numnodes(app.G)];
            
            app.UITableDistMatrix.Visible = "on";
            app.UITableDistMatrix.Enable = "on";

            app.ShortestPathButton.Visible = "on";
            app.ShortestPathButton.Enable = "on";   
            
            app.matrixOfDistance = app.calculateMatrixOfDistance();
            app.UITableDistMatrix.Data = app.matrixOfDistance;  
            
            app.matrixOfPath = app.calculateMatrixOfPath();
        end

        % Button pushed function: ShortestPathButton
        function ShortestPathButtonPushed(app, event)
            startNode = app.SpinnerStart.Value;
            endNode = app.SpinnerEnd.Value; 
            if (app.findShortestPath(startNode, endNode))
                path = app.findShortestPath(startNode, endNode);
            else
                removeStyle(app.UITableDistMatrix);
                app.p = app.drawGraph();
                return;
            end

            app.p = app.drawGraph();
            highlight(app.p, path, 'EdgeColor', 'g');
            
            removeStyle(app.UITableDistMatrix);
            
            s = uistyle('BackgroundColor', 'yellow');
            addStyle(app.UITableDistMatrix, s, 'cell', [startNode, endNode]);
            addStyle(app.UITableDistMatrix, s, 'cell', [endNode, startNode]);
        end

        % Button pushed function: RestartButton
        function RestartButtonPushed(app, event)
            app.startupFcn();
            app.SizeEditField.Value = 0; 
        end

        % Value changing function: SpinnerStart
        function SpinnerStartValueChanging(app, event)
            changingValue = event.Value;
            if (changingValue == 0)
                uialert(app.UIFigure, "There is no node with number 0", "Title", "Icon", "info");
                app.SpinnerStart.Value = 1;
            end
        end

        % Value changing function: SpinnerEnd
        function SpinnerEndValueChanging(app, event)
            changingValue = event.Value;
            if (changingValue == 0)
                uialert(app.UIFigure, "There is no node with number 0", "Title", "Icon", "info");
                app.SpinnerEnd.Value = 1;
            end            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1156 790];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Weighted graph')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [511 321 626 438];

            % Create UITableAdjMatrix
            app.UITableAdjMatrix = uitable(app.UIFigure);
            app.UITableAdjMatrix.ColumnName = {'Adjacency matrix'};
            app.UITableAdjMatrix.RowName = {''};
            app.UITableAdjMatrix.ColumnEditable = true;
            app.UITableAdjMatrix.RowStriping = 'off';
            app.UITableAdjMatrix.CellEditCallback = createCallbackFcn(app, @UITableAdjMatrixCellEdit, true);
            app.UITableAdjMatrix.Tooltip = {''; ''; ''};
            app.UITableAdjMatrix.Position = [78 226 342 300];

            % Create SizeofthegraphEditFieldLabel
            app.SizeofthegraphEditFieldLabel = uilabel(app.UIFigure);
            app.SizeofthegraphEditFieldLabel.HorizontalAlignment = 'right';
            app.SizeofthegraphEditFieldLabel.Position = [157 536 96 22];
            app.SizeofthegraphEditFieldLabel.Text = 'Size of the graph';

            % Create SizeEditField
            app.SizeEditField = uieditfield(app.UIFigure, 'numeric');
            app.SizeEditField.Limits = [0 10];
            app.SizeEditField.ValueChangedFcn = createCallbackFcn(app, @SizeEditFieldValueChanged, true);
            app.SizeEditField.Position = [268 536 100 22];

            % Create CreateGraphButton
            app.CreateGraphButton = uibutton(app.UIFigure, 'push');
            app.CreateGraphButton.ButtonPushedFcn = createCallbackFcn(app, @CreateGraphButtonPushed, true);
            app.CreateGraphButton.Position = [320 169 100 22];
            app.CreateGraphButton.Text = 'Create Graph';

            % Create StartnodeLabel
            app.StartnodeLabel = uilabel(app.UIFigure);
            app.StartnodeLabel.HorizontalAlignment = 'right';
            app.StartnodeLabel.Position = [907 270 61 22];
            app.StartnodeLabel.Text = 'Start node';

            % Create SpinnerStart
            app.SpinnerStart = uispinner(app.UIFigure);
            app.SpinnerStart.ValueChangingFcn = createCallbackFcn(app, @SpinnerStartValueChanging, true);
            app.SpinnerStart.Limits = [1 10];
            app.SpinnerStart.Position = [983 270 100 22];
            app.SpinnerStart.Value = 1;

            % Create EndnodeLabel
            app.EndnodeLabel = uilabel(app.UIFigure);
            app.EndnodeLabel.HorizontalAlignment = 'right';
            app.EndnodeLabel.Position = [909 226 57 22];
            app.EndnodeLabel.Text = 'End node';

            % Create SpinnerEnd
            app.SpinnerEnd = uispinner(app.UIFigure);
            app.SpinnerEnd.ValueChangingFcn = createCallbackFcn(app, @SpinnerEndValueChanging, true);
            app.SpinnerEnd.Limits = [1 10];
            app.SpinnerEnd.Position = [981 226 100 22];
            app.SpinnerEnd.Value = 1;

            % Create ShortestPathButton
            app.ShortestPathButton = uibutton(app.UIFigure, 'push');
            app.ShortestPathButton.ButtonPushedFcn = createCallbackFcn(app, @ShortestPathButtonPushed, true);
            app.ShortestPathButton.Position = [957 160 100 22];
            app.ShortestPathButton.Text = 'Shortest Path';

            % Create TextArea
            app.TextArea = uitextarea(app.UIFigure);
            app.TextArea.FontSize = 13;
            app.TextArea.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TextArea.Position = [24 585 478 174];
            app.TextArea.Value = {'Welcome :)'; 'This program will allow you to find the shortest paths in a given graph.'; ''; 'All you have to do is:'; '1: Enter the size of the graph you want to create'; '2: Complete the adjacency matrix (remember that the weights cannot be  '; '    negative and those on the diagonal must be 0)'; '3: Click: Create graph'; '4: Select two vertices'; '5: Click: Shortest path'};

            % Create RestartButton
            app.RestartButton = uibutton(app.UIFigure, 'push');
            app.RestartButton.ButtonPushedFcn = createCallbackFcn(app, @RestartButtonPushed, true);
            app.RestartButton.Position = [33 57 100 22];
            app.RestartButton.Text = 'Restart';

            % Create UITableDistMatrix
            app.UITableDistMatrix = uitable(app.UIFigure);
            app.UITableDistMatrix.ColumnName = {'Matrix of distances'};
            app.UITableDistMatrix.RowName = {''};
            app.UITableDistMatrix.ColumnEditable = true;
            app.UITableDistMatrix.RowStriping = 'off';
            app.UITableDistMatrix.Tooltip = {''; ''; ''};
            app.UITableDistMatrix.Position = [511 21 342 300];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ProjectDijkstra

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