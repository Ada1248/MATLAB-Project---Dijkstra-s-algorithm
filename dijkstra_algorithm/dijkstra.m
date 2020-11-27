function [shortest_path,distance] = dijkstra(G,source, dest, num_of_nodes) 

% G - graph 
% source - source node 
% dest - destination node 

    n = num_of_nodes;
    d = ones(1,n)*Inf;      % array of the shortest distnaces to source node 
    d(source) = 0;          % the distance from source node to source node is 0
    prev = zeros(1,n);      % array of previous nodes 
    visited = zeros(1,n);	% array of visited nodes, when value is 0 - node has not been visited yet, otherwise value is Inf  
    count = 0;              % counter of visited nodes 
    while count < n
        tmp = ones(1,n) * Inf; % temporary array of distances to nodes 
        for i = 1:n
        	if visited(i) == 0  % if the i'th node has not been visited yet
        		tmp(i) = d(i);  % assign actual distance to this node to the tmp array   
            end
        end
        [~, node_idx] = min(tmp); % get the index of closest unvisited node (node with minimum distance)
        visited(node_idx) = Inf;  
        neighbours = neighbors(G,node_idx); % get all neighbours of node
        for i = 1:size(neighbours,1)
            w = neighbours(i); 
            if visited(w) == 0  
               weight = G.Edges.Weight(findedge(G, node_idx, w));  
                if d(w) > d(node_idx) + weight
                    d(w) = d(node_idx) + weight;
                    prev(w) = node_idx;
                end
            end
        end
        count = count + 1; 
    end
    
    distance = d(dest); 
    
    path = []; 
    while dest > 0
    	path(end+1) = dest;
    	dest = prev(dest);
    end 
    
    shortest_path = path;
    end

