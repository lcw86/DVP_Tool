//
//  readGWin.h
//  DUT_Tool
//
//  Created by RyanGao on 2019/8/29.
//  Copyright © 2019  Automation___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface readGWin : NSWindowController
{
    
    IBOutlet NSTextField *alertTextField;
    IBOutlet NSWindow *GGWin;
    IBOutlet NSTextView *chargingTxtWin;
}

- (IBAction)OnReadGG:(id)sender;
- (IBAction)OnStopCharging:(id)sender;
- (IBAction)OnStartCharging:(id)sender;
- (IBAction)OnStopClose:(id)sender;
- (IBAction)ClearTxt:(id)sender;
- (IBAction)OnEnterDiags:(id)sender;

-(void)GGWinClose;

@end

NS_ASSUME_NONNULL_END
