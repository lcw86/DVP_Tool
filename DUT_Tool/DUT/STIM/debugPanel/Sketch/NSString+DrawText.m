//
//  NSString+DrawText.m
//  LineView
//
//  Created by tombp on 12/23/16.
//  Copyright (c) 2016 tom.com. All rights reserved.
//

#import "NSString+DrawText.h"

@implementation NSString (DrawText)

-(void)drawInRectAtCenter:(NSRect)mRect withAttributes:(NSDictionary *)md
{
    CGSize mStrSize = [self sizeWithAttributes:md];
    NSRect strRect  = NSMakeRect(mRect.origin.x, mRect.origin.y, mStrSize.width, mStrSize.height);
    [self drawAtPoint:NSMakePoint(mRect.origin.x+(mRect.size.width-mStrSize.width)/2,
                                      mRect.origin.y+(mRect.size.height-mStrSize.height)/2)
           withAttributes:md];
//    [NSBezierPath strokeRect:strRect];
}

@end
