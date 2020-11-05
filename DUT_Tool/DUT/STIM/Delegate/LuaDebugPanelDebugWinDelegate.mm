//
//  LuaDebugPanelDebugWinDelegate.m
//  LuaDebugPanel
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#import "LuaDebugPanelDebugWinDelegate.h"
//#import <CoreLib/Common.h>
//#include <CoreLib/PathManager.h>
#import "AAPLSimpleNodeData.h"
#import "AAPLImageAndTextCell.h"

//#import "DbgMsg.h"
#import "GraphicHeader.h"

#include "CLuaDebugPanel.h"
#include "RegexKitLite.h"


#define kNotificationDebugPanelLog  @"debugPanel_log"        //debug panel message log




CLuaDebugPanel    *LuaDebugPanel        ;

#pragma mark -

// It is best to #define strings to avoid making typing errors
#define LOCAL_REORDER_PASTEBOARD_TYPE   @"MyCustomOutlineViewPboardType"
#define COLUMNID_IS_EXPANDABLE          @"IsExpandableColumn"
#define COLUMNID_NAME                   @"NameColumn"
#define COLUMNID_NODE_KIND              @"NodeKindColumn"
#define COLUMID_IS_SELECTABLE           @"IsSelectableColumn"

#define NAME_KEY                        @"Name"
#define CHILDREN_KEY                    @"Children"
#define kNotificationDebugPanelLog      @"debugPanel_log"        //debug panel message log

#pragma mark -


@implementation LuaDebugPanelDebugWinDelegate
- (id)init
{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(handleNotification:)
//                                                     name:kNotificationAttachMenu
//                                                   object:nil] ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                         :@selector(DebugButton:) name
                                                         :@"DoDebugButton" object
                                                         :nil] ;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnDebugView:) name:kNotificationDebugPanelLog object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                         :@selector(addBtToGoup:) name
                                                         :@"addButtonToGroup" object
                                                         :nil] ;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                         :@selector(getMeasValue:) name
                                                         :@"getMeasurementValue" object
                                                         :nil] ;
      
        selectedButtonsID = [[NSMutableArray alloc] init];
        rClickedBtn = nil;
        rLastClickedBtn = nil;
        gainValue = [[NSMutableString alloc] initWithString:@"1"];
        
        
        LuaDebugPanel=new CLuaDebugPanel();
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGraphicCilck:) name:GraphicCilckNotification object:nil];
        
        NSString *filecmd = [[NSBundle mainBundle] pathForResource:@"StimCmdList" ofType:@"plist"];
        cmdList = [[NSMutableDictionary alloc]init];
        [cmdList removeAllObjects];
        [cmdList setDictionary:[NSDictionary dictionaryWithContentsOfFile:filecmd]];
        
        if ([[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"FIXTURERESET"])
        {
            NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
            [dicCmd setValue:[[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"FIXTURERESET"] forKey:kSendCmd];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                      :nil userInfo
                                                                      :dicCmd] ;
        }
        
    }
    return self;
}

-(void)awakeFromNib
{
//    [m_luaView setAutomaticQuoteSubstitutionEnabled:NO];
//    [mWinCtrlPanel setShowsToolbarButton:YES];
    //LuaDebugPanel->setWinDelPointer(self);
    mWinDebugPanel.backgroundColor = [NSColor whiteColor];
    
}


- (void)onGraphicCilck:(NSNotification *)nf
{
    char cmd[255];
    NSDictionary * dic = [nf userInfo];
    NSString *sPrefix = [dic objectForKey:GraphicPrefixNotification];
    int nidentifier = [[dic objectForKey:GraphicIdentifierNotification] intValue];
    int nstate = [[dic objectForKey:GraphicStateNotification] intValue];
    NSString *strButtonBlindTextfile = [dic objectForKey:GraphicButtonBlindTextFileNotification];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationGetUIInsValue object:nil];
    //    NSString *strCount = [CTestContext::m_dicGlobal objectForKey:@"DebugPanelSelectCount"];
    //    CScriptEngine * se = (CScriptEngine *)[pTestEngine GetScripEngine:strCount.intValue];
    sprintf(cmd, "luadebugpanel.onClickGraphic(\"%s\",%d,%d,\"%s\")",
            [sPrefix cStringUsingEncoding:NSASCIIStringEncoding],
            nidentifier,
            nstate,
            [strButtonBlindTextfile cStringUsingEncoding:NSASCIIStringEncoding]
            );
    
    NSLog(@"===click: %s",cmd);
    if ([[NSString stringWithUTF8String:cmd] containsString:@"ORION_IO"])
    {
        return;
    }
    
    
    NSString * sendCmd = [self graphicToCmd:sPrefix withIdentifier:nidentifier withState:nstate withTextContent:strButtonBlindTextfile];
     NSLog(@"===sendCmd: %@",sendCmd);
    NSString *mutex_identifier = nil;
    if (sendCmd)
    {
        NSArray *cmdArray = [sendCmd componentsSeparatedByString:@"#"];
        if ([cmdArray count]>0)
        {
            sendCmd = cmdArray[0];
        }
        if ([cmdArray count]>1)
        {
            mutex_identifier = cmdArray[1];
        }
        
    }
    
    //NSLog(@"======>send cmd: %@    mutex_identifier: %@",sendCmd,mutex_identifier);
    if (!sendCmd)
    {
//        NSAlert * alert = [[NSAlert alloc] init];
//        alert.messageText = @"Error!!!";
//        alert.informativeText = @"StimCmdList.plist did not find command,please add command in it.";
//        [alert runModal];
//        [alert release];
//        return;
    }
    if (nstate >0)
    {
        nstate =0;
    }
    else
    {
        nstate = 1;
    }
    //NSLog(@"===>nstate %d",nstate);
    LuaDebugPanel->SetGraphicState(const_cast<char*>([sPrefix cStringUsingEncoding:NSASCIIStringEncoding]), [[dic objectForKey:GraphicIdentifierNotification] unsignedLongValue], nstate);
    
    if (mutex_identifier)  // for mutex IO relay
    {
      
        NSString *regexString = @"mutex\\s*:\\s*\(.*)";
        NSString *matchedString = [mutex_identifier stringByMatching:regexString capture:1L];
        
        if (matchedString)
        {
            NSArray *arrayS = [matchedString componentsSeparatedByString:@","];
            for (NSString *subS in arrayS)
            {
                NSArray *subArrayS = [subS componentsSeparatedByString:@"="];
                if ([subArrayS count]>1)
                {
                    NSString *nidentifier_sub = [subArrayS[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSString *nstate_sub = [subArrayS[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    //NSLog(@"===>nstate_sub %@",nstate_sub);
                    LuaDebugPanel->SetGraphicState(const_cast<char*>([sPrefix cStringUsingEncoding:NSASCIIStringEncoding]),[nidentifier_sub integerValue], [nstate_sub intValue]);
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"krefreshTab" object:nil];
                    
                }
                
                
            }
        }
        else
        {
            regexString = @"gain\\s*=\\s*([+-]?[0-9]{1,}[.]?[0-9]*)([+-]?[0-9]{1,}[.]?[0-9]*)";
            matchedString = [mutex_identifier stringByMatching:regexString capture:1L];
            if (matchedString)
            {
                NSLog(@"=======gainValue = matchedString   :%@",matchedString);
                [gainValue setString:matchedString];
            }
            else
            {
                [gainValue setString:@"1"]; //default setting is 1
            }
            
        }
        

        
    }
    
    NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
    [dicCmd setValue:sendCmd forKey:kSendCmd];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                              :nil userInfo
                                                              :dicCmd] ;
    
}

-(NSString *)graphicToCmd:(NSString *) sPrefix withIdentifier:(int)nidentifier withState:(int)nState withTextContent:(NSString *)buttonText
{
    NSString *cmdSend= nil;
    NSString * identifier = [NSString stringWithFormat:@"%04d",nidentifier];
    
    if ([sPrefix isEqualToString:@"BUTTON"])
    {
        if ([[cmdList valueForKey:@"BUTTON"] valueForKey:identifier])
        {
            if (buttonText &&[buttonText isNotEqualTo:@"N/A"])
            {
                NSString *str = [[cmdList valueForKey:@"BUTTON"] valueForKey:identifier];
                buttonText = [buttonText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                cmdSend = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:buttonText];
            }
            
            
        }
        
    }
    else if ([sPrefix isEqualToString:@"MEAS"])
    {
        if ([[cmdList valueForKey:@"MEAS"] valueForKey:identifier])
        {
            NSString *str = [[cmdList valueForKey:@"MEAS"] valueForKey:identifier];
            cmdSend = str;
        }
        
    }
    
    else if ([sPrefix isEqualToString:@"PDMBUTTON"])
    {
        if ([[cmdList valueForKey:@"PDMBUTTON"] valueForKey:identifier])
        {
            NSString *str = [[cmdList valueForKey:@"PDMBUTTON"] valueForKey:identifier];
            cmdSend = str;
        }
        
    }
    
    else if ([sPrefix isEqualToString:@"VBUS"])
    {
        if ([[cmdList valueForKey:@"VBUS"] valueForKey:identifier])
        {
            if (buttonText &&[buttonText isNotEqualTo:@"N/A"])
            {
                NSString *str = [[cmdList valueForKey:@"VBUS"] valueForKey:identifier];
                buttonText = [buttonText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([buttonText intValue]>16000)
                {
                    buttonText = @"16000";
                }
                if ([buttonText intValue]<1221)
                {
                    buttonText = @"1221";
                }
                
                //int ret = ([buttonText intValue] -1221)/4;
                int ret = (5000 -1221)/4;
                cmdSend = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:[NSString stringWithFormat:@"%d",ret]];
            }
            
            
        }
        
    }
    else if ([sPrefix isEqualToString:@"VBUS2"])
    {
        if ([[cmdList valueForKey:@"VBUS2"] valueForKey:identifier])
        {
            if (buttonText &&[buttonText isNotEqualTo:@"N/A"])
            {
                NSString *str = [[cmdList valueForKey:@"VBUS2"] valueForKey:identifier];
                buttonText = [buttonText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([buttonText intValue]>3000)
                {
                    buttonText = @"3000";
                }
                if ([buttonText intValue]<0)
                {
                    buttonText = @"0";
                }
//                int volt = 5000;
//                if ([identifier isEqualToString:@"0001"])
//                {
//                    volt = 5000;
//                    int ret = (volt -1221)/4;
//                    //cmdSend = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:[NSString stringWithFormat:@"%d",ret]];
//                }
//                else if ([identifier isEqualToString:@"0002"])
//                {
//                    volt = 9000;
//                }
//                 else if ([identifier isEqualToString:@"0003"])
//                {
//                    volt = 12000;
//                }
//                else if ([identifier isEqualToString:@"0004"])
//                {
//                    volt = 15000;
//                }
                
                
                cmdSend = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:[NSString stringWithFormat:@"%@",buttonText]];
            }
            
            
        }
        
    }
    
    else if ([sPrefix isEqualToString:@"VBATT"])
    {
        if ([[cmdList valueForKey:@"VBATT"] valueForKey:identifier])
        {
            if (buttonText &&[buttonText isNotEqualTo:@"N/A"])
            {
                NSString *str = [[cmdList valueForKey:@"VBATT"] valueForKey:identifier];
                buttonText = [buttonText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSLog(@"---VBATT : %@",buttonText);
                cmdSend = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:buttonText];
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"krefreshTab" object:nil];
            }
        }
        
    }
    
    else if ([sPrefix isEqualToString:@"ELOAD"])
    {
        if ([[cmdList valueForKey:@"ELOAD"] valueForKey:identifier])
        {
            if (buttonText &&[buttonText isNotEqualTo:@"N/A"])
            {
                NSString *str = [[cmdList valueForKey:@"ELOAD"] valueForKey:identifier];
                buttonText = [buttonText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([buttonText isNotEqualTo:@"0"])
                {
                    cmdSend = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:buttonText];
                }
                else
                {
                    str = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:buttonText];
                    cmdSend = [str stringByReplacingOccurrencesOfString:@"eload enable" withString:@"eload disable"];
                }
                
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"krefreshTab" object:nil];
            }
        }
        
    }
    
    else if([sPrefix isEqualToString:@"IO"])
    {
        NSString *subKey =@"";
        if (nState >0)
        {
            subKey = [NSString stringWithFormat:@"%@_DISCONNECT",identifier];
        }
        else
        {
           subKey = [NSString stringWithFormat:@"%@_CONNECT",identifier];
        }
        
        if ([[cmdList valueForKey:@"IO"] valueForKey:subKey])
        {
            cmdSend = [[cmdList valueForKey:@"IO"] valueForKey:subKey];
        }
        
    }
    else if([sPrefix isEqualToString:@"BIT"])
    {
        NSString *subKey =@"";
        if (nState >0)
        {
            subKey = [NSString stringWithFormat:@"%@_DISCONNECT",identifier];
        }
        else
        {
            subKey = [NSString stringWithFormat:@"%@_CONNECT",identifier];
        }
        
        if ([[cmdList valueForKey:@"IO"] valueForKey:subKey])
        {
            cmdSend = [[cmdList valueForKey:@"IO"] valueForKey:subKey];
        }
        
    }
     else if([sPrefix isEqualToString:@"EXIO"])
     {
         NSString *subKey =@"";
         if (nState >0)
         {
             subKey = [NSString stringWithFormat:@"%@_DISCONNECT",identifier];
         }
         else
         {
             subKey = [NSString stringWithFormat:@"%@_CONNECT",identifier];
         }
         if ([[cmdList valueForKey:@"EXIO"] valueForKey:subKey])
         {
             cmdSend = [[cmdList valueForKey:@"EXIO"] valueForKey:subKey];
         }
         
     }
     else if([sPrefix isEqualToString:@"LED"])
     {
         NSString *subKey =@"";
         if (nState >0)
         {
             subKey = [NSString stringWithFormat:@"%@_DISCONNECT",identifier];
         }
         else
         {
             subKey = [NSString stringWithFormat:@"%@_CONNECT",identifier];
         }
         if ([[cmdList valueForKey:@"LED"] valueForKey:subKey])
         {
             cmdSend = [[cmdList valueForKey:@"LED"] valueForKey:subKey];
         }
         
         
     }
     else if ([sPrefix isEqualToString:@"ORION_SET"])
     {
         if ([[cmdList valueForKey:@"ORION_SET"] valueForKey:identifier])
         {
             if (buttonText &&[buttonText isNotEqualTo:@"N/A"])
             {
                 NSString *str = [[cmdList valueForKey:@"ORION_SET"] valueForKey:identifier];
                 buttonText = [buttonText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                 if ([buttonText isNotEqualTo:@"0"])
                 {
                     cmdSend = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:buttonText];
                 }
                 else
                 {
                     str = [str stringByReplacingOccurrencesOfString:@"xxxx" withString:buttonText];
                     cmdSend = [str stringByReplacingOccurrencesOfString:@"eload enable" withString:@"eload disable"];
                 }
                 
                [[NSNotificationCenter defaultCenter]postNotificationName:@"krefreshTab" object:nil];
             }
         }
         
     }
    
     else if ([sPrefix isEqualToString:@"ORION_BTN"])
     {
         if ([[cmdList valueForKey:@"ORION_BTN"] valueForKey:identifier])
         {
             if ([identifier isEqualToString:@"0001"])
             {
                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_IO"), 1, 1);
                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_IO"), 2, 1);
                 
//                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_BTN"), 2, 0);
//                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_BTN"), 3, 0);
             }
             else if ([identifier isEqualToString:@"0002"])
             {
                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_IO"), 1, 0);
                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_IO"), 2, 1);
             }
             else if ([identifier isEqualToString:@"0003"])
             {
                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_IO"), 1, 0);
                 LuaDebugPanel->SetGraphicState(const_cast<char*>("ORION_IO"), 2, 0);
             }
             NSString *str = [[cmdList valueForKey:@"ORION_BTN"] valueForKey:identifier];
             cmdSend = str;
         }
     }
    
    else
    {
        
    }
    
    return cmdSend;
}


