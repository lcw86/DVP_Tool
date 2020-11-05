//
//  NSString+DrawText.h
//  LineView
//
//  Created by tombp on 12/23/16.
//  Copyright (c) 2016 tom.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSStringDrawing.h>

@interface NSString (DrawText)

-(void)drawInRectAtCenter:(NSRect)mRect withAttributes:(NSDictionary *)md;

@end
