//
//  LoadVC.h
//  DUT_Tool
//
//  Created by ciwei luo on 2020/8/21.
//  Copyright © 2020 ___Intelligent Automation___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoadMode.h"
#define kNotificationOnLoadProfile            @"On_ReloadProfileByRecMsg"
//@interface LoadMode : NSObject
//@property (assign) NSString *prFile;
//@property (assign) NSString *diagsBinary;
//@property (assign) NSString *iBootFile;
//@property (assign) NSString *diagsRoot;
//@property (assign) NSString *usbArr;
//@property  BOOL isCheckDiagsRoot;


//@end

NS_ASSUME_NONNULL_BEGIN

@protocol LoadVCDelegate< NSObject>

//-(void)LoadVCApplyClickWithBudelDirPath:(NSString *)bundleDirPath diagsFilePath:(NSString *)diagsFilePath address:(NSString *)address prFile:(NSString *)prFile;

-(void)LoadVCApplyClickWithLoadMode:(LoadMode *)loadMode;
-(void)LoadVCEnterDiagsClickWithLoadMode:(LoadMode *)loadMode;
@end


@interface LoadVC : NSViewController
-(void)serDefautPath:(NSArray *)pathArr;
@property (nonatomic,strong)NSWindowController *parentVC;
@property(assign)id<LoadVCDelegate>loadVCDelegate;
@end

NS_ASSUME_NONNULL_END
