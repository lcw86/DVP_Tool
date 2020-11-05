//
//  zmqCenter.m
//  MainUI
//
//  Created by IvanGan on 16/1/7.
//  Copyright © 2016年 ___Intelligent Automation___. All rights reserved.
//

#import "zmqCenter.h"

@implementation zmqCenter
-(id)init
{
    self = [super init];
    req = new CRequester();
    return self;
}


-(int)connect:(int)port :(int)timeout
{
    int ret = -9999;
    if(port != -1)
    {
        if(req)
        {
            req->close();
            ret = req->connect([[NSString stringWithFormat:@"tcp://127.0.0.1:%d",port]UTF8String]);
            req->SetTimeOut(timeout*1000);
        }
    }
    return ret;
}

-(const char*)sendCmd:(const char *)cmd :(long long)size :(int)timeout
{
    int ret = 0;
    req->SetTimeOut(timeout*1000);
    ret = req->Request((void*)cmd, strlen(cmd),NO);
    char * buf = (char*)malloc(size);
    memset(buf, 0, size);
    usleep(1000);
    long len;
    req->Recv((void*)buf, &len);
    NSString * tmp = [NSString stringWithFormat:@"%s",buf];
    free(buf);
    return [tmp UTF8String];
}

-(int)disconnect
{
    int ret = -9999;
    if(req)
        ret = req->close();
    return ret;
}

-(void)dealloc
{
    if(req)
        req->close();
    [super dealloc];
}
@end
