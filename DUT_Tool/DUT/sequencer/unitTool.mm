//
//  unitTool.m
//  MainUI
//
//  Created by IvanGan on 16/1/7.
//  Copyright © 2016年 ___Intelligent Automation___. All rights reserved.
//

#import "unitTool.h"
#import "RegexKitLite.h"
#import "zmqCenter.h"
#import "LuaDebugPanelDebugWinDelegate.h"
#import "GraphicHeader.h"
#import "readGWin.h"
#import "StimMainVC.h"
#import "MobileRestoreWin.h"
#define kNotificationOnLoadProfile            @"On_ReloadProfileByRecMsg"
#define kNotificationStartTestByRecMsg        @"On_StartTestByRecMsg"

@interface unitTool()

@property(strong)LuaDebugPanelDebugWinDelegate *LuaDebugPanelWin;
@property(strong)readGWin *GGWindow;
@property(nonatomic, strong)MobileRestoreWin *mobileRestoreWin;
@property(nonatomic, strong)StimMainVC *stimVC;

@end

@implementation unitTool

#define JSON_RPC        @"2.0"

#define kFunction        @"method"
#define kParams          @"args"
#define kId              @"id"
#define kJsonrpc         @"jsonrpc"
#define kResult          @"result"
#define kError           @"error"
#define kMessage         @"message"
#define kUUT             @"uut"
#define d_Timeout        3


#define KEY_STEP        @"STEP"
#define KEY_JUMP        @"JUMP"
#define KEY_CONTINUE    @"CONTINUE"
#define KEY_BREAK       @"BREAK"
#define KEY_ALL         @"ALL"
#define KEY_CLEAR       @"CLEAR"
#define KEY_STOP        @"STOP"
#define KEY_STATUS      @"STATUS"
#define KEY_SHOW        @"SHOW"
#define KEY_NEXT        @"NEXT"
#define KEY_LOAD        @"LOAD"
#define KEY_LIST        @"LIST"
#define KEY_EnterDiags  @"EnterDiags"

-(NSString * )getUUTKey:(int)index
{
    return [NSString stringWithFormat:@"%@%d",kUUT, index];
}

-(id)initWithIndex:(int)index :(id)window;
{
    self = [super initWithNibName:@"unitTool" bundle:[NSBundle bundleForClass:[self class]]];
    win = window;

    m_slots = 1;
    arrTimeOut = [[NSMutableDictionary alloc]init];
    arrBreak = [[NSMutableDictionary alloc]init];
    arrZmq = [[NSMutableDictionary alloc]init];
    
    currentStep = [[NSMutableDictionary alloc]init];
    totalStep = [[NSMutableDictionary alloc]init];
    
    mLock  = [[NSLock alloc]init];
    
    sequncer=[zmqCenter new];
    return self;
}

-(void)InitialPort:(int)port
{
    [sequncer connect:port :1];

}

-(int)setSlots:(int)slots :(int)port
{
    m_slots = slots;
    m_port = port;
    return m_slots;
}


- (void)initEnableDic
{
    if(dicEnable == nil)
        dicEnable = [[NSMutableDictionary alloc]init];
    
    [dicEnable setObject:@"1" forKey:KEY_STEP];
    [dicEnable setObject:@"1" forKey:KEY_JUMP];
    [dicEnable setObject:@"1" forKey:KEY_CONTINUE];
    [dicEnable setObject:@"1" forKey:KEY_BREAK];
    [dicEnable setObject:@"1" forKey:KEY_ALL];
    [dicEnable setObject:@"1" forKey:KEY_CLEAR];
    [dicEnable setObject:@"1" forKey:KEY_STOP];
    [dicEnable setObject:@"1" forKey:KEY_STATUS];
    [dicEnable setObject:@"1" forKey:KEY_SHOW];
    [dicEnable setObject:@"1" forKey:KEY_NEXT];
    [dicEnable setObject:@"1" forKey:KEY_LOAD];
    [dicEnable setObject:@"1" forKey:KEY_LIST];
    [dicEnable setObject:@"1" forKey:KEY_EnterDiags];
}

- (void)initDisableDic
{
    if(dicEnable == nil)
        dicEnable = [[NSMutableDictionary alloc]init];
    
    [dicEnable setObject:@"0" forKey:KEY_STEP];
    [dicEnable setObject:@"0" forKey:KEY_JUMP];
    [dicEnable setObject:@"0" forKey:KEY_CONTINUE];
    [dicEnable setObject:@"0" forKey:KEY_BREAK];
    [dicEnable setObject:@"0" forKey:KEY_ALL];
    [dicEnable setObject:@"0" forKey:KEY_CLEAR];
    [dicEnable setObject:@"0" forKey:KEY_STOP];
    [dicEnable setObject:@"0" forKey:KEY_STATUS];
    [dicEnable setObject:@"0" forKey:KEY_SHOW];
    [dicEnable setObject:@"0" forKey:KEY_NEXT];
    [dicEnable setObject:@"0" forKey:KEY_LOAD];
    [dicEnable setObject:@"0" forKey:KEY_LIST];
    [dicEnable setObject:@"0" forKey:KEY_EnterDiags];
}

- (void)setEnableDic:(NSArray*) keyArr
{
    NSInteger len = [keyArr count];
    if(len < 1) return;
    [self initDisableDic];
    for(NSInteger index=0; index<len; index++)
    {
        [dicEnable setObject:@"1" forKey:[keyArr objectAtIndex:index]];
    }
}

- (void)setDisableDic:(NSArray *)keyArr
{
    NSInteger len = [keyArr count];
    if(len < 1) return;
    [self initEnableDic];
    for(NSInteger index=0; index<len; index++)
    {
        [dicEnable setObject:@"0" forKey:[keyArr objectAtIndex:index]];
    }
}

- (void)setBtnDisable:(NSArray *)arr
{
    
    [self setDisableDic:arr];
    for(NSInteger index=0; index<13;index++)
    {
        NSInteger state = 1;
        id disable = [dicEnable objectForKey:[btnTitle objectAtIndex:index]];
        state = [disable integerValue];
        if(!state)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [btnCtrl[index] setEnabled:NO];
            });
            
        }
    }
     dispatch_async(dispatch_get_main_queue(), ^{
        [btnShowVariant setEnabled:NO];
        [btnNext setEnabled:NO];
          });
    
}


