//
//  SNProtocol.h
//  SN
//
//  Created by Liang on 15-8-10.
//  Copyright (c) 2015年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol UIExProtocol <NSObject>
@required
-(int)uixLoad:(id)sender;
-(void)uixSetDelegate:(id)sender;
-(int)uixUnload:(id)sender;

@optional
-(void)uixCtrlEvent:(id)sender;
@end

