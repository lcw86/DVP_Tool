//
//  AppDelegate.m
//  DUT
//
//  Created by Ryan on 11/2/15.
//  Copyright © 2015  Automation___. All rights reserved.
//

#import "AppDelegate.h"
#import "unitTool.h"
#import "Xavier/XavierFunVC.h"
#import "RegexKitLite.h"
//#import "UnitViewController.h"
#import <MMTabBarView/UnitFakeModel.h>
#include "ConfigurationWndDelegate.h"
#include <stdlib.h>



#define kPath  @"path_seq"
#define kKey @"key_seq"
#define kSlots @"slots_seq"

//int funcsPort[] = {7970,6990,7000,6800,7300,7500};
//int funcsPort[] = {6800,6850,7600,7650,6100,6150};
//int funcsPort[] = {6800,6850,7600,7650,6900,6950};
int funcsPort[] = {6800,6850,6900,6950,7000,7050};
int funcsPortXaview[] = {7600,7650};
/*
 "UART_PORT":6800,
 "UART_PUB":6850,
 
 "ARM_PORT":7600,
 "ARM_PUB":7650,
 
 "TEST_ENGINE_PORT": 6100,
 "TEST_ENGINE_PUB": 6150,
 
 */


@interface AppDelegate ()

//@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    for (NSViewController * v in arrUnit)
    {
        [v release];
    }
    [arrUnit release];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark ---- tab bar config ----
-(int)LoadDefine
{
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [bundle pathForResource:@"define" ofType:@"plist"];
    m_dicDefine = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    if (!m_dicDefine) {
        [m_dicDefine setValue:@"utils" forKey:kProjectName];
        [m_dicDefine setValue:@"4" forKey:kSoltsNumber];
        [m_dicDefine setValue:@"3" forKey:kFuncsNumber];
    }
    return 0;
}

-(void)awakeFromNib
{
    NSLog(@"ulimit -n 8192");
    system("/usr/bin/ulimit -n 8192");

    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/ulimit"
                              arguments:[NSArray arrayWithObjects:@"-n",@"8192", nil]]
     waitUntilExit];
    
    [self LoadDefine];
    [self LoadConfiguration];
    [self LoadXavierDefine];
    [self LoadXavierConfiguration];
    
    arrUnit = [NSMutableArray new];
    [tabBar setStyleNamed:@"Safari"];
    [tabBar setOnlyShowCloseOnHover:YES];
    [tabBar setCanCloseOnlyTab:YES];
    [tabBar setDisableTabClose:YES];
    [tabBar setAllowsBackgroundTabClosing:YES];
    [tabBar setHideForSingleTab:YES];
    [tabBar setShowAddTabButton:YES];
    [tabBar setSizeButtonsToFit:NO];
    
    [tabBar setTearOffStyle:MMTabBarTearOffAlphaWindow];
    [tabBar setUseOverflowMenu:YES];
    [tabBar setAutomaticallyAnimates:YES];
    [tabBar setAllowsScrubbing:YES];
    [tabBar setButtonOptimumWidth:120];
    [self CreateUnit:[[m_dicDefine valueForKey:kSoltsNumber] intValue]];
    
    // sequencer
    port_seq = -1;
    NSString * path = [NSString stringWithFormat:@"%@/config_seq.plist",[[NSBundle mainBundle]resourcePath] ];
    if([[NSFileManager defaultManager]fileExistsAtPath:path])
        dicConfig_seq = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    else
    {
        dicConfig_seq = [[NSMutableDictionary alloc]init];
        [dicConfig_seq setObject:@"~/testerconfig/zmqports.json" forKey:kPath];
        [dicConfig_seq setObject:@"SEQUENCER_PORT" forKey:kKey];
        [dicConfig_seq setObject:[NSNumber numberWithInt:1] forKey:kSlots];
        [dicConfig_seq writeToFile:path atomically:YES];
    }
    
    if([[NSFileManager defaultManager]fileExistsAtPath:[[dicConfig_seq objectForKey:kPath]  stringByResolvingSymlinksInPath]])
    {
        NSString * str = [NSString stringWithContentsOfFile:[[dicConfig_seq objectForKey:kPath]  stringByResolvingSymlinksInPath] encoding:NSUTF8StringEncoding error:nil];
        NSString * fmt = [NSString stringWithFormat:@"%@\":\\s*(\\d+)",[dicConfig_seq objectForKey:kKey]];
        NSString * p = [str stringByMatching:fmt capture:1];
        if(p)
            port_seq = [p intValue];
    }
    
    m_Slots_seq = [[dicConfig_seq objectForKey:kSlots]intValue];
    
    [self CreateUnitSeq:1];
    [self CreateUnitXavier:1];
    
    [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(btMsgStop:) name:@"On_NotificationCenterOnStop" object:nil];
    
    
}

-(int)btMsgStop:(id)sender
{
 
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = @"Alert!!!";
    alert.informativeText = @"Fixture is Open,Please Close the fixture before test or debug";
    [alert runModal];
    [alert release];
    return 0;
}

-(void)CreateUnit:(int)count
{
    for (int i=0; i<count; i++) {
        [self addNewTabWithTitle:[NSString stringWithFormat:@"Debug_UART%d",i+1] withIndex:i];
    }
    
    for (int i=0; i<count; i++) {
        [self addNewTabWithTitle:[NSString stringWithFormat:@"Dock_Channel%d",i+1] withIndex:i+10];
    }
    
    for (int i=0; i<count; i++) {
        [self addNewTabWithTitle:[NSString stringWithFormat:@"Config%d",i+1] withIndex:i+20];
    }

    m_Funcs = [((FunViewController *)[arrFuncView objectAtIndex:0]) FuncNum];
    
    [tabView selectFirstTabViewItem:nil];
}

-(void)SetUpUnit:(int)index withUnit:(unitTool *)controller
{
    int p = port_seq + index;
    [controller InitialPort:p];
}
-(void)CreateUnitSeq:(int)count
{

    unitTool * c = [[unitTool alloc] initWithIndex:0 :winMain];
    [self SetUpUnit:0 withUnit:c];
    [arrUnit addObject:c];
    UnitFakeModel *newModel = [[UnitFakeModel alloc] init];
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];
    [tabViewSequencerTool addTabViewItem:newItem];
    //[tabViewSequencerTool selectTabViewItem:newItem];
    [newItem setView:c.view];
    [newModel release];
    [newItem release];
    
//     unitTool * c = [[unitTool alloc] initWithIndex:0 :winMain];
//     [self SetUpUnit:0 withUnit:c];
//     [tabViewSequencerTool addSubview:c.view];
    
//    UnitViewController * c = [[UnitViewController alloc] initialwithID:index];
//    [arrUnit addObject:c];
//    UnitFakeModel *newModel = [[UnitFakeModel alloc] init];
//    [newModel setTitle:aTitle];
//    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];
//    [newItem setLabel:aTitle];
//    [tabFuncView addTabViewItem:newItem];
//    [tabFuncView selectTabViewItem:newItem];
//    [newItem setView:c.view];
//    [newModel release];
//    [newItem release];
    
}

-(void)CreateUnitXavier:(int)count
{
    XavierFunVC * funC = [[XavierFunVC alloc]initialwithID:0];
    //[funC CreateFuncUnit];
    [funC addNewTabWithTitle:@"---" withIndex:0];
    
    [arrUnit addObject:funC];
    [funC SetUpUnit:m_dicConfiguration_Xavier];
    
    UnitFakeModel *newModel = [[UnitFakeModel alloc] init];
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];

    [tabViewXaVierTool addTabViewItem:newItem];
    //[tabView selectTabViewItem:newItem];
    
    [newItem setView:funC.view];
    //    [c.view setFrame:[view frame]];
    [newModel release];
    [newItem release];
    
}


