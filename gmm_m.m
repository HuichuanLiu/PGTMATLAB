classdef gmm_m < handle
    % Class myLogReg is a model using Logitic Regression Algorithem or Conjugate Gradient Algorithem.
    % Scalar a expresses the stepsize, default at 0.01
    % Scalar maxepochs gives a restriction on iterations, default at featureNumber * 5
    % Scalar traintimes records how many times the model has been trained.
    % Array w represents weights in the model.
    properties
        model = [];
    end
    
    methods
        function train(this,ldata,labels,udata)
            this.model = EM_GMM(ldata,labels,udata);
        end
        
        function unsup_train(this,udata)
            this.model = origin_gmm(udata,5);
        end
        
        function [acc,entropy] = test(this,ldata,labels)
            [N,D] = size(ldata);
            class = unique(labels);
            C = size(unique(labels),1);
            f = zeros(N,C);
            %Gaussian posterior probability
            %N(x|pMiu,ppSigma) = 1/((2pi)^(D/2))*(1/(abs(pSigma))^0.5)*exp(-1/2*(x-pMiu)'ppSigma^(-1)*(x-pMiu))
            %data_num = size(data,1);
            %Px = zeros(data_num,C);
            for j = 1:C
                Xshift = ldata-repmat(this.model.u(j, :), N, 1); %X-pMiu
                inv_pSigma = inv(this.model.pSigma(:, :, j));
                tmp = sum((Xshift*inv_pSigma) .* Xshift, 2);
                coef = (2*pi)^(-D/2) * sqrt(det(inv_pSigma));
                f(:,j) = coef * exp(-0.5*tmp);
            end
            
            [~,ic] = max(f,[],2);
            preds = class(ic);
            
%             [~,sort_id] = sort(pb,'descend');
%             preds = preds(sort_id);
%             labels = labels(sort_id);
%             
%             preds = preds(1:floor(end/100));
%             labels = labels(1:floor(end/100));
            
            bingo = preds==labels;
            acc = size(bingo(bingo==1))/size(labels);
            diff = preds-labels;
            entropy = 1-1/(1+exp(mean(abs(diff))));
        end
        
    end
end
