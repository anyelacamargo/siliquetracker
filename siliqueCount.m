%Software to count siliques
%Anyela Camargo

%Main function call the rest
function main()
    imagesTrainingfolder = 'C:\Anyela\students\gina\Siliques\';
    imagesTestingfolder = 'C:\Anyela\students\gina\Siliques\';
    outputfile = 'silique_output.csv';
    rd = GetFiles(imagesfolder);
    getTrainingData(rd, imagesTrainingfolder, outputfile);
    rd = GetFiles(imagesfolder);
    classifyImage(rd, imagesTestingfolder, outputfile);
 
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
  
    
 function getTrainingData(filelist, rootname, outputfile)
     fileID = fopen(outputfile,'w');
     fprintf(fileID,'%s, %s, %s\n', 'Filename', 'idtag', 'area0');
     for k=1:length(filelist)
        fname = strcat(rootname, filelist(k).name);
        try   
        I= imread(fname);
        [data, group] = load_data(I);
        [svn_model] = train_classifier(data, group);
        catch
            warning('Problem using function. Assigning a value of 0.');
        end
        savedata(fileID, fname);
     end
     
 % Get training data
 function getTrainingData(filelist, rootname, outputfile)
     fileID = fopen(outputfile,'w');
     fprintf(fileID,'%s, %s, %s\n', 'Filename', 'idtag', 'area0');
     for k=1:length(filelist)
        fname = strcat(rootname, filelist(k).name);
        try   
        I= imread(fname);
        [data, group] = load_data(I);
        [svn_model] = train_classifier(data, group);
        catch
            warning('Problem using function. Assigning a value of 0.');
        end
        savedata(fileID, fname);
     end

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
    disp('Make image bigger and select silique only')
    i = impixel
    
    imshow(I);
    pause(5);
    %input('Make image bigger and select background only')
    j = impixel
    xdata = cat(1, i, j);
    group = cell((length(i)+ length(j)),1);
    group(1:length(i)) = {1};
    group((length(i)+1):length(group)) = {0};
    save('test.mat','group', 'xdata') 
    
 
function[xdata, group] = load_data(I)
    load('test.mat')
    
% Train clasifier
function[svmStruct] = train_classifier(xdata, group)
    svmStruct = svmtrain(xdata, group);

%Test classifier
function[resultclass] = test_classifier(svmStruct, testdata)
    resultclass = svmclassify(svmStruct, testdata)
    
 