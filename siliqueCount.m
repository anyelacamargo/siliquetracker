%Software to count siliques
%Anyela Camargo

%Main function call the rest
function main()
    imagesTrainingfolder = 'C:\Anyela\students\gina\Siliques\images\train\';
    imagesTestingfolder = 'C:\Anyela\students\gina\Siliques\images\test\';
    outputfile = 'silique_output.csv';
    % Training images
    rd = GetFiles(imagesTrainingfolder);
    getTrainingData(rd, imagesTrainingfolder, outputfile);
    %Test images
    rd = GetFiles(imagesTestingfolder);
    getTestData(rd, imagesTestingfolder, outputfile);

   
    %classifyImage(rd, imagesTestingfolder, outputfile);
 
 %List files from folder
 function rd = GetFiles(rootname)
    rd = dir(strcat(rootname));
    p = [];
    for i=3:size(rd)
        if (length(rd(i).name) > 1)
            p = [p,i];
        end
    end
    rd = rd(p);
 
   
     
 % Get training data
 function getTrainingData(filelist, rootname, outputfile)
     fileID = fopen(outputfile,'w');
     fprintf(fileID,'%s, %s, %s\n', 'Filename', 'idtag', 'area0');
     inx = getIndex(filelist, 'modified');
     xgroup = cell(1,1); xgroup(1:length(xgroup)) = {'0'};
     xdata = zeros(1,3);
     for k=1:numel(inx)
        fname = strcat(rootname, filelist(inx(k)).name);
        fnameOrig = strcat(rootname, splitname(filelist(inx(k)).name),'.png');
        
        try   
        I = imread(fname);
        IOrig = imread(fnameOrig);
        BW = cropImage(I, 0, 0, 3);
        s = getProps(BW, IOrig);
        
%         xdata = cat(1, xdata, data);
%         xgroup = cat(1, xgroup, group);
        catch
            warning('Problem using function. Assigning a value of 0.');
        end   
     end
%      [svn_model] = train_classifier(xdata, xgroup);
%      save('train.mat','group', 'xdata', 'svn_model');
 
     

 % Get test data
 function getTestData(filelist, rootname, outputfile)
     fileID = fopen(outputfile,'w');
     fprintf(fileID,'%s, %s, %s\n', 'Filename', 'idtag', 'area0');
     load train.mat
     for k = 1:numel(filelist)
        fname = strcat(rootname, filelist(k).name);
        try
        I = imread(fname);
        mn = 51;  mx = 170;
        ICrop = cropImage(I, mn, mx, 3);
        createBoundary(ICrop, I);
        vextr = findCorners(ICrop); 
        ExtendVertix(vextr, ICrop);
        %[data, group] = getColors(I, [], o);
        catch
            warning('Problem using function. Assigning a value of 0.');
        end
%         resultclass = test_classifier(svn_model, data)
     end
 
    
%Extend vertix
function[] = ExtendVertix(vextr, BW)
    for i=1:size(vextr,1)
        r = vextr(i,2);
        c = vextr(i,1);
        %impixelinfo()
        BW(r,c) %row col
        n = BW(r-2, c)
        s = BW(r+2, c)
        e = BW(r, c-2)
        w = BW(r, c+2)
    end
    
         
         
%Select region of interest and apply dilation
% I = Image (RGB)
function[BW] = cropImage(I, mn, mx, sl)
    G = I(:,:,2);
    BW = roicolor(G, mn, mx);
    BW = deleteCorners(BW);
    BW = bwareaopen(BW, 100);
    SE = strel('line',sl,90);
    BW = imdilate(BW,SE);

%Clean edges
function[BW] = deleteCorners(BW)
    h = size(BW,1);
    w = size(BW,2);
    BW(:,1:10) = 0;
    BW(:,(w-10):w) = 0;
    BW(1:10,:) = 0;
    BW((h-10):h,:) = 0;
    
% Create boundary of segmented vs original image
function[B] = createBoundary(BW, I)
    B = bwboundaries(BW);
    imshow(BW)
    hold on
    visboundaries(B)

%Find corners 
% Returns table (c,r)
function[C] = findCorners(BW)
    C = corner(BW, 'MinimumEigenvalue');
    imshow(BW);
    hold on
    plot(C(:,1), C(:,2), 'r*');
    z = [];
    for i=1:size(C,1)
        if(BW(C(i,2), C(i,1)) == 0) %row col
            z = [z, i];
        end
    end
    C(z,:) = [];
    
function[stats] = getProps(BW, IOrig)
    CC = bwconncomp(BW);
    stats = regionprops(CC,'Centroid','Area', 'PixelIdxList');
    stats([stats.Area] == 1) = [];
    for i=1:length(stats)
        stats(i).avgArea = getAverageColors(IOrig, stats(i).PixelIdxList)
    end

    
function[LI] = LabelCrop(BW)
    CC = bwconncomp(BW);
    Label2=labelmatrix (CC);
    rgb_labeled=label2rgb(Label2);
    imshow(rgb_labeled);
        
     