- (void)setBtnEnable:(NSArray *)arr
{
   
    [self setEnableDic:arr];
    for(NSInteger index=0; index<13;index++)
    {
        NSInteger state = 0;
        id enable = [dicEnable objectForKey:[btnTitle objectAtIndex:index]];
        state = [enable integerValue];
        if(state)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            [btnCtrl[index] setEnabled:YES];
            });
        }
    }
     dispatch_async(dispatch_get_main_queue(), ^{
        [btnShowVariant setEnabled:NO];
        [btnNext setEnabled:NO];
          });
}


-(void)awakeFromNib
{
    
    
    [currentStep setObject:[NSNumber numberWithInt:0] forKey:[self getUUTKey:0]];
    [totalStep setObject:[NSNumber numberWithInt:0] forKey:[self getUUTKey:0]];
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    [arrBreak setObject:arr forKey:[self getUUTKey:0]];
    
    [self funcList:[NSNumber numberWithInt:0]];

    [self initEnableDic];
    btnCtrl = [[NSArray arrayWithObjects:btnStep,btnJump,btnContinue,btnBreak,btnAllBreak,btnClear,btnStop,btnStatus,btnShowVariant,btnNext,btnLoad,btnList,btnEnterDiags, nil]retain];
    btnTitle = [[NSArray arrayWithObjects:KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_BREAK,KEY_ALL,KEY_CLEAR,KEY_STOP,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags, nil]retain];
    [self setBtnDisable:@[KEY_STOP]];
    threadArr=[NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                     :@selector(setStimButtonEnable:) name
                                                     :@"KsetStimButtonEnable" object
                                                     :nil] ;
    
    
    
    
 
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];
}


-(void)setStimButtonEnable:(id)sender
{
    [m_btnStim setEnabled:YES];
}

