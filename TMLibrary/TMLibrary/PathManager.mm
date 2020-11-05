//
//  PathManager.cpp
//  TMLibrary
//
//  Created by Ryan on 6/8/15.
//  Copyright (c) 2015 ___Intelligent Automation___. All rights reserved.
//

#include "PathManager.h"
#include "TMLibrary.h"

#include <Foundation/Foundation.h>


static CPathManager * defaultPathManager=new CPathManager();


CPathManager::CPathManager()
{
    strcpy(m_ModuleName, "TM");
    strcpy(m_ValutPath, "/Vault/Intelli_log");
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * err;
    BOOL b = [fm createDirectoryAtPath:[NSString stringWithFormat:@"%s",m_ValutPath] withIntermediateDirectories:YES attributes:NULL error:&err];
    if (!b) {
        fprintf(stderr, "\033[31mCreate %s directory failed! with reason:r\n\%s\r\n\033[0m",m_ValutPath,[[err description] UTF8String]);
    }
}

CPathManager::CPathManager(char * module)
{
    if (module) {
        strcpy(m_ModuleName, module);
    }
    else
    {
        strcpy(m_ModuleName, "TM");
    }
}

CPathManager::~CPathManager()
{
}

CPathManager * CPathManager::sharedManager()
{
    return defaultPathManager;
}

const char * CPathManager::vaultPath()
{
    return (const char *)m_ValutPath;
}
const char * CPathManager::mainPath()
{
    //获取当前程序绝对路径
    const char * p = [[[NSBundle mainBundle] bundlePath] UTF8String];
    NSString * tmp = [NSString stringWithUTF8String:p];
    //if([[tmp lastPathComponent]containsString:@".app"])
    if([[tmp lastPathComponent]rangeOfString:@".app"].location!=NSNotFound)
        tmp = [tmp stringByDeletingLastPathComponent];
    strcpy(m_MainPath, [tmp UTF8String]);
    return m_MainPath;
}

const char * CPathManager::logPath()
{
    return [[NSString stringWithFormat:@"%s/log",vaultPath()] UTF8String];
}

const char * CPathManager::blobPath()
{
    return [[NSString stringWithFormat:@"%s/blob",vaultPath()] UTF8String];
}

const char * CPathManager::profilePath()
{
    return [[NSString stringWithFormat:@"%s/profile",mainPath()] UTF8String];
}

const char * CPathManager::scriptPath()
{
    return [[NSString stringWithFormat:@"%s/script",mainPath()] UTF8String];
}

const char * CPathManager::configPath()
{
    return [[NSString stringWithFormat:@"%s/%s_config",mainPath(),m_ModuleName] UTF8String];
}

const char * CPathManager::driverPath()
{
    return [[NSString stringWithFormat:@"%s/Driver",mainPath()] UTF8String];
}