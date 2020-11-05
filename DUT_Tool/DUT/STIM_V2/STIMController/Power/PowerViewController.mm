//
//  BaseVC.m
//  STIM_Pannel
//
//  Created by ciwei luo on 2019/10/17.
//  Copyright © 2019 macdev. All rights reserved.
//

#import "PowerViewController.h"
#import "RegexKitLite.h"
#define kNotificationOnLoadProfile            @"On_ReloadProfileByRecMsg"
@interface PowerViewController ()

@property (assign) IBOutlet NSTextField *textF1;
@property (assign) IBOutlet NSTextField *textF2;
@property (assign) IBOutlet NSTextField *textF3;
@property (assign) IBOutlet NSTextField *textF4;
@property (assign) IBOutlet NSTextField *textF5;
@property (assign) IBOutlet NSTextField *textF6;
@property (copy) NSArray *textFeilds;
@property(strong,nonatomic)NSTextField *showingTextF;

@property (assign) IBOutlet NSTextField *measurementLable;
@property (assign) IBOutlet NSButton *s1;
@property (assign) IBOutlet NSButton *s2;
@property (assign) IBOutlet NSButton *s3;
@property (assign) IBOutlet NSButton *s4;
@property (assign) IBOutlet NSButton *s5;

@property (assign) IBOutlet NSButton *btn5v;
@property (assign) IBOutlet NSButton *btn9v;
@property (assign) IBOutlet NSButton *btn12v;
@property (assign) IBOutlet NSButton *btn15v;

@end


@implementation PowerViewController
{
//    CDUTController * pDUT;
    NSString *gainValue;
    NSString *nameAIMeas;
    NSString *nameAIUnit;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DebugLog saveLogToDefaultFileWithContent:[NSString stringWithFormat:@"start---------------%@-----------------log",self.title] fileName:self.title];
    
    self.textFeilds = @[_textF1,_textF2,_textF3,_textF4,_textF5,_textF6];
    self.allSwitchs = @[@[_s1,_s2,_s3,_s4],@[_s5]];
    
    [self.btn5v setEnabled:YES];
    [self.btn9v setEnabled:NO];
    [self.btn12v setEnabled:NO];
    [self.btn15v setEnabled:NO];
    
    // [self setDutController];
}
//-(void)setDutController{
//    pDUT = new CDUTController();
//    pDUT->SetDelegate(self);
//    pDUT->Close();
//    pDUT->Initial([@"tcp://127.0.0.1:7600" UTF8String], [@"tcp://127.0.0.1:7650" UTF8String]);
//}

- (IBAction)btnsClick:(NSButton *)switchBtn {
    
    if (switchBtn.tag == 49) {
        [self setSwitch3BtnImage:switchBtn];
    }else{
        [self setSwitch1BtnImage:switchBtn];
    }
    [CommandHandler generateCommandWithSwitchBtn:switchBtn text:@""];
    //    [self sendCmd:[CommandHandler generateCommandWithSwitchBtn:switchBtn text:@""]];
}


-(void)resetRelays{
    [super resetRelays];
    
    [self.s5 setImage:[NSImage imageNamed:@"switch3_on"]];
    
    [self.btn5v setEnabled:YES];
    [self.btn9v setEnabled:NO];
    [self.btn12v setEnabled:NO];
    [self.btn15v setEnabled:NO];
}

-(void)setSwitch3BtnImage:(NSButton *)switchBtn{
    if (switchBtn.state) {
        [switchBtn setImage:[NSImage imageNamed:@"switch3_off"]];
    }else{
        [switchBtn setImage:[NSImage imageNamed:@"switch3_on"]];
    }
}


