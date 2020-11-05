//
//  DutDebug.h
//  DUT
//

//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarView.h>

#define kProjectName        @"project_name"
#define kSoltsNumber         @"slots_number"

#define kRequest           @"Request"
#define kSubscrib        @"Subscribe"

@interface DutDebug : NSObject
{
    IBOutlet MMTabBarView           *tabBar;
    IBOutlet NSTabView              *tabView;
    NSMutableArray * arrUnit;
    
    IBOutlet NSWindow * winConfiguration;
    IBOutlet NSWindow * winMain;
    
    int m_Slots;
    
    NSMutableDictionary * m_dicDefine;
    NSMutableDictionary * m_dicConfiguration;
    IBOutlet NSMenuItem * dutMenuItem;
}

@end