-(void)viewDidAppear{
    [super viewDidAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
}

-(void)dealloc
{
    [arrBreak removeAllObjects];
    [arrBreak release];
    [arrZmq removeAllObjects];
    [arrZmq release];
    [arrTimeOut removeAllObjects];
    [arrTimeOut release];
    [currentStep removeAllObjects];
    [currentStep release];
    [totalStep removeAllObjects];
    [totalStep release];
    [btnCtrl release];
    [btnTitle release];
    [threadArr release];
    [sequncer release];
    
    [listCsvName release];
    
    if(dicEnable != nil)
    {
        [dicEnable removeAllObjects];
        [dicEnable release];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


-(NSDictionary *)sendCommand:(NSString *) str :(int)timeout :(int)index//timeout : sec
{
    if([str length]>0)
    {
        long long size = 1024;
        if([str containsString:@"list"])
            size = 5*1024*1024;
      //  id zmqReq = [arrZmq objectForKey:[self getUUTKey:index]];
       if(sequncer == nil) return NULL;

        NSLog(@"< send > : %@",str);
        NSString * tmp = [NSString stringWithUTF8String:[sequncer sendCmd:[str UTF8String] :size : timeout]];
        NSLog(@"< receive > : %@",tmp);
//        txtShow.stringValue = tmp;
        if(tmp)
        {
            NSData * data = [tmp dataUsingEncoding:NSUTF8StringEncoding];
            id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if(obj)
            {
                NSDictionary * dic = (NSDictionary*)obj;
                if([dic objectForKey:kError])
                    [self textViewAddTest:[NSString stringWithFormat:@"<< (Error:) %@",[[dic objectForKey:kError] objectForKey:kMessage]] : index];
                return dic;
            }
        }
        return NULL;
    }
    return NULL;
}

-(NSString *)serialCommand:(NSString *)cmd :(NSString*)str
{
   // {"id":"f143164097ff11e58c6d3c15c2dab3ba","function":"load","jsonrpc":"1.0","params":["/Users/ivangan/Desktop/trial__1224.csv"]}
    if([str length]>0)
        return [NSString stringWithFormat:@"{\"id\":\"f143164097ff11e58c6d3c15c2dab3ba\",\"method\":\"%@\",\"jsonrpc\":\"2.0\",\"args\":[\"%@\"]}",cmd,str];
    else
        return [NSString stringWithFormat:@"{\"id\":\"f143164097ff11e58c6d3c15c2dab3ba\",\"method\":\"%@\",\"jsonrpc\":\"2.0\",\"args\":\"%@\"}",cmd,str];
}

-(void)textViewAddTest:(NSString *)str :(int)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [mLock lock];
        if (!str) return;
        NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
        [fmt setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
        NSString * date = [NSString stringWithFormat:@"%@\t[%d] %@\n",[fmt stringFromDate:[NSDate date]],index,str];
        
        NSMutableString * pstr = [[txtView textStorage] mutableString];
        [pstr appendFormat:@"%@",date];
            NSRange range = NSMakeRange([pstr length]-1,0);
            [txtView scrollRangeToVisible:range];
        [mLock unlock];
    });
}

-(void)textScroll
{
    NSMutableString * pstr = [[txtView textStorage] mutableString];
//    [pstr appendFormat:@"%@",date];
    NSRange range = NSMakeRange([pstr length]-1,0);
    [txtView scrollRangeToVisible:range];
}

-(void)funcStep:(NSNumber*)number
{
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    int index = [number intValue];
    [self textViewAddTest:@" >> step" :index];
    int tmpStepIndex = 0;
    int tmpTotal = 0;
    id currIndex = [currentStep objectForKey:[self getUUTKey:index]];
    if(currIndex!=nil) tmpStepIndex = [(NSNumber*)currIndex intValue];
    id total = [totalStep objectForKey:[self getUUTKey:index]];
    if(total != nil) tmpTotal = [(NSNumber*)total intValue];
    
    if(tmpStepIndex >= tmpTotal)
    {
        [self textViewAddTest:[NSString stringWithFormat:@"<< The end of Sequencer :%d",tmpTotal] :index];
        [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
        return;
    }
    
    int tmpTimeOut = 8;
    id timeout = [arrTimeOut objectForKey:[self getUUTKey:index]];
    if((timeout) && (tmpStepIndex < [(NSArray*)timeout count]))
        tmpTimeOut = [[(NSArray*)timeout objectAtIndex: tmpStepIndex ]intValue];
    if(tmpStepIndex == 0)
        tmpTimeOut = tmpTimeOut + 5;
    
    NSDictionary * dic = [self sendCommand:[self serialCommand:@"step" :@""] :tmpTimeOut :index];
    NSString * item = nil;
    if(dic)
    {
        NSArray * arr = [dic objectForKey:kResult];
        //[arr isKindOfClass:[NSNull class]];
        if(arr&&[arr isKindOfClass:[NSArray class]])
        {
            item = [arr objectAtIndex:0];
            NSString * name = [[arr objectAtIndex:1] stringByMatching:@"DESCRIPTION':\\s*'(.+)',\\s*'VAL'" capture:1];
            [self textViewAddTest:[NSString stringWithFormat:@"<< (item:) %@\t%@",item,name] : index];
        }
    }
    else
        [self textViewAddTest:@"<< (item:) NULL" : index];
    if (item)
        tmpStepIndex = item.intValue;//sequencer index is start from 1, this code is from 0
    else
        tmpStepIndex = tmpStepIndex + 1;
    [mLock lock];
    [currentStep setObject:[NSNumber numberWithInt:tmpStepIndex] forKey:[self getUUTKey:index]];
    [mLock unlock];
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];

}

-(IBAction)btnStep:(id)sender
{
    
    [NSThread sleepForTimeInterval:0.1];
    [NSThread detachNewThreadSelector:@selector(funcStep:) toTarget:self withObject:[NSNumber numberWithInt:0]];
   
}



-(void)funcJump:(NSNumber*)number
{
    int index = [number intValue];
    if(txtDataJump.stringValue.length>0)
    {
        [self textViewAddTest:@">> jump" : index];
        NSDictionary * dic = [self sendCommand:[self serialCommand:@"jump" :txtDataJump.stringValue] :d_Timeout : index];
        if(dic)
        {
            int currStep = txtDataJump.stringValue.intValue;
            [mLock lock];
            [currentStep setObject:[NSNumber numberWithInt:currStep] forKey:[self getUUTKey:index]];
            [mLock unlock];
            
            NSArray * arr = [dic objectForKey:kResult];
            if(arr)
            {
                NSString * name = [[arr objectAtIndex:1] stringByMatching:@"DESCRIPTION':\\s*'(.+)',\\s*'VAL'" capture:1];
                [self textViewAddTest:[NSString stringWithFormat:@"<< (index:) %@\t%@",[arr objectAtIndex:0],name] : index];
            }
        }
    }
    else
        [self textViewAddTest:@"... key in index first(e.g. 5)" : index];
    
}


-(void)funcEnterDiagsFrom:(NSNumber*)numberFrom
{
    int index = 0;
    if(txtDataEnterDiagsFrom.stringValue.length>0 && txtDataEnterDiagsTo.stringValue.length>0)
    {
        if (txtDataEnterDiagsFrom.intValue < txtDataEnterDiagsTo.intValue)
            {
                [self textViewAddTest:@">> jump" : index];
                NSDictionary * dic = [self sendCommand:[self serialCommand:@"jump" :txtDataEnterDiagsFrom.stringValue] :d_Timeout : index];
                if(dic)
                {
                    int currStep = txtDataEnterDiagsFrom.stringValue.intValue;
                    [mLock lock];
                    [currentStep setObject:[NSNumber numberWithInt:currStep] forKey:[self getUUTKey:index]];
                    [mLock unlock];
                    
                    NSArray * arr = [dic objectForKey:kResult];
                    if(arr)
                    {
                        NSString * name = [[arr objectAtIndex:1] stringByMatching:@"DESCRIPTION':\\s*'(.+)',\\s*'VAL'" capture:1];
                        [self textViewAddTest:[NSString stringWithFormat:@"<< (index:) %@\t%@",[arr objectAtIndex:0],name] : index];
                    }
                }
                [NSThread sleepForTimeInterval:1.0];
                [self tofuncStep:0];
            
            }
        
        else
            {
                [self textViewAddTest:@"...enter diags From number value must less than To number value ": index];
            }
        
    }
    else
    {
        [self textViewAddTest:@"... key in index first(e.g. 5)" : index];
    }
    
    
    
}


-(void)tofuncStep:(NSNumber*)number

{
    for (int i=txtDataEnterDiagsFrom.intValue; i<=txtDataEnterDiagsTo.intValue; i++)
    {
        [self funcStep:0];
        [NSThread sleepForTimeInterval:0.05];
    }
}


-(NSArray *)SelectedOnCells
{
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    for(int i=0; i<m_slots; i++)
    {
        NSCell * cell = [btnUUTSelected cellAtRow:0 column:i];
        if ([cell state] == NSOnState) {
            [arr addObject:cell];
        }
    }
    NSArray * onArr = [NSArray arrayWithArray:arr];
    [arr release];
    return onArr;
}

-(IBAction)btnJump:(id)sender
{
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    [self funcJump:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];

}

-(void)funcContine:(NSNumber*)number
{
    [self setBtnEnable:@[KEY_STOP]];
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_BREAK,KEY_ALL,KEY_CLEAR,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    int index = [number intValue];
    NSArray * arr = [arrBreak objectForKey:[self getUUTKey:index]];
    int total = [[totalStep objectForKey:[self getUUTKey:index]] intValue];
    while (![[threadArr objectAtIndex:index]isCancelled])
    {
        int curr = [[currentStep objectForKey:[self getUUTKey:index]] intValue];
        if (![arr containsObject:[NSString stringWithFormat:@"%d",curr+1]])
        {
            [self funcStep:number];
            curr = [[currentStep objectForKey:[self getUUTKey:index]] intValue];
            if (curr >= total)
            {
                [self textViewAddTest:[NSString stringWithFormat:@"<< The end of Sequencer"] : index];
                break;
            }
        }
        else
            break;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        [NSThread sleepForTimeInterval:0.01];
    }
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_BREAK,KEY_ALL,KEY_CLEAR,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    [self setBtnDisable:@[KEY_STOP]];
}


-(IBAction)btnContinue:(id)sender
{
    [threadArr removeAllObjects];
    NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(funcContine:) object:[NSNumber numberWithInt:0]];
    [threadArr addObject:thread];
    [thread start];
        
    
}