- (IBAction)okBtnsClick:(NSButton *)switchBtn {
    NSTextField *textF =nil;
    
    for (NSTextField *textFiled in self.textFeilds) {
        if (textFiled.tag == switchBtn.tag) {
            textF =textFiled;
        }
    }
    NSString *textVaule =textF.stringValue;
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    //    [self sendCmd:[CommandHandler generateCommandWithSwitchBtn:switchBtn text:textVaule]];
    if ([switchBtn.alternateTitle isEqualToString:@"VBUS"]) {
      
        if ([listCsvName valueForKey:@"PowerVbus_TEST"])
        {
            NSString *csvName = [listCsvName valueForKey:@"PowerVbus_TEST"];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
            
            [NSThread sleepForTimeInterval:5];
        }
  
    }else if ([switchBtn.alternateTitle isEqualToString:@"VBUS2"]){
        
        NSString *listCsvKey =@"PowerVbus_5v_TEST";
        if (switchBtn.tag ==10) {
            listCsvKey =@"PowerVbus_5v_TEST";
            [self.btn9v setEnabled:YES];
        }else if (switchBtn.tag ==11){
            listCsvKey =@"PowerVbus_9v_TEST";
            //            [self.btn5v setEnabled:NO];
            [self.btn12v setEnabled:YES];
            //             [self.btn15v setEnabled:YES];
        }else if (switchBtn.tag ==12){
            //            [self.btn9v setEnabled:NO];
            [self.btn15v setEnabled:YES];
            listCsvKey =@"PowerVbus_12v_TEST";
        }else if (switchBtn.tag ==13){
            //            [self.btn9v setEnabled:NO];
            listCsvKey =@"PowerVbus_15v_TEST";
        }
        
        
        if ([listCsvName valueForKey:listCsvKey])
        {
            NSString *csvName = [listCsvName valueForKey:listCsvKey];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
            
            [NSThread sleepForTimeInterval:10];
        }
        
    }else if ([switchBtn.alternateTitle isEqualToString:@"VBATT"]){
        
       // NSString *listCsvKey =@"PowerVbus_5v_TEST";
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stimPanelResetAll" object
                                                                  :nil userInfo
                                                                  :nil] ;

//
//        if ([listCsvName valueForKey:listCsvKey])
//        {
//            NSString *csvName = [listCsvName valueForKey:listCsvKey];
//            NSLog(@"%@",csvName);
//
//            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 csvName,@"Load_Profile_Debug",nil];
//            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
//
//            [NSThread sleepForTimeInterval:10];
//        }
        
    }
        [CommandHandler generateCommandWithSwitchBtn:switchBtn text:textVaule];
    
    
    
    if (switchBtn.tag ==3 || switchBtn.tag==4) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        if (switchBtn.tag == 3) {
            [dic setObject:textVaule forKey:Set_VBATT];
        }else if(switchBtn.tag == 4){
            [dic setObject:textVaule forKey:Set_VBUS];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:StimSetNotification object
                                                                :nil userInfo
                                                                  :dic] ;
    }
    
}


