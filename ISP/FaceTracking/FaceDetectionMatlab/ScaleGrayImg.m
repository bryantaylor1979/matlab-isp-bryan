function ScaledImg = ScaleGrayImg(Img, NewXDim, NewYDim, option)

Img = double(Img);
[OrigXDim,OrigYDim]=size(Img);
Xoffset = floor(OrigXDim/NewXDim);
Yoffset = floor(OrigYDim/NewYDim);
NumOfPixels = Xoffset*Yoffset;
ScaledImg = double(zeros(NewXDim,NewYDim));

k=1; l=1;

if(option == 0)
   for i=1:Xoffset:OrigXDim-Xoffset+1
      l=1;
      for j=1:Yoffset:OrigYDim-Yoffset+1
         for s=0:Xoffset-1
            for t=0:Yoffset-1
               ScaledImg(k,l)=ScaledImg(k,l)+Img(s+i,t+j);
            end
         end
         ScaledImg(k,l)=ScaledImg(k,l)/NumOfPixels;
         l=l+1;
      end
      k=k+1;
   end

elseif (option== 1)%
   NumOfPixels = 4;
   for i=1:Xoffset:OrigXDim-Xoffset+1
      l=1;
      for j=1:Yoffset:OrigYDim-Yoffset+1
         ScaledImg(k,l)=Img(i,j)+Img(i,j+Yoffset-1)+Img(i+Xoffset-1,j)+Img(i+Xoffset-1,j+Yoffset-1);
         ScaledImg(k,l)=ScaledImg(k,l)/NumOfPixels;
         l=l+1;
      end
      k=k+1;
   end

else
   for i=1:Xoffset:OrigXDim-Xoffset+1
      l=1;
      for j=1:Yoffset:OrigYDim-Yoffset+1
         ScaledImg(k,l)=Img(i+Xoffset-1,j+Yoffset-1);
         l=l+1;
      end
      k=k+1;
   end
end
