//
//  NSBezierPath+IAKBBezierPath.h
//  Keyboard
//
//  Created by tombp on 19/01/2017.
//  Copyright © 2017 tombp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (IAKBBezierPath)

+(void)IA_DrawKey_L_Shape_UL:(NSPoint)pUL CE:(NSPoint)pCE CC:(NSPoint)pCC CS:(NSPoint)pCS LR:(NSPoint)pLR UR:(NSPoint)pUR;

+(NSRect)getNineRectangleOutRectangle_Rect:(NSRect)mRect Index:(int)POS;
+(NSRect)getsameCenterXRectangle_Rect:(NSRect)mRec X:(float)xX;
+ (NSRect)getSquareInRect:(NSRect)rect;
+(void)IA_PreProcessPoints:(NSPoint*)pXX Len:(int*)nLen;
+(int)DrawArcCCW_PS:(NSPoint)pST PE:(NSPoint)pEN PJ:(NSPoint)pJU;
+(NSBezierPath*)IA_L_Shape:(NSPoint*)pXX Len:(int)nLen AR:(CGFloat)aR;
@end
