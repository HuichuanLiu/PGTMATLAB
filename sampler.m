% MLOTOOLS/Core/sampler.m
%
% Allows for simple data statistics/manipulations
% Example usage:
%
% >> mysampler = sampler(data,labels);
% >> [tr te] = mysampler.split(1,5);
% >> model = logreg();
% >> model.train(tr.data,tr.labels);
%
% Properties
%   data        - NxM matrix (N examples, M features)
%   labels      - true class labels
%
%   numexamples - number of examples in this task
%   numfeatures - number of features in this task
%   numclasses  - number of classes in this task
%   classes     - unique class labels
%   arities     - arities of features 
%
% Methods
%   bootstrap   - returns train/test split by bootstrap
%   split(n,K)  - returns train/test split by cross-val
%                  e.g. [tr te] = split(1,5);
%   randomize   - returns shuffled version of this task
%
classdef sampler < handle
    
    properties
        
        data;
        labels;
        tasktype;
        
        numexamples;
        numfeatures;
        numclasses;
        classes;
        arities;
        
    end
    
    methods

        function this = sampler ( data, labels )
        % MLOtools/sampler
        % function this = sampler( data, labels )
        %
        % Arguments: data, labels - two matrices with same number of rows
        % Returns  : [train test] sampler objects
        %
            this.data = data;
            this.labels = labels;
            
            labs = unique(labels)';
            this.numclasses = length(labs);
            this.classes = num2str(labs);
            this.numexamples = size(data,1);
            this.numfeatures = size(data,2);
            this.tasktype = 'classification';
            
            %EXPENSIVE!
            for i=1:this.numfeatures
                this.arities(i) = length(unique(data(:,i)));
            end
            
        end
                
        function [train test] = bootstrap( this )
        % MLOtools/sampler.bootstrap
        % function [train test] = bootstrap()
        %
        % Arguments: None
        % Returns  : [train test] sampler objects
        %
            N = size(this.data,1);
            
            tridx = randsample(N,N,true);  
            teidx = setdiff( 1:N, tridx ); 

            train = sampler( this.data(tridx,:), this.labels(tridx,:) );
            test = sampler( this.data(teidx,:), this.labels(teidx,:) );

        end
                        
        function randomizedtask = randomize( this )
        % MLOtools/sampler.randomize
        % function randomizedtask = randomize()
        %
        % Arguments: none
        % Returns  : randomized copy of this sampler object
        %
            idx = randperm(size(this.data,1));  

            randomizedtask = sampler( this.data(idx,:), this.labels(idx,:) );

        end
        
        function [train test] = loocv(this, whichfold)
            
            [train test] = split(this, whichfold, size(this.data,1));

        end
        
        function [train test] = split(this, whichfold, numfolds)
        % MLOtools/sampler.split
        % function [train test] = split(whichfold, numfolds)
        %
        % Arguments: whichfold, numfolds - two integers
        % Returns  : [train test] sampler objects
        %
        % Example  : [train1 test2] = obj.split(1,3)
        %            [train2 test2] = obj.split(2,3)
        %    
        
            %calculate how big each fold (data partition) will be
            foldsize = floor( size(this.data,1) / numfolds );
            
            %calculate the row indices for the start/end of the partitions
            startindex = (whichfold-1)*foldsize + 1;
            endindex   = startindex + foldsize - 1;
            
            %boundary condition
            if whichfold==numfolds
                endindex = size(this.data,1);
            end
            
            %find the testing rows
            testindices = startindex:endindex;
            %everything else is training data
            trainindices = [ (1:startindex-1) (endindex+1):size(this.data,1) ];
            
            %split it
            train = sampler( this.data(trainindices,:), this.labels(trainindices,:) );
            test  = sampler( this.data(testindices,:), this.labels(testindices,:) );
        
        end

    end
    
end