-(IBAction)btnStop:(id)sender
{
    for (int i=0; i<[threadArr count]; i++)
    {
        if ([threadArr objectAtIndex:i])
        {
            [[threadArr objectAtIndex:i]cancel];
            [[threadArr objectAtIndex:i]release];

        }
    }

}


-(void)funcBreak:(NSNumber*)number
{
    int index = [number intValue];
    NSMutableArray * arrBreakIndex = (NSMutableArray *)[arrBreak objectForKey:[self getUUTKey:index]];
    
    if(txtDataBreak.stringValue.length>0)
    {
        [self textViewAddTest:@">> break" : index];
        NSArray * arr = [txtDataBreak.stringValue componentsSeparatedByString:@","];
        for(int i=0; i<arr.count; i++)
        {
            int t =  [[arr objectAtIndex:i]intValue];//delete space
            NSString * indexStr = [NSString stringWithFormat:@"%d",t];
            if(![arrBreakIndex containsObject:indexStr])
                [arrBreakIndex addObject:indexStr];
        }
        NSComparator cmptr = ^(id obj1, id obj2){
            if([obj1 intValue]>[obj2 intValue])
                return NSOrderedDescending;
            else if([obj1 intValue]<[obj2 intValue])
                return NSOrderedAscending;
            else return NSOrderedSame;
        };
        NSMutableArray * tmp = [[NSMutableArray alloc]init ];
        [tmp addObjectsFromArray:[arrBreakIndex sortedArrayUsingComparator:cmptr]];
        [arrBreak setObject:tmp forKey:[self getUUTKey:index]];
        [tmp release];
    }
    else
        [self textViewAddTest:@"... key in break point first(e.g. 2,5,7)" : index];
}

-(IBAction)btnBreak:(id)sender
{
    [self setBtnDisable:@[KEY_BREAK]];
    [self funcBreak:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_BREAK]];
}



-(void)funcAllBreak:(NSNumber*)number
{
    int index = [number intValue];
    [self textViewAddTest:@">> all" :index];
    NSMutableString * str = [[NSMutableString alloc]init];
    NSArray * arr = [arrBreak objectForKey:[self getUUTKey:index]];
    for(NSString *s in arr)
    {
        [str appendFormat:@"%@,",s];
    }
    [self textViewAddTest:[NSString stringWithFormat:@"<< %@",str]:index];
    [str release];
}

-(IBAction)btnAllBreak:(id)sender
{
    [self setBtnDisable:@[KEY_ALL]];
    [self funcAllBreak:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_ALL]];
}

-(void)funcClearBreak:(NSNumber*)number
{
    int index = [number intValue];
    [self textViewAddTest:@">> clear Break" :index];
    NSMutableArray * arr = [arrBreak objectForKey:[self getUUTKey:index]];
    [arr removeAllObjects];
}

-(IBAction)btnClearBreak:(id)sender
{
    [self setBtnDisable:@[KEY_CLEAR]];
    [self funcClearBreak:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_CLEAR]];
}


-(void)funcStatus:(NSNumber*)number
{
    int index = [number intValue];
    [self textViewAddTest:@">> status" : index];
    NSDictionary * dic = [self sendCommand:[self serialCommand:@"status" :@""] :d_Timeout : index];
    if(dic)
    {
        NSString * str = [dic objectForKey:kResult];
        if(str)
            [self textViewAddTest:[NSString stringWithFormat:@"<< result: %@",str] : index];
    }
}

