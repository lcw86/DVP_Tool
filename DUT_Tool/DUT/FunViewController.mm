//
//  FunViewController.m
//  DUT
//

//

#import "FunViewController.h"
#import <MMTabBarView/UnitFakeModel.h>
#import "AppDelegate.h"
//#import "UnitViewController.h"

@interface FunViewController ()

@end

@implementation FunViewController


-(id)initialwithID:(int)ID
{
//    self = [super init];
    self = [super initWithNibName:@"FunViewController" bundle:[NSBundle bundleForClass:[self class]]];
    
    if (self.view == nil)
    {
        return nil;
    }
    
    if (self)
    {
        mID = ID;
        NSLog(@"Func controller init ok");
    }
   
    
    return self;
}


-(void)awakeFromNib
{
    NSLog(@"awakeFromNib?");
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    
    [tabFuncBar setStyleNamed:@"Safari"];
    [tabFuncBar setOnlyShowCloseOnHover:YES];
    [tabFuncBar setCanCloseOnlyTab:YES];
    [tabFuncBar setDisableTabClose:YES];
    [tabFuncBar setAllowsBackgroundTabClosing:YES];
    [tabFuncBar setHideForSingleTab:YES];
    [tabFuncBar setShowAddTabButton:YES];
    [tabFuncBar setSizeButtonsToFit:NO];
    [tabFuncBar setTearOffStyle:MMTabBarTearOffAlphaWindow];
    [tabFuncBar setUseOverflowMenu:YES];
    [tabFuncBar setAutomaticallyAnimates:YES];
    [tabFuncBar setAllowsScrubbing:YES];
    [tabFuncBar setButtonOptimumWidth:200];
    
    arrUnit = [NSMutableArray new];
    
    NSLog(@"func viewDidLoad is ok");
    
    // Do view setup here.
}

-(void)CreateFuncUnit
{
//    [self addNewTabWithTitle:@"ARM" withIndex:0];
//    [self addNewTabWithTitle:@"DUT" withIndex:1];
//    [self addNewTabWithTitle:@"ELOAD" withIndex:2];
    [tabFuncView selectFirstTabViewItem:nil];
}


- (void)addNewTabWithTitle:(NSString *)aTitle withIndex:(int)index
{
    UnitViewController * c = [[UnitViewController alloc] initialwithID:index];
    [arrUnit addObject:c];
    UnitFakeModel *newModel = [[UnitFakeModel alloc] init];
    [newModel setTitle:aTitle];
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];
    [newItem setLabel:aTitle];
    [tabFuncView addTabViewItem:newItem];
    [tabFuncView selectTabViewItem:newItem];
    [newItem setView:c.view];
    [newModel release];
    [newItem release];
}

-(void)SetUpUnit:(NSMutableDictionary *)m_dicConfiguration
{
    for (int i=0; i<[arrUnit count];i++)
    {
        NSLog(@"arrUnit count:%ld   i: %d",[arrUnit count],i);
        NSString * key1 = [NSString stringWithFormat:@"%@%d%d",kRequest,i,mID/10];
        NSString * key2 = [NSString stringWithFormat:@"%@%d%d",kSubscribe,i,mID/10];
//        if (mID > 9) {
//            key1 = [NSString stringWithFormat:@"%@%d",kRequest,mID];
//            key2 = [NSString stringWithFormat:@"%@%d",kSubscribe,mID];
//        }
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[m_dicConfiguration valueForKey:key1],kRequest,[m_dicConfiguration valueForKey:key2],kSubscribe, nil];
        if ([[[dic keyEnumerator]allObjects]count]==0) {
            dic = [NSDictionary dictionaryWithObjectsAndKeys:@"tcp://0.0.0.0:0",kRequest,@"tcp://0.0.0.0:0",kSubscribe, nil];
        }
        UnitViewController *controller = (UnitViewController *)[arrUnit objectAtIndex:i];
        [controller InitialPort:dic];
    }
}

-(void)btRefresh
{
    for (int i=0; i<[arrUnit count];i++)
    {
        UnitViewController *controller = (UnitViewController *)[arrUnit objectAtIndex:i];
        [controller btRefresh];
    }
}

-(int)FuncNum
{
    return (int)[arrUnit count];
}

-(void)dealloc
{
    NSLog(@"FuncView dealloc");
    for (NSViewController * v in arrUnit)
    {
        NSLog(@"dealloc");
        [v release];
    }
    if(arrUnit)
        [arrUnit release];
    [super dealloc];
    

}


@end
