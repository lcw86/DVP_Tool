//
//  UnitViewController.m
//  DUT
//
//  Created by Ryan on 11/3/15.

//

#import "XavierFunVC.h"
#import "HWIOMode.h"
#include "AppDelegate.h"
#include "RegexKitLite.h"
#import "LuaDebugPanelDebugWinDelegate.h"
#import "hwioWinController.h"
#import "GraphicHeader.h"
#import "StimMainVC.h"
#import "DebugLog.h"
@interface XavierUinitVC ()
{
   
}
@property (assign) IBOutlet NSTextField *eLoadText;

@property(strong)hwioWinController *hwioWindow;
@property(strong)LuaDebugPanelDebugWinDelegate *LuaDebugPanelWin;
@property (copy)NSArray *searchArrAI;
@property (copy)NSArray *searchArrRelay;

@property (copy)NSArray *searchArrVoltage;
@property (copy)NSArray *searchArrCurrent;
@property (copy)NSArray *searchArrFrequency;


@end

#define REQUEST_ADDRESS         @"REQUEST_ADDRESS"
#define SUBSCRIBER_ADDRESS      @"SUBSCRIBER_ADDRESS"

@implementation XavierUinitVC
@synthesize searchBtn;
@synthesize searchCurrent;
@synthesize searchFrequency;
@synthesize searchBtnRelay;

@synthesize btnReturn1;
@synthesize btnNewLine1;

-(id)initialwithID:(int)ID
{
    NSLog(@"=====222=====");
    //self = [super init];
    self = [super initWithNibName:@"XavierUinitVC" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        mID = ID;
        pDUT = new CDUTController(mID);
        pDUT->SetDelegate(self);
        
        cellArrayAI = [[NSMutableArray alloc]init];
        cellArrayRelay = [[NSMutableArray alloc]init];
        
        cellArray_Voltage = [[NSMutableArray alloc]init];
        cellArray_Current = [[NSMutableArray alloc]init];
        cellArray_Frequence = [[NSMutableArray alloc]init];
        
    }
    return self;
}


-(int)InitialPort:(NSDictionary *)diConfig
{
    pDUT->Close();
    NSLog(@"pDUT->Close()");
    pDUT->Initial([[diConfig valueForKey:kRequest] UTF8String], [[diConfig valueForKey:kSubscribe] UTF8String]);
    return 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    //[txtBuffer setUsesFindBar:YES];
    coefficient =1.0;
    [self loadHwioTableFile:@"HWIO_Voltage.lua"];
    [self loadHwioTableFile:@"HWIO_Current.lua"];
    [self loadHwioTableFile:@"HWIO_Frequency.lua"];
    //NSLog(@">>: %@",cellArray_Voltage);
  //  [self loadHwioTableFile];
    //NSArray *arr = @[@"Xavier 1",@"Xavier 2",@"Xavier 3",@"Xavier 4"];
//    [m_label setStringValue:[NSString stringWithFormat:@"Xavier %d",mID+1]];
//    m_label.backgroundColor = [NSColor lightGrayColor];
    
    _eLoadText.cell.formatter = [self textFormater];
    m_batt.cell.formatter = [self textFormater];
    m_usb.cell.formatter = [self textFormater];
    
    //NSLog(@"-2-1 Initial Uint in here!,ID: %d @%p",mID,self);
    [cmdControll_AIList setTarget:self];
    [cmdControll_AIList setDoubleAction:@selector(DblClickOnTableView_Voltage:)];
    [cmdControll_AIList setAction:@selector(ClickOnTableView_Voltage:)];
    [cmdControll_AIList reloadData];
    
    [cmdControl_CurrentList setTarget:self];
    [cmdControl_CurrentList setDoubleAction:@selector(DblClickOnTableView_Current:)];
    [cmdControl_CurrentList setAction:@selector(ClickOnTableView_Current:)];
    [cmdControl_CurrentList reloadData];
    
    [cmdCOntrol_FrequencyList setTarget:self];
    [cmdCOntrol_FrequencyList setDoubleAction:@selector(DblClickOnTableView_Frequency:)];
    [cmdCOntrol_FrequencyList setAction:@selector(ClickOnTableView_Frequency:)];
    [cmdCOntrol_FrequencyList reloadData];
    
    [cmdControll_RelayList setTarget:self];
    [cmdControll_RelayList setDoubleAction:@selector(DblClickOnTableView_Relay:)];
    [cmdControll_RelayList setAction:@selector(ClickOnTableView_Relay:)];
    [cmdControll_RelayList reloadData];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                     :@selector(setStimButtonEnable:) name
                                                     :@"KsetStimButtonEnable" object
                                                     :nil] ;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SendCmdToXavier:) name:kNotificationStimCmd object:nil];
    
}

-(void)SendCmdToXavier:(NSNotification*)nf
{
    NSDictionary *userInfo = [nf userInfo];
    
    if ([userInfo objectForKey:@"coefficient"]) {
        coefficient =[[userInfo objectForKey:@"coefficient"] intValue];
    }
    
    if ([userInfo objectForKey:kSendCmd])
    {
        NSString * cmd = [userInfo objectForKey:kSendCmd];
        [comboxCmd setStringValue:cmd];
         [self btSend:nil];
    }
    else
    {
         [comboxCmd setStringValue:@"nil"];
    }
   
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc unitviewcontroller object-----");
    pDUT->Close();
    NSLog(@"dealloc unitviewcontroller object1-----");
    
    [cellArrayAI removeAllObjects];
    [cellArrayAI release];
    
    [cellArrayRelay removeAllObjects];
    [cellArrayRelay release];
    
    [cellArray_Voltage removeAllObjects];
    [cellArray_Voltage release];
    
    [cellArray_Current removeAllObjects];
    [cellArray_Current release];
    
    [cellArray_Frequence removeAllObjects];
    [cellArray_Frequence release];
    
    [super dealloc];
    
    if (pDUT)
    {
        delete pDUT;
        pDUT = nullptr;
    }
    NSLog(@"dealloc unitviewcontroller object2-----");
    
}

