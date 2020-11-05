//
//  hwioWinController.h
//  hwio_Test
//
//  Created by RyanGao on 2019/6/18.
//  Copyright © 2019 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface hwioWinController : NSWindowController <NSTableViewDelegate,NSTableViewDataSource>
{
    
    
    NSMutableArray *cellArray;
    IBOutlet NSTableView *cmdControlList;
    IBOutlet NSWindow *hwioMainWin;
    
    IBOutlet NSTextField *m_label;
    IBOutlet NSScrollView *m_scrollView;
    
    IBOutlet NSComboBox *m_batt;
    IBOutlet NSComboBox *m_usb;
    
    IBOutlet NSComboBox *m_eload;
    IBOutlet NSComboBox *m_usb_rect;
    IBOutlet NSTextField *m_freq;
    
}

-(void)hwioMainWinClose;
-(void)sethwioMainWinTitle:(NSString *)title withID:(int)iID;


@end


NS_ASSUME_NONNULL_END
