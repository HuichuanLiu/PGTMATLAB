for i = [10,50,150,200,300,400,800]
features = load(['features_' int2str(i)]);
features = struct2cell(features);
features = features{1};

s = data_labeling(features);
save(['data_' int2str(i)],'s');
end