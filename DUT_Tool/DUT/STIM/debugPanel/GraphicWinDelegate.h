//
//  AppDelegate.h
//  documentViewTest
//

//

#import <Cocoa/Cocoa.h>

@interface GraphicWinDelegate : NSObject <NSWindowDelegate>
{
    
    IBOutlet NSWindow *window;
    IBOutlet NSTabView* tab;
    NSMutableArray *arrview;
    
    NSInteger indexView;
    bool indexViewFlag;
    
}

-(IBAction)Add:(id)sender;

-(NSView*)get_TabView;

-(void)refreshTab:(id)sender;

@end

