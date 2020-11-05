//
//  AppDelegate.m
//  documentViewTest
//

//

#import "GraphicWinDelegate.h"
//#import "Documentview.h"
#import "GraphicViewController.h"

@implementation GraphicWinDelegate
- (instancetype)init
{
    self = [super init];
    if (self) {
        arrview=[[NSMutableArray alloc] init];
    }
    return self;
}
-(void)dealloc
{
    [arrview release];
    [super dealloc];
}
-(void)awakeFromNib
{
    NSLog(@"--GraphicWinDelegate awakeFromNib--");
    indexViewFlag = NO;
    indexView = 0;
    [self addDebugViewWindow:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                     :@selector(addDebugViewWindow:) name
                                                     :@"kAddDebugViewWindow" object
                                                     :nil] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                     :@selector(refreshTab:) name
                                                     :@"krefreshTab" object
                                                     :nil] ;

}


-(void)addDebugViewWindow:(id)sender
{
    while ([[tab tabViewItems] count]>0) {
        [tab removeTabViewItem:[[tab tabViewItems] objectAtIndex:0]];
    }
    
    NSString *debugfile = [[NSString stringWithFormat:@"%@/debugfile/",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] stringByResolvingSymlinksInPath];
    
    NSArray *arr=[self EnumerateDebugfile:debugfile];
    //NSArray *arr=[self EnumerateDebugfile:@"/vault/debugfile/"];
    NSLog(@"======>>>debugfile: %@  =:%@",debugfile,arr);

    if (arr) {
        for (NSString* file in arr) {
            [self AddDebugView:file];
        }
        [arr release];
    }
}


-(IBAction)AddDebugView:(NSString*)file
{
    //NSString *path=[@"/vault/debugfile/" stringByAppendingPathComponent:file];
     NSString *path = [[NSString stringWithFormat:@"%@/debugfile/",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]] stringByAppendingString:file];
    GraphicViewController *docview=[GraphicViewController newGraphicView:path];
    if (docview)
    {
        NSString *identifier=[file stringByDeletingPathExtension];
        NSTabViewItem *newItem = [[NSTabViewItem alloc] init];
        [newItem setIdentifier:identifier];
        [newItem setLabel:identifier];
        [newItem setView:[docview view]];
        [tab addTabViewItem:newItem];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadnewgraphic" object:nil userInfo:[NSDictionary dictionaryWithObject:[docview graphics] forKey:identifier]];
        [newItem release];
        [docview release];
        
    }
    
    
}
-(GraphicView*)getGraphicView:(NSView*)view
{
    NSArray *arr=[view subviews];
    GraphicView *v=nil;
    for (NSView *sub in arr) {
        if ([sub isKindOfClass:[GraphicView class]])
        {
            v= (GraphicView*)sub;
            break;
        }
        v=[self getGraphicView:sub];
        if (v) {
            break;
        }
    }
    return v;
}
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    
    if ([tab indexOfTabViewItem:tabViewItem]!=0)
    {
        indexView = [tab indexOfTabViewItem:tabViewItem];
        indexViewFlag = NO;
    }
    else
    {
        indexViewFlag = YES;
    }
   // NSLog(@"=====didSelectTabViewItem: %ld   %d",(long)indexView,indexViewFlag);
    NSView *view1=[tabViewItem view];
    GraphicView* view= [self getGraphicView:view1];
    if (!view) {
        return;
    }
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:view.bounds
                                                        options:NSTrackingMouseMoved |NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
                                                          owner:view
                                                       userInfo:nil];
    [view addTrackingArea:area];
    [view becomeFirstResponder];

    [area release];
}


-(void)refreshTab:(id)sender
{
    if (indexViewFlag)
    {
        
        [tab selectTabViewItemAtIndex:indexView];
        [tab selectTabViewItemAtIndex:0];
    }
    else
    {
        [tab selectTabViewItemAtIndex:0];
        [tab selectTabViewItemAtIndex:indexView];
    }

}

- (BOOL)windowShouldClose:(id)sender
{
    return YES;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(NSArray*)EnumerateDebugfile:(NSString*)Path
{
    NSMutableArray *arrfiles=[NSMutableArray array];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir, valid = [manager fileExistsAtPath:Path isDirectory:&isDir];
    if(!isDir)
    {
//        NSLog(@"%@",Path);
        return nil;
    }
    NSString *home = [Path stringByExpandingTildeInPath];
//    home=[home stringByAppendingPathComponent:@"*.data"];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:home];
    NSString *filename;
    while (filename = [direnum nextObject])
    {
        NSArray *att=[filename pathComponents];
        if ( [att count]>1) {
            continue;
        }
        [arrfiles addObject:filename];
    }
    return [arrfiles count]>0?[arrfiles retain]:nil;
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(IBAction)Add:(id)sender
{
//    GraphicViewController *docview=[[GraphicViewController alloc] init];
//    NSUInteger tabid=[[tab tabViewItems] count]+1;
//    NSString *newModel=[NSString stringWithFormat:@"tabview%d",(int)tabid];
//    NSTabViewItem *newItem = [[NSTabViewItem alloc] init];
//    [newItem setLabel:newModel];
//    [newItem setView:[docview view]];
//    [tab addTabViewItem:newItem];
//    //[arrview addObject:docview];
//    [docview release];
//    [newItem release];
}
-(IBAction)remove:(id)sender
{
    NSTabViewItem *newItem =[tab selectedTabViewItem];
    if (newItem) {
       NSInteger n= [tab indexOfTabViewItem:newItem];
        [tab removeTabViewItem:newItem];
        //[newItem release];
        //[arrview objectAtIndex:n];
        //[arrview removeObjectAtIndex:n];
    }

}

-(NSView*)get_TabView
{
    
    return tab;
}
@end
