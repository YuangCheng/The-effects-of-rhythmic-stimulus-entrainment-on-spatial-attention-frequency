%%
%初始化
clear all;                                                                  %#ok<*CLALL> %全部清空
KbName('UnifyKeyNames');                                                    %键盘标准化
Screen('Preference','SkipSyncTests',1);                                     %跳过自检
Screen('Preference','TextEncodingLocale','UTF-8');                          %encode中文
%%
%信息录入
prompt={'ID','Age','Handness','Gender'};
title='Subject Information';
dims=[1,55];
defineput={'999','999','999','999','999'};
SubjectInfo = inputdlg(prompt,title,dims,defineput,'on');
ID=str2double(SubjectInfo{1});
%%
%控制鼠标和键盘
ListenChar(2);
HideCursor;
%%
%顺序随机化
rng shuffle
traileach=10; %每个trial重复10次
pretesttraillist=genTrials(traileach,[2,2,24]);
total=traileach*2*2*24;
%正式程序
try
    %%
    %初始化Screen
    screens=Screen('Screens');
    ScreenNum=max(screens);
    [win,rect]=Screen('OpenWindow',ScreenNum);
    refresh=Screen('GetFlipInterval',win);
    slack=refresh/2;
    wx=rect(3);
    wy=rect(4);
    cx=wx/2;
    cy=wy/2;
    black=[0,0,0];
    white=[255,255,255];
    gray=[128 128 128];
    Screen('FillRect',win,gray);
   %%
    %呈现指导语
    DrawTextAt(win,'屏幕上将呈现两个图案，接着在其中一个图案周围可能出现闪光',cx,cy-160,white)
    DrawTextAt(win,'在闪光出现后，其中一个图案上会出现灰点',cx,cy-80,white);
    DrawTextAt(win,'请保持视线聚焦在中央注视点，判断灰点出现在哪一个图案上',cx,cy,white)
    DrawTextAt(win,'在左边请按z在右边请按m，请又快又准进行反应',cx,cy+80',white)
    DrawTextAt(win,'按z或m开始实验，请保持注意力集中',cx,cy+160,white)
    Screen('Flip',win);
    %%
    %按z或m继续 
    keyz=KbName('z');
    keym=KbName('m');
    escape=KbName('escape');
    while 1
        [keyisDown,~,keyCode]=KbCheck();
        if keyCode(keyz)||keyCode(keym)
            break;
        end
    end
   %%
    %初始化大小
    INCH=15.6;                                                             %这个和电脑有关系!!!
    VDIST=57;
    PWIDTH=wx;
    ECC=deg2pix(5,INCH,PWIDTH,VDIST);
    Rgrating=deg2pix(2,INCH,PWIDTH,VDIST);
    Rfocus=deg2pix(0.25,INCH,PWIDTH,VDIST);
    Rflash=deg2pix(0.5,INCH,PWIDTH,VDIST);
    Redge=deg2pix(3.5,INCH,PWIDTH,VDIST);
    timeout=0;
    Rdecrement=deg2pix(0.5,INCH,PWIDTH,VDIST);
    sf=deg2pix(1/1.4,INCH,PWIDTH,VDIST);
    cd ..
    cd data;
    load(strcat(SubjectInfo{1},'_threshold.mat'));
    cd ..;
    cd 实验程序
    contrast=threshold;                                                             %到底调的是什么
    %%
    %正式trial
    focuspic=makefocus(Rfocus);
    focus=Screen('MakeTexture',win,focuspic);
    for numoftrials=1:total
        [keyisDown,~,keyCode]=KbCheck();
        if keyCode(escape)
            break;
        end
        timeout=1;
        %Stage 1
        Screen('DrawTexture',win,focus);
        vbl=Screen('Flip',win);
        rng shuffle;duration1=(1000+200*rand)/1000;
        %Stage 2
        rng shuffle;
        orientationleft=rand*360;
        orientationright=rand*360;
        phaseleft0=rand*2*pi;
        phaseright0=rand*2*pi;
        lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft0,1);
        rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright0,1);
        lgrating=Screen('MakeTexture',win,lgratingpic);
        rgrating=Screen('MakeTexture',win,rgratingpic);
        grect=[0,0,2*Rgrating,2*Rgrating];
        lRect=CenterRectOnPoint(grect,cx-ECC,cy);
        rRect=CenterRectOnPoint(grect,cx+ECC,cy);
        Screen('DrawTexture',win,lgrating,[],lRect);
        Screen('DrawTexture',win,rgrating,[],rRect);
        Screen('DrawTexture',win,focus);
        vbl=Screen('Flip',win,vbl+duration1-slack);
        Screen('Close',lgrating);
        Screen('Close',rgrating);
        tphase0=GetSecs();
        rng shuffle;duration2=(1250+1250*rand)/1000;
        while((GetSecs()-tphase0)<=duration2)
            phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
            phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
            lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
            rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
            lgrating=Screen('MakeTexture',win,lgratingpic);
            rgrating=Screen('MakeTexture',win,rgratingpic);
            Screen('DrawTexture',win,lgrating,[],lRect);
            Screen('DrawTexture',win,rgrating,[],rRect);
            Screen('DrawTexture',win,focus);
            vbl=Screen('Flip',win,vbl+refresh-slack);
            Screen('Close',lgrating);
            Screen('Close',rgrating);
        end
        %Stage 3
        phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
        phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
        lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
        rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
        lgrating=Screen('MakeTexture',win,lgratingpic);
        rgrating=Screen('MakeTexture',win,rgratingpic);
        Screen('DrawTexture',win,lgrating,[],lRect);
        Screen('DrawTexture',win,rgrating,[],rRect);
        frect=[0,0,2*Rflash,2*Rflash];
        if(pretesttraillist(numoftrials,1)==1)
            ccx=cx-ECC;
            ccy=cy;
        else
            ccx=cx+ECC;
            ccy=cy;
        end
        flashrect1=CenterRectOnPoint(frect,ccx,ccy+Redge);
        flashrect2=CenterRectOnPoint(frect,ccx,ccy-Redge);
        flashrect3=CenterRectOnPoint(frect,ccx+Redge,ccy);
        flashrect4=CenterRectOnPoint(frect,ccx-Redge,ccy);
        Screen('FillOval',win,white,flashrect1);
        Screen('FillOval',win,white,flashrect2);
        Screen('FillOval',win,white,flashrect3);
        Screen('FillOval',win,white,flashrect4);
        Screen('DrawTexture',win,focus);
        vbl=Screen('Flip',win,vbl-slack);
        Screen('Close',lgrating);
        Screen('Close',rgrating);
        phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
        phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
        lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
        rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
        lgrating=Screen('MakeTexture',win,lgratingpic);
        rgrating=Screen('MakeTexture',win,rgratingpic);
        Screen('DrawTexture',win,lgrating,[],lRect);
        Screen('DrawTexture',win,rgrating,[],rRect);
        frect=[0,0,2*Rflash,2*Rflash];
        if(pretesttraillist(numoftrials,1)==1)
            ccx=cx-ECC;
            ccy=cy;
        else
            ccx=cx+ECC;
            ccy=cy;
        end
        flashrect1=CenterRectOnPoint(frect,ccx,ccy+Redge);
        flashrect2=CenterRectOnPoint(frect,ccx,ccy-Redge);
        flashrect3=CenterRectOnPoint(frect,ccx+Redge,ccy);
        flashrect4=CenterRectOnPoint(frect,ccx-Redge,ccy);
        Screen('FillOval',win,white,flashrect1);
        Screen('FillOval',win,white,flashrect2);
        Screen('FillOval',win,white,flashrect3);
        Screen('FillOval',win,white,flashrect4);
        Screen('DrawTexture',win,focus);
        duration3=(16.7)/1000;
        vbl=Screen('Flip',win,vbl+duration3-slack);
        Screen('Close',lgrating);
        Screen('Close',rgrating);
        tempt=GetSecs();
        %Stage 4
        phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
        phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
        lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
        rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
        lgrating=Screen('MakeTexture',win,lgratingpic);
        rgrating=Screen('MakeTexture',win,rgratingpic);
        Screen('DrawTexture',win,lgrating,[],lRect);
        Screen('DrawTexture',win,rgrating,[],rRect);
        Screen('DrawTexture',win,focus);
        vbl=Screen('Flip',win,vbl+duration3-slack);
        Screen('Close',lgrating);
        Screen('Close',rgrating);
        duration4=pretesttraillist(numoftrials,3)*2/60+0.2;
        while((GetSecs()-tempt)<=duration4)
            phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
            phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
            lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
            rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
            lgrating=Screen('MakeTexture',win,lgratingpic);
            rgrating=Screen('MakeTexture',win,rgratingpic);
            Screen('DrawTexture',win,lgrating,[],lRect);
            Screen('DrawTexture',win,rgrating,[],rRect);
            Screen('DrawTexture',win,focus);
            vbl=Screen('Flip',win,vbl+refresh-slack);
            Screen('Close',lgrating);
            Screen('Close',rgrating);
        end
        %Stage 5
        if(pretesttraillist(numoftrials,2)==1)
            phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
            phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
            rng shuffle
            randomv=rand;
            ltargetpic=maketarget(randomv,Rgrating,orientationleft,sf,phaseleft,1,Rdecrement,contrast);
            rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
            ltarget=Screen('MakeTexture',win,ltargetpic);
            rgrating=Screen('MakeTexture',win,rgratingpic);
            Screen('DrawTexture',win,ltarget,[],lRect);
            Screen('DrawTexture',win,rgrating,[],rRect);
            Screen('DrawTexture',win,focus);
            vbl=Screen('Flip',win,vbl-slack);
            Screen('Close',ltarget);
            Screen('Close',rgrating);
            phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
            phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh); 
            ltargetpic=maketarget(randomv,Rgrating,orientationleft,sf,phaseleft,1,Rdecrement,contrast);
            rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
            ltarget=Screen('MakeTexture',win,ltargetpic);
            rgrating=Screen('MakeTexture',win,rgratingpic);
            Screen('DrawTexture',win,ltarget,[],lRect);
            Screen('DrawTexture',win,rgrating,[],rRect);
            Screen('DrawTexture',win,focus);
            duration5=(16.7)/1000;
            vbl=Screen('Flip',win,vbl+duration5-slack);
            Screen('Close',ltarget);
            Screen('Close',rgrating);
            tempt=GetSecs();
        else
            phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
            phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
            rng shuffle
            randomv=rand;
            lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
            rtargetpic=maketarget(randomv,Rgrating,orientationright,sf,phaseright,1,Rdecrement,contrast);
            lgrating=Screen('MakeTexture',win,lgratingpic);
            rtarget=Screen('MakeTexture',win,rtargetpic);
            Screen('DrawTexture',win,lgrating,[],lRect);
            Screen('DrawTexture',win,rtarget,[],rRect);
            Screen('DrawTexture',win,focus);
            vbl=Screen('Flip',win,vbl-slack);
            Screen('Close',lgrating);
            Screen('Close',rtarget);
            phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
            phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
            lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
            rtargetpic=maketarget(randomv,Rgrating,orientationright,sf,phaseright,1,Rdecrement,contrast);
            lgrating=Screen('MakeTexture',win,lgratingpic);
            rtarget=Screen('MakeTexture',win,rtargetpic);
            Screen('DrawTexture',win,lgrating,[],lRect);
            Screen('DrawTexture',win,rtarget,[],rRect);
            Screen('DrawTexture',win,focus);
            duration5=(16.7)/1000;
            vbl=Screen('Flip',win,vbl+duration5-slack);
            Screen('Close',lgrating);
            Screen('Close',rtarget);
            tempt=GetSecs();
        end
        %Stage6
        phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
        phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
        lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
        rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
        lgrating=Screen('MakeTexture',win,lgratingpic);
        rgrating=Screen('MakeTexture',win,rgratingpic);
        Screen('DrawTexture',win,lgrating,[],lRect);
        Screen('DrawTexture',win,rgrating,[],rRect);
        Screen('DrawTexture',win,focus);
        vbl=Screen('Flip',win,vbl+duration5-slack);
        Screen('Close',lgrating);
        Screen('Close',rgrating);
        duration6=3;
        while((GetSecs()-tempt)<=duration6)
            %捕捉按键反应
            [~,secs,keyCode]=KbCheck();
            if keyCode(keyz)
                pretesttraillist(numoftrials,4)=1;
                timeout=0;
                break;
            elseif keyCode(keym)
                pretesttraillist(numoftrials,4)=0;
                timeout=0;
                break;
            end
            phaseleft=phaseleft0+0.7*2*pi*(GetSecs()-tphase0+refresh);%可能会有问题
            phaseright=phaseright0+0.7*2*pi*(GetSecs()-tphase0+refresh);
            lgratingpic=makegrating(Rgrating,orientationleft,sf,phaseleft,1);
            rgratingpic=makegrating(Rgrating,orientationright,sf,phaseright,1);
            lgrating=Screen('MakeTexture',win,lgratingpic);
            rgrating=Screen('MakeTexture',win,rgratingpic);
            Screen('DrawTexture',win,lgrating,[],lRect);
            Screen('DrawTexture',win,rgrating,[],rRect);
            Screen('DrawTexture',win,focus);
            vbl=Screen('Flip',win,vbl+refresh-slack);
            Screen('Close',lgrating);
            Screen('Close',rgrating);
        end
        %看一看有没有timeout
        if timeout==1
            pretesttraillist(numoftrials,4)=NaN;
            DrawTextAt(win,'太慢了！！请尽快反应！！',cx,cy,white)
            DrawTextAt(win,'如果没侦测到灰点，请按照您的感觉尽快选一个',cx,cy-80,white)
            Screen('Flip',win);
            WaitSecs(2.5+rand());
        end
    end
    %%
    %正式程序截止
    cd data;
    save(strcat(SubjectInfo{1},'_pretest.mat'),'pretesttraillist');                       %要不要这么存数据
    cd ..;
    sca;
    ListenChar(0);
    ShowCursor;
catch ME
    sca;
    ListenChar(0);
    ShowCursor;
    rethrow(ME);
end
