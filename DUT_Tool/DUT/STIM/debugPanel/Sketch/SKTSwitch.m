/*
     File: SKTSwitch.m
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

#import "SKTSwitch.h"


@implementation SKTSwitch
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
-(NSArray*)getSwitchPoint
{
    NSPoint point[5];
    CGFloat bx=[self bounds].origin.x;
    CGFloat by=[self bounds].origin.y;
    CGFloat bw=[self bounds].size.width;
    CGFloat bh=[self bounds].size.height;
    double r=[self bounds].size.height>[self bounds].size.width?[self bounds].size.width:[self bounds].size.height;
    r=r/30;
    if (self.direction==0) {
    
        if ([self bounds].size.height<[self bounds].size.width){
            double half_height = [self bounds].size.height/2;
            double third_width = [self bounds].size.width/3;
            CGFloat sw_h=by+half_height;//-[self strokeWidth]*3;
            if ([self state]==0)
            {
                sw_h=by+half_height/4;
            }
            point[0]=NSMakePoint(bx, by+half_height);
            point[1]=NSMakePoint(bx+third_width, by+half_height);
            point[2]=NSMakePoint(bx+third_width*2+r,sw_h);
            point[3]=NSMakePoint(bx+third_width*2, by+half_height);
            point[4]=NSMakePoint(bx+[self bounds].size.width, by+half_height);
        }else
        {
            double half_width = [self bounds].size.width/2;
            double third_height = [self bounds].size.height/3;
            CGFloat sw_h=bx+half_width;//+[self strokeWidth]*3;
            if ([self state]==0)
            {
                sw_h=(bx+half_width)+half_width*2/3;
            }
            point[0]=NSMakePoint(bx+half_width, by);
            point[1]=NSMakePoint(bx+half_width, by+third_height);
            point[2]=NSMakePoint(sw_h,by+third_height*2+r);
            point[3]=NSMakePoint(bx+half_width, by+third_height*2);
            point[4]=NSMakePoint(bx+half_width, by+[self bounds].size.height);
        }
        
    }else{
        if ([self bounds].size.height<[self bounds].size.width){
            double half_height = [self bounds].size.height/2;
            double third_width = [self bounds].size.width/3;
            CGFloat sw_h=by+half_height;//-[self strokeWidth]*3;
            if ([self state]==0)
            {
                sw_h=by+half_height/4;
            }
            point[0]=NSMakePoint(bx+bw, by+half_height);
            point[1]=NSMakePoint(bx+third_width*2, by+half_height);
            point[2]=NSMakePoint(bx+third_width-r,sw_h);
            point[3]=NSMakePoint(bx+third_width, by+half_height);
            point[4]=NSMakePoint(bx, by+half_height);
        }else
        {
            double half_width = [self bounds].size.width/2;
            double third_height = [self bounds].size.height/3;
            CGFloat sw_h=bx+half_width;//+[self strokeWidth]*3;
            if ([self state]==0)
            {
                sw_h=(bx+half_width)+half_width*2/3;
            }
            point[0]=NSMakePoint(bx+half_width, by+bh);
            point[1]=NSMakePoint(bx+half_width, by+third_height*2);
            point[2]=NSMakePoint(sw_h,by+third_height-r);
            point[3]=NSMakePoint(bx+half_width, by+third_height);
            point[4]=NSMakePoint(bx+half_width, by);
        }
    }
    return [NSArray arrayWithObjects:
            [NSValue valueWithPoint:point[0]],
            [NSValue valueWithPoint:point[1]],
            [NSValue valueWithPoint:point[2]],
            [NSValue valueWithPoint:point[3]],
            [NSValue valueWithPoint:point[4]],
            nil];
}
- (NSBezierPath *)bezierPathForDrawing {
    NSArray *arrpoint=[self getSwitchPoint];
    double r=[self bounds].size.height>[self bounds].size.width?[self bounds].size.width:[self bounds].size.height;
    r=r/20;
//    if (r<=[self strokeWidth]+3)
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
    NSBezierPath *linepath = [NSBezierPath bezierPath];
    if ([self state]==1) {
        [[NSColor redColor] set];
    }else
    {
        [[NSColor blackColor] set];
    }
    [linepath setLineWidth:[self strokeWidth]*2];
    [linepath moveToPoint:[[arrpoint objectAtIndex:0] pointValue]];
    [linepath lineToPoint:[[arrpoint objectAtIndex:1] pointValue]];
    [linepath lineToPoint:[[arrpoint objectAtIndex:2] pointValue]];
    [linepath moveToPoint:[[arrpoint objectAtIndex:3] pointValue]];
    [linepath lineToPoint:[[arrpoint objectAtIndex:4] pointValue]];
    NSRect rect=NSMakeRect([[arrpoint objectAtIndex:1] pointValue].x-r/2,[[arrpoint objectAtIndex:1] pointValue].y-r/2, r, r);
    
    NSBezierPath *Ovalpath = [NSBezierPath bezierPath];
    
    [Ovalpath appendBezierPathWithOvalInRect:rect];
    rect=NSMakeRect([[arrpoint objectAtIndex:3] pointValue].x-r/2,[[arrpoint objectAtIndex:3] pointValue].y-r/2, r, r);
    [Ovalpath appendBezierPathWithOvalInRect:rect];
    [Ovalpath fill];
    [Ovalpath stroke];
    [linepath stroke];
    return nil;
}


//- (BOOL)isContentsUnderPoint:(NSPoint)point {
//    
//    // Just check to see if the point is in the path.
//    return [[self bezierPathForDrawing] containsPoint:point];
//
//}


@end