-(NSString *)getDisplayCmd{
    
    
    return nil;
}

-(IBAction)btSend:(id)sender
{
   
    if (![comboxCmd stringValue] ||[[comboxCmd stringValue] isEqualToString:@""]||[[comboxCmd stringValue]isEqualToString:@"N/A"]||[[comboxCmd stringValue] isEqualToString:@"nil"])
    {
        return;
    }
    
    NSMutableString * cmds = [NSMutableString string];
    [cmds appendString:[comboxCmd stringValue]];
    
    if ([cmds containsString:@"[123]adc read(-c,nor,G,5V,10000,1,70)"]) {
        displayVaule = YES;
    }
    
    NSArray *arrayCmd = [cmds componentsSeparatedByString:@";"];
        [DebugLog saveLogToDefaultFileWithContent:[NSString stringWithFormat:@"send commands:%@",cmds]];
    NSMutableString * cmd = [NSMutableString string];
    for (NSString *sub_cmd in arrayCmd)
    {
        
        [DebugLog saveLogToDefaultFileWithContent:[NSString stringWithFormat:@"send subCmd:%@",sub_cmd]];
        if ([sub_cmd containsString:@"delay"])
        {
            NSString *regexStr = @"delay\\s*([0-9]{1,}[.]?[0-9]*)";
            NSString *matchedStr = [sub_cmd stringByMatching:regexStr capture:1L];
            if(matchedStr)
            {
                 [NSThread sleepForTimeInterval:[matchedStr floatValue]];
            }
        }
        
        else if ([sub_cmd containsString:@"["] && [sub_cmd containsString:@"]"])
        {
            
        
            [cmd setString:sub_cmd];
//            if([btnReturn1 state]==NSOnState)
////                [cmd appendString:@"\r"];
//            if([btnNewLine1 state]==NSOnState)
                if (![cmd containsString:@"pwm output disable"]) {
                   [cmd appendString:@"\n"];
                }
            
            int ret = pDUT->WriteString([cmd UTF8String]);
            
            if (ret<0)//CWDEBUG
            {
               [DebugLog saveLogToDefaultFileWithContent:@"Exit....not connect"];
                NSAlert * alert = [[NSAlert alloc] init];
                alert.messageText = [NSString stringWithFormat:@"Write DUT%d failed",mID];
                alert.informativeText = @"Replier not response,Please make sure TestEngine is running..";
                [alert runModal];
                [alert release];
                return;
            }
            [NSThread sleepForTimeInterval:0.01];
            NSLog(@"---cmd: %@",cmd);
        }
        else if([sub_cmd containsString:@"i2c"])
        {
            //NSLog(@"-->sub_cmd: %@",sub_cmd);
            
            NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
            [dicCmd setValue:sub_cmd forKey:kSendDUTCmd];
            NSLog(@"==diags=>: %@",dicCmd);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                                      :nil userInfo
                                                                      :dicCmd] ;
            [NSThread sleepForTimeInterval:0.01];
        }
    }
}


-(void)btRefresh
{
    int ret = pDUT->WriteString("reconnect");
    if (ret<0)
    {
        //NSRunAlertPanel(@"Write DUT", @"Write DUT%d failed,please check connection,or make sure TestEngine is running", @"OK", nil, nil,mID);
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"Write DUT%d failed",mID];
        alert.informativeText = @"Replier not response,Please make sure TestEngine is running...";
        [alert runModal];
        [alert release];
    }
}



-(IBAction)btClear:(id)sender
{
    [txtBuffer setString:@""];
}

- (IBAction)btHwio:(NSButton *)sender
{
    
}

-(void)OnLog:(NSString *)str
{
    if (!str) return;
    
    NSMutableString * pstr = [[txtBuffer textStorage] mutableString];
    
    if ([str containsString:@"\n"])
    {
        [pstr appendFormat:@"%@",str];
    }
    else
    {
        [pstr appendFormat:@"%@\n",str];
    }
    
    
    //    [m_measurment setStringValue:str];
    
    
    
    if (([str containsString:@"ACK"]))//[pstr containsString:@"444555666"]&&
    {
        //        [m_measurment setStringValue:@"null"];
        
        NSString *regexStr = @"ACK\\s*\\(\\s*([+-]?[0-9]{1,}[.]?[0-9]*)";
        NSString *matchedStr = [str stringByMatching:regexStr capture:1L];
        
        
        if(matchedStr)
        {
            NSString *strItem = @"";
            if (matchedStr.length)//[matchedStr doubleValue]>5
            {
                strItem = [NSString stringWithFormat:@"%@:%f %@",nameAIMeas,[matchedStr doubleValue]*[gainValue doubleValue],nameAIUnit];
                
            }
            else
            {
                strItem = [NSString stringWithFormat:@"%@:%f %@",nameAIMeas, [matchedStr doubleValue],nameAIUnit];
            }
            [m_measurment setStringValue:strItem];
            if (displayVaule) {
                NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
                [dicCmd setValue:matchedStr forKey:@"measurement"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMeasurementValue" object
                                                                          :nil userInfo
                                                                          :dicCmd] ;
                displayVaule = NO;
            }
        }
//        else
//        {
//            [m_measurment setStringValue:[NSString stringWithFormat:@"%@:NULL %@",nameAIMeas,nameAIUnit]];
//        }
        
    }
    else if ([str containsString:@"[555666777]"]&&([str containsString:@"ACK"]))
    {
        NSString *regexStr = @"ACK\\s*\\(\\s*([+-]?[0-9]{1,}[.]?[0-9]*)";
        NSString *matchedStr = [str stringByMatching:regexStr capture:1L];
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:matchedStr forKey:@"measurement"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMeasurementValue" object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
        //        NSString *regexStr = @"ACK\\s*\\(\\s*([+-]?[0-9]{1,}[.]?[0-9]*)";
        //        NSString *matchedStr = [str stringByMatching:regexStr capture:1L];
        //
        //        if(matchedStr)
        //        {
        //
        //        }
        //        else
        //        {
        //            matchedStr = @"NULL";
        //        }
        //            NSAlert * alert = [[NSAlert alloc] init];
        //            alert.messageText = @"Measure Result,UUT%d";
        //            alert.informativeText = matchedStr;
        //            [alert runModal];
        //            [alert release];
    }
    else if ([str containsString:@"[777999888]"]&&([str containsString:@"ACK"]))
    {
        
    }
    NSRange range = NSMakeRange([pstr length]-1,0);
    [txtBuffer scrollRangeToVisible:range];
}

