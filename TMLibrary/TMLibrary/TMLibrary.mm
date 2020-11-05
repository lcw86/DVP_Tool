//
//  TMLibrary.c
//  TMLibrary
//
//  Created by Ryan on 15/5/25.
//  Copyright (c) 2015年 ___Intelligent Automation___. All rights reserved.
//

#include <stdio.h>
#include <Foundation/Foundation.h>
#include "PathManager.h"

#define CLI_CR_RED          "\033[31m"
#define CLI_CR_YELLOW       "\033[33m"
#define CLI_CR_CLOSE        "\033[0m"


#define SYSTEM_LOG_FILE     "tm"


static char fileLog[128]={0};

static int OpenSystemLog()
{
    @autoreleasepool {
        
    if (strlen(fileLog)!=0) {
        return 1;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd"];

    CPathManager * pm = CPathManager::sharedManager();
    
    NSError * err;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%s",pm->logPath()] withIntermediateDirectories:YES attributes:NULL error:&err]) {
        NSLog(@"%@",[err description]);
    }
    
    NSString * str = [NSString stringWithFormat:@"%s/TMLog_%@.log",pm->logPath(),[dateFormatter stringFromDate:[NSDate date]]];
    
    if (strlen(fileLog) == 0) {
        strcpy(fileLog, [str UTF8String]);  //Save Log file
    }
    
    }
    
    return 0;
}

int WriteLogFile(const char * fmt,va_list vl)
{
    @autoreleasepool {
        
    OpenSystemLog();
    FILE * f = fopen(fileLog, "a+");
    if (!f) {
        fprintf(stderr, "%sWrite system log file failed:%d\r\n%s",CLI_CR_RED,errno,CLI_CR_CLOSE);
        return -1;
    }
    vfprintf(f, fmt, vl);
    fclose(f);
    return 0;
    
    }
}

int tmPrintf(const char * fmt,...)
{
    @autoreleasepool {
        
    va_list argptr;
    int cnt;
    //第一个参数为指向可变参数字符指针的变量,第二个参数是可变参数的第一个参数,通常用于指定可变参数列表中参数的个数
    va_start(argptr,fmt);
    cnt=vprintf(fmt,argptr);
    
    WriteLogFile(fmt, argptr);
    
    //将存放可变参数字符串的变量清空
    va_end(argptr);
    return(cnt);
    }
}

int tmError(const char * fmt,...)
{
    @autoreleasepool {
        
    fprintf(stderr,"%s--->Error:\r\n\t%s",CLI_CR_RED,CLI_CR_CLOSE);
    
    
    va_list argfp;
    va_start(argfp,fmt);
    WriteLogFile(fmt, argfp);
    va_end(argfp);

    va_list argptr;
    int cnt;
    //第一个参数为指向可变参数字符指针的变量,第二个参数是可变参数的第一个参数,通常用于指定可变参数列表中参数的个数
    va_start(argptr,fmt);
    
    char * buffer = new char[strlen(fmt)+32];
    sprintf(buffer, "%s%s%s",CLI_CR_RED,fmt,CLI_CR_CLOSE);
    fmt = buffer;
    
    //cnt=vprintf(fmt,argptr);
    cnt=vfprintf(stderr, fmt, argptr);
    
    //将存放可变参数字符串的变量清空
    va_end(argptr);
    return(cnt);
    }
}


int tmGetCurrentPath(char * path)
{
    @autoreleasepool {
    //获取当前程序绝对路径
    const char * p = [[[NSBundle mainBundle] bundlePath] UTF8String];
    strcpy(path, p);
    return 0;
    }
}