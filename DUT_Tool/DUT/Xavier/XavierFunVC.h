//
//  FunViewController.h
//  DUT
//
//

#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarView.h>
#import "XavierUinitVC.h"

#define kRequest           @"Request"
#define kSubscribe        @"Subscribe"



@interface XavierFunVC : NSViewController
{
    IBOutlet MMTabBarView           *tabFuncBar;
    IBOutlet NSTabView              *tabFuncView;
    NSMutableArray * arrUnit;
    int mID;
}



-(id)initialwithID:(int)ID;
-(void)CreateFuncUnit;
-(void)addNewTabWithTitle:(NSString *)aTitle withIndex:(int)index;
-(void)SetUpUnit:(NSMutableDictionary *)m_dicConfiguration;
-(int)InitialPort:(NSDictionary *)diConfig;
-(int)FuncNum;
-(void)btRefresh;

@end
