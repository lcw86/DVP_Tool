//
//  lockByFile.h
//  ErrorMsg
//
//  Created by IvanGan on 2017/3/14.
//  Copyright © 2017年 IvanGan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lockByFile : NSObject
{
    NSMutableArray * lock_files;
//    NSMutableDictionary * lock_dic;
    FILE ** lock_arr;
    int uut_count;
}

- (id)init:(int)count;
- (void)createFiles;
- (int)lockFile:(int)slot;
- (int)unlockFile:(int)slot;
- (void)lockAllFile;
- (void)unlockAllFile;

@end
