//
//  LuaDebugPanelDebugWinDelegate.h
//  LuaDebugPanel
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreLib/TestEngine.h>
//#import <CoreLib/ScriptEngine.h>
//#import "tolua++.h"
//#import "MyTreeNode.h"
#import "SKTGraphic.h"
#import "SKTButton.h"
@interface LuaDebugPanelDebugWinDelegate : NSWindowController
{
    
    IBOutlet NSWindow *mWinCtrlPanel;
    IBOutlet NSWindow *mWinDebugPanel;
    IBOutlet NSWindow *GroupConfigWnd;
//    IBOutlet NSMenu *popUpMenu;
//    IBOutlet NSWindow *mWinInstrument;
    IBOutlet NSMenuItem *menuItem ;
    IBOutlet NSMatrix * btChooseMode;
    IBOutlet NSToolbar *m_ToolbarScripts;
    IBOutlet NSTextView *m_DebugOutView;
    IBOutlet NSTextView *m_luaView;
//    IBOutlet NSTextField *m_InstrumentValue;
//    CScriptEngine * RelayEngine;
    //
    SKTButton *rClickedBtn;
    SKTButton *rLastClickedBtn;
    NSMutableArray *selectedButtonsID;
    
    NSMutableDictionary * cmdList ;
    NSMutableString *gainValue;
}
-(IBAction)menu_ShowDebugPanel:(id)sender;
-(IBAction)menu_ShowLuaScriptsPanel:(id)sender;
-(IBAction)btChooseMode:(id)sender;
-(IBAction)btDebugSw:(id)sender;
-(IBAction)btnConfigWnd:(id)sender;
- (IBAction)btIsGroupSelectable:(id)sender; // let switch selectable
- (IBAction)btSwitch:(id)sender;    // change switch state
//-(IBAction)onMenuAddtoGroup:(id)sender;
//-(IBAction)onMenuDeleteFromGroup:(id)sender;

-(NSWindow*)get_DebugWindow;
-(void)MainWinDebugPanelClose;

@end
