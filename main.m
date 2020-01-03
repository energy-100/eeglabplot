clear all
clc
% filepath = uigetdir('*.*','��ѡ���ļ���');%fliepathΪ�ļ���·��</span>
featurecol=[2,3];     %������
datacol=[4];          %������
loccol=1;            %�缫����
boundlimitcol=3;        %���ƻ�ͼ�����޵��б�
boundlimitcolindex=find(featurecol==boundlimitcol);

%����GUI����ѡ���ļ�
[filename1,filepath1]=uigetfile('*.xlsx','���ļ�');
filepath=strcat(filepath1,filename1); 

% filepath='allת��(1).xlsx';
[num,txt,raw]=xlsread(filepath);%��ȡxlsx�ļ�
% size(raw)

%���ÿ�д��ںϲ���Ԫ����������Կ�ֵ�������
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
disp('����ɵ�Ԫ�����!')
%ͳ��ÿ��������ֵ���ܳ��ֵ�ֵ(��ȡÿ�����ݲ�ȥ��) ->colall
for i = 1:length(featurecol) 
    ii=featurecol(i);
    if isnumeric(raw{3,ii}) 
        for iii=2:length(raw)
            raw{iii,ii}=num2str(raw{iii,ii});
        end
        
    end
    colall{i,1}=unique(raw(2:size(raw,1),ii));  
end
disp('�����������ͳ��!')
%����boundlimitcol�ṩ���б꣬������������boundlimitcol��ֵ��ͬ���л���Ϊһ�飬
%����ÿ������ֵ����Сֵ���ں��ڻ�ͼʱ��ͬ�������ʹ����ͬ����С�ޡ�
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
disp('�ѷ��鼫ֵ����!')
%����ÿ��ÿ�������ظ��Ĵ���
for i =1:length(colall)
    featurelen(i)=1;
    if i<length(colall)
        for ii =i+1:length(colall)
            featurelen(i)=featurelen(i)*length(colall{ii,1});
        end
    end
end

%�����������ݾ���������������п��ܳ��ֵ���� ->dicttemp
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
disp('�ѱ��������������!')
% fprintf(1,'\n');
%����ÿ��ͼƬ�������õ��ļ�����ÿ��ͼƬ�õ������ݣ�ÿ��ͼƬ�趨����������Ϣ
loccolnum=length(unique(raw(2:size(raw,1),loccol)));  %�缫����Ŀ
count=0;


for i =1:length(dicttemp) % dicttemp ��Ŀ
    i;
    name='';
    for ii = 1:size(dicttemp,2)
        ii;
        name=[name,'-',dicttemp{i,ii}];
    end
    dict{i,1}=name;
    datavaluenum=1;
    datavalue=cell(loccolnum,1+length(datacol));
    
    
    for k1 = 2:size(raw,1)  % raw����
        ismatch=1;
        for ii =1:length(featurecol)        % ��ѡ������
            if ~(strcmp(raw{k1,featurecol(ii)}(1,:),dicttemp{i,ii}))
                ismatch=0;
                break;
            end    
        end
        if ismatch==1  %��raw��k1��������dicttemp��ǰ�е�������ͬ���������е����ݷ���datavalue
            datavalue{datavaluenum,1}=raw{k1,loccol}(1,:);
            for iii =1:length(datacol)
                datavalue{datavaluenum,1+iii}=raw{k1,datacol(iii)}(1,:);
            end
            datavaluenum = datavaluenum+1;
        end
    end

%     for k1 = 2:size(raw,1)  % raw����
%         if strcmp([raw{k1,featurecol}],[dicttemp{i,:}])
%             datavalue{datavaluenum,1}=raw{k1,loccol}(1,:);
%             for iii =1:length(datacol)
%                 datavalue{datavaluenum,1+iii}=raw{k1,datacol(iii)}(1,:);
%             end
%             datavaluenum = datavaluenum+1;  
%         end
%     end
    dict{i,2}=datavalue; %�����з���dicttemp i�е����ݷ��ظ���ӵ�dict������
    boundlimitcolpro=find(featurecol==boundlimitcol);%�߽��������ڲ��±�
    boundindex=find(strcmp(colall{boundlimitcolpro,1},dicttemp(i,boundlimitcolpro)));%ÿ�����ݶ�Ӧ�������޵�����
    for ii =1:length(datacol)%��Բ�ͬ�����������ò�ͬ��������
       dict{i,3+(ii-1)*2}=boundlow(1,boundindex);
       dict{i,4+(ii-1)*2}=boundup(1,boundindex);
    end
    fprintf(1,repmat('\b',1,count));
    count=fprintf(1,'���ڱ������ݣ�����ɣ�%d/%d',i,length(dicttemp));
end
fprintf(1,'\n');

filename=filepath(1:end-5);%ɾ���ļ����ĺ�׺��

%����һ��Ŀ¼
if exist(filename,'dir')==0
    mkdir(filename);
end

%��������Ŀ¼
for i =1:length(datacol)
    if exist([filename,'/',raw{1,datacol(i)}(1,:)],'dir')==0
        mkdir([filename,'/',raw{1,datacol(i)}(1,:)]);
    end
end   
count=0;
%����topoplot��ͼ
structloc=chanlocsseek(dict{1,2}(:,1));%���缫��λ������ת����topoplotҪ��ľ���ṹ
for i=1:length(dicttemp)
    for ii = 1:length(datacol)
        h_fig=figure('Visible', 'off');%
        %h_fig=figure('Visible', 'off');%��ʾÿ�λ��Ƶ�ͼƬ
        axes = subplot(1,1,1);
        bound=[dict{i,3}(1,1),dict{i,4}(1,1)];
        topoplot(cell2mat(dict{i,2}(:,1+ii)),structloc,'maplimits',bound,'plotrad',0.6,'headrad',0.6,'gridscale',300);
        cbar(0,0,bound);%��ʾ��ɫbar
        saveas(h_fig, [filename,'/',raw{1,datacol(ii)}(1,:),'/',(dict{i,1}),'-',raw{1,datacol(ii)}(1,:),'.png']);%������Ƶ�ͼƬ
        close(h_fig); %�ر�ͼƬ��Դ
    end
    fprintf(1,repmat('\b',1,count));
    count=fprintf(1,'����ɻ�ͼ��%d/%d',i,length(dicttemp));
end
fprintf(1,'\n');