#define TIME_STAMP_MATCH        @"[0-9A-Fa-f]+@R\\d"
#define TIME_STAMP_MATCH_CAP    @"([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])@R\\d"
-(NSString *)ReplaceTimeStamp:(NSString *)str
{
    return [str stringByReplacingOccurrencesOfRegex:TIME_STAMP_MATCH options:RKLMultiline inRange:NSMakeRange(0, [str length]-1) error:nil enumerationOptions:RKLRegexEnumerationNoOptions usingBlock:^NSString *(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString * cap = [NSString stringWithString:(NSString *)*capturedStrings];
        NSString * strSecond = [cap stringByMatching:TIME_STAMP_MATCH_CAP capture:1];
        NSString * strMS = [cap stringByMatching:TIME_STAMP_MATCH_CAP capture:2];
        if ((!str)||(!strMS)) {
            return @"";
        }
        
        long seconds = strtol([[@"0x" stringByAppendingString:strSecond] UTF8String], NULL, 16);
        long ms = strtol([[@"0x" stringByAppendingString:strMS] UTF8String], NULL, 16);
        NSTimeInterval time = seconds+(double)ms/1000.0;
        
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
        
        NSString * rep = [dateFormatter stringFromDate:date];

        [dateFormatter release];
        return rep;
        
    }];
}

-(void)OnData:(void *)bytes length:(long)len
{
    if (!len) return;
    NSLog(@"OnData len:%ld",len);
    if (len < 1) return;
    NSString * str;

    if ( (str= [[NSString alloc] initWithBytes:bytes length:len encoding:NSUTF8StringEncoding]) == nil)
    {
        NSLog(@"OnData bytes:nil");
        return;
    }

    NSLog(@"str:%@",str);
    NSString *str1 = [NSString stringWithString:str];
    str1 = [self ReplaceTimeStamp:str1];
    NSLog(@"str1:%@",str1);

    [DebugLog saveLogToDefaultFileWithContent:[NSString stringWithFormat:@"response:%@",str1]];
    [self performSelectorOnMainThread:@selector(OnLog:)  withObject:str1 waitUntilDone:NO];
    [str release];
}


