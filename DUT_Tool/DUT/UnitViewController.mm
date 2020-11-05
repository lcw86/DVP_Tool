//
//  UnitViewController.m
//  DUT
//
//  Created by Ryan on 11/3/15.

//

#import "UnitViewController.h"
#import "GraphicHeader.h"
#include "AppDelegate.h"

#include "RegexKitLite.h"

@interface UnitViewController ()

@end

#define REQUEST_ADDRESS         @"REQUEST_ADDRESS"
#define SUBSCRIBER_ADDRESS      @"SUBSCRIBER_ADDRESS"

@implementation UnitViewController

@synthesize btnReturn1;
@synthesize btnNewLine1;

-(id)initialwithID:(int)ID
{
    //self = [super init];
    self = [super initWithNibName:@"UnitViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        mID = ID;
        pDUT = new CDUTController(mID);
        pDUT->SetDelegate(self);
        gg_buffer = [[NSMutableString alloc] init];
        gg_count = 0;
        
    }
    return self;
}


-(int)InitialPort:(NSDictionary *)diConfig
{
    pDUT->Close();
    NSLog(@"pDUT->Close()");
    pDUT->Initial([[diConfig valueForKey:kRequest] UTF8String], [[diConfig valueForKey:kSubscribe] UTF8String]);
    return 0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [txtBuffer setUsesFindBar:YES];
}

-(void)awakeFromNib
{
    NSLog(@"-1 Initial Uint in here!,ID: %d @%p",mID,self);
    [btnHwio setHidden:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SendCmdToDUT:) name:kNotificationDUTCmd object:nil];
    
}
-(void)dealloc
{
    if (gg_buffer)
    {
        [gg_buffer release];
    }
    
    NSLog(@"dealloc unitviewcontroller object-----");
    pDUT->Close();
    NSLog(@"dealloc unitviewcontroller object1-----");
    [super dealloc];
    
    if (pDUT)
    {
        delete pDUT;
        pDUT = nullptr;
    }
    NSLog(@"dealloc unitviewcontroller object2-----");
    
}


-(void)SendCmdToDUT:(NSNotification*)nf
{
    NSDictionary *userInfo = [nf userInfo] ;
    NSLog(@"====>>mID : %d",mID);
    if ([userInfo objectForKey:kSendDUTCmd])
    {
        if (mID == 0)
        {
            NSString * cmd = [userInfo objectForKey:kSendDUTCmd];
            [comboxCmd setStringValue:cmd];
            [self btSend:nil];
        }

    }
    else if ([userInfo objectForKey:kSendDUTDockConfigCmd])
    {
        if (mID == 20)
        {
            NSString * cmd = [userInfo objectForKey:kSendDUTDockConfigCmd];
            NSLog(@"====kSendDUTDockConfigCmd : %@",cmd);
            
            NSArray *arrayCmd = [cmd componentsSeparatedByString:@";"];
            
            for (NSString *sub_cmd in arrayCmd)
            {
                NSLog(@"===> sub_cmd :: %@",sub_cmd);
                if ([sub_cmd containsString:@"delay"])
                {
                    NSString *regexStr = @"delay\\s*([0-9]{1,}[.]?[0-9]*)";
                    NSString *matchedStr = [sub_cmd stringByMatching:regexStr capture:1L];
                    if(matchedStr)
                    {
                        [NSThread sleepForTimeInterval:[matchedStr floatValue]];
                    }
                }
                else
                {
                    [comboxCmd setStringValue:sub_cmd];
                    [self btSend:nil];
                }
            }
        }
    }
    else
    {
        [comboxCmd setStringValue:@"nil"];
    }
    
}


-(IBAction)btSend:(id)sender
{
    
    NSMutableString * cmd = [NSMutableString string];
    [cmd appendString:[comboxCmd stringValue]];
    if([btnReturn1 state]==NSOnState)
       [cmd appendString:@"\r"];
//    if([btnNewLine1 state]==NSOnState)
//        [cmd appendString:@"\n"];
    int ret = pDUT->WriteString([cmd UTF8String]);
    if (ret<0)
    {
        //NSRunAlertPanel(@"Write DUT", @"Write DUT%d failed,please check connection,or make sure TestEngine is running", @"OK", nil, nil,mID);
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"Write DUT--%d failed",mID];
        alert.informativeText = @"Replier not response,Please make sure TestEngine is running....";
        [alert runModal];
        [alert release];
    }
}


