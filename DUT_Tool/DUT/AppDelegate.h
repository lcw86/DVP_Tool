//
//  AppDelegate.h
//  DUT
//
//  Created by Ryan on 11/2/15.
//  Copyright © 2015 ___Intelligent Automation___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarView.h>
#import "FunViewController.h"
#import "ConfigurationWndDelegate.h"


#define kProjectName        @"project_name"
#define kSoltsNumber         @"slots_number"
#define kFuncsNumber        @"funcs_number"

#define kRequest           @"Request"
#define kSubscribe        @"Subscribe"
//NSWindowController <NSToolbarDelegate, MMTabBarViewDelegate, NSMenuDelegate>
@interface AppDelegate : NSWindowController <NSToolbarDelegate,MMTabBarViewDelegate,NSMenuDelegate,NSApplicationDelegate>
{
//@interface AppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet MMTabBarView           *tabBar;
    IBOutlet NSTabView              *tabView;
    IBOutlet NSTabView              *tabViewSequencerTool;
    IBOutlet NSTabView              *tabViewXaVierTool;
    
    NSMutableArray * arrUnit;
    
    IBOutlet NSWindow * winConfiguration;
    IBOutlet NSWindow * winMain;
    IBOutlet ConfigurationWndDelegate *configDelegete;
    
    IBOutlet NSWindow *testWin;
    
    int m_Slots;
    int m_Funcs;
    
    NSMutableDictionary * m_dicDefine;
    NSMutableDictionary * m_dicConfiguration;
    NSMutableArray * arrFuncView;
    
    //sequencer tool
    int m_Slots_seq;
    NSMutableDictionary * dicConfig_seq;
    int port_seq;
    
    //Xaviewr Tool
    NSMutableDictionary * m_dicDefine_Xavier;
    NSMutableDictionary * m_dicConfiguration_Xavier;
    
}

-(void)SaveConfiguration:(NSMutableDictionary *)dic;

@end

