//
//  zmqCenter.h
//  MainUI
//
//  Created by IvanGan on 16/1/7.
//  Copyright © 2016年 ___Intelligent Automation___. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Requester.hpp"

@interface zmqCenter : NSObject
{
    @private
    CRequester * req;
}

-(int)connect:(int)port :(int)timeout;
-(const char*)sendCmd:(const char *)cmd :(long long)size :(int)timeout;
-(int)disconnect;
@end
