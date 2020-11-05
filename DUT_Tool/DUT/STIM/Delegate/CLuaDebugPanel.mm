//
//  CLuaDebugPanel.cpp
//  LuaDebugPanel
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#include "CLuaDebugPanel.h"
#import "GraphicWinDelegate.h"
#import "SKTGraphic.h"
#import "SKTTextFile.h"
#import "GraphicHeader.h"

NSView* tool_getViewByID(NSView *supView ,unsigned long identifier);


CLuaDebugPanel::CLuaDebugPanel()
{
    m_dicGraphics=[[NSMutableDictionary alloc]init];
}

CLuaDebugPanel::~CLuaDebugPanel()
{
    if(m_dicGraphics) {
        [m_dicGraphics release];
        m_dicGraphics=nil;
    }
}

void CLuaDebugPanel::addgraphics(NSDictionary *dic)
{
    [m_dicGraphics setValuesForKeysWithDictionary:dic];
}

void CLuaDebugPanel::SetTextBoxString(unsigned long identifier, const char* str)
{
    
}

const char* CLuaDebugPanel::GetTextBoxString(char *viewname,unsigned long identifier)
{
    NSArray *graphics = [m_dicGraphics objectForKey:[NSString stringWithUTF8String:viewname]];
    for (id obj in graphics)
    {
        if([obj class] ==[SKTTextFile class])
        {
            SKTTextFile *textbox=(SKTTextFile*)obj;
            if(textbox.identifier==identifier)
                return [[textbox GetTextFileString] UTF8String];
        }
    }
    return NULL;
}

//void CLuaDebugPanel::setWinDelPointer(void* pp)
//{
//    p_windel = pp;
//}


void CLuaDebugPanel::SetGraphicState(char *szPrefix,unsigned long identifier,unsigned long state)
{
//    LuaDebugPanelDebugWinDelegate *m_del = (LuaDebugPanelDebugWinDelegate*)p_windel;
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithUnsignedLong:state],GraphicStateNotification,
                          [NSNumber numberWithUnsignedLong:identifier],GraphicIdentifierNotification,
                          [NSString stringWithCString:szPrefix encoding:NSASCIIStringEncoding],GraphicPrefixNotification,
                          nil];
    [notifCenter postNotificationName:SetGraphicStateNotification object:nil userInfo:dic];
}



NSView* tool_getViewByID(NSView *supView ,unsigned long identifier)
{
    SKTGraphic *m_g;
    id m_item;
    NSArray *arr_subview = [supView subviews];
    for (int i = 0; i < [arr_subview count]; i++) {
        m_item = [arr_subview objectAtIndex:i];
        if ([m_item isKindOfClass:[SKTGraphic class]]) {
            m_g = (SKTGraphic*)m_item;
            if ([m_g identifier]==identifier) {
                return m_item;
            }
        }else{
            id m_temp = tool_getViewByID(m_item, identifier);
            if(m_temp){
                return m_temp;
            }
        }
    }
    return nil;
}

