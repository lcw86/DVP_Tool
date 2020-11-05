//
//  ButtonGroupConfigDelegate.h
//  LuaDebugPanel
//
//  Created by Rony on 11/20/17.
//  Copyright © 2017 Louis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTGraphic.h"
#import "SKTButton.h"



@interface ButtonGroupConfigDelegate : NSObject
{
    IBOutlet NSWindow *mw;
    IBOutlet NSTextField *tfname;
    IBOutlet NSTableView *tv;
    IBOutlet NSButton *btnCreateGrp;
    IBOutlet NSButton *btnDeleteGrp;
    
    IBOutlet NSButton *btnAddBtn;
    IBOutlet NSButton *btnDelBtn;
    IBOutlet NSTextField *tiplabel;
    IBOutlet NSTextField *btnname;
    SKTButton *rClickedBtn;
    SKTButton *rLastClickedBtn;
    NSPoint point;
}

-(IBAction)btnCreateGroup:(id)sender;
-(IBAction)btnDeleteGroup:(id)sender;
-(IBAction)btnSwitch:(id)sender;

-(IBAction)onAddBtnto:(id)sender;
-(IBAction)onRemoveBtnFrom:(id)sender;


@property(readwrite,assign) NSMutableDictionary *dic_groupinfor;
@property(readwrite,assign) NSMutableArray *arr_groupname;

@end
