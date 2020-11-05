//
//  StimTabViewController
//  STIM_Pannel
//
//  Created by ciwei luo on 2019/10/17.
//  Copyright © 2019 macdev. All rights reserved.
//



#import "StimTabViewController.h"
#import "CCELoadViewController.h"
#import "ELoadViewController.h"
#import "DMICViewController.h"
#import "ResAudioViewController.h"
#import "ORIONViewController.h"
#import "PowerViewController.h"
#import "RigelViewController.h"
#import "NTCViewController.h"
#import "ButtonPressViewController.h"
#import "DischargeViewController.h"
#import "LDCMViewController.h"
#import "PenroseViewController.h"


@interface StimTabViewController ()

@end


@implementation StimTabViewController

-(void)dealloc{
    [super dealloc];
    NSLog(@"%s",__func__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUPChildVC:[CCELoadViewController new]];
//    [self setUPChildVC:[ELoadViewController new]];
    [self setUPChildVC:[DMICViewController new]];
    [self setUPChildVC:[ResAudioViewController new]];
    [self setUPChildVC:[ORIONViewController new]];
    [self setUPChildVC:[PowerViewController new]];
    [self setUPChildVC:[RigelViewController new]];
    [self setUPChildVC:[NTCViewController new]];
    [self setUPChildVC:[ButtonPressViewController new]];
    [self setUPChildVC:[DischargeViewController new]];
    [self setUPChildVC:[LDCMViewController new]];
    [self setUPChildVC:[PenroseViewController new]];
   
}


-(void)setUPChildVC:(NSViewController *)vc{
    
    NSString *title = NSStringFromClass([vc class]);
    vc.title = title;
    
    if ([title containsString:@"ViewController"]) {
        NSRange range = [title rangeOfString:@"ViewController"];
        vc.title = [title substringToIndex:range.location];
    }
    
    [self addChildViewController:vc];
}


@end
