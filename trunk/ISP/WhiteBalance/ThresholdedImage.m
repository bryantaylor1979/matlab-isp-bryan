function [LowAndHighThresholdedImage] = ThresholdedImage(image,Range)
LowThreshold = Range(1);  
HighThreshold = Range(2); 

%% Reshape Image for processing
[x,y]= size(double(image(:,:,1)));
RedPixelReshape = reshape(image(:,:,1),x*y,1);
GreenPixelReshape = reshape(image(:,:,2),x*y,1);
BluePixelReshape = reshape(image(:,:,3),x*y,1);
[ReshapedImage] = [RedPixelReshape,GreenPixelReshape,BluePixelReshape];

%% If any of the MinVal is less than the low threshold then dismiss
MinVal = min(ReshapedImage,[],2);
n = find(MinVal>LowThreshold);
LowThresholdedImage = ReshapedImage(n,:);

%% If any data is above the high threshold then remove
MaxVal = max(LowThresholdedImage,[],2);
n = find(MaxVal<HighThreshold);
LowAndHighThresholdedImage = LowThresholdedImage(n,:);
end