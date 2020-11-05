//
//  readGWin.m
//  DUT_Tool
//
//  Created by RyanGao on 2019/8/29.
//  Copyright © 2019  Automation___. All rights reserved.
//

#import "readGWin.h"
#import "GraphicHeader.h"
//#import "RegexKitLite.h"
#define kNotificationOnLoadProfile            @"On_ReloadProfileByRecMsg"
@interface readGWin ()

@end

@implementation readGWin

- (void)windowDidLoad {
    [super windowDidLoad];
    [GGWin setLevel:kCGFloatingWindowLevel];

}
-(void)awakeFromNib
{
    [chargingTxtWin setUsesFindBar:YES];
    alertTextField.textColor = [NSColor blueColor];
    GGWin.backgroundColor = [NSColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                     :@selector(getGGValue:) name
                                                     :kNotificationGGValue object
                                                     :nil] ;
    
}



- (IBAction)OnReadGG:(id)sender
{
    
    NSString *filecmd = [[NSBundle mainBundle] pathForResource:@"StimCmdList" ofType:@"plist"];
    NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
    [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:filecmd]];
    if ([[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"READ_GG"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"READ_GG"] forKey:kSendCmd];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
    }
    
    
    [cmdList release];
}

- (IBAction)OnStopCharging:(id)sender
{
    alertTextField.textColor = [NSColor blueColor];
    [alertTextField setStringValue:@"Alert!!!\r\nBattery is Stop Charging!!!"];
    
    NSString *filecmd = [[NSBundle mainBundle] pathForResource:@"StimCmdList" ofType:@"plist"];
    NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
    [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:filecmd]];
    if ([[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"STOP_CHG"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"STOP_CHG"] forKey:kSendCmd];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
    }
    [cmdList release];
}

- (IBAction)OnStartCharging:(id)sender
{
    alertTextField.textColor = [NSColor redColor];
    [alertTextField setStringValue:@"Alert!!!\r\nBattery is Start Charging!!!"];
    
    NSString *filecmd = [[NSBundle mainBundle] pathForResource:@"StimCmdList" ofType:@"plist"];
    NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
    [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:filecmd]];
    if ([[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"START_CHG"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"START_CHG"] forKey:kSendCmd];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
    }
    [cmdList release];
    
    
}

- (IBAction)OnStopClose:(id)sender
{
    [self OnStopCharging:sender];
    [GGWin close];
}

- (IBAction)ClearTxt:(id)sender
{
    [chargingTxtWin setString:@""];
}

- (IBAction)OnEnterDiags:(id)sender
{
//    NSString *filecmd = [[NSBundle mainBundle] pathForResource:@"StimCmdList" ofType:@"plist"];
//    NSMutableDictionary *cmdList = [[NSMutableDictionary alloc]init];
//    [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:filecmd]];
//    if ([[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"ENTER_DIAGS"])
//    {
//        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
//        [dicCmd setValue:[[cmdList valueForKey:@"REAL_BATT_CHG"] valueForKey:@"ENTER_DIAGS"] forKey:kSendCmd];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
//                                                                  :nil userInfo
//                                                                  :dicCmd] ;
//    }
//    [cmdList release];
    
    //[self performSelector:@selector(sendDiagsCmd:) withObject:nil afterDelay:8.0f];
    
    [self sendDiagsCmd:nil];
    
}

-(void)sendDiagsCmd:(id)sender
{
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    if ([listCsvName valueForKey:@"EnterDiags_TEST"])
    {
        // [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"EnterDiags_TEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
}

-(void)sendDiagsCmd1:(id)sender{
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
}

-(void)GGWinClose
{
    [GGWin close];
    [super dealloc];
}

-(void)dealloc
{
    [super dealloc];
}

-(void)getGGValue:(NSNotification *)nf
{
    NSDictionary *dic = [nf userInfo];
    NSString *val = [dic objectForKey:@"KEY_GG"];
    [self OnLog:val];
    
}

-(void)OnLog:(NSString *)str
{
    if (!str) return;
    NSMutableString * pstr = [[chargingTxtWin textStorage] mutableString];
    if ([str containsString:@"\n"])
    {
        [pstr appendFormat:@"%@",str];
    }
    else
    {
        [pstr appendFormat:@"%@\n",str];
    }
    NSRange range = NSMakeRange([pstr length]-1,0);
    [chargingTxtWin scrollRangeToVisible:range];
}



@end
