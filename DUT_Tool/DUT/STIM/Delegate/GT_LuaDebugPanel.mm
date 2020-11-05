//
//  GT_LuaDebugPanel.m
//  LuaDebugPanel
//
//  Created by Louis on 13-11-12.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#import "GT_LuaDebugPanel.h"
//#include "LuaDebugPanel_global.h"
#import "GraphicHeader.h"

#define kNotificationGetUIInsValue         @"get_UI_Instrument_Value"



//TOLUA_API int  tolua_CLuaDebugPanel_lua_open (lua_State* tolua_S);
//TOLUA_API int  tolua_CLuaDebugPanel_Object_open (lua_State* tolua_S);



//TestEngine * pTestEngine=nil;
@implementation GT_LuaDebugPanel
//-(id)init
//{
//    self = [super init] ;
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addGraphicsArray:) name:@"loadnewgraphic" object:nil];
//    return self ;
//}
//
//- (void)dealloc
//{
//    [super dealloc];
//}

#pragma mark-DriverModule interface
-(NSString *)ModuleName           //模块名称说明
{
    return @"GT LuaDebugPanel" ;
}

-(int)RegisterModule:(id)sender
{
//    NSMutableDictionary * dic = (NSMutableDictionary *)sender;
////    lua_State * lua = (lua_State *)[[dic objectForKey:@"lua"] longValue];
////    pTestEngine = [dic objectForKey:@"TestEngine"];
//    int fixId = [[dic objectForKey:@"id"] intValue];
//    //Register FCT class
//    tolua_CLuaDebugPanel_lua_open(lua) ;
//    tolua_CLuaDebugPanel_Object_open(lua);
//
//    //Register Script
//    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
////    NSLog(@"......%@",[bundle resourcePath]) ;
//    NSString * str = [NSString stringWithFormat:@"package.path = package.path..';'..'%@'..'/?.lua'",[bundle resourcePath]];
//
//
//    CScriptEngine * se = (CScriptEngine *)[pTestEngine GetScripEngine:fixId];
//    int err = se->DoString([str UTF8String]);
//    err = se->DoString("luadebugpanel = require \"luadebugpanel\"");
//
//    if (err)
//    {
//        NSRunAlertPanel(@"Load Error", @"%s", @"OK", nil, nil,lua_tostring(se->m_pLuaState, -1));
//    }
//
//    if (fixId==0)
//    {
//        LuaDebugPanel=new CLuaDebugPanel();
//        NSString * strscript = [[NSBundle bundleForClass:[self class]] pathForResource:@"hidreport" ofType:@"lua"];
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGraphicCilck:) name:GraphicCilckNotification object:nil];
//
//        ListLuaFile([strscript UTF8String],"hidreport");
//
//    }
    return 0;
}

-(void)addGraphicsArray:(NSNotification*)nf
{
//    NSDictionary * dic = [nf userInfo];
//    LuaDebugPanel->addgraphics(dic);
}


- (void)onGraphicCilck:(NSNotification *)nf
{
    char cmd[255];
    NSDictionary * dic = [nf userInfo];
    NSString *sPrefix = [dic objectForKey:GraphicPrefixNotification];
    int nidentifier = [[dic objectForKey:GraphicIdentifierNotification] intValue];
    int nstate = [[dic objectForKey:GraphicStateNotification] intValue];
    NSString *strButtonBlindTextfile = [dic objectForKey:GraphicButtonBlindTextFileNotification];
   [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationGetUIInsValue object:nil];
//    NSString *strCount = [CTestContext::m_dicGlobal objectForKey:@"DebugPanelSelectCount"];
//    CScriptEngine * se = (CScriptEngine *)[pTestEngine GetScripEngine:strCount.intValue];
    sprintf(cmd, "luadebugpanel.onClickGraphic(\"%s\",%d,%d,\"%s\")",
            [sPrefix cStringUsingEncoding:NSASCIIStringEncoding],
            nidentifier,
            nstate,
            [strButtonBlindTextfile cStringUsingEncoding:NSASCIIStringEncoding]
            );


}

-(int)SelfTest:(id)sender          //模块自我测试
{
    return 0 ;
}

-(int)Load:(id)sender
{
//    if ([NSBundle loadNibNamed:@"LuaDebugPanelDebug" owner:self]==FALSE)
//        return -1 ;
    
    return 0 ;
}

-(int)Unload:(id)sender
{
    return 0 ;
}

@end
