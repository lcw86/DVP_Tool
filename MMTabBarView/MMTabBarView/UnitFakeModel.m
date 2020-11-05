//
//  UnitFakeModel.m
//  DUT
//
//  Created by Ryan on 11/2/15.
//  Copyright © 2015 ___Intelligent Automation___. All rights reserved.
//

#import "UnitFakeModel.h"

@implementation UnitFakeModel

@synthesize title = _title;
@synthesize largeImage = _largeImage;
@synthesize icon = _icon;
@synthesize iconName = _iconName;

@synthesize isProcessing = _isProcessing;
@synthesize objectCount = _objectCount;
@synthesize objectCountColor = _objectCountColor;
@synthesize showObjectCount = _showObjectCount;
@synthesize isEdited = _isEdited;
@synthesize hasCloseButton = _hasCloseButton;

- (id)init {
    if ((self = [super init])) {
        _isProcessing = NO;
        _icon = nil;
        _iconName = nil;
        _largeImage = nil;
        _objectCount = 2;
        _isEdited = NO;
        _hasCloseButton = YES;
        _title = [@"Xavier1" copy];
        _objectCountColor = nil;
        _showObjectCount = NO;
    }
    return self;
}

//-(void)dealloc {
//
//    [_title release], _title = nil;
//    [_icon release], _icon = nil;
//    [_iconName release], _iconName = nil;
//    [_largeImage release], _largeImage = nil;
//    [_objectCountColor release], _objectCountColor = nil;
//
//    [super dealloc];
//}

@end
