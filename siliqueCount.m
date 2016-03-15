%Software to count siliques


%Main function call the rest
function main()
    SegmentSilique();
 
 %Functio search for files
 function rd = GetFiles(rootname, dates, datee)
    rd = dir(strcat(rootname));
    p = [];
    for i=3:size(rd)
        if (length(rd(i).name) == 10)
            p = [p,i];
        end
    end
    rd = rd(p);
    
 %Segment image  
 function SegmentSilique()
     pc1 = dir(strcat('*.tiff')); % Look for files with a .tif extension and on the current folder
     if(length(pc1) >= 1)
        for k=1:length(pc1)
           fname = pc1(k).name;
           try   
                I= imread(fname);
                BWI1 = segmentRegion(I);
                BWI2 = imagePostPro(BWI1);
                getNumber(BWI2);
   
           catch
               warning('Problem using function. Assigning a value of 0.');
           end
        end
     end
     
%Segment region according to threshold
function[BW] = segmentRegion(IM)
    mn=72;
    mx=133;
    R= IM(:,:,1);
    BW = roicolor(R, mn, mx);

%Mathematic morphology   and post-processing         
function[BW] = imagePostPro(IM)
    BW = bwareaopen(IM, 100);

%get Silique number
function getNumber(IM)
    cc = regionprops(IM, 'Area', 'Perimeter'); %Get properties per segmented regions
    [a,v] = sort([cc.Perimeter]); %Sort perimeter by size
    CC = bwconncomp(IM);
    L = labelmatrix(CC); %Label segmented regions
    o = find(a > 300); %Search regions whose perimeter is large
    for i=1:length(o)
        k = find(L==v(o(i))); 
        L(k) = 0;
    end
    n = length(cc); %Delete large areas
    n = n - length(o);
    figure
    imagesc(L);
    title(['Number of siliques ',num2str(n)])
           
           
           
