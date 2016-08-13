function pred = SKNN%(ldata,udata,n)
%SKNN Summary of this function goes here
%   Detailed explanation goes here
data = load('features');
data = data.features;
%data = data(:,[1,2,3,4,5,8,9]);
%data=[-1,7,2;-1,5,4;-1,2,3;-1,4,7;-1,8,1;-1,9,6;-1,8,5];
data = [1:2:27;2:2:28];
data =data';
global dimension;
dimension = size(data,2)-1; % without timestamp;
kdtree = buildTree(data,1);
neighber = searchTree(kdtree,[7,8.1]);

end

function kdtree = buildTree(data,depth)
elt = getDimension(depth);

%search node point
[~,p] = min(abs(data(:,elt)-median(data(:,elt))));
node = data(p,:);

%divide branches
leftData = data(data(:,elt)<node(elt),:);
rightData = data(data(:,elt)>node(elt),:);

%create left branch
if size(leftData,1)>1
    lbranch = buildTree(leftData,depth+1);
else
    lbranch = leftData;
end
%create right branch
if size(rightData,1)>1
    rbranch = buildTree(rightData,depth+1);
else
    rbranch = rightData;
end

%create node
kdtree = {node,lbranch,rbranch};
end

function pred = predict(data,kdtree,n)
pred = [data,zeros(size(data,1))];
for i = 1:size(data,1)
    point = data(i,:);
    neighbors = searchTree(kdtree,point,n);
    pred(i,end) = mode(neighbors(:,end));
end
end

function neighbor = searchTree(kdtree,point)
path = [];
while true
    path = forewardSearch(path,kdtree,point);
    [path,neighbor]= backwardSearch(path,kdtree,point);
    if isempty(path)
        breaks;
    end
end
end

function path = forewardSearch(path,kdtree,point)
pnode = kdtree;
while size(pnode,1)~=1
    point(depth+1)
    median = pnode{1};
    median(depth+1)
    
    if point(depth+1)<=median(depth+1)
        pnode = kdtree{2};
        path = [path,2];
    else
        pnode = kdtree{3};
        path = [path,3];
    end 
end

end

function [path,nnode] = backwardSearch(path,kdtree,point)
    [nnode,ndist] = calDist(kdtree,point,path);     %calculate the nearest node and its distance to the target
    bnode = 5 - path(end);          %save the brother node
    path = path(1:(end-1));         %remove the last node from comparing list(path)
    
    while ~isempty(path)
        [node,dist] = calDist(kdtree,point,path);      % find the comparing point
        elt = getDimension(size(path));        
        dist2surf = pnode(elt)-point(elt);               % find the distance from the comparing surface to the target

        if ndist<dist2surf           % if it is larger than the smallest distance
            if dist<ndist
                nnode = node;
                ndist = dist;
            end
            
            
        end
    end
end

function elt = getDimension(depth)
global dimension;
elt = mod(depth,dimension);
if ~elt
    elt = dimension+1;
    
else
    elt = elt+1;
end
end

function [node,dist] = calDist(kdtree,point,path)
    for i=1:size(path)
       node = kdtree(path(i)) ;
    end
    dist = norm(node-point);
end