//
//  CLuaDebugPanel.h
//  LuaDebugPanel
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#ifndef __LuaDebugPanel__CLuaDebugPanel__
#define __LuaDebugPanel__CLuaDebugPanel__

#include <iostream>
#import <Foundation/Foundation.h>
//#import <CoreLib/SerialportEx.h>

#import "LuaDebugPanelDebugWinDelegate.h"

class CLuaDebugPanel {
public:
    CLuaDebugPanel();
    ~CLuaDebugPanel();
    void CreateGraphcics(char *szPrefix);
    void SetGraphicState(char *szPrefix,unsigned long identifier,unsigned long state);
    const char* GetTextBoxString(char *viewname,unsigned long identifier);
    void SetTextBoxString(unsigned long identifier, const char* str);
    void addgraphics(NSDictionary *dic);
    void handlernotification(NSDictionary *dic);

//    void setWinDelPointer(void* pp);
//    void* p_windel;
public:
    NSMutableDictionary * m_dicGraphics;
    
private:

};


#endif /* defined(__LuaDebugPanel__CLuaDebugPanel__) */