//-(void)sendCmd:(NSString *)command{
//
//    if (!command.length)
//    {
//        return;
//    }
//
//    NSMutableString * cmds = [NSMutableString string];
//    [cmds appendString:command];
//
//    NSArray *arrayCmd = [cmds componentsSeparatedByString:@";"];
//    [DebugLog saveLogToDefaultFileWithContent:[NSString stringWithFormat:@"send command:%@",cmds] fileName:self.title];
//    NSMutableString * cmd = [NSMutableString string];
//    for (NSString *sub_cmd in arrayCmd)
//    {
//       // [self saveLogWithContent:[NSString stringWithFormat:@"send command:%@",sub_cmd]];
//
//         [DebugLog saveLogToDefaultFileWithContent:[NSString stringWithFormat:@"send command:%@",sub_cmd] fileName:self.title];
//        if ([sub_cmd containsString:@"delay"])
//        {
//            NSString *regexStr = @"delay\\s*([0-9]{1,}[.]?[0-9]*)";
//            NSString *matchedStr = [sub_cmd stringByMatching:regexStr capture:1L];
//            if(matchedStr)
//            {
//                [NSThread sleepForTimeInterval:[matchedStr floatValue]];
//            }
//        }
//
//        else if ([sub_cmd containsString:@"["] && [sub_cmd containsString:@"]"])
//        {
//
//
//            [cmd setString:sub_cmd];
//            [cmd appendString:@"\r\n"];
//
//            int ret = pDUT->WriteString([cmd UTF8String]);
//            if (ret<0)//cwdebug
//            {
//                [DebugLog saveLogToDefaultFileWithContent:@"Exit...not connect.." fileName:self.title];
//                NSAlert * alert = [[NSAlert alloc] init];
//                alert.messageText = [NSString stringWithFormat:@"Write DUT failed"];
//                alert.informativeText = @"Replier not response,Please make sure TestEngine is running...";
//                [alert runModal];
//                [alert release];
//                return;
//            }
//            [NSThread sleepForTimeInterval:0.01];
//            NSLog(@"---cmd: %@",cmd);
//
//
//        }
//        else
//        {
//            //NSLog(@"-->sub_cmd: %@",sub_cmd);
//
//            //            NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
//            //            [dicCmd setValue:sub_cmd forKey:kSendDUTCmd];
//            //            NSLog(@"==diags=>: %@",dicCmd);
//            //            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
//            //                                                                      :nil userInfo
//            //                                                                      :dicCmd] ;
//            //            [NSThread sleepForTimeInterval:0.01];
//        }
//    }
//}
-(void)dealloc{
    [super dealloc];
    NSLog(@"%s",__func__);
    
//    pDUT->Close();
//    
//    if (pDUT)
//    {
//        delete pDUT;
//        pDUT = nullptr;
//    }
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
    //    self.resultString = str1;
    
    [DebugLog saveLogToDefaultFileWithContent:[NSString stringWithFormat:@"response:%@",str1] fileName:self.title];
    
    NSLog(@"str1:%@",str1);
    [self performSelectorOnMainThread:@selector(OnLog:)  withObject:str1 waitUntilDone:NO];
    [str release];
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



//-(void)OnLog:(NSString *)str
//{
//    if (!str) return;
//
//    //  NSMutableString * pstr = [[txtBuffer textStorage] mutableString];
//    //    if ([str containsString:@"\n"])
//    //    {
//    //        [pstr appendFormat:@"%@",str];
//    //    }
//    //    else
//    //    {
//    //        [pstr appendFormat:@"%@\n",str];
//    //    }
//    //  NSMutableString *mutString= [NSMutableString stringWithString:str];
//    if (([str containsString:@"ACK"]))//[str containsString:@"[444555666]"]&&
//    {
//        //  [m_measurment setStringValue:@""];
//        NSString *regexStr = @"ACK\\s*\\(\\s*([+-]?[0-9]{1,}[.]?[0-9]*)";
//        NSString *matchedStr = [str stringByMatching:regexStr capture:1L];
//        if(matchedStr)
//        {
//
//            NSString *strItem = @"";
//            if ([matchedStr doubleValue]>5)
//            {
//                strItem = [NSString stringWithFormat:@"%@:%f %@",nameAIMeas, [matchedStr doubleValue]*[gainValue doubleValue],nameAIUnit];
//
//            }
//            else
//            {
//                strItem = [NSString stringWithFormat:@"%@:%f %@",nameAIMeas, [matchedStr doubleValue],nameAIUnit];
//            }
//
//
//            self.measurementLable.stringValue=strItem;
//
//        }
//        else
//        {
//
//            [self.measurementLable setStringValue:[NSString stringWithFormat:@"%@:NULL %@",nameAIMeas,nameAIUnit]];
//
//        }
//
//    }
//    else if ([str containsString:@"[555666777]"]&&([str containsString:@"ACK"]))
//    {
//        NSString *regexStr = @"ACK\\s*\\(\\s*([+-]?[0-9]{1,}[.]?[0-9]*)";
//        NSString *matchedStr = [str stringByMatching:regexStr capture:1L];
//        NSString *strValue = [NSString stringWithFormat:@"%f",[matchedStr doubleValue]*[gainValue doubleValue]];
//        self.measurementLable.stringValue=[NSString stringWithFormat:@"Measure Result:%@",strValue];
//        //        [mutString appendString:[NSString stringWithFormat:@"measurementValue2:%@",matchedStr]];
//
//        //        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
//        //        [dicCmd setValue:matchedStr forKey:@"measurement"];
//        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMeasurementValue" object
//        //                                                                  :nil userInfo
//        //                                                                  :dicCmd] ;
//
//    }
//    else if ([str containsString:@"[777999888]"]&&([str containsString:@"ACK"]))
//    {
//
//    }
//    // NSRange range = NSMakeRange([pstr length]-1,0);
//    // [txtBuffer scrollRangeToVisible:range];
//    // [self.showingLabel setStringValue:mutString];
//
//}



@end