- (IBAction)showOrHideDbgMsg:(id)sender {
    
    // We always show the same tool palette panel. Its controller doesn't get deallocated when the user closes it.
//    [[DbgMsg DbgMsgWin] showOrHideWindow];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KsetStimButtonEnable" object
                                                              :nil userInfo
                                                              :nil] ;
    [mWinDebugPanel close];
    
}

-(IBAction)btnConfigWnd:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showgroupconfigwindow" object:nil];
    
}

// **********//



- (IBAction)btIsGroupSelectable:(id)sender {
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:selectedButtonsID,@"button", nil];
    NSInteger state = [sender state];
    if (state == 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"clearButtonSelectColor" object:nil userInfo:dic];
        [selectedButtonsID removeAllObjects];
    }else if (state == 1){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"selectedButtonColor" object:nil userInfo:dic];

    }
}

-(void)addBtToGoup:(NSNotification *)nf
{
    NSDictionary *dic = [nf userInfo];
    rClickedBtn = [dic objectForKey:@"button"];
    if (![self isSelectedOfButtonID:[rClickedBtn identifier]]) {
        [selectedButtonsID addObject:[NSNumber numberWithInteger:[rClickedBtn identifier]]];
    }
}

-(void)getMeasValue:(NSNotification *)nf
{
    NSLog(@"======gain: %@",gainValue);//measurement
    NSDictionary *dic = [nf userInfo];
    NSString *val = [dic objectForKey:@"measurement"];
    NSString *strValue = [NSString stringWithFormat:@"%f",[val doubleValue]*[gainValue doubleValue]];
    
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = @"Measure Result:";
    alert.informativeText = strValue;
    [alert runModal];
    [alert release];
    
}

- (IBAction)btSwitch:(id)sender {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(1-[sender state]),@"state",selectedButtonsID,@"button", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"buttongroupswitch" object:nil userInfo:dic];
}

-(BOOL)isSelectedOfButtonID:(NSInteger) btID
{
    BOOL isSelected = false;
    for (int i = 0; i < selectedButtonsID.count; i++) {
        if ([selectedButtonsID[i] integerValue] == btID) {
            isSelected = true;
            break;
        }
    }
    return isSelected;
}

// *************//


//-(void)onRightClick:(NSNotification*)nf
//{
//    NSDictionary *dic = [nf userInfo];
//    NSView *view = [dic objectForKey:@"view"];
//    [NSMenu popUpContextMenu:popUpMenu withEvent:[NSApp currentEvent] forView:view];
//}

//-(IBAction)onMenuAddtoGroup:(id)sender
//{
//    
//}
//
//-(IBAction)onMenuDeleteFromGroup:(id)sender
//{
//    
//}

-(void)DebugButton:(NSNotification *)nf
{
//    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
//    NSDictionary *dic = [nf userInfo];
//    int uid = [[dic valueForKey:@"uid"]intValue];
//    NSString *doPath = [dic valueForKey:@"msg"];
    
    
//    RelayEngine = (CScriptEngine *)[pTestEngine GetScripEngine:uid];
//    int err = RelayEngine->DoFile([doPath UTF8String]);
//    if (err) {
//        NSRunAlertPanel(@"Load Device", @"Failed to load %@,with message :\r\n%s", @"OK", nil, nil,[[bundle bundlePath] lastPathComponent],lua_tostring(RelayEngine->m_pLuaState, -1));
//       }
}

