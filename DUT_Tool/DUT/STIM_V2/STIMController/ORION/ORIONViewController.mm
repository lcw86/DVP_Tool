//
//  ORIONViewController
//  STIM_Pannel
//
//  Created by ciwei luo on 2019/10/17.
//  Copyright © 2019 macdev. All rights reserved.
//

#import "ORIONViewController.h"

#define kNotificationOnLoadProfile            @"On_ReloadProfileByRecMsg"

@interface ORIONViewController ()
@property (assign) IBOutlet NSButton *switchBtn1;
@property (assign) IBOutlet NSButton *switchBtn2;
@property (assign) IBOutlet NSButton *switchBtn3;

@property (copy) NSArray *switchBtns;

@property (assign) IBOutlet NSTextField *textF;
@property (assign) IBOutlet NSButton *setBtn;

@property (assign) IBOutlet NSButton *btnProvider;
@property (assign) IBOutlet NSButton *btnConsumer;
@property (assign) IBOutlet NSButton *btnOAB;


@end
typedef NS_ENUM(NSUInteger, OrionSwitchControlType) {
    OrionSwitchControlTypeOAB    = 0,
    OrionSwitchControlTypeProvider     = 1,
    OrionSwitchControlTypeConsumer            = 2,
};

@implementation ORIONViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.switchBtns = @[_switchBtn1,_switchBtn2,_switchBtn3];
    self.allSwitchs = @[@[_switchBtn1,_switchBtn2,_switchBtn3]];
    
}

-(void)setSwitchsStateWithType:(OrionSwitchControlType)type{
    for (int i=0; i<self.switchBtns.count; i++) {
        NSButton *btn = self.switchBtns[i];
        if (type == OrionSwitchControlTypeProvider) {
            
            btn.state=1;
        }else if(type == OrionSwitchControlTypeOAB){
            
            btn.state=0;
        }
        else if(type == OrionSwitchControlTypeConsumer){
            btn.state = btn.tag==1 ? 0 :1;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setSwitch1BtnImage:btn];
            });
        });
        
    }
  
}


-(void)sleepUntilMainTestFinish{
    
    [NSThread sleepForTimeInterval:1];
    while (1) {
        [NSThread sleepForTimeInterval:0.5];
        NSString *isTesting = [NSString stringWithContentsOfFile:KTestingFlag encoding:NSUTF8StringEncoding error:nil];//
        
        if ([isTesting isEqualTo:@"NO"]) {
            break;
        }
        
    }
}

- (IBAction)orionBtnClick:(NSButton *)switchBtn {
    NSString *btnTitle = switchBtn.title.uppercaseString;
    
    
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    
    
    if ([btnTitle containsString:@"PROVIDER"]) {
        
        if ([listCsvName valueForKey:@"MLBIsProvider_TEST"])
        {
            self.textF.stringValue = @"0";
            [self setSwitchsStateWithType:OrionSwitchControlTypeProvider];
            NSString *csvName = [listCsvName valueForKey:@"MLBIsProvider_TEST"];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
 
        }
        
        
    }else if ([btnTitle containsString:@"OAB"]){
        
        if ([listCsvName valueForKey:@"DisconnectOAB_TEST"])
        {
            self.textF.stringValue = @"0";
            [self setSwitchsStateWithType:OrionSwitchControlTypeOAB];
            NSString *csvName = [listCsvName valueForKey:@"DisconnectOAB_TEST"];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
            
//            [NSThread sleepForTimeInterval:8];

        }
        
    }else{
        
        if ([listCsvName valueForKey:@"MLBIsConsumer_TEST"])
        {
            self.textF.stringValue = @"0";
            [self setSwitchsStateWithType:OrionSwitchControlTypeConsumer];
            NSString *csvName = [listCsvName valueForKey:@"MLBIsConsumer_TEST"];
            NSLog(@"%@",csvName);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 csvName,@"Load_Profile_Debug",nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
  
            
        }
        
    }
    
    [self sleepUntilMainTestFinish];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self sleepUntilMainTestFinish];
//        });
//    });
//
    
    //    if ([btnTitle containsString:@"PROVIDER"]) {
    //        [self setSwitchsStateWithType:OrionSwitchControlTypeProvider];
    //    }else if ([btnTitle containsString:@"OAB"]){
    //        [self setSwitchsStateWithType:OrionSwitchControlTypeOAB];
    //    }else{
    //
    //    }
    //
    //    [CommandHandler generateCommandWithSwitchBtn:switchBtn text:@""];
}


- (IBAction)setBtnClick:(NSButton *)switchBtn {
    
    [CommandHandler generateCommandWithSwitchBtn:switchBtn text:self.textF.stringValue];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.textF.stringValue forKey:Set_ELoad1_CC];
    [[NSNotificationCenter defaultCenter] postNotificationName:StimSetNotification object
                                                              :nil userInfo
                                                              :dic] ;
}



@end