- (void)addNewTabWithTitle:(NSString *)aTitle withIndex:(int)index
{
    FunViewController * funC = [[FunViewController alloc]initialwithID:index];
    [funC CreateFuncUnit];
    [funC addNewTabWithTitle:aTitle withIndex:index];
    [arrUnit addObject:funC];
    [funC SetUpUnit:m_dicConfiguration];
//    [arrUnit addObject:funC];
    
    UnitFakeModel *newModel = [[UnitFakeModel alloc] init];
    [newModel setTitle:aTitle];
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];
    
    newModel.objectCount = (index%10+1);
    newModel.showObjectCount = YES;
    switch (index%10) {
        case 0:
        newModel.objectCountColor = [NSColor blueColor];
        break;
        case 1:
        newModel.objectCountColor =  [NSColor magentaColor];
        break;
        case 2:
        newModel.objectCountColor = [NSColor purpleColor];
        break;
        case 3:
        newModel.objectCountColor = [NSColor orangeColor];
        break;
        case 4:
        newModel.objectCountColor = [NSColor redColor];
        break;
        case 5:
        newModel.objectCountColor = [NSColor lightGrayColor];
        break;
        default:
        break;
    }
    
    
    [newItem setLabel:aTitle];
   // [newItem setColor:[NSColor yellowColor]];
    
    [tabView addTabViewItem:newItem];
    [tabView selectTabViewItem:newItem];
  
    
    //Debug
    //[newItem setView:c.view];
    [newItem setView:funC.view];
    
    
//    [c.view setFrame:[view frame]];
    [newModel release];
    [newItem release];
    //[c release];
}


-(IBAction)btConfiguration:(id)sender
{
    [winMain beginSheet:winConfiguration completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSModalResponseOK:
                m_dicConfiguration = [configDelegete configReturn];
                [self SaveConfiguration:m_dicConfiguration];
                for (int i=0;i<[arrUnit count];i++)
                {
                    [[arrUnit objectAtIndex:i] SetUpUnit:m_dicConfiguration];
                }
                break;
            case NSModalResponseCancel:
                break;
            default:
                break;
        }
    }];
}

-(IBAction)btRefresh:(id)sender
{
   FunViewController * c = [arrUnit objectAtIndex:[tabView indexOfTabViewItem:[tabView selectedTabViewItem]]];
    [c btRefresh];
}

-(void )LoadConfiguration
{
    //Load configuration in here
    if (m_dicConfiguration)
    {
        [m_dicConfiguration release];
    }
    m_dicConfiguration = [NSMutableDictionary new];
//    NSString * config_path = [NSString stringWithFormat:@"/Vault/%@_config/dut_config.plist",[m_dicDefine valueForKey:kProjectName]];
//    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
//    NSString * path_config = [bundle pathForResource:@"dut_config" ofType:@"plist"];
    
    NSString * contentPath = [[NSBundle bundleForClass:[self class]]executablePath];
    contentPath = [[contentPath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent];
    NSString * path_config = [contentPath stringByAppendingPathComponent:@"/Resources/dut_config.plist"];
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:path_config])
            [[NSFileManager defaultManager] createDirectoryAtPath:[path_config stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];

//    [contentPath writeToFile:path_config atomically:YES ];
    
    if (m_dicConfiguration) {
        [m_dicConfiguration release];
    }
    m_dicConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:path_config];
    
    if (!m_dicConfiguration)
    {
        m_dicConfiguration = [NSMutableDictionary new];
        int chn = [[m_dicDefine valueForKey:kSoltsNumber] intValue];
        int funs = [[m_dicDefine valueForKey:kFuncsNumber] intValue];
        for (int i=0;i<chn;i++)
        {
            for (int j=0;j<funs;j++)
            {
                NSString * rep = [NSString stringWithFormat:@"tcp://127.0.0.1:%d",funcsPort[2*j]+i ];
                NSString * sub = [NSString stringWithFormat:@"tcp://127.0.0.1:%d",funcsPort[2*j+1]+i ];
                [m_dicConfiguration setValue:rep forKey:[NSString stringWithFormat:@"%@%d%d",kRequest,j,i]];
                [m_dicConfiguration setValue:sub forKey:[NSString stringWithFormat:@"%@%d%d",kSubscribe,j,i]];
            }
        }
        
        [self SaveConfiguration:m_dicConfiguration];
    }
}

