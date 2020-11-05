//
//  lockByFile.m
//  ErrorMsg
//
//  Created by IvanGan on 2017/3/14.
//  Copyright © 2017年 IvanGan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "lockByFile.h"
#include <stdio.h>

@implementation lockByFile

#define LOCK_FOLDER @"/vault/"

- (id)init:(int)count
{
    self = [super init];
    uut_count = count;
    lock_files = [[NSMutableArray alloc]init];
    NSString * fmt = @"%@msg_lock%d.lock";
//    lock_dic = [[NSMutableDictionary alloc]init];
    lock_arr = new FILE* [uut_count];
    memset(lock_arr, 0, sizeof(FILE*)*uut_count);
    for(int i=0; i<uut_count; i++)
        [lock_files addObject:[NSString stringWithFormat:fmt,LOCK_FOLDER,i]];

    [self createFiles];
    return self;
}

- (void)createFiles
{
    if([[NSFileManager defaultManager]fileExistsAtPath:LOCK_FOLDER])
    {
        for(int i=0; i<uut_count; i++)
        {
            @try {
                NSString * str = @"This is a lock file";
                [str writeToFile:[lock_files objectAtIndex:i] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            } @catch (NSException *exception) {
                NSLog(@"< lock file > : Write File Fail : %@",[lock_files objectAtIndex:i]);
            } @finally {

            }
        }
    }
}

- (int)lockFile:(int)slot
{
    NSString * path = [lock_files objectAtIndex:slot];
    NSLog(@"< lock file > Lock File : %d, %@", slot,path);

    FILE * fp;
    if(![[NSFileManager defaultManager]fileExistsAtPath:path])
        [[NSFileManager defaultManager]createFileAtPath:path contents:nil attributes:nil];
    if((fp=fopen([path UTF8String], "r+w")) == NULL)
    {
        NSLog(@"< lock file > Lock File : File Open error");
        return -1;
    }
    if(flock(fp->_file, LOCK_EX) != 0)
    {
        NSLog(@"< lock file > Lock File : File Locked error");
        return -2;
    }
    lock_arr[slot] = fp;
//    [lock_dic setValue:(__bridge id _Nullable)fp forKey:[NSString stringWithFormat:@"%d",slot]];
    NSLog(@"< lock file > Lock File : Success %d, %@", slot,path);
    return 0;
}

- (int)unlockFile:(int)slot
{
    NSString * path = [lock_files objectAtIndex:slot];
    NSLog(@"< lock file > unLock File : %d, %@", slot,path);

//    id fp_i = [lock_dic objectForKey:[NSString stringWithFormat:@"%d",slot]];
    FILE * fp = lock_arr[slot];
    if(fp)
    {
//        FILE * fp = (__bridge FILE *)fp_i;
        fclose(fp);
        flock(fp->_file, LOCK_UN);
        fp = NULL;

        lock_arr[slot] = NULL;
//        [lock_dic removeObjectForKey:[NSString stringWithFormat:@"%d",slot]];
        NSLog(@"< lock file > unLock File : Success %d, %@", slot,path);
    }
    else
        NSLog(@"< lock file > unLock File : Success %d, %@ has no this lock", slot,path);
    return 0;
}

- (void)lockAllFile
{
    NSLog(@"< lock file > Lock All File ");
    for(int i=0; i<uut_count; i++)
        [self lockFile:i];
}

- (void)unlockAllFile
{
    NSLog(@"< lock file > unLock All File ");
    for(int i=0; i<uut_count; i++)
        [self unlockFile:i];
}

- (void)dealloc
{
    [self unlockAllFile];
//    [lock_dic removeAllObjects];
    delete [] lock_arr;
    [lock_files removeAllObjects];
    [super dealloc];
}

@end
