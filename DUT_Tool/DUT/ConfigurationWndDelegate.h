//
//  ConfigurationWndDelegate.h
//  DUT
//
//  Created by Ryan on 11/12/15.

//

#import <Cocoa/Cocoa.h>

@interface ConfigurationWndDelegate : NSObject{
    IBOutlet NSTableView *  tableView;
    IBOutlet NSButton * btOK;
    IBOutlet NSButton * btCancel;
    
    IBOutlet NSWindow * winConfiguration;
    IBOutlet NSWindow * winMain;
    
//    IBOutlet AppDelegate *winDelegete;
    NSMutableDictionary * dicConfiguration;
    int m_Solts;
    int m_funcs;
    
    NSMutableDictionary * dicTableView;
}

-(void)InitCtrls:(NSMutableDictionary *)dic withSolts:(int)number withFuncs:(int)funsNum;
-(NSMutableDictionary*)configReturn;
@end