-(IBAction)btnStatus:(id)sender
{
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    [self funcStatus:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
}


-(void)funcShowVariant:(NSNumber*)number
{
    int index = [number intValue];
    if(txtData.stringValue.length>0)
    {
        [self textViewAddTest:@">> show" : index];
        NSDictionary* dic = [self sendCommand:[self serialCommand:@"show" :txtData.stringValue] :d_Timeout : index];
        if(dic)
        {
            NSString * str = [dic objectForKey:kResult];
            if(str)
            {
                [self textViewAddTest:[NSString stringWithFormat:@"<< result: %@",str] : index];
            }
        }
    }
    else
        [self textViewAddTest:@"... key in variant(e.g. station_name)" : index];
}

-(IBAction)btnShowVariant:(id)sender
{
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    [self funcShowVariant:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
}


-(void)funcNext:(NSNumber *)number
{
    int index = [number intValue];
    [self textViewAddTest:@">> next":index];
    NSDictionary * dic = [self sendCommand:[self serialCommand:@"s_next" :@""] :d_Timeout :index];
    if(dic)
    {
        NSString * str = [dic objectForKey:kResult];
        [self textViewAddTest:[NSString stringWithFormat:@"<< result: %@",str]:index];
    }
}

-(IBAction)btnNext:(id)sender
{
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    [self funcNext:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
}

-(IBAction)btnLoad:(id)sender
{
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    NSOpenPanel * p = [NSOpenPanel openPanel];
    [p setCanChooseDirectories:YES];
    [p setCanChooseFiles:YES];
    
    NSString *pathCsv = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    if ([pathCsv containsString:@"/tools"]) {
        pathCsv = [pathCsv stringByDeletingLastPathComponent];
    }
    pathCsv = [NSString stringWithFormat:@"%@/Profile",pathCsv];
    
    [p setDirectoryURL:[NSURL URLWithString:[pathCsv stringByResolvingSymlinksInPath]]];
    
    [p beginSheetModalForWindow:win completionHandler:^(NSInteger result){
        if(result == NSFileHandlingPanelOKButton)
        {
            @try {
                NSURL * url = [[p URLs]objectAtIndex:0];
                NSMutableString * file = [[NSMutableString alloc]init];
                [file setString:[url path]];
                if([file length]>0)
                {

                        int index = 0;
                        NSDictionary * ret = [self sendCommand:[self serialCommand:@"load" :file] :5 :index];
                        [self textViewAddTest:@">> load" : index];
                        if([ret objectForKey:kResult])
                        {
                            [self textViewAddTest:[NSString stringWithFormat:@"<< result: %@",[ret objectForKey:kResult]] : index];
                            [self funcList:[NSNumber numberWithInt:index]];
                        }
                    
                }
                [file release];

            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }];
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
}


-(void)funcList:(NSNumber*)number
{
    int index = [number intValue];
    [self textViewAddTest:@">> list" :index];
    NSString * str = @"all";
    if(txtData.stringValue.intValue != 0)
        str = txtData.stringValue;
    NSDictionary * dic = [self sendCommand:[self serialCommand:@"list" :str] :5 : index];
    if(dic)
    {
        NSMutableArray * tmpTimeout = [[NSMutableArray alloc]init];
        NSArray * arr = [dic objectForKey:kResult];
        if(arr)
        {
            [arrTimeOut removeAllObjects];
            if([str isEqualToString:@"all"])
            {
                int total = [[[arr objectAtIndex:0]objectAtIndex:2]intValue];
                [mLock lock];
                [totalStep setObject:[NSNumber numberWithInt:total] forKey:[self getUUTKey:index]];
                [mLock unlock];
            }
            
            NSMutableString * tmp = [[NSMutableString alloc]init];
            for(int i=1; i<[arr count]; i++)
            {
                NSString * descrip = [[arr objectAtIndex:i]objectAtIndex:1];
                id timeoutString = [descrip stringByMatching:@"'TIMEOUT': '(.+)'," capture:1];
                int timeout = 3;
                if(timeoutString)
                    timeout = [timeoutString intValue];
                NSString * des = [descrip stringByMatching:@"DESCRIPTION': '(.+)', 'VAL'" capture:1];
                [tmp appendFormat:@"\n%@  %@,(Timeout:)%d\r",[[arr objectAtIndex:i]objectAtIndex:0],des,timeout ];
                if(timeout==0) timeout = 3;
                [tmpTimeout addObject:[NSNumber numberWithInt:timeout]];
            }
            [self textViewAddTest:[NSString stringWithFormat:@"<< result: %@",tmp] : index];
            [tmp release];
        }
        [mLock lock];
        if ([tmpTimeout count]>0) {
            [arrTimeOut setObject:tmpTimeout forKey:[self getUUTKey:index]];
            [tmpTimeout release];
        }
        [mLock unlock];
    }
}

-(IBAction)btnList:(id)sender
{
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    [self funcList:[NSNumber numberWithInt:0]];
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
}

-(IBAction)btnSelectAll:(id)sender
{
    if([btnSelectAll state] == NSOnState)
    {
        [btnSelectAll setTitle:@"UnselectAll"];
        for (NSCell * cell in [btnUUTSelected cells]) {
            [cell setState:NSOnState];
        }
    }
    else
    {
        [btnSelectAll setTitle:@"SelectAll"];
        for (NSCell * cell in [btnUUTSelected cells]) {
            [cell setState:NSOffState];
        }
    }
}
- (void)btnEnterDiags1:(id)sender{
    /* [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
     
     
     //[self funcEnterDiagsFrom:0 to:0];
     [threadArr removeAllObjects];
     NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(funcEnterDiagsFrom:) object:[NSNumber numberWithInt:0]];
     [threadArr addObject:thread];
     [thread start];
     
     
     [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
     */
    
    [self setBtnDisable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
    [self m_btnButtonDisable];
    NSString *diagsCmd = [[NSBundle mainBundle] pathForResource:@"EnterDiagsCmd" ofType:@"plist"];
    NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
    [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:diagsCmd]];
    
    
    if ([[cmdList valueForKey:@"1_XAVIER_CMD"] valueForKey:@"command"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"1_XAVIER_CMD"] valueForKey:@"command"] forKey:kSendCmd];
        NSLog(@"===>: %@",dicCmd);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
        [NSThread sleepForTimeInterval:2.0];
    }
    
    if ([[cmdList valueForKey:@"2_Dock_Config"] valueForKey:@"command"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"2_Dock_Config"] valueForKey:@"command"] forKey:kSendDUTDockConfigCmd];
        NSLog(@"===>: %@",dicCmd);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
        [NSThread sleepForTimeInterval:2.0];
    }
    
    if ([[cmdList valueForKey:@"3_XAVIER_CMD"] valueForKey:@"command"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"3_XAVIER_CMD"] valueForKey:@"command"] forKey:kSendCmd];
        NSLog(@"===>: %@",dicCmd);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
        [NSThread sleepForTimeInterval:2.0];
    }
    
    if ([[cmdList valueForKey:@"4_Dock_Config"] valueForKey:@"command"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"4_Dock_Config"] valueForKey:@"command"] forKey:kSendDUTDockConfigCmd];
        NSLog(@"===>: %@",dicCmd);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
        [NSThread sleepForTimeInterval:2.0];
    }
    
    if ([[cmdList valueForKey:@"5_XAVIER_CMD"] valueForKey:@"command"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"5_XAVIER_CMD"] valueForKey:@"command"] forKey:kSendCmd];
        NSLog(@"===>: %@",dicCmd);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
        [NSThread sleepForTimeInterval:2.0];
    }
    
    if ([[cmdList valueForKey:@"6_Dock_Config"] valueForKey:@"command"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"6_Dock_Config"] valueForKey:@"command"] forKey:kSendDUTDockConfigCmd];
        NSLog(@"===>: %@",dicCmd);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
        [NSThread sleepForTimeInterval:2.0];
    }
    
    
    if ([[cmdList valueForKey:@"DUT_CMD"] valueForKey:@"command"])
    {
        //[self sendDiagsCmd:nil];
        [self performSelector:@selector(sendDiagsCmd:) withObject:nil afterDelay:1.0f];
        
    }
    [cmdList release];
    
    [self setBtnEnable:@[KEY_STEP,KEY_JUMP,KEY_CONTINUE,KEY_STATUS,KEY_SHOW,KEY_NEXT,KEY_LOAD,KEY_LIST,KEY_EnterDiags]];
}
- (IBAction)btnEnterDiags:(id)sender
{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"information.plist" ofType:nil];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
  
    NSAlert * alert = [[NSAlert alloc] init];
    //    NSAlertStyleWarning = 0,
    //    NSAlertStyleInformational = 1,
    //    NSAlertStyleCritical = 2
    [alert addButtonWithTitle:@"OK"];
    if ([dic objectForKey:@"title"]) {
        alert.messageText = [dic objectForKey:@"title"];//@"Warning"
    }else{
        alert.messageText = @"Warning";
    }
    
    if ([dic objectForKey:@"info"]) {
        alert.informativeText = [dic objectForKey:@"info"];
    }else{
        alert.informativeText = @"USBSOC is connected";
    }
    
    //    alert.informativeText = @"Please make sure real battery is connected and BATT switch pushed to REAL position!\r\n\r\nPlease use only the POR batteries!";
