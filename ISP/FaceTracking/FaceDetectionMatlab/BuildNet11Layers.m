net11Layer = network;
net11Layer.numInputs = 10;
net11Layer.numLayers = 11;

for i=1:11
net11Layer.biasConnect(i)=1;
end

%Input i connect to the i'th layer
for i=1:10
net11Layer.inputConnect(i,i) = 1;
end

% for i=1:10
%    net11Layer.inputWeights{i}.size = 100;
% end

%Layers 1-10 connect to the 11'th layer
for i=1:10
   net11Layer.layerConnect(end,i) = 1;
end


net11Layer.outputConnect(1,end) = 1;
net11Layer.targetConnect(1,end) = 1;

for i=1:10
   net11Layer.inputs{i}.size = 100;
   net11Layer.inputs{i}.range = ones(100,1)*[0 255];
end

for i=1:11
%    net11Layer.layers{i}.size = 100;
   net11Layer.layers{i}.transferFcn = 'tansig';
   net11Layer.layers{i}.initFcn = 'initnw';
end


net11Layer.initFcn = 'initlay';
net11Layer.performFcn = 'mse';
net11Layer.trainFcn = 'trainlm';

net11Layer