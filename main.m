[accs,accsCell] = rule_base_filter;
patches = splitPatch(accsCell);
features = extractFeatures(accsCell);
assessment1 = semisup_ML(features,labels);
assessment2 = unsup_ML(features);

