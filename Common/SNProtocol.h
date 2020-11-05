//
//  SNProtocol.h
//  SN
//
//  Created by Liang on 15-8-10.
//  Copyright (c) 2015年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SNProtocol <NSObject>
@required
-(int)snLoad:(id)sender;
-(int)snShowPanel:(id)sender;
-(int)snHidePanel:(id)sender;
-(void)snSetDelegate:(id)sender;
-(int)snUnload:(id)sender;

@optional
-(void)snInputFinished:(id)sender;
@end

