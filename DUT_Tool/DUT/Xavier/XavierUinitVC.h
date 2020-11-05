//
//  UnitViewController.h
//  DUT
//
//  Created by Ryan on 11/3/15.

//

#import <Cocoa/Cocoa.h>
#include "DutController.h"

//@protocol DataInterfaceXavier <NSObject>
//
//-(void)OnData:(void *)bytes length:(long)len;
//@end

@interface XavierUinitVC<DataInterface> : NSViewController<NSTableViewDelegate,NSTableViewDataSource>
{
    IBOutlet NSTextField *comboxCmd;
    IBOutlet NSTextView * txtBuffer;
    IBOutlet NSButton * btnReturn;
    IBOutlet NSButton * btnNewLine;
    int mID;
    
    IBOutlet NSButton *btnHwio;
    NSMutableDictionary * m_dicConfiguration;
    
    CDUTController * pDUT;
    
    
    NSMutableArray *cellArrayAI;
    
    NSMutableArray *cellArray_Voltage;
    NSMutableArray *cellArray_Current;
    NSMutableArray *cellArray_Frequence;
    
    NSMutableArray *cellArrayRelay;
    
    //IBOutlet NSTableView *cmdControlList;
   
    IBOutlet NSScrollView *m_scrollView;
    
    IBOutlet NSScrollView *m_scrollView_AI;
    IBOutlet NSScrollView *m_scrollViewRelay;
    
    IBOutlet NSTableView *cmdControll_AIList;  //voltage
    IBOutlet NSTableView *cmdControl_CurrentList;//current
    IBOutlet NSTableView *cmdCOntrol_FrequencyList;////frequency
    
    IBOutlet NSTableView *cmdControll_RelayList;
    
    
    
    // IBOutlet NSWindow *hwioMainWin;
    //IBOutlet NSTextField *m_label;
    
    IBOutlet NSTextField *m_label;
    IBOutlet NSTextField *m_batt;
    IBOutlet NSTextField *m_usb;
    
    IBOutlet NSComboBox *m_eload;
    IBOutlet NSComboBox *m_usb_rect;
    //IBOutlet NSTextField *m_freq;
//    NSSearchField *SearchBtn;
//    NSSearchField *SearchBtnRelay;
    IBOutlet NSTextField *m_measurment;
    NSString *gainValue;
    NSString *nameAIMeas;
    NSString *nameAIUnit;
    
    float coefficient;
    
    BOOL displayVaule;

    IBOutlet NSButton *m_btStim;
    
}


@property (assign) IBOutlet NSSearchField *searchBtn;

@property (assign) IBOutlet NSSearchField *searchCurrent;
@property (assign) IBOutlet NSSearchField *searchFrequency;

@property (assign) IBOutlet NSSearchField *searchBtnRelay;


//-(void)hwioMainWinClose;
//-(void)sethwioMainWinTitle:(NSString *)title withID:(int)iID;
- (IBAction)btHwio:(NSButton *)sender;
    
-(IBAction)btClear:(id)sender;
-(IBAction)btSend:(id)sender;
-(id)initialwithID:(int)ID;
-(void)OnData:(void *)bytes length:(long)len;
-(int)InitialPort:(NSDictionary *)diConfig;
-(void)btRefresh;

@property(assign) IBOutlet NSButton *btnReturn1;
@property(assign) IBOutlet NSButton *btnNewLine1;
@end
