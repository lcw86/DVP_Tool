//
//  UnitViewController.h
//  DUT
//
//  Created by Ryan on 11/3/15.

//

#import <Cocoa/Cocoa.h>
#include "DutController.h"

@protocol DataInterface <NSObject>
-(void)OnData:(void *)bytes length:(long)len;
@end

@interface UnitViewController<DataInterface> : NSViewController
{
    
    IBOutlet NSComboBox * comboxCmd;
    IBOutlet NSTextView * txtBuffer;
    IBOutlet NSButton * btnReturn;
    IBOutlet NSButton * btnNewLine;
    int mID;
    
    IBOutlet NSButton *btnHwio;
    NSMutableDictionary * m_dicConfiguration;
    NSMutableString * gg_buffer;
    int gg_count;
    
    CDUTController * pDUT;
    
}

//- (IBAction)btHwio:(NSButton *)sender;
-(IBAction)btClear:(id)sender;
-(IBAction)btSend:(id)sender;
-(id)initialwithID:(int)ID;
-(void)OnData:(void *)bytes length:(long)len;
-(int)InitialPort:(NSDictionary *)diConfig;
-(void)btRefresh;

@property IBOutlet NSButton *btnReturn1;
@property IBOutlet NSButton *btnNewLine1;
@end