//    alert.window.backgroundColor = [NSColor redColor];
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn)  //OK
    {
        if ([listCsvName valueForKey:@"EnterDiags_TEST"])
        {
            [self m_btnButtonDisable];
            NSString *csvName = [listCsvName valueForKey:@"EnterDiags_TEST"];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
        }
    }
    
    
}

- (IBAction)DFUMode:(NSButton *)btn {
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"information.plist" ofType:nil];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSAlert * alert = [[NSAlert alloc] init];
    //    NSAlertStyleWarning = 0,
    //    NSAlertStyleInformational = 1,
    //    NSAlertStyleCritical = 2
    [alert addButtonWithTitle:@"OK"];
    if ([dic objectForKey:@"title"]) {
        alert.messageText = [dic objectForKey:@"title"];//@"Warning"
    }else{
        alert.messageText = @"Warning";
    }
    
    if ([dic objectForKey:@"info"]) {
        alert.informativeText = [dic objectForKey:@"info"];
    }else{
        alert.informativeText = @"USBSOC is connected";
    }
    
    //    alert.informativeText = @"Please make sure real battery is connected and BATT switch pushed to REAL position!\r\n\r\nPlease use only the POR batteries!";
//    alert.window.backgroundColor = [NSColor redColor];
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn)  //OK
    {
        
        if ([listCsvName valueForKey:@"DFUMode_TEST"])
        {
            [self m_btnButtonDisable];
            NSString *csvName = [listCsvName valueForKey:@"DFUMode_TEST"];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
            
            NSString *path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
            path = [NSString stringWithFormat:@"%@/DutSocket.app",path];
            NSLog(@"===:::>>path : %@",path);
            [[NSWorkspace sharedWorkspace] launchApplication:path];
        }
    }
    
    
}



- (IBAction)btnResetAll:(id)sender
{
//    NSString *filecmd = [[NSBundle mainBundle] pathForResource:@"StimCmdList" ofType:@"plist"];
//    NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
//    [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:filecmd]];
//
//    if ([[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"FIXTURERESET"])
//    {
//        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
//        [dicCmd setValue:[[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"FIXTURERESET"] forKey:kSendCmd];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
//                                                                  :nil userInfo
//                                                                  :dicCmd] ;
//    }
//
//    if ([[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"RESET_END"])
//    {
//        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
//        [dicCmd setValue:[[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"RESET_END"] forKey:kSendCmd];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
//                                                                  :nil userInfo
//                                                                  :dicCmd] ;
//    }
    
    if ([listCsvName valueForKey:@"ResetAll_TEST"])
    {
        [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"ResetAll_TEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
        
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
        path = [NSString stringWithFormat:@"%@/DutSocket.app",path];
        NSLog(@"===:::>>path : %@",path);
        [[NSWorkspace sharedWorkspace] launchApplication:path];
        
        [NSThread sleepForTimeInterval:10];
        
    }
//
    if (_stimVC !=nil) {
        [self.stimVC resetAllRelays];
    }
    
    
//    [cmdList release];
    
}

- (IBAction)IbootMode:(NSButton *)btn {
    
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"information.plist" ofType:nil];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSAlert * alert = [[NSAlert alloc] init];
    //    NSAlertStyleWarning = 0,
    //    NSAlertStyleInformational = 1,
    //    NSAlertStyleCritical = 2
    [alert addButtonWithTitle:@"OK"];
    if ([dic objectForKey:@"title"]) {
        alert.messageText = [dic objectForKey:@"title"];//@"Warning"
    }else{
        alert.messageText = @"Warning";
    }
    
    if ([dic objectForKey:@"info"]) {
        alert.informativeText = [dic objectForKey:@"info"];
    }else{
        alert.informativeText = @"USBSOC is connected";
    }
    
    //    alert.informativeText = @"Please make sure real battery is connected and BATT switch pushed to REAL position!\r\n\r\nPlease use only the POR batteries!";
//    alert.window.backgroundColor = [NSColor redColor];
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn)  //OK
    {
        
        if ([listCsvName valueForKey:@"IbootMode_TEST"])
        {
            [self m_btnButtonDisable];
            NSString *csvName = [listCsvName valueForKey:@"IbootMode_TEST"];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
            
            NSString *path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
            path = [NSString stringWithFormat:@"%@/DutSocket.app",path];
            NSLog(@"===:::>>path : %@",path);
            [[NSWorkspace sharedWorkspace] launchApplication:path];
        }
    }
    
    

}

- (IBAction)btnMobleRestore:(id)sender {
    

//    NSString *path = [[NSBundle mainBundle]pathForResource:@"information.plist" ofType:nil];
//    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
//
//    NSAlert * alert = [[NSAlert alloc] init];
//    //    NSAlertStyleWarning = 0,
//    //    NSAlertStyleInformational = 1,
//    //    NSAlertStyleCritical = 2
//    [alert addButtonWithTitle:@"OK"];
//    if ([dic objectForKey:@"title"]) {
//        alert.messageText = [dic objectForKey:@"title"];//@"Warning"
//    }else{
//        alert.messageText = @"Warning";
//    }
//
//    if ([dic objectForKey:@"info"]) {
//        alert.informativeText = [dic objectForKey:@"info"];
//    }else{
//        alert.informativeText = @"USBSOC is connected";
//    }
//
//    //    alert.informativeText = @"Please make sure real battery is connected and BATT switch pushed to REAL position!\r\n\r\nPlease use only the POR batteries!";
////    alert.window.backgroundColor = [NSColor redColor];
//    NSInteger result = [alert runModal];
//    if (result == NSAlertFirstButtonReturn)  //OK
//    {
//
//        [m_btnMobileResRunFct setEnabled:NO];
//        [self.mobileRestoreWin.window orderFront:nil];
//    }
//
//
    [m_btnMobileResRunFct setEnabled:NO];
    [self.mobileRestoreWin.window orderFront:nil];

}



- (IBAction)btnRealBattChg:(id)sender
{
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"NO"];
    alert.messageText = @"Real Batt Charger";
    alert.informativeText = @"Please make sure real battery is connected and BATT switch pushed to REAL position!\r\n\r\nPlease use only the POR batteries!";
    alert.window.backgroundColor = [NSColor redColor];
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn)  //OK
    {
        NSLog(@"OK");
        if( ![_GGWindow.window isVisible])
        {
            _GGWindow=[[readGWin alloc]initWithWindowNibName:@"readGWin"];
            [_GGWindow.window orderFront:nil];
        }
        
        
    }
    else if ( result == NSAlertSecondButtonReturn) //NO
    {
        NSLog(@"NO");
    }
    [alert release];
}

- (IBAction)bootDiag:(id)sender {
    NSDictionary *cmdList = [self getJsonDatasWithFileName:@"RecoverMode.json"];
    NSDictionary *par = [cmdList objectForKey:@"EnterParameters"];
//    float a= [[par objectForKey:@"commandDelay"] floatValue];
//    int b=[[par objectForKey:@"powerAfterDelay"] intValue];
//    int c=[[par objectForKey:@"times"] intValue];
    for (NSString *key in cmdList) {
        NSArray *arr = cmdList[key];
        if ([key isEqualToString:@"PowerCommands"]) {
            for (NSString *command in arr){
                NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
                [dicCmd setValue:command forKey:kSendCmd];
                NSLog(@"===>: %@",dicCmd);
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                          :nil userInfo
                                                                          :dicCmd] ;
                [NSThread sleepForTimeInterval:0.2];
              
            }
            
           [NSThread sleepForTimeInterval:[[par objectForKey:@"powerAfterDelay"] intValue]];
            
        }else if ([key isEqualToString:@"DutCommands"]){
            int j =0;
            for (NSString *command in arr) {
                int z =1;
                if (j==0) {
                    z=[[par objectForKey:@"times"] intValue];
                }
                for (int k = 0; k<z; k++) {
                    NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
                    [dicCmd setValue:command forKey:kSendDUTCmd];
                    NSLog(@"==diags=>: %@",dicCmd);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                                              :nil userInfo
                                                                              :dicCmd] ;
                    if (j==0) {
                        float delay = [[par objectForKey:@"commandDelay"] floatValue];
                        [NSThread sleepForTimeInterval:delay];
                    }else{
                        [NSThread sleepForTimeInterval:0.3];
                    }
                    
                }
                
                j++;
                
            }
        }
    }
}
-(id)getJsonDatasWithFileName:(NSString *)file{
    
    NSString *configfile = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    // NSString *configfile = [[NSBundle mainBundle] pathForResource:@"Property List.plist" ofType:nil];
    
    //    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    //    NSString *eCodePath=[desktopPath stringByDeletingLastPathComponent];
    //    NSString *configfile=[eCodePath stringByAppendingPathComponent:@"pinList.json"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:configfile]) {
        
        return nil;
    }
    NSString* items = [NSString stringWithContentsOfFile:configfile encoding:NSUTF8StringEncoding error:nil];
    if (items.length<10) {
        return nil;
    }
    NSData *data= [items dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    return jsonObject;
}
-(void)sendCommandInDut:(NSString *)command{
    NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
    [dicCmd setValue:command forKey:kSendDUTCmd];
    NSLog(@"==diags=>: %@",dicCmd);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                              :nil userInfo
                                                              :dicCmd] ;
    [NSThread sleepForTimeInterval:0.3];
}

-(void)sendEnterInDut{
    
    [self sendCommandInDut:@"\r"];
    [self sendCommandInDut:@"\n"];
}

-(void)sendDiagsCmd:(id)sender
{
    NSString *diagsCmd = [[NSBundle mainBundle] pathForResource:@"EnterDiagsCmd" ofType:@"plist"];
    NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
    [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:diagsCmd]];
    
    NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
    [dicCmd setValue:[[cmdList valueForKey:@"DUT_CMD"] valueForKey:@"command"] forKey:kSendDUTCmd];
    NSLog(@"==diags=>: %@",dicCmd);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                              :nil userInfo
                                                              :dicCmd] ;
    [cmdList release];
    //[self m_btnButtonEnable];

}





- (IBAction)btnClear:(id)sender
{
    [txtView setString:@""];
}


-(void)m_btnButtonEnable
{
    if (![m_btnAceFWDl isEnabled]) {
        [m_btnAceFWDl setEnabled:YES];
    }
    if (![m_btnEnterDiags isEnabled]) {
        [m_btnEnterDiags setEnabled:YES];
    }
    if (![m_btnUSB3_0 isEnabled]) {
        [m_btnUSB3_0 setEnabled:YES];
    }
    if (![m_btnEfficiency isEnabled]) {
        [m_btnEfficiency setEnabled:YES];
    }
    
    if (![m_btnDFU isEnabled]) {
        [m_btnDFU setEnabled:YES];
    }
    if (![m_btnIboot isEnabled]) {
        [m_btnIboot setEnabled:YES];
    }
    if (![m_btnResetAll isEnabled]) {
        [m_btnResetAll setEnabled:YES];
    }
    if (![m_btnBattChg isEnabled]) {
        [m_btnBattChg setEnabled:YES];
    }
    
    if (![m_btnMobileResRunFct isEnabled]) {
        [m_btnMobileResRunFct setEnabled:YES];
    }
    //    if (![m_btnStim isEnabled]) {
    //         [m_btnStim setEnabled:YES];
    //    }
}

