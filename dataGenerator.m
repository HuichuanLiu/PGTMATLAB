function dataGenerator
%DATAGNERATOR Summary of this function goes here
%   Detailed explanation goes here
% accsCell = load('linear_accsCell_P04');
% accsCell = struct2cell(accsCell);
% accsCell = accsCell{1};

[accs,accsCell] = rule_base_filter;

patches = splitPatch(accsCell,10);
features = extractFeatures(patches);
save('features_10','features');
%save('patches','patches');

patches = splitPatch(accsCell,50);
features = extractFeatures(patches);
save('features_50','features');


patches = splitPatch(accsCell,150);
features = extractFeatures(patches);
save('features_150','features');

patches = splitPatch(accsCell,200);
features = extractFeatures(patches);
save('features_200','features');

patches = splitPatch(accsCell,300);
features = extractFeatures(patches);
save('features_300','features');

patches = splitPatch(accsCell,400);
features = extractFeatures(patches);
save('features_400','features');

patches = splitPatch(accsCell,400);
features = extractFeatures(patches);
save('features_500','features');

end

