clear all
clc
% filepath = uigetdir('*.*','请选择文件夹');%fliepath为文件夹路径</span>
featurecol=[2,3];     %特征列
datacol=[4];          %数据列
loccol=1;            %电极点列
boundlimitcol=3;        %限制画图上下限的列标
boundlimitcolindex=find(featurecol==boundlimitcol);

%调用GUI界面选择文件
[filename1,filepath1]=uigetfile('*.xlsx','打开文件');
filepath=strcat(filepath1,filename1); 

% filepath='all转置(1).xlsx';
[num,txt,raw]=xlsread(filepath);%读取xlsx文件
% size(raw)

%如果每列存在合并单元格的情况，则对空值进行填充
for i = 1:max([featurecol,loccol,datacol])
    temp=raw{2,i};
    for j = 2:size(raw,1)
        if isnan(raw{j,i})
            raw{j,i}=temp;
        else
            temp=raw{j,i};
        end
    end
end
disp('已完成单元格填充!')
%统计每个特征列值可能出现的值(读取每列数据并去重) ->colall
for i = 1:length(featurecol) 
    ii=featurecol(i);
    if isnumeric(raw{3,ii}) 
        for iii=2:length(raw)
            raw{iii,ii}=num2str(raw{iii,ii});
        end
        
    end
    colall{i,1}=unique(raw(2:size(raw,1),ii));  
end
disp('已完成特征列统计!')
%根据boundlimitcol提供的列标，将所有数据中boundlimitcol列值相同的行划分为一组，
%计算每组的最大值和最小值，在后期绘图时相同组的数据使用相同的上小限。
alldatanum=ones(length(colall{boundlimitcolindex,1})*length(datacol),1);
alldata=ones((length(raw)-1)/length(colall{boundlimitcolindex,1}),length(datacol)*length(colall{boundlimitcolindex,1}));
for k1 = 2:size(raw,1)
    k1;
    for k2 =1:length(colall{boundlimitcolindex,1})
        k2;
        if(strcmp(raw{k1,boundlimitcol}(1,:),colall{boundlimitcolindex,1}(k2,:)))
           for ii =1:length(datacol)
               alldata(alldatanum(k2+(ii-1)*length(colall{boundlimitcolindex,1})),k2+(ii-1)*length(colall{boundlimitcolindex,1})) = raw{k1,datacol(ii)}(1,1);
               alldatanum(k2+(ii-1)*length(colall{boundlimitcolindex,1}))=alldatanum(k2+(ii-1)*length(colall{boundlimitcolindex,1}))+1;
           end
        end
    end
end
boundlow=min(alldata);
boundup=max(alldata);
disp('已分组极值计算!')
%计算每列每个特征重复的次数
for i =1:length(colall)
    featurelen(i)=1;
    if i<length(colall)
        for ii =i+1:length(colall)
            featurelen(i)=featurelen(i)*length(colall{ii,1});
        end
    end
end

%遍历整个数据矩阵，穷举所有特征列可能出现的组合 ->dicttemp
for i =1:length(colall)
    if i==1
        circulatecount=1;
    else
        circulatecount=1;
        for t=1:i-1
            circulatecount=circulatecount*length(colall{t,1});
        end
    end
    for ii =1:length(colall{i,1})
        for iii=1:circulatecount
            startnum=1+(ii-1)*featurelen(i)+(iii-1)*length(colall{i,1})*featurelen(i);
            endunm=ii*featurelen(i)+(iii-1)*length(colall{i,1})*featurelen(i);
            dicttemp(startnum:endunm,i)=colall{i,1}(ii);
        end
    end
end
disp('已遍历所有特征组合!')
% fprintf(1,'\n');
%生成每张图片保存所用的文件名，每张图片用到的数据，每张图片设定的上下线信息
loccolnum=length(unique(raw(2:size(raw,1),loccol)));  %电极点数目
count=0;


for i =1:length(dicttemp) % dicttemp 条目
    i;
    name='';
    for ii = 1:size(dicttemp,2)
        ii;
        name=[name,'-',dicttemp{i,ii}];
    end
    dict{i,1}=name;
    datavaluenum=1;
    datavalue=cell(loccolnum,1+length(datacol));
    
    
    for k1 = 2:size(raw,1)  % raw数据
        ismatch=1;
        for ii =1:length(featurecol)        % 所选特征数
            if ~(strcmp(raw{k1,featurecol(ii)}(1,:),dicttemp{i,ii}))
                ismatch=0;
                break;
            end    
        end
        if ismatch==1  %若raw的k1列特征和dicttemp当前列的特征相同，则将数据列的数据放入datavalue
            datavalue{datavaluenum,1}=raw{k1,loccol}(1,:);
            for iii =1:length(datacol)
                datavalue{datavaluenum,1+iii}=raw{k1,datacol(iii)}(1,:);
            end
            datavaluenum = datavaluenum+1;
        end
    end

%     for k1 = 2:size(raw,1)  % raw数据
%         if strcmp([raw{k1,featurecol}],[dicttemp{i,:}])
%             datavalue{datavaluenum,1}=raw{k1,loccol}(1,:);
%             for iii =1:length(datacol)
%                 datavalue{datavaluenum,1+iii}=raw{k1,datacol(iii)}(1,:);
%             end
%             datavaluenum = datavaluenum+1;  
%         end
%     end
    dict{i,2}=datavalue; %将所有符合dicttemp i列的数据返回给添加到dict矩阵中
    boundlimitcolpro=find(featurecol==boundlimitcol);%边界限制列内部下标
    boundindex=find(strcmp(colall{boundlimitcolpro,1},dicttemp(i,boundlimitcolpro)));%每条数据对应的上下限的索引
    for ii =1:length(datacol)%针对不同的数据列设置不同的上下限
       dict{i,3+(ii-1)*2}=boundlow(1,boundindex);
       dict{i,4+(ii-1)*2}=boundup(1,boundindex);
    end
    fprintf(1,repmat('\b',1,count));
    count=fprintf(1,'正在遍历数据，已完成：%d/%d',i,length(dicttemp));
end
fprintf(1,'\n');

filename=filepath(1:end-5);%删除文件名的后缀名

%创建一级目录
if exist(filename,'dir')==0
    mkdir(filename);
end

%创建二级目录
for i =1:length(datacol)
    if exist([filename,'/',raw{1,datacol(i)}(1,:)],'dir')==0
        mkdir([filename,'/',raw{1,datacol(i)}(1,:)]);
    end
end   
count=0;
%调用topoplot画图
structloc=chanlocsseek(dict{1,2}(:,1));%将电极点位置数组转换成topoplot要求的矩阵结构
for i=1:length(dicttemp)
    for ii = 1:length(datacol)
        h_fig=figure('Visible', 'off');%
        %h_fig=figure('Visible', 'off');%显示每次绘制的图片
        axes = subplot(1,1,1);
        bound=[dict{i,3}(1,1),dict{i,4}(1,1)];
        topoplot(cell2mat(dict{i,2}(:,1+ii)),structloc,'maplimits',bound,'plotrad',0.6,'headrad',0.6,'gridscale',300);
        cbar(0,0,bound);%显示颜色bar
        saveas(h_fig, [filename,'/',raw{1,datacol(ii)}(1,:),'/',(dict{i,1}),'-',raw{1,datacol(ii)}(1,:),'.png']);%保存绘制的图片
        close(h_fig); %关闭图片资源
    end
    fprintf(1,repmat('\b',1,count));
    count=fprintf(1,'已完成绘图：%d/%d',i,length(dicttemp));
end
fprintf(1,'\n');



