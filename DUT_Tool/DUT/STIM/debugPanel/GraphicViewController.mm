//
//  GraphicViewController.m
//  documentViewTest
//

//

#import "GraphicViewController.h"
#import "GraphicView.h"
#include "CLuaDebugPanel.h"

@interface GraphicViewController ()

@end

@implementation GraphicViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        m_graphics=nil;
        m_backgrounpimage=nil;
        _zoomFactor = 1.0f;
    }
    return self;
}
- (void)dealloc
{
    if (m_graphics) {
        [m_graphics release];
        m_graphics=nil;
    }
    if (m_backgrounpimage) {
        [m_backgrounpimage release];
        m_backgrounpimage=nil;
    }
    [super dealloc];
}
+ (GraphicViewController *)newGraphicView:(NSString*)path
{
    GraphicViewController* Self=[[[self class] alloc] initWithNibName:@"GraphicViewController" bundle:[NSBundle bundleForClass:[self class]]];
    Self.path=path;
    if([Self LoadGraphicFile:path])
        return Self;
    [Self release];
    return nil;
}

- (void)viewDidLoad {
    [graphicview bin:self];
    [_zoomingScrollView bind:SKTZoomingScrollViewFactor toObject:self withKeyPath:@"zoomFactor" options:nil];
   }
- (NSArray *)graphics {
    return m_graphics;
}
- (NSImage *)backgrounpimage {
    return m_backgrounpimage;
}
-(BOOL)LoadGraphicFile:(NSString*)path
{
    NSArray *graphics = nil;
    NSImage *image = nil;
    NSData *data=[NSData dataWithContentsOfFile:path];
    if (data==nil) {
        return NO;
    }
    NSDictionary *properties = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    if (properties) {
        NSData *data=[properties objectForKey:@"BACKGROUND_IMAGE"];
        if (data) {
            image=[[NSImage alloc] initWithData:data];
        }
        NSArray *graphicPropertiesArray = [properties objectForKey:@"graphics"];
        graphics = [graphicPropertiesArray isKindOfClass:[NSArray class]]? [SKTGraphic graphicsWithProperties:graphicPropertiesArray]:[NSArray array];
        NSData *printInfoData = [properties objectForKey:@"printInfo"];
        
        //_printInfo = [printInfoData isKindOfClass:[NSData class]] ? [NSUnarchiver unarchiveObjectWithData:printInfoData] : [[[NSPrintInfo alloc] init] autorelease];
    }else
    {
        return NO;
    }
    if (graphics) {
        if(m_graphics)
        {
            [m_graphics release];
        }
        m_graphics=[graphics retain];
    }
    if (image) {
        if (m_backgrounpimage) {
            [m_backgrounpimage release];
        }
        m_backgrounpimage=[image retain];
        [image release];
    }
    return YES;
}
//
//- (void)viewWillTransitionToSize:(NSSize)newSize
//{
//    NSLog(@"viewWillTransitionToSize,%d\n",__LINE__);
//    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:graphicview.bounds
//                                                        options:NSTrackingMouseMoved |NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
//                                                          owner:graphicview
//                                                       userInfo:nil];
//    [graphicview addTrackingArea:area];
//    [graphicview becomeFirstResponder];
//    [area release];
//}

//- (void)viewDidAppear
//{
////    NSLog(@"viewDidAppear,%d\n",__LINE__);
//    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:graphicview.bounds
//                                                        options:NSTrackingMouseMoved |NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
//                                                          owner:graphicview
//                                                       userInfo:nil];
//    [graphicview addTrackingArea:area];
//    [graphicview becomeFirstResponder];
//    [area release];
//}
//- (void)viewWillAppear
//{
////    NSLog(@"viewWillAppear,%d\n",__LINE__);
//    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:graphicview.bounds
//                                                        options:NSTrackingMouseMoved |NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
//                                                          owner:graphicview
//                                                       userInfo:nil];
//    [graphicview addTrackingArea:area];
//    [graphicview becomeFirstResponder];
//    [area release];
//}
//- (void)updateViewConstraints
//{
//    NSLog(@"viewWillAppear,%d\n",__LINE__);
//    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:graphicview.bounds
//                                                        options:NSTrackingMouseMoved |NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
//                                                          owner:graphicview
//                                                       userInfo:nil];
//    [graphicview addTrackingArea:area];
//    [graphicview becomeFirstResponder];
//    [area release];
//}
//- (void)viewWillLayout
//{
//    NSLog(@"viewWillAppear,%d\n",__LINE__);
//    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:graphicview.bounds
//                                                        options:NSTrackingMouseMoved |NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
//                                                          owner:graphicview
//                                                       userInfo:nil];
//    [graphicview addTrackingArea:area];
//    [graphicview becomeFirstResponder];
//    [area release];
//}
//- (void)viewDidLayout
//{
//    NSLog(@"viewWillAppear,%d\n",__LINE__);
//    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:graphicview.bounds
//                                                        options:NSTrackingMouseMoved |NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
//                                                          owner:graphicview
//                                                       userInfo:nil];
//    [graphicview addTrackingArea:area];
//    [graphicview becomeFirstResponder];
//    [area release];
//}
@end