-(void)m_btnButtonDisable
{
    if ([m_btnAceFWDl isEnabled]) {
        [m_btnAceFWDl setEnabled:NO];
    }
    if ([m_btnEnterDiags isEnabled]) {
        [m_btnEnterDiags setEnabled:NO];
    }
    if ([m_btnUSB3_0 isEnabled]) {
        [m_btnUSB3_0 setEnabled:NO];
    }
    if ([m_btnEfficiency isEnabled]) {
        [m_btnEfficiency setEnabled:NO];
    }
    
    if ([m_btnDFU isEnabled]) {
        [m_btnDFU setEnabled:NO];
    }
    if ([m_btnIboot isEnabled]) {
        [m_btnIboot setEnabled:NO];
    }
    if ([m_btnResetAll isEnabled]) {
        [m_btnResetAll setEnabled:NO];
    }
    if ([m_btnBattChg isEnabled]) {
        [m_btnBattChg setEnabled:NO];
    }
    
    if ([m_btnMobileResRunFct isEnabled]) {
        [m_btnMobileResRunFct setEnabled:NO];
    }
    
    //    if ([m_btnStim isEnabled]) {
    //        [m_btnStim setEnabled:NO];
    //    }
    
}

- (IBAction)btnACEFWDL:(id)sender
{
    if ([listCsvName valueForKey:@"ACEFWDLTEST"])
    {
        [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"ACEFWDLTEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
}

- (IBAction)btnUSB3_0_Test:(id)sender
{
    if ([listCsvName valueForKey:@"USB3TEST"])
    {
        [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"USB3TEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
}

- (IBAction)otpTest:(id)sender {
    NSAlert * alert = [[NSAlert alloc] init];
//    NSAlertStyleWarning = 0,
//    NSAlertStyleInformational = 1,
//    NSAlertStyleCritical = 2
    [alert addButtonWithTitle:@"Exit"];
    [alert addButtonWithTitle:@"MP OTP(Not Ready)"];
    [alert addButtonWithTitle:@"EVT OTP"];
    [alert addButtonWithTitle:@"P2 OTP"];
    
    alert.messageText = @"OTP Flash";
//    alert.informativeText = @"Please make sure real battery is connected and BATT switch pushed to REAL position!\r\n\r\nPlease use only the POR batteries!";
    alert.window.backgroundColor = [NSColor redColor];
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn)  //OK
    {
    }
    else if ( result == NSAlertSecondButtonReturn) //NO
    {
        [self sendNotificationOnLoadProfile:@"MP_TEST"];
        NSLog(@"MP OTP");
       
    }
    else if ( result == NSAlertThirdButtonReturn) //NO
    {
        [self sendNotificationOnLoadProfile:@"EVT_TEST"];
        NSLog(@"EVT OTP");
    }else{
        [self sendNotificationOnLoadProfile:@"P2_TEST"];
        NSLog(@"P2 OTP");
    }
    
}

-(void)sendNotificationOnLoadProfile:(NSString *)name{
    
    if ([listCsvName valueForKey:name])
    {
        NSString *csvName = [listCsvName valueForKey:name];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
}

- (IBAction)btnEfficiencyTest:(id)sender
{
    if ([listCsvName valueForKey:@"EFFICIENCYTEST"])
    {
        [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"EFFICIENCYTEST"];
        NSLog(@"%@",csvName);
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
        
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
        path = [NSString stringWithFormat:@"%@/Efficiency.app",path];
        NSLog(@"===:::>>path : %@",path);
        [[NSWorkspace sharedWorkspace] launchApplication:path];
    }
}

- (IBAction)btnStimPanel:(id)sender
{
    [m_btnStim setEnabled:NO];
    [self STIM_V2];
    
}

-(void)STIM_V2{
    
    
    [self.stimVC.window orderFront:nil];
    
}



-(void)STIM_V1{
    if (_LuaDebugPanelWin)
    {
        [_LuaDebugPanelWin MainWinDebugPanelClose];
    }
    _LuaDebugPanelWin=[[LuaDebugPanelDebugWinDelegate alloc]initWithWindowNibName:@"LuaDebugPanelDebug"];
    
    [_LuaDebugPanelWin.window orderFront:nil];
}

- (IBAction)explorerTest:(id)sender
{
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    path = [NSString stringWithFormat:@"%@/Explorer.app",path];
    NSLog(@"===:::>>path : %@",path);
    [[NSWorkspace sharedWorkspace] launchApplication:path];
}

- (IBAction)btn_MeasPanel:(id)sender
{
}

-(void)OnTimer:(NSTimer *)timer
{
    NSString *isTesting = [NSString stringWithContentsOfFile:KTestingFlag encoding:NSUTF8StringEncoding error:nil];//#import "GraphicHeader.h"
    if ([isTesting isEqualTo:@"YES"])
    {
        [self m_btnButtonDisable];
    }
    else
    {
       [self m_btnButtonEnable];
    }
    
}


- (void)windowWillClose:(NSNotification *)notification {
    
    NSWindow *window =notification.object ;
    if ([window.title isEqualToString:@"STIM"]) {
        [m_btnStim setEnabled:YES];
        
        
        NSString *cmds = [[NSBundle mainBundle] pathForResource:@"StimCmdList" ofType:@"plist"];
        NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
        [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:cmds]];
        
        
        if ([[cmdList valueForKey:@"Set_ELoad"] valueForKey:@"shut_down"])
        {
            NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
            [dicCmd setValue:[[cmdList valueForKey:@"Set_ELoad"] valueForKey:@"shut_down"] forKey:kSendCmd];
            NSLog(@"===>: %@",dicCmd);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                      :nil userInfo
                                                                      :dicCmd] ;
            [NSThread sleepForTimeInterval:0.2];
        }
        
        [self.stimVC.window orderBack:nil];
        
    }
    else if ([window.title isEqualToString:@"Bundle Options"]) {
        [m_btnMobileResRunFct setEnabled:YES];
        [self.mobileRestoreWin.window orderBack:nil];
        
    }
    else if ([window.title isEqualToString:@"DVP Panel"]){
        // [self.stimVC.window close];
        [NSApp terminate:nil];
        //
    }
    
}
-(MobileRestoreWin *)mobileRestoreWin{
    if (_mobileRestoreWin == nil) {
        _mobileRestoreWin = [[MobileRestoreWin alloc] initWithWindowNibName:@"MobileRestoreWin"];
        
    }
    return _mobileRestoreWin;
}

-(StimMainVC *)stimVC{
    if (_stimVC == nil) {
        _stimVC = [[StimMainVC alloc] initWithWindowNibName:@"StimMainVC"];
        
    }
    return _stimVC;
}
@end
