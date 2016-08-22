classdef logReg < handle
    % Class myLogReg is a model using Logitic Regression Algorithem or Conjugate Gradient Algorithem.
    % Scalar a expresses the stepsize, default at 0.01
    % Scalar maxepochs gives a restriction on iterations, default at featureNumber * 5
    % Scalar traintimes records how many times the model has been trained.
    % Array w represents weights in the model.
    properties
        % properties used in gradient descent
        w = [];     %weights
        maxepochs = 0;  %the max epochs
        t = 0;

        
        %porperties used generally
        a = 0;      %stepsize in GD
        py =[];     %prediction list
        row =0;     %rows of data and labels
        col = 0;    %columes of data
        traintimes = 0;     %indicates the the amount of training        
    end
    
    methods
        % train the model via Gradient Desent Algorithm
        function this = train(this,data,labels)
            %initialize key values in the first train.
            if this.traintimes == 0;
                [this.row, this.col] = size(data);
                this.initial(data);
            end
            
            for i = 1:this.maxepochs   %   in each epoch, do :
                for j = 1:this.row  %   for each example, do :
                    xj = data(j,:);
                    yp = this.f(xj);
                    y = labels(j);
                    
                    for k = 1:this.col	% for each w, do :
                        x = data(j,k);
                        this.w(k) = this.w(k) - this.a*(yp-y)*x;    % wk = wk - a(f(x)-y)*xk
                    end
                    this.t = this.t + this.a*(yp-y);    % t = t + a(f(x)-y)
                  
                end
            end
            this.traintimes = this.traintimes+1;    % record trained times
        end
        
        % test the data from the error function  errorrate = -sum{yi*log(f(xi))+(1-yi)*log(1-f(xi))}/m
        function [E,yp]= test(this,data,labels)
            loss = 0;
            yp = zeros(size(data,1),1);
            for i = 1:size(data,1)
                yp(i) = this.f(data(i,:));
                loss = loss+yp(i)-labels(i);
            end
            E = 1-1/(1+exp(loss/this.row));          
        end
        
        % call prediction function
        function yp = f(this,x)
            %yl = x*this.w - this.t;
            yp = x*this.w - this.t;  % f(x) = 1/(1+exp(-(WTX-t)))
        end
        
        %initialize the datasets for Gradient Decent training
        function initial(this,data)
            
            [this.row, this.col] = size(data);
            
            if this.maxepochs == 0
                this.maxepochs = this.col*50;
            end
            
            if this.a == 0
                this.a = 0.1;  % initialize the stepsize a.
            end
            
            if size(this.w) == 0
                this.w = rand(this.col,1);   % initialize vector w.
            end
        end

    end
end
