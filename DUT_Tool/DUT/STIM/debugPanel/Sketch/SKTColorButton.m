//
//  SKTColorButton.m
//  Sketch
//

//
//

#import "SKTColorButton.h"

@implementation SKTColorButton
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setState:1];
    }
    return self;
}
- (BOOL)isDrawingFill {
    
    // You can't fill a line.
    return NO;
    
}


- (BOOL)isDrawingStroke {
    
    // You can't not stroke a line.
    return YES;
    
}
- (void)setBounds:(NSRect)abounds
{
    if (abounds.size.height>abounds.size.width) {
        abounds.size.width=abounds.size.height;
    }else
    {
        abounds.size.height=abounds.size.width;
    }
    [super setBounds:abounds];
}
- (NSBezierPath *)bezierPathForDrawing
{
//    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    NSColor *startColor;
    NSColor *endColor;
    if ([self state]>0)
    {
        startColor=[NSColor colorWithCalibratedRed:0.4 green:1 blue:0.4 alpha:1];
        endColor= [NSColor colorWithCalibratedRed:0 green:0.4 blue:0 alpha:1];
    }else
    {
        startColor=[NSColor colorWithCalibratedRed:0.9 green:1 blue:1 alpha:1];
        endColor= [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1];
    }
    NSColor *colors[2] = {startColor,endColor};
    CGFloat components[2*4];
    for (int i = 0; i < 2; i++) {
        CGColorRef tmpcolorRef = colors[i].CGColor;
        const CGFloat *tmpcomponents = CGColorGetComponents(tmpcolorRef);
        for (int j = 0; j < 4; j++) {
            components[i * 4 + j] = tmpcomponents[j];
        }
    }
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, NULL,2);
    CGColorSpaceRelease(space),space=NULL;//release
    
    CGPoint start;
    start.x=[self bounds].size.height/2+[self bounds].origin.x;
    start.y=[self bounds].size.height/2+[self bounds].origin.y;
    CGPoint end;
    end.x=[self bounds].size.height/2+[self bounds].origin.x;;
    end.y=[self bounds].size.height/2+[self bounds].origin.y;;
    CGFloat startRadius = 0.0f;
    CGFloat endRadius =0;
    if ([self bounds].size.height>[self bounds].size.width) {
        endRadius=[self bounds].size.width/2;
    }else
    {
        endRadius = [self bounds].size.height/2;
    }
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextBeginPath(context);
    CGContextDrawRadialGradient(context, gradient, start, startRadius, end, endRadius, 0);
    CGGradientRelease(gradient);
    CGContextFlush(context);
    CGContextStrokePath(context);
    gradient=NULL;
//    CGContextAddPath(gc, path);
    return nil;
}
@end