-(int)loadHwioTableFile:(NSString *)fileName
{
    NSString *luapath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    NSString * luaCont = [NSString stringWithContentsOfFile:luapath encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *arrayCont = [luaCont componentsSeparatedByString:@"\n"];

    NSString *pattern0 = @"CH\\s*=";
    NSRegularExpression *regular0 = [[NSRegularExpression alloc] initWithPattern:pattern0 options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (NSString *str in arrayCont)
    {
        if (str)
        {
            str =  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([str length] >3 &&[str isNotEqualTo:@""])
            {
                if ([[str substringWithRange:NSMakeRange(0, 2)] isNotEqualTo:@"--"] && ![str containsString:@"HWIO.critical"] &&![str containsString:@"HWIO.MeasureTable"] && ![str containsString:@"HWIO.RelayTable"])
                {
                    
                    NSString *pattern = @"IO\\s*=";
                    //1.1将正则表达式设置为OC规则
                    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
                    //2.利用规则测试字符串获取匹配结果
                    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
                    [regular release];
                    
                    if (results.count)
                    {
                        //[cellArray addObject:[NSString stringWithFormat:@"%@ %@",nameItem,str]];
                        NSArray *results0 = [regular0 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
                        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if (results0.count)
                        {
                            if ([fileName isEqualToString:@"HWIO_Voltage.lua"])
                            {
                                [cellArray_Voltage addObject:[self setHWIOModeAIWithStr:str]];
                            }
                            else if([fileName isEqualToString:@"HWIO_Current.lua"])
                            {
                                [cellArray_Current addObject:[self setHWIOModeAIWithStr:str]];
                            }
                            else if([fileName isEqualToString:@"HWIO_Frequency.lua"])
                            {
                                [cellArray_Frequence addObject:[self setHWIOModeAIWithStr:str]];
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    [regular0 release];
    return 0;
}



-(int)loadHwioTableFile
{
    //bool isDebug = [SettingConfig isDebugMode];
    
    NSString *luapath = [[NSBundle mainBundle] pathForResource:@"HWIO.lua" ofType:nil];
//    if (!isDebug) {
//        NSString *luapath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
//        if ([luapath containsString:@"/tools"]) {
//            luapath = [luapath stringByDeletingLastPathComponent];
//        }
//        luapath = [[luapath stringByAppendingPathComponent:@"LuaDriver/Driver/hw/HWIO.lua"] stringByResolvingSymlinksInPath];
//    }

    
    NSString * luaCont = [NSString stringWithContentsOfFile:luapath encoding:NSUTF8StringEncoding error:nil];
    
    NSRange range_io_start = [luaCont rangeOfString:@"HWIO.MeasureTable"];
    NSRange range_io_end = [luaCont rangeOfString:@"return HWIO"];
    NSRange range_io;
    range_io.location = range_io_start.location+range_io_start.length;
    range_io.length = range_io_end.location-range_io_start.location-range_io_start.length;
    NSString * io_con = [luaCont substringWithRange:range_io];
    
    NSArray *arrayCont = [io_con componentsSeparatedByString:@"\n"];
    NSString *nameItem = @"";
    
    NSString *pattern0 = @"CH\\s*=";
    NSRegularExpression *regular0 = [[NSRegularExpression alloc] initWithPattern:pattern0 options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (NSString *str in arrayCont)
    {
        if (str)
        {
            str =  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([str length] >3 &&[str isNotEqualTo:@""])
            {
                if ([[str substringWithRange:NSMakeRange(0, 2)] isNotEqualTo:@"--"] && ![str containsString:@"HWIO.critical"] &&![str containsString:@"HWIO.MeasureTable"] && ![str containsString:@"HWIO.RelayTable"])
                {
                    
                    NSString *pattern = @"IO\\s*=";
                    //1.1将正则表达式设置为OC规则
                    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
                    //2.利用规则测试字符串获取匹配结果
                    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
                    [regular release];
                    
                    if (results.count)
                    {
                        //[cellArray addObject:[NSString stringWithFormat:@"%@ %@",nameItem,str]];
                        NSArray *results0 = [regular0 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
                        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if (results0.count)
                        {
                            // for AI
                            [cellArrayAI addObject:[self setHWIOModeAIWithStr:str]];
                            
                        }
                        else
                        {
                            // for relay
                            [cellArrayRelay addObject:[self setHWIOModeRelayWithStr:[NSString stringWithFormat:@"%@ %@",nameItem,str]]];
                        }
                        
                    }
                    else
                    {
                        nameItem = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    }
                    
                }
            }
        }
    }
    
    [regular0 release];
    return 0;
}

-(HWIOModeAI *)setHWIOModeAIWithStr:(NSString *)subjectString
{
    HWIOModeAI *mode = [[[HWIOModeAI alloc]init] autorelease];
    mode.fullname = subjectString;
    
    NSString *regexStringName = @"(.*?)\\s*=\\s*\\{\\s*IO\\s*=";
    NSString *matchedStringName = [subjectString stringByMatching:regexStringName capture:1L];
    if (!matchedStringName) {
        matchedStringName = @"NULL";
    }
    mode.itemname =matchedStringName;
    
    NSString *regexStringIOvalue = @".*?\\s*=\\s*\\{\\s*(IO\\s*=.*)\\s*CH";
    NSString *matchedStringIOvalue = [subjectString stringByMatching:regexStringIOvalue capture:1L];
    if (!matchedStringIOvalue) {
        matchedStringIOvalue = @"NULL";
    }
    mode.iovalue = matchedStringIOvalue;
    
    NSString *regexStringCH = @"CH\\s*=\\s*\"\\s*(\\w+)\\s*\"";
    NSString *matchedStringCH = [subjectString stringByMatching:regexStringCH capture:1L];
    if (!matchedStringCH) {
        matchedStringCH = @"NULL";
    }
    mode.channel = matchedStringCH;
    
    NSString *regexStringGain = @"GAIN\\s*=\\s*([0-9]{1,}[.]?[0-9]*)";
    NSString *matchedStringGain = [subjectString stringByMatching:regexStringGain capture:1L];
    if (!matchedStringGain) {
        matchedStringGain = @"1";
    }
    mode.gain = matchedStringGain;
    return mode;
}

-(HWIOModeRelay *)setHWIOModeRelayWithStr:(NSString *)subjectString
{
    HWIOModeRelay *mode = [[[HWIOModeRelay alloc]init] autorelease];
    mode.fullname = subjectString;
    
    NSString *regexStringName = @"(.*?)\\s*=\\s*\\{\\s*IO\\s*=";
    NSString *matchedStringName = [subjectString stringByMatching:regexStringName capture:1L];
    matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@"=" withString:@""];
    matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@" " withString:@""];
    matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@"{" withString:@" - "];
    if (!matchedStringName) {
        regexStringName = @"(.*?)\\s*=\\s*\\{\\s*EXIO\\s*=";
        matchedStringName = [subjectString stringByMatching:regexStringName capture:1L];
        matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@"=" withString:@""];
        matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@" " withString:@""];
        matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        matchedStringName = [ matchedStringName stringByReplacingOccurrencesOfString:@"{" withString:@" - "];
        if (!matchedStringName) {
             matchedStringName = @"NULL";
        }
    }
    mode.itemname =matchedStringName;
    
    NSString *regexStringIOvalue = @"IO\\s*=\\s*\\{\\s*(\\{\\s*.*?\\s*\\})\\s*\\}";
    NSString *matchedStringIOvalue = [subjectString stringByMatching:regexStringIOvalue capture:1L];
    if (!matchedStringIOvalue) {
        matchedStringIOvalue = @"NULL";
    }
    mode.iovalue = matchedStringIOvalue;
    
    NSString *regexStringDac2 = @"DAC2\\s*=\\s*([0-9]{1,}[.]?[0-9]*)";
    NSString *matchedStringDac2 = [subjectString stringByMatching:regexStringDac2 capture:1L];
    
    if (!matchedStringDac2) {
        matchedStringDac2 = @"1";
    }
    mode.dac2 = matchedStringDac2;
    
    NSString *regexStringRvalue = @"R\\s*=\\s*([0-9]{1,}[.]?[0-9]*)";
    NSString *matchedStringRvalue = [subjectString stringByMatching:regexStringRvalue capture:1L];
    if (!matchedStringRvalue) {
        matchedStringRvalue = @"1";
    }
    mode.R_value = matchedStringRvalue;
    return mode;
    
}


-(NSString *) channel_number:(NSString *)ch
{
    NSString* temp =@"";
    if ([ch isEqualToString:@"AI1"])
    {
        temp = @"A";
    }
    else if ([ch isEqualToString:@"AI2"])
    {
        temp = @"B";
    }
    else if ([ch isEqualToString:@"AI3"])
    {
        temp = @"C";
    }
    else if ([ch isEqualToString:@"AI4"])
    {
        temp = @"D";
    }
    else if ([ch isEqualToString:@"AI5"])
    {
        temp = @"E";
    }
    else if ([ch isEqualToString:@"AI6"])
    {
        temp = @"F";
    }
    else if ([ch isEqualToString:@"AI7"])
    {
        temp = @"G";
    }
    else
    {
        temp = @"H";
    }
    
    return temp;
}

-(NSString *)aiCommand:(NSString *)ch
{
    NSString * option = @"nor";
    NSString * channel = [self channel_number:ch];
    NSString * adc_range = @"10V";
    int sample_rate = 10000;
    int count = 1;
    int measue_time = 150;
    
    NSString *cmd = [NSString stringWithFormat:@"[444555666]adc read(%@,%@,%@,%d,%d,%d)",option,channel,adc_range,sample_rate,count,measue_time];
    return cmd;
    
}
-(NSNumberFormatter *)textFormater{
    NSNumberFormatter * formater = [[NSNumberFormatter alloc] init];
    formater.numberStyle = NSNumberFormatterDecimalStyle;
    formater.maximum = @(10000);
    formater.minimum = @(0.0001);
    return formater;
}
-(NSString *)frequenceCommand
{
    
    int door_v = 300;
    NSString *cmd = [NSString stringWithFormat:@"[444555666]frequency measure(-fdv,%d,200)",door_v];
    return cmd;
}

-(NSString *)convertCmd:(NSArray *)arrayIO with:(NSString *)ioname
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:@""];
    for (NSString *sub in arrayIO)
    {
        NSArray *s = [sub componentsSeparatedByString:@","];
        if ([s count]>1)
        {
            NSString *io = [s[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *status = [s[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [cmd appendString:[NSString stringWithFormat:@"bit%@=%@,",io,status]];
        }
        
    }
    NSString *cmdIO =[NSString stringWithFormat:@"[123]%@(%zd,%@,,)",ioname,[arrayIO count],cmd];
    cmdIO = [cmdIO stringByReplacingOccurrencesOfString:@",,," withString:@""];
    [cmd release];
    return cmdIO;
}


-(NSString *) cmdRealyIO:(NSString *)str
{
    //NSLog(@"==>> %@",str);
    NSString *pattern = @"[0-9]+\\s*,\\s*[0-9]+";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSMutableArray *arrayIO = [[NSMutableArray alloc]init];
    for (NSTextCheckingResult *result in results)
    {
        //NSLog(@"==> %@",[str substringWithRange:result.range]);
        [arrayIO addObject:[str substringWithRange:result.range]];
    }
    if ( [arrayIO count] == 0)
    {
        [regular release];
        [arrayIO release];
        return @"click is wrong!!!";
    }
    
    NSString *pattern0 = @"CH\\s*=";
    NSRegularExpression *regular0 = [[NSRegularExpression alloc] initWithPattern:pattern0 options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results0 = [regular0 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
    if (results0.count)
    {
        //for AI measurement
        NSString *regexString1 = @"IO\\s*=\\s*\\{\\s*(\\{\\s*.*?\\s*\\})\\s*\\}";
        NSString *regexString2 = @"EXIO\\s*=\\s*\\{\\s*(\\{\\s*.*?\\s*\\})\\s*\\}";
        NSString *regexString3 = @"EXIO_DISCONNECT\\s*=\\s*\\{\\s*(\\{\\s*.*?\\s*\\})\\s*\\}";
        NSString *matchedStr1 = [str stringByMatching:regexString1 capture:1L];
        NSString *matchedStr2 = [str stringByMatching:regexString2 capture:1L];
        NSString *matchedStr3 = [str stringByMatching:regexString3 capture:1L];
        
        NSString *regexString4 = @"CH\\s*=\\s*\"\\s*(AI\\d+)\\s*\"";
        NSString *results4 = [str stringByMatching:regexString4 capture:1L];
        
        NSString *regexString5 = @"CH\\s*=\\s*\"\\s*(\\w*_\\w*)\\s*\"";
        NSString *results5 = [str stringByMatching:regexString5 capture:1L];
        
        NSArray *results1=nil;
        NSArray *results2=nil;
        NSArray *results3=nil;
        
        if (matchedStr1)
        {
            results1 = [regular matchesInString:matchedStr1 options:0 range:NSMakeRange(0, matchedStr1.length)];
        }
        if (matchedStr2)
        {
            results2 = [regular matchesInString:matchedStr2 options:0 range:NSMakeRange(0, matchedStr2.length)];
        }
        if (matchedStr3)
        {
            results3 = [regular matchesInString:matchedStr3 options:0 range:NSMakeRange(0, matchedStr3.length)];
        }
        
        //NSLog(@"%@    | %@   |   %@",matchedStr1,matchedStr2,matchedStr3);
        
        NSMutableString *cmdIO = [[[NSMutableString alloc]initWithString:@""] autorelease];
        if (results1)
        {
            if (arrayIO)
            {
                [arrayIO removeAllObjects];
            }
            for (NSTextCheckingResult *result in results1)
            {
                [arrayIO addObject:[matchedStr1 substringWithRange:result.range]];
            }
            
            [cmdIO appendString: [self convertCmd:arrayIO with:@"io set"]];
            
        }
        if (results2)
        {
            if (arrayIO)
            {
                [arrayIO removeAllObjects];
            }
            for (NSTextCheckingResult *result in results2)
            {
                [arrayIO addObject:[matchedStr2 substringWithRange:result.range]];
            }
            
            [cmdIO appendString:@";"];
            [cmdIO appendString: [self convertCmd:arrayIO with: @"exio set"]];
            
            // NSLog(@"---2--%@",cmdIO);
            
        }
        
        if (results4)
        {
            [cmdIO appendString:@";"];
            [cmdIO appendString:[self aiCommand:results4]];
        }
        
        if (results5)
        {
            [cmdIO appendString:@";"];
            [cmdIO appendString:[self frequenceCommand]];
        }
        
        if (results3)
        {
            if (arrayIO)
            {
                [arrayIO removeAllObjects];
            }
            for (NSTextCheckingResult *result in results3)
            {
                [arrayIO addObject:[matchedStr3 substringWithRange:result.range]];
            }
            
            [cmdIO appendString:@";"];
            [cmdIO appendString:[self convertCmd:arrayIO with:@"exio set"]];
            
        }
        
        //NSLog(@"===%@====",cmdIO);
        [arrayIO release];
        [regular release];
        [regular0 release];
        
        return cmdIO;
    }
    else
    {
        //for relay
        
        NSMutableString *cmd = [[NSMutableString alloc] initWithString:@""];
        for (NSString *sub in arrayIO)
        {
            NSArray *s = [sub componentsSeparatedByString:@","];
            if ([s count]>1)
            {
                NSString *io = [s[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *status = [s[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [cmd appendString:[NSString stringWithFormat:@"bit%@=%@,",io,status]];
            }
            
        }
        
        NSString *pattern2 = @"EXIO\\s*=";
        NSRegularExpression *regular2 = [[NSRegularExpression alloc] initWithPattern:pattern2 options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results2 = [regular2 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        
        
        NSString * ioname= @"io set";
        if (results2.count)
        {
            ioname= @"exio set";
        }
        NSString *cmdIO =[NSString stringWithFormat:@"[123]%@(%zd,%@,,)",ioname,[arrayIO count],cmd];
        cmdIO = [cmdIO stringByReplacingOccurrencesOfString:@",,," withString:@""];
        
        
        [arrayIO release];
        [cmd release];
        [regular0 release];
        [regular release];
        [regular2 release];
        return cmdIO;
    }
}

-(NSString *) cmdRealyIO_no_use:(NSString *)str
{
    NSString *pattern = @"[0-9]+\\s*,\\s*[0-9]+";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSMutableArray *arrayIO = [[NSMutableArray alloc]init];
    for (NSTextCheckingResult *result in results)
    {
        //NSLog(@" %@",[str substringWithRange:result.range]);
        [arrayIO addObject:[str substringWithRange:result.range]];
    }
    if ( [arrayIO count] == 0)
    {
        [regular release];
        [arrayIO release];
        return @"click is wrong!!!";
    }
    
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:@""];
    for (NSString *sub in arrayIO)
    {
        NSArray *s = [sub componentsSeparatedByString:@","];
        if ([s count]>1)
        {
            NSString *io = [s[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *status = [s[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [cmd appendString:[NSString stringWithFormat:@"bit%@=%@,",io,status]];
        }
        
    }
    
    NSString *pattern2 = @"EXIO\\s*=";
    NSRegularExpression *regular2 = [[NSRegularExpression alloc] initWithPattern:pattern2 options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results2 = [regular2 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
    NSString * ioname= @"io set";
    if (results2.count)
    {
        ioname= @"exio set";
    }
    NSString *cmdIO =[NSString stringWithFormat:@"[123]%@(%zd,%@,,)",ioname,[arrayIO count],cmd];
    cmdIO = [cmdIO stringByReplacingOccurrencesOfString:@",,," withString:@""];
    
    [regular release];
    [arrayIO release];
    [cmd release];
    [regular2 release];
    
    return cmdIO;
}


-(void)DblClickOnTableView_AI:(id)sender
{
    NSInteger row = [cmdControll_AIList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrAI.count ? self.searchArrAI : cellArrayAI;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    gainValue = mode.gain;
    nameAIMeas = mode.itemname;
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
    [self btSend:nil];
}

-(void)ClickOnTableView_AI:(id)sender
{

    NSInteger row = [cmdControll_AIList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrAI.count ? self.searchArrAI : cellArrayAI;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    gainValue = mode.gain;
    nameAIMeas = mode.itemname;
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
}

-(void)DblClickOnTableView_Voltage:(id)sender
{
    NSInteger row = [cmdControll_AIList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrVoltage.count ? self.searchArrVoltage : cellArray_Voltage;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    gainValue = mode.gain;
    nameAIMeas = mode.itemname;
    nameAIUnit = @"mV";
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
    [self btSend:nil];
}

-(void)ClickOnTableView_Voltage:(id)sender
{
    
    NSInteger row = [cmdControll_AIList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrVoltage.count ? self.searchArrVoltage : cellArray_Voltage;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    gainValue = mode.gain;
    nameAIMeas = mode.itemname;
    nameAIUnit = @"mV";
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
}


-(void)DblClickOnTableView_Current:(id)sender
{
    NSInteger row = [cmdControl_CurrentList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrCurrent.count ? self.searchArrCurrent : cellArray_Current;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    nameAIMeas = mode.itemname;
    if ([nameAIMeas isEqualToString:@"USB_TARGET_CURRENT"]) {
       gainValue =[NSString stringWithFormat:@"%3f",mode.gain.intValue/coefficient] ;
    }else{
        gainValue =mode.gain;
    }
    
    
    
    nameAIUnit = @"mA";
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
    [self btSend:nil];
}

-(void)ClickOnTableView_Current:(id)sender
{
    
    NSInteger row = [cmdControl_CurrentList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrCurrent.count ? self.searchArrCurrent : cellArray_Current;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    gainValue = mode.gain;
    nameAIMeas = mode.itemname;
    nameAIUnit = @"mA";
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
}

-(void)DblClickOnTableView_Frequency:(id)sender
{
    NSInteger row = [cmdCOntrol_FrequencyList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrFrequency.count ? self.searchArrFrequency : cellArray_Frequence;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    gainValue = mode.gain;
    nameAIMeas = mode.itemname;
    nameAIUnit = @"Hz";
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
    [self btSend:nil];
}

-(void)ClickOnTableView_Frequency:(id)sender
{
    
    NSInteger row = [cmdCOntrol_FrequencyList selectedRow];
    if (row<0) return;
    
    NSArray *array = self.searchArrFrequency.count ? self.searchArrFrequency : cellArray_Frequence;
    HWIOModeAI *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    gainValue = mode.gain;
    nameAIMeas = mode.itemname;
    nameAIUnit = @"Hz";
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
}

-(void)DblClickOnTableView_Relay:(id)sender
{
    NSInteger row = [cmdControll_RelayList selectedRow];
    if (row<0) return;
    NSArray *array = self.searchArrRelay.count ? self.searchArrRelay : cellArrayRelay;
    HWIOModeRelay *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
    [self btSend:nil];
    
}

-(void)ClickOnTableView_Relay:(id)sender
{
    NSInteger row = [cmdControll_RelayList selectedRow];
    if (row<0) return;
    NSArray *array = self.searchArrRelay.count ? self.searchArrRelay : cellArrayRelay;
    HWIOModeRelay *mode =[array objectAtIndex:row];
    NSString *string = mode.fullname;
    NSString *name = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [comboxCmd setStringValue:[self cmdRealyIO:name]];
   
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    
    if([[tableView identifier] isEqualToString:@"leftTableAI"])
    {
        NSInteger count = self.searchArrVoltage.count ? :cellArray_Voltage.count;
        return count;
    }
    else if([[tableView identifier] isEqualToString:@"middleTableAI"])
    {
        NSInteger count = self.searchArrCurrent.count ? :cellArray_Current.count;
        return count;
    }
    else if([[tableView identifier] isEqualToString:@"rightTableAI"])
    {
        NSInteger count = self.searchArrFrequency.count ? :cellArray_Frequence.count;
        return count;
    }
    
    else if ([[tableView identifier] isEqualToString:@"RightTableRelay"])
    {
        NSInteger count = self.searchArrRelay.count ? :cellArrayRelay.count;
        return count;
    }
    else
    {
        return 1;
    }
    
    
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    
    return YES;
}

//- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    NSString *str =[cellArray objectAtIndex:rowIndex];
//    if ([str containsString:@"\t\t\t\t"]) {
//        return [str stringByReplacingOccurrencesOfString:@"\t\t\t\t" withString:@""];
//    }else{
//        return str;
//    }
//
//}

#pragma mark- NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    //NSLog(@"---NSTableViewDelegate--");
    //根据表格列的标识,创建单元视图
    if([[tableView identifier] isEqualToString:@"leftTableAI"])
    {
        NSView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        NSArray *subviews = [view subviews];
        NSTextField *textField = subviews[0];
        //更新单元格的文本
        NSArray *array = self.searchArrVoltage.count ? self.searchArrVoltage : cellArray_Voltage;
        
        HWIOModeAI *mode =[array objectAtIndex:row];
        if ([tableColumn.identifier isEqualToString:@"HWIO_Name"])
        {
            
            textField.stringValue = mode.itemname;
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_Vaule"])
        {
           
            textField.stringValue = mode.iovalue;
        
            
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_GAIN"])
        {//HWIO_GAIN
            textField.stringValue = mode.gain;
        }
        return view;
    }
    else if([[tableView identifier] isEqualToString:@"middleTableAI"])
    {
        NSView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        NSArray *subviews = [view subviews];
        NSTextField *textField = subviews[0];
        //更新单元格的文本
        NSArray *array = self.searchArrCurrent.count ? self.searchArrCurrent : cellArray_Current;
        
        HWIOModeAI *mode =[array objectAtIndex:row];
        if ([tableColumn.identifier isEqualToString:@"HWIO_Name"])
        {
            
            textField.stringValue = mode.itemname;
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_Vaule"])
        {
            
            textField.stringValue = mode.iovalue;
            
            
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_GAIN"])
        {//HWIO_GAIN
            textField.stringValue = mode.gain;
        }
        return view;
    }
    else if([[tableView identifier] isEqualToString:@"rightTableAI"])
    {
        NSView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        NSArray *subviews = [view subviews];
        NSTextField *textField = subviews[0];
        //更新单元格的文本
        NSArray *array = self.searchArrFrequency.count ? self.searchArrFrequency : cellArray_Frequence;
        
        HWIOModeAI *mode =[array objectAtIndex:row];
        if ([tableColumn.identifier isEqualToString:@"HWIO_Name"])
        {
            
            textField.stringValue = mode.itemname;
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_Vaule"])
        {
            
            textField.stringValue = mode.iovalue;
            
            
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_GAIN"])
        {//HWIO_GAIN
            textField.stringValue = mode.gain;
        }
        return view;
    }
    
    else if([[tableView identifier] isEqualToString:@"RightTableRelay"])
    {
        NSView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        NSArray *subviews = [view subviews];
        NSTextField *textField = subviews[0];
        //更新单元格的文本
        NSArray *array = self.searchArrRelay.count ? self.searchArrRelay : cellArrayRelay;
        
        HWIOModeRelay *mode =[array objectAtIndex:row];
        if ([tableColumn.identifier isEqualToString:@"HWIO_Name"])
        {
            
            textField.stringValue = mode.itemname;
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_Vaule"])
        {
            
            textField.stringValue = mode.iovalue;
            
            
        }
        else if([tableColumn.identifier isEqualToString:@"HWIO_DAC2"])
        {//HWIO_GAIN
            textField.stringValue = mode.dac2;
        }
        return view;
    }
    return nil;
}

//-(void)hwioMainWinClose
//{
//    [hwioMainWin close];
//    [self dealloc];
//}

//-(void)sethwioMainWinTitle:(NSString *)title withID:(int)iID
//{
//
//    hwioMainWin.title = title;
//    [m_label setStringValue:[NSString stringWithFormat:@"Xavier %d",iID+1]];
//    hwioMainWin.backgroundColor = [NSColor lightGrayColor];
//
//    //NSLog(@"---%@",[m_label stringValue]);
//}
- (IBAction)btClickBatt:(NSButton *)sender
{
    NSString *value = [m_batt stringValue];
    if (value)
    {
        int ret = [value intValue] *1000;
        NSString *cmd = [NSString stringWithFormat:@"[123]dac set(a,%d)",ret];
        [comboxCmd setStringValue:cmd];
        [self btSend:nil];
    }
    
}

- (IBAction)btClickUSB:(NSButton *)sender
{
    NSString *value = [m_usb stringValue];
    if (value)
    {
        int ret = ([value intValue] *1000-1221)/4;
        NSString *cmd = [NSString stringWithFormat:@"[123]dac set(d,%d)",ret];
        [comboxCmd setStringValue:cmd];
        [self btSend:nil];
    }
    
}
- (IBAction)btClickEload:(NSButton *)sender
{
    NSString *numStr =self.eLoadText.stringValue;
    NSString *mode = [m_eload stringValue];
    if (numStr.length && mode.length){
        NSString *cmd = [NSString stringWithFormat:@"[123]eload set(%@,%ld)",mode,(long)[numStr integerValue]];
        [comboxCmd setStringValue:cmd];
        [self btSend:nil];
    }
    
}
- (IBAction)btClickUSBRect:(NSButton *)sender
{
    
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSTextField *textF=obj.object;
    if (textF == self.searchBtn) {
        NSString *string = [textF stringValue];
        [self searchListWithCharacter:string];
    }
    else if (textF == self.searchBtnRelay)
    {
        NSString *string = [textF stringValue];
        [self searchRelayListWithCharacter:string];
    }
    else if (textF == self.searchCurrent)
    {
        NSString *string = [textF stringValue];
        [self searchListWithCharacterCurrent:string];
    }
    else if (textF == self.searchFrequency)
    {
        NSString *string = [textF stringValue];
        [self searchListWithCharacterFrequency:string];
    }
    
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender NS_AVAILABLE_MAC(10_11){
    self.searchArrAI=nil;
    self.searchArrVoltage=nil;
    [cmdControll_AIList reloadData];
//    self.searchArrRelay=nil;
//    [cmdControll_RelayList reloadData];
    
    self.searchArrCurrent=nil;
    [cmdControl_CurrentList reloadData];
    self.searchArrFrequency=nil;
    [cmdCOntrol_FrequencyList reloadData];
    
}

-(void)searchListWithCharacter:(NSString *)character{
    if (character.length<3) {
        return;
    }
    
    NSMutableArray *mutArr = [NSMutableArray array];
    for (HWIOModeAI *mode in cellArray_Voltage) {
        if ([mode.fullname containsString:character.uppercaseString]) {
            [mutArr addObject:mode];
        }
    }
    self.searchArrVoltage = mutArr;
    [cmdControll_AIList reloadData];
}

-(void)searchListWithCharacterCurrent:(NSString *)character{
    if (character.length<3) {
        return;
    }
    
    NSMutableArray *mutArr = [NSMutableArray array];
    for (HWIOModeAI *mode in cellArray_Current) {
        if ([mode.fullname containsString:character.uppercaseString]) {
            [mutArr addObject:mode];
        }
    }
    self.searchArrCurrent = mutArr;
    [cmdControl_CurrentList reloadData];
}

-(void)searchListWithCharacterFrequency:(NSString *)character{
    if (character.length<3) {
        return;
    }
    
    NSMutableArray *mutArr = [NSMutableArray array];
    for (HWIOModeAI *mode in cellArray_Frequence) {
        if ([mode.fullname containsString:character.uppercaseString]) {
            [mutArr addObject:mode];
        }
    }
    self.searchArrFrequency = mutArr;
    [cmdCOntrol_FrequencyList reloadData];
}

-(void)searchRelayListWithCharacter:(NSString *)character{
    if (character.length<3) {
        return;
    }
    
    NSMutableArray *mutArr = [NSMutableArray array];
    for (HWIOModeRelay *mode in cellArrayRelay) {
        if ([mode.fullname containsString:character.uppercaseString]) {
            [mutArr addObject:mode];
        }
    }
    self.searchArrRelay = mutArr;
    [cmdControll_RelayList reloadData];
}

- (IBAction)btStim:(id)sender
{
   

    [m_btStim setEnabled:NO];
    
    [self STIM_V1];
    
    
}

-(void)STIM_V2{
    
    StimMainVC *stim = [[StimMainVC alloc] initWithWindowNibName:@"StimMainVC"];

    [stim.window orderFront:nil];
    
}
-(void)STIM_V1{
    if (_LuaDebugPanelWin)
    {
        [_LuaDebugPanelWin MainWinDebugPanelClose];
    }
    _LuaDebugPanelWin=[[LuaDebugPanelDebugWinDelegate alloc]initWithWindowNibName:@"LuaDebugPanelDebug"];
    
    [_LuaDebugPanelWin.window orderFront:nil];
}


-(void)setStimButtonEnable:(id)sender
{
    [m_btStim setEnabled:YES];
}



@end
