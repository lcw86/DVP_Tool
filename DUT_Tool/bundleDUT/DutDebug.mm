//
//  DutDebug.m
//  DUT
//
//

#import "DutDebug.h"
#import "UnitViewController.h"
#import "ConfigurationWndDelegate.h"
#import <MMTabBarView/UnitFakeModel.h>
int _slots=6;
NSString * _pName = @"DUT";

NSMenu * menuInstr=nil;

@implementation DutDebug
#pragma mark ---- tab bar config ----
-(id)init
{
    self = [super init];
    return self;
}

-(int)LoadDefine
{
//    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
//    NSString * path = [bundle pathForResource:@"define" ofType:@"plist"];
//    m_dicDefine = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
//    if (!m_dicDefine) {
//        [m_dicDefine setValue:@"utils" forKey:kProjectName];
//        [m_dicDefine setValue:@"6" forKey:kSoltsNumber];
//    }
    m_dicDefine = [[NSMutableDictionary alloc]init];
    [m_dicDefine setValue:_pName forKey:kProjectName];
    [m_dicDefine setValue:[NSString stringWithFormat:@"%d", _slots] forKey:kSoltsNumber];
    return 0;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:@"Attach_Menu" object:nil];
    [self LoadDefine];
    [self LoadConfiguration];
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
    [tabBar setButtonOptimumWidth:200];
    
    [self CreateUnit:[[m_dicDefine valueForKey:kSoltsNumber] intValue]];
    
    [menuInstr addItem:dutMenuItem];
    [dutMenuItem setTarget:self];
}

-(void)OnNotification:(NSNotification *)nf
{
    NSMenu * instrMenu = [[nf userInfo]objectForKey:@"menus"];
    [instrMenu addItem:dutMenuItem];
    [dutMenuItem setTarget:self];
}

-(void)CreateUnit:(int)count
{
    for (int i=0; i<count; i++) {
        [self addNewTabWithTitle:[NSString stringWithFormat:@"UUT%d",i] withIndex:i];
    }
    [tabView selectFirstTabViewItem:nil];
}

-(void)SetUpUnit:(int)index withUnit:(UnitViewController *)controller
{
    NSString * key1 = [NSString stringWithFormat:@"%@%d",kRequest,index];
    NSString * key2 = [NSString stringWithFormat:@"%@%d",kSubscrib,index];
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[m_dicConfiguration valueForKey:key1],kRequest,[m_dicConfiguration valueForKey:key2],kSubscrib, nil];
    [controller InitialPort:dic];
}

- (void)addNewTabWithTitle:(NSString *)aTitle withIndex:(int)index
{
    UnitViewController * c = [[UnitViewController alloc] initialwithID:index];
    [self SetUpUnit:index withUnit:c];
    
    [arrUnit addObject:c];
    
    UnitFakeModel *newModel = [[UnitFakeModel alloc] init];
    [newModel setTitle:aTitle];
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];
    [newItem setLabel:aTitle];
    [tabView addTabViewItem:newItem];
    [tabView selectTabViewItem:newItem];
    [newItem setView:c.view];
    //    [c.view setFrame:[view frame]];
    [newModel release];
    [newItem release];
    //[c release];
}

-(IBAction)menuClick:(id)sender
{
    [winMain center];
    [winMain makeKeyAndOrderFront:sender];
    //    [winFct setLevel:NSStatusWindowLevel];
    
}

-(IBAction)btConfiguration:(id)sender
{
    [winMain beginSheet:winConfiguration completionHandler:^(NSModalResponse returnCode) {
   
        switch (returnCode) {
            case NSModalResponseOK:
                [self SaveConfiguration:m_dicConfiguration];
                for (int i=0;i<[arrUnit count];i++)
                {
                    [self SetUpUnit:i withUnit:[arrUnit objectAtIndex:i]];
                }
                break;
            case NSModalResponseCancel:
                break;
            default:
                break;
        }
    }];
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
//    NSString * config_path = [NSString stringWithFormat:@"/Vault/%@_config/dut_config.plist",[m_dicDefine valueForKey:kProjectName]];
    NSString * p = [[[[NSBundle mainBundle]bundlePath]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"TM_config/DebugPanle"];
    if(![[NSFileManager defaultManager]fileExistsAtPath:p])
        [[NSFileManager defaultManager]createDirectoryAtPath:p withIntermediateDirectories:YES attributes:NULL error:NULL];
    
    NSString * config_path = [NSString stringWithFormat:@"%@/dut_config.plist",p];
    [m_dicDefine setObject:config_path forKey:@"path"];
    if (m_dicConfiguration) {
        [m_dicConfiguration release];
    }
    m_dicConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:config_path];
    
    if (!m_dicConfiguration)
    {
        m_dicConfiguration = [NSMutableDictionary new];
        int chn = [[m_dicDefine valueForKey:kSoltsNumber] intValue];
        for (int i=0;i<chn;i++)
        {   NSString * req = [NSString stringWithFormat:@"tcp://127.0.0.1:%d",7000+i ];
            NSString * sub = [NSString stringWithFormat:@"tcp://127.0.0.1:%d",6800+i ];
            [m_dicConfiguration setValue:req forKey:[NSString stringWithFormat:@"%@%d",kRequest,i]];
            [m_dicConfiguration setValue:sub forKey:[NSString stringWithFormat:@"%@%d",kSubscrib,i]];
        }
        
        [m_dicConfiguration writeToFile:config_path atomically:YES];
    }
}

-(void)SaveConfiguration:(NSMutableDictionary *)dic
{
//    NSString * config_path = [NSString stringWithFormat:@"/Vault/%@_config/dut_config.plist",[m_dicDefine valueForKey:kProjectName]];
    NSString * config_path = [m_dicDefine objectForKey:@"path"];
    NSError * err;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[config_path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:NULL error:&err])
    {
        NSRunAlertPanel(@"Save Configuration", @"Create config path failed,with file path:%@ with error: %@", @"OK", nil, nil,config_path,[err description]);
    }
    if (![dic writeToFile:config_path atomically:YES])
    {
        NSRunAlertPanel(@"Save Configuration", @"Write configuration file failed,with file path:%@", @"OK", nil, nil,config_path);
    }
}

- (void)windowWillBeginSheet:(NSNotification *)notification
{
    [(ConfigurationWndDelegate *)[winConfiguration delegate] InitCtrls:m_dicConfiguration withSolts:[[m_dicDefine valueForKey:kSoltsNumber] intValue]];
}

-(BOOL)windowShouldClose:(id)sender
{
    [winMain orderOut:nil];
    return NO;
}

@end
