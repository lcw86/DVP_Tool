//
//  LoadMode.h
//  DUT_Tool
//
//  Created by ciwei luo on 2020/8/21.
//  Copyright © 2020 ___Intelligent Automation___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadMode : NSObject
@property (assign) NSString *prFile;
@property (assign) NSString *restoreFile;
@property (assign) NSString *diagsBinary;
@property (assign) NSString *iBootFile;
@property (assign) NSString *diagsRoot;
@property (assign) NSString *usbArr;
@property  (assign) NSString * isCheckDiagsRoot;
@end

NS_ASSUME_NONNULL_END