-(void)btRefresh
{
    int ret = pDUT->WriteString("reconnect");
    if (ret<0)
    {
        //NSRunAlertPanel(@"Write DUT", @"Write DUT%d failed,please check connection,or make sure TestEngine is running", @"OK", nil, nil,mID);
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"Write DUT%d failed",mID];
        alert.informativeText = @"Replier not response,Please make sure TestEngine is running.....";
        [alert runModal];
        [alert release];
    }
}



-(IBAction)btClear:(id)sender
{
    [txtBuffer setString:@""];
}



-(void)OnLog:(NSString *)str
{
    if (!str) return;
    NSMutableString * pstr = [[txtBuffer textStorage] mutableString];
    
    if ([str containsString:@"\n"])
    {
        [pstr appendFormat:@"%@",str];
    }
    else
    {
        [pstr appendFormat:@"%@\n",str];
    }
    
    if (1)//[str containsString:@"device -k gasgauge -p"]
    {
        [gg_buffer setString:@""];
        gg_count = 1;
        if ([str containsString:@"\n"])
        {
            [gg_buffer appendFormat:@"%@",str];
        }
        else
        {
            [gg_buffer appendFormat:@"%@\n",str];
        }
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setValue:gg_buffer forKey:@"KEY_GG"] ;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGGValue object
                                                                  :nil userInfo
                                                                  :dic] ;
        
    }
    //    if (gg_count == 1){
    //        if ([str containsString:@"\n"])
    //        {
    //            [gg_buffer appendFormat:@"%@",str];
    //        }
    //        else
    //        {
    //            [gg_buffer appendFormat:@"%@\n",str];
    //        }
    //
    //        if ([str containsString:@":-)"])
    //        {
    //            gg_count = 0;
    //            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    //            [dic setValue:gg_buffer forKey:@"KEY_GG"] ;
    //            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGGValue object
    //                                                                      :nil userInfo
    //                                                                      :dic] ;
    //        }
    //    }
    
    NSRange range = NSMakeRange([pstr length]-1,0);
    [txtBuffer scrollRangeToVisible:range];
    
    
    
}

#define TIME_STAMP_MATCH        @"[0-9A-Fa-f]+@R\\d"
#define TIME_STAMP_MATCH_CAP    @"([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])@R\\d"
-(NSString *)ReplaceTimeStamp:(NSString *)str
{
    return [str stringByReplacingOccurrencesOfRegex:TIME_STAMP_MATCH options:RKLMultiline inRange:NSMakeRange(0, [str length]-1) error:nil enumerationOptions:RKLRegexEnumerationNoOptions usingBlock:^NSString *(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString * cap = [NSString stringWithString:(NSString *)*capturedStrings];
        NSString * strSecond = [cap stringByMatching:TIME_STAMP_MATCH_CAP capture:1];
        NSString * strMS = [cap stringByMatching:TIME_STAMP_MATCH_CAP capture:2];
        if ((!str)||(!strMS)) {
            return @"";
        }
        
        long seconds = strtol([[@"0x" stringByAppendingString:strSecond] UTF8String], NULL, 16);
        long ms = strtol([[@"0x" stringByAppendingString:strMS] UTF8String], NULL, 16);
        NSTimeInterval time = seconds+(double)ms/1000.0;
        
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
        
        NSString * rep = [dateFormatter stringFromDate:date];

        [dateFormatter release];
        return rep;
        
    }];
}

-(void)OnData:(void *)bytes length:(long)len
{
    if (!len) return;
    NSLog(@"OnData len:%ld",len);
    if (len < 1) return;
    NSString * str;

    if ( (str= [[NSString alloc] initWithBytes:bytes length:len encoding:NSUTF8StringEncoding]) == nil)
    {
        NSLog(@"OnData bytes:nil");
        return;
    }

    NSLog(@"str:%@",str);
    NSString *str1 = [NSString stringWithString:str];
    str1 = [self ReplaceTimeStamp:str1];
    NSLog(@"str1:%@",str1);
    [self performSelectorOnMainThread:@selector(OnLog:)  withObject:str1 waitUntilDone:NO];
    [str release];
}


@end