-(int)LoadXavierDefine
{
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [bundle pathForResource:@"XavierDefine" ofType:@"plist"];
    m_dicDefine_Xavier = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    if (!m_dicDefine_Xavier) {
        [m_dicDefine_Xavier setValue:@"utils" forKey:kProjectName];
        [m_dicDefine_Xavier setValue:@"1" forKey:kSoltsNumber];
        [m_dicDefine_Xavier setValue:@"1" forKey:kFuncsNumber];
    }
    return 0;
}

-(void)LoadXavierConfiguration{
    //Load configuration in here
    if (m_dicConfiguration_Xavier)
    {
        [m_dicConfiguration_Xavier removeAllObjects];
        [m_dicConfiguration_Xavier release];
    }
    m_dicConfiguration_Xavier = [NSMutableDictionary new];
    //    NSString * config_path = [NSString stringWithFormat:@"/Vault/%@_config/dut_config.plist",[m_dicDefine valueForKey:kProjectName]];
    //    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    //    NSString * path_config = [bundle pathForResource:@"dut_config" ofType:@"plist"];
    
    NSString * contentPath = [[NSBundle bundleForClass:[self class]]executablePath];
    contentPath = [[contentPath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent];
    NSString * path_config = [contentPath stringByAppendingPathComponent:@"/Resources/Xavier_Config.plist"];
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:path_config])
        [[NSFileManager defaultManager] createDirectoryAtPath:[path_config stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    
    //    [contentPath writeToFile:path_config atomically:YES ];
    
    if (m_dicConfiguration_Xavier)
    {
        [m_dicConfiguration_Xavier release];
    }
    m_dicConfiguration_Xavier = [[NSMutableDictionary alloc] initWithContentsOfFile:path_config];
    
    if (!m_dicConfiguration_Xavier)
    {
        m_dicConfiguration_Xavier = [NSMutableDictionary new];
        int chn = [[m_dicDefine_Xavier valueForKey:kSoltsNumber] intValue];
        int funs = [[m_dicDefine_Xavier valueForKey:kFuncsNumber] intValue];
        for (int i=0;i<chn;i++)
        {
            for (int j=0;j<funs;j++)
            {
                NSString * rep = [NSString stringWithFormat:@"tcp://127.0.0.1:%d",funcsPortXaview[2*j]+i ];
                NSString * sub = [NSString stringWithFormat:@"tcp://127.0.0.1:%d",funcsPortXaview[2*j+1]+i ];
                [m_dicConfiguration_Xavier setValue:rep forKey:[NSString stringWithFormat:@"%@%d%d",kRequest,j,i]];
                [m_dicConfiguration_Xavier setValue:sub forKey:[NSString stringWithFormat:@"%@%d%d",kSubscribe,j,i]];
            }
        }
        [self SaveXavierConfiguration:m_dicConfiguration_Xavier];
    }
}

-(void)SaveXavierConfiguration:(NSMutableDictionary *)dic
{
    
    NSString * contentPath = [[NSBundle bundleForClass:[self class]]executablePath];
    contentPath = [[contentPath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent];
    NSString * path_config = [contentPath stringByAppendingPathComponent:@"/Resources/Xavier_Config.plist"];
    NSError * err;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[path_config stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nullptr error:&err])
    {
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"Save Xavier Configuration";
        alert.informativeText =[NSString stringWithFormat:@"Create config path failed,with file path:%@ with error: %@",path_config,[err description]];
        [alert runModal];
        [alert release];
        
        
    }
    if (![dic writeToFile:path_config atomically:YES])
    {
        //        NSRunAlertPanel(@"Save Configuration", @"Write configuration file failed,with file path:%@", @"OK", nil, nil,path_config);
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"Save Xavier Configuration";
        alert.informativeText =[NSString stringWithFormat:@"Write configuration file failed,with file path:%@",path_config];
        [alert runModal];
        [alert release];
    }
    NSLog(@"OK.Save Xavier Configuration");
}


-(void)SaveConfiguration:(NSMutableDictionary *)dic
{

//    NSString * p = [[[[NSBundle mainBundle]bundlePath]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"TM_config/DebugPanle"];
//    if(![[NSFileManager defaultManager]fileExistsAtPath:p])
//        [[NSFileManager defaultManager]createDirectoryAtPath:p withIntermediateDirectories:YES attributes:NULL error:NULL];
//    NSString * config_path = [NSString stringWithFormat:@"%@/dut_config.plist",p];
    
//    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
//    NSString * path_config = [bundle pathForResource:@"dut_config" ofType:@"plist"];
    
    NSString * contentPath = [[NSBundle bundleForClass:[self class]]executablePath];
    contentPath = [[contentPath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent];
    NSString * path_config = [contentPath stringByAppendingPathComponent:@"/Resources/dut_config.plist"];
    NSError * err;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[path_config stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nullptr error:&err])
    {
//        NSRunAlertPanel(@"Save Configuration", @"Create config path failed,with file path:%@ with error: %@", @"OK", nil, nil,path_config,[err description]);
        
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"Save Configuration";
        alert.informativeText =[NSString stringWithFormat:@"Create config path failed,with file path:%@ with error: %@",path_config,[err description]];
        [alert runModal];
        [alert release];

        
    }
    if (![dic writeToFile:path_config atomically:YES])
    {
//        NSRunAlertPanel(@"Save Configuration", @"Write configuration file failed,with file path:%@", @"OK", nil, nil,path_config);
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"Save Configuration";
        alert.informativeText =[NSString stringWithFormat:@"Write configuration file failed,with file path:%@",path_config];
        [alert runModal];
        [alert release];
    }
    
    NSLog(@"OK.SaveConfiguration");
}

- (void)windowWillBeginSheet:(NSNotification *)notification
{
    [(ConfigurationWndDelegate *)[winConfiguration delegate] InitCtrls:m_dicConfiguration withSolts: [[m_dicDefine valueForKey:kSoltsNumber] intValue] withFuncs:[[m_dicDefine valueForKey:kFuncsNumber] intValue]];
}




//
//- (MMTabBarView *)tabView:(NSTabView *)aTabView newTabBarViewForDraggedTabViewItem:(NSTabViewItem *)tabViewItem atPoint:(NSPoint)point {
//    NSLog(@"---->>newTabBarViewForDraggedTabViewItem: %@ atPoint: %@", tabViewItem.label, NSStringFromPoint(point));
//
//    //create a new window controller with no tab items
//    AppDelegate *controller = [[AppDelegate alloc] initWithWindowNibName:@"DemoWindow"];
//
//    MMTabBarView *tabBarView = (MMTabBarView *)aTabView.delegate;
//
//    id <MMTabStyle> style = tabBarView.style;
//
//    NSRect windowFrame = winMain.frame;
//    point.y += windowFrame.size.height - controller.window.contentView.frame.size.height;
//    [style leftMarginForTabBarView:tabBarView];
//
//    [controller.window setFrameTopLeftPoint:point];
//    [controller->tabBar setStyle:style];
//
//    return controller->tabBar;
//}
//
//- (void)tabView:(NSTabView *)aTabView closeWindowForLastTabViewItem:(NSTabViewItem *)tabViewItem {
//    NSLog(@"---->>closeWindowForLastTabViewItem: %@", tabViewItem.label);
//    [winMain close];
//}
//
//- (void)tabView:(NSTabView *)aTabView tabBarViewDidHide:(MMTabBarView *)tabBarView {
//    NSLog(@"---->>tabBarViewDidHide: %@", tabBarView);
//}
//
//- (void)tabView:(NSTabView *)aTabView tabBarViewDidUnhide:(MMTabBarView *)tabBarView {
//    NSLog(@"---->>tabBarViewDidUnhide: %@", tabBarView);
//}
//
//- (NSString *)tabView:(NSTabView *)aTabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem {
//    return tabViewItem.label;
//}
//
//- (NSString *)accessibilityStringForTabView:(NSTabView *)aTabView objectCount:(NSInteger)objectCount {
//    return (objectCount == 1) ? @"item" : @"items";
//}


@end
