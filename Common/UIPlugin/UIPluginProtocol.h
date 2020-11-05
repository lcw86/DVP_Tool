//
//  Header.h
//  MainUI
//
//  Created by Ryan on 12/3/15.
//  Copyright © 2015 ___Intelligent Automation___. All rights reserved.
//

#pragma once

#define     kMainWnd            @"kMainWnd"
#define     kDetailView         @"kDetailView"
#define     kScopeView          @"kScopView"
#define     kInteractionView    @"kInteractionView"
#define     kInstrumentMenu     @"kInstrumentMenu"
#define     kMainMenu           @"kMainMenu"
#define     kMsgDelegate        @"kMsgDelegate"

typedef enum _UI_EVENT{
    UI_EVENT_SCANBARCODE,
}UI_EVENT;

@protocol UIPlugin
@required
-(int)uixLoad:(id)sender;
-(int)uixUnload:(id)sender;
@optional
-(int)CtrlEvent:(int)code with:(id)sender;
@end

@protocol UIPluginDelegate <NSObject>
-(void)OnUpdateSN:(NSString *)sn atSlot:(int)slot witIndex:(int)index;

@end