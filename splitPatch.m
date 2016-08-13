function [ patches ] = splitPatch(accsCells,pSize)
%SPLITPATCH Summary of this function goes here
%   size represents the number of point in each patch
% patches = [];
patches = [];

cellNum = size(accsCells,1);
cellSize = 0;
count = 1;

for i = 1:cellNum
    cell = accsCells{i};
    cellSize = size(cell,1);
    for j=1:pSize-1:cellSize
        if j+pSize-1<cellSize
            temp = [cell(j:j+pSize-1,:),repmat(i,[pSize,1])];
            patches{count}=temp;
            %patches = [patches;temp];
            count = count+1;
        end
    end
end

