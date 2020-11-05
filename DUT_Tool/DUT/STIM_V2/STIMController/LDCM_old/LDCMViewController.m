//
//  LDCMViewController.m
//  DUT_Tool
//
//  Created by ciwei luo on 2020/8/24.
//  Copyright © 2020 ___Intelligent Automation___. All rights reserved.
//

#import "LDCMViewController.h"
#import "CommandHandler.h"

@interface LDCMViewController ()

@property (assign) IBOutlet NSButton *imagBtn1;

@property (assign) IBOutlet NSButton *imagBtn2;

@property (assign) IBOutlet NSButton *imagBtn3;
@property (assign) IBOutlet NSImageView *image1;
@property (assign) IBOutlet NSImageView *image2;

@end

@implementation LDCMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
//    NSInteger state = self.imagBtn1.state;
    NSLog(@"111");
}


- (IBAction)imagBtnsClick:(NSButton *)btn {
    
    
    [self setSwitch1BtnImage:btn];
    
    [CommandHandler generateCommandWithSwitchBtn:btn text:@""];
    
    
}

-(void)setSwitch1BtnImage:(NSButton *)switchBtn{
    NSInteger state = switchBtn.state;
    self.imagBtn1.state = state;
    self.imagBtn2.state = state;
    self.imagBtn3.state = state;
    if (state) {
        [self.imagBtn1 setImage:[NSImage imageNamed:@"Canvas 4"]];
        [self.imagBtn2 setImage:[NSImage imageNamed:@"Canvas 4"]];
        [self.imagBtn3 setImage:[NSImage imageNamed:@"Canvas 4"]];
    }else{
        [self.imagBtn1 setImage:[NSImage imageNamed:@"Canvas 1"]];
        [self.imagBtn2 setImage:[NSImage imageNamed:@"Canvas 1"]];
        [self.imagBtn3 setImage:[NSImage imageNamed:@"Canvas 1"]];
    }
}


- (IBAction)btnsClick:(NSButton *)btn {
    NSInteger btn_tag = btn.tag;
    if (btn_tag==1001) {
        [self.image1 setImage:[NSImage imageNamed:@"image1"]];
    }else if (btn_tag==1002){
        [self.image1 setImage:[NSImage imageNamed:@"image2"]];
    }else if (btn_tag==1003){
        [self.image1 setImage:[NSImage imageNamed:@"image3"]];
    }else if (btn_tag==1004){
        [self.image1 setImage:[NSImage imageNamed:@"image4"]];
    }else if (btn_tag==1005){
        [self.image1 setImage:[NSImage imageNamed:@"image5"]];
    }else if (btn_tag==1006){
        [self.image1 setImage:[NSImage imageNamed:@"image6"]];
    }else if (btn_tag==1007){
        [self.image1 setImage:[NSImage imageNamed:@"image7"]];
    }else if (btn_tag==1008){
        [self.image1 setImage:[NSImage imageNamed:@"image8"]];
    }else if (btn_tag==1009){
        [self.image2 setImage:[NSImage imageNamed:@"image9"]];
    }else if (btn_tag==1010){
        [self.image2 setImage:[NSImage imageNamed:@"image10"]];
    }else if (btn_tag==1011){
        [self.image2 setImage:[NSImage imageNamed:@"image11"]];
    }else if (btn_tag==1012){
        [self.image2 setImage:[NSImage imageNamed:@"image12"]];
    }
    
    
    [CommandHandler generateCommandWithSwitchBtn:btn text:@""];
    
}


-(void)resetRelays{
    self.imagBtn1.state = 0;
    self.imagBtn2.state = 0;
    self.imagBtn3.state = 0;
    
    [self.imagBtn1 setImage:[NSImage imageNamed:@"Canvas 1"]];
    [self.imagBtn2 setImage:[NSImage imageNamed:@"Canvas 1"]];
    [self.imagBtn3 setImage:[NSImage imageNamed:@"Canvas 1"]];
    
    [self.image1 setImage:[NSImage imageNamed:@"image8"]];
    [self.image2 setImage:[NSImage imageNamed:@"image12"]];
}

@end