-(void)OnDebugView:(NSNotification *)nf
{
    [self performSelectorOnMainThread:@selector(DebugViewOut:) withObject:[nf userInfo] waitUntilDone:YES];
}
-(void)DebugViewOut:(id)sender
{
    NSString * msg = [sender valueForKey:@"msg"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    NSUInteger length = 0;
    NSAttributedString *theString;
    NSRange theRange;
    NSString * str = [NSString stringWithFormat:@"Receive: %@\r",msg];
    theString = [[NSAttributedString alloc] initWithString:str];
    [[m_DebugOutView textStorage] appendAttributedString: theString];
    length = [[m_DebugOutView textStorage] length];
    theRange = NSMakeRange(length, 0);
    [m_DebugOutView scrollRangeToVisible:theRange];
    [dateFormatter release];
    [theString release];
}

-(IBAction)menu_ShowDebugPanel:(id)sender
{
    [mWinDebugPanel center];
    [mWinDebugPanel makeKeyAndOrderFront:sender];
}
-(IBAction)menu_ShowLuaScriptsPanel:(id)sender
{
    [mWinCtrlPanel center];
    [mWinCtrlPanel makeKeyAndOrderFront:sender];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
    if (selectedButtonsID)
    {
        [selectedButtonsID release];
    }
    
    if (LuaDebugPanel) {
        delete LuaDebugPanel;
    }
    
    [cmdList removeAllObjects];
    if (cmdList)
    {
        [cmdList release];
    }
    if (gainValue) {
        [gainValue release];
    }
    [super dealloc];
}
-(IBAction)btChooseMode:(id)sender
{
//    [CTestContext::m_dicGlobal setValue:[NSString stringWithFormat:@"%ld",(long)[sender selectedColumn]]forKey:@"DebugPanelSelectCount"];
}

-(IBAction)btDebugSw:(id)sender
{
    if ([[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"FIXTURERESET"])
    {
        NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
        [dicCmd setValue:[[cmdList valueForKey:@"RESET_ALL"] valueForKey:@"FIXTURERESET"] forKey:kSendCmd];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStimCmd object
                                                                  :nil userInfo
                                                                  :dicCmd] ;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kAddDebugViewWindow" object:nil];
    
   // NSBundle * bundle = [NSBundle bundleForClass:[self class]];
   // NSString *sendCmd = [NSString stringWithFormat:@"luadebugpanel.%@()",[sender identifier] ];
//    RelayEngine = (CScriptEngine *)[pTestEngine GetScripEngine:[btChooseMode selectedColumn]];
//    int err = RelayEngine->DoString([sendCmd UTF8String]);
//    if (err)
//    {
//        NSRunAlertPanel(@"Load Device", @"Failed to load %@,with message :\r\n%s", @"OK", nil, nil,[[bundle bundlePath] lastPathComponent],lua_tostring(RelayEngine->m_pLuaState, -1));
//    }
}


#pragma mark--handle notifiction
-(void)handleNotification:(NSNotification*)nf
{
//    NSDictionary *userInfo = [nf userInfo] ;
//    if ([nf.name isEqualToString:kNotificationAttachMenu])
//    {
//        NSMenu * instrMenu = [userInfo objectForKey:@"menus"];
//        [instrMenu addItem:menuItem];
//    }
    return ;
}

-(NSWindow*)get_DebugWindow
{
    return mWinDebugPanel;
}


-(void)MainWinDebugPanelClose
{
    [mWinDebugPanel close];
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
    [super dealloc];
    NSLog(@"-dealloc -2 ---LuaDebugPanelDebugWinDelegate.h--");
}



@end
