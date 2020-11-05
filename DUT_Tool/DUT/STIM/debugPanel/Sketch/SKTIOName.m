/*
     File: SKTIOName.m
 Abstract: A graphic object to represent a circle.
  Version: 1.8
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "SKTIOName.h"


@implementation SKTIOName
-(instancetype)init
{
    self=[super init];
    if (self) {
        [super setAngle:1];
    }
    return self;
}

- (BOOL)isDrawingFill {
    
    // You can't fill a line.
    return YES;
    
}


- (BOOL)isDrawingStroke {
    
    // You can't not stroke a line.
    return YES;
    
}
- (NSBezierPath *)bezierPathForDrawing {
    double r=[self bounds].size.height>[self bounds].size.width?[self bounds].size.width:[self bounds].size.height;
    r=r/20;
    if (r<=[self strokeWidth]+3)
    {
        r=[self strokeWidth]*3;
    }
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    [path setLineWidth:[self strokeWidth]];
    if([self isDrawingFill])
    {
        [[self fillColor] set];
        [path fill];
    }
    [[self strokeColor] set];
    [path stroke];    
    [[self prefix] drawAtPoint:NSMakePoint(self.bounds.origin.x+3,self.bounds.origin.y+2) withAttributes:nil];
    return nil;
}

-(void)drawRect:(NSRect)dirtyRect
{
    NSString * s1 = @"hello wrold";
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    //字体类型和大小
    [md setObject:[NSFont fontWithName:@"Arial" size:20] forKey:NSFontAttributeName];
    //字体颜色
    [md setObject:[NSColor yellowColor] forKey:NSForegroundColorAttributeName];
    [s1 drawAtPoint:NSMakePoint(200, 300) withAttributes:md];
    
    //(2)NSMutableAttributedString绘制带属性字符串
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:@"Big Nerd Ranch"];
    //字体类型和大小
    [s addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial Black" size:22] range:NSMakeRange(0,14)];
    //给字体加下划线
    [s addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0,3)];
    //字体颜色
    [s addAttribute:NSForegroundColorAttributeName value:[NSColor greenColor] range:NSMakeRange(0,8)];
    //上下移动
    [s addAttribute:NSSuperscriptAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, 5)];
    [s drawInRect:[self bounds]];
    
    //(3)CGContext
    
    NSPoint point = NSMakePoint(80, 80);
    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSelectFont (myContext, "Helvetica-Bold",1,kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (myContext, 0.5);
    CGContextSetTextDrawingMode (myContext, kCGTextFill);
    CGContextSetRGBFillColor (myContext, 0, 1, 0, 0.5);
    CGContextShowTextAtPoint (myContext,point.x , point.y, "www.google.com", 14);
}

//- (BOOL)isContentsUnderPoint:(NSPoint)point {
//    
//    // Just check to see if the point is in the path.
//    return [[self bezierPathForDrawing] containsPoint:point];
//
//}


@end