function[str] = splitname(n)
    s = strsplit(n,'_');
    k = {s{1}, s{2}};
    str = strjoin(k,'_');
         
% Get pixel colours according to index
function [m, group] = getColors(I, inxc1, inxc2)
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
    m = zeros((length(inxc1)+length(inxc2)), 3);
    xinx = [inxc1, inxc2];
    group = cell((length(inxc1)+ length(inxc2)),1);
    group(1:length(inxc1)) = {'1'};
    group((length(inxc1)+1):length(group)) = {'0'};
    
    for ii=1:numel(xinx)
        i = xinx(ii);
        m(ii,1:3) = [R(i), G(i),B(i)];
    end

function[] = getDatafStruct(s)
    ss = s;
    ss = rmfield(ss,'PixelIdxList');
    m = zeros(length(ss), length(fieldnames(ss)));
    group = cell(length(ss),1);

    

function [m] = getAverageColors(I, inxc)
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
    m = zeros(length(inxc), 3);   
    for ii=1:numel(inxc)
        i = inxc(ii);
        m(ii,1:3) = [R(i), G(i),B(i)];
    end
    m = mean(mean(m));
    
% Look for training images
function ix = getIndex(filelistname, kw)
    k = strfind({filelistname.name}, kw);
    p = 18;
    ix = [];
    j = 1;
    for ii = 1:numel(k)
      if(k{ii} >= p)
         ix(j) = ii;
         j = j+1;
      end
    end     

function ix = searchPixelInx(I, r,g,b)
   ix = find(I(:,:,1) == r & I(:,:,2) == g & I(:,:,3) == b);
    
    
% Classify images 
function classifyImage(filelist, rootname, outputfile)
     fileID = fopen(outputfile,'w');
     fprintf(fileID,'%s, %s, %s\n', 'Filename', 'idtag', 'area0');
     for k=1:length(filelist)
        fname = strcat(rootname, filelist(k).name);
        try   
        I= imread(fname);
        r = test_classifier(svn_model, data(1:5,1:3));
        catch
            warning('Problem using function. Assigning a value of 0.');
        end
        savedata(fileID, fname);
     end
     
%Segment region according to threshold
function[BW] = segmentRegion(IM)
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
    mn=21;
    mx=164;
    R= IM(:,:,1);
    BW = roicolor(R, mn, mx);

%Mathematic morphology   and post-processing         
function[BW] = imagePostPro(IM)
    BW = bwareaopen(IM, 100);

%get Silique number
    function[] = getNumber(IM)
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
           
           
function savedata(outputfile, fname, totals)
  fprintf(outputfile,'%s, %12.0f\n', fname, totals);       

function edge_detection()
    rotI = imrotate(WB,12,'crop');
    BW = roicolor(rotI, mn, mx);
    [H,T,R] = hough(BW);
    
    lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
    figure, imshow(rotI), hold on
    max_len = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
    end
    
function comparePixel()
    C1 = 1 ./ sqrt((2*pi)^2 * pDet);
    pMeanT = transpose(pMean);
    for count=1:height
      for count2=1:width
         x = reshape(image(count, count2, :), 3, 1);
         for count3=1:noOfClasses
           invZ = pInv(:,:,count3);
           y = pMeanT(:, count3);
           C2 = x - y;
           post = C1(count3) * exp(-C2' * invZ * C2 * 0.5);
         end
      end
    end

function[xdata, group] = get_data(I)
  
    imshow(I);
    pause(10);
    %disp('Make image bigger and select silique only')
    i = impixel
    
    imshow(I);
    pause(5);
    %input('Make image bigger and select background only')
    j = impixel
    xdata = cat(1, i, j);
    group = cell((length(i)+ length(j)),1);
    group(1:length(i)) = {'1'};
    group((length(i)+1):length(group)) = {'0'};
    save('test.mat','group', 'xdata') 
    
 
function[xdata, group] = load_data(I)
    load('test.mat')
    
% Train clasifier
function[svmStruct] = train_classifier(xdata, group)
    svmStruct = svmtrain(xdata, group);

%Test classifier
function[resultclass] = test_classifier(svn_model, testdata)
    resultclass = svmclassify(svn_model, testdata)
    
function[imGW] = illuminant_correction(im)
    % im -  the RGB image 
    % imshow(im)
    % [min(im(:)) max(im(:))]
    [row,col] = size(im(:,:,1));
    im2d = reshape(im, [row*col 3]);
    im2d = im2double(im2d);

    %Grey World
    LGW = mean(im2d);
    % illuminant corrected image
    imGW = im2double(im);
    c=1; imGW(:,:,c) = imGW(:,:,c) ./ LGW(c);
    c=2; imGW(:,:,c) = imGW(:,:,c) ./ LGW(c);
    c=3; imGW(:,:,c) = imGW(:,:,c) ./ LGW(c);
    imshow(uint8(imGW.*255))