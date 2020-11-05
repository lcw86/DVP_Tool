//
//  unitTool.h
//  MainUI
//
//  Created by IvanGan on 16/1/7.
//  Copyright © 2016年 ___Intelligent Automation___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "zmqCenter.h"
typedef enum BTN_TYPE
{
    BTN_STEP=0,
    BTN_JUMP,
    BTN_CONTINUE,
    BTN_BREAK,
    BTN_ALL,
    BTN_CLEAR,
    BTN_STOP,
    BTN_STATUS,
    BTN_SHOW,
    BTN_NEXT,
    BTN_LOAD,
    BTN_LIST,
} _btn_type;

@interface unitTool : NSViewController
{
    IBOutlet NSButton * btnStep;
    IBOutlet NSButton * btnJump;
    IBOutlet NSButton * btnContinue;
    IBOutlet NSButton * btnBreak;//set break point
    IBOutlet NSButton * btnAllBreak;//show all break point
    IBOutlet NSButton * btnClear;
    IBOutlet NSButton * btnStop;
    IBOutlet NSButton * btnStatus;
    
    IBOutlet NSButton *btnNext;
    IBOutlet NSButton *btnShowVariant;
    IBOutlet NSButton * btnLoad;
    IBOutlet NSButton * btnList;
    IBOutlet NSButton * btnEnterDiags;
    
    IBOutlet NSTextField * txtData;
    IBOutlet NSTextField *txtDataJump;
    IBOutlet NSTextField *txtDataBreak;
    IBOutlet NSTextField *txtDataEnterDiagsFrom;
    IBOutlet NSTextField *txtDataEnterDiagsTo;
    
    
    IBOutlet NSTextView * txtView;
    IBOutlet NSTextField * txtShow;

    IBOutlet NSButton * btnSelectAll;
    
    @private
    NSWindow * win;
    NSMutableDictionary * currentStep;
    NSMutableDictionary * totalStep;
    
    NSMutableDictionary * dicConfig;
//    void * zmqReq;
    IBOutlet NSMatrix * btnUUTSelected;
    int m_slots;
    int m_port;
    NSMutableDictionary * arrBreak;
    NSMutableDictionary * arrTimeOut;
    NSMutableDictionary * arrZmq;
    NSLock * mLock;

    NSMutableDictionary * dicEnable;

    NSArray * btnCtrl;
    NSArray * btnTitle;
    
    zmqCenter *sequncer;
    
    NSMutableArray  *threadArr;
    
    
    IBOutlet NSButton *m_btnAceFWDl;
    IBOutlet NSButton *m_btnUSB3_0;
    IBOutlet NSButton *m_btnEfficiency;
    IBOutlet NSButton *m_btnStim;
    IBOutlet NSButton *m_btnExplorer;
    IBOutlet NSButton *m_btnEnterDiags;
    
    IBOutlet NSButton *m_btnMobileResRunFct;
    
    
    IBOutlet NSButton *m_btnMeas;
    IBOutlet NSButton *m_btnResetAll;
    NSMutableDictionary * listCsvName ;
    
    IBOutlet NSButton *m_btnIboot;
    IBOutlet NSButton *m_btnDFU;
    IBOutlet NSButton *m_btnBattChg;
}

-(IBAction)btnStep:(id)sender;
-(IBAction)btnJump:(id)sender;
-(IBAction)btnContinue:(id)sender;
-(IBAction)btnBreak:(id)sender;
-(IBAction)btnAllBreak:(id)sender;
-(IBAction)btnStatus:(id)sender;
-(IBAction)btnShowVariant:(id)sender;
-(IBAction)btnLoad:(id)sender;
-(IBAction)btnNext:(id)sender;
-(IBAction)btnList:(id)sender;
-(IBAction)btnStop:(id)sender;
-(IBAction)btnSelectAll:(id)sender;
- (IBAction)btnEnterDiags:(id)sender;
- (IBAction)btnResetAll:(id)sender;
- (IBAction)btnRealBattChg:(id)sender;

-(int)setSlots:(int)slots :(int)port;
-(id)initWithIndex:(int)index :(id)window;

//-(id)initWithIndex:(int)index;
-(void)InitialPort:(int)port;

//-(int)setSlots:(int)slots;
- (IBAction)btnACEFWDL:(id)sender;
- (IBAction)btnUSB3_0_Test:(id)sender;
- (IBAction)btnEfficiencyTest:(id)sender;
- (IBAction)btnStimPanel:(id)sender;
- (IBAction)explorerTest:(id)sender;

- (IBAction)btn_MeasPanel:(id)sender;

@end
