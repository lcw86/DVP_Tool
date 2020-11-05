//
//  NTCViewController.m
//  STIM_Pannel
//
//  Created by ciwei luo on 2019/10/17.
//  Copyright © 2019 macdev. All rights reserved.
//


#import "NTCViewController.h"

@interface NTCViewController ()
@property (assign) IBOutlet NSButton *bit120_btn;
@property (assign) IBOutlet NSButton *bit121_btn;

@property (assign) IBOutlet NSButton *bit122_btn;


@property (copy) NSArray *switchBtns;
@end


@implementation NTCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.switchBtns = @[_bit120_btn,_bit121_btn,_bit122_btn];
     self.allSwitchs = @[@[_bit120_btn,_bit121_btn,_bit122_btn]];
}

- (IBAction)bitBtnsClick:(NSButton *)switchBtn {
    
    [self mutexSwitchsStateWithCurrentSelectedBtn1:switchBtn WithSwitchsArray:self.switchBtns];
    [CommandHandler generateCommandWithSwitchBtn:switchBtn text:@""];
    
}

@end
