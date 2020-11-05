//
//  SKTPropertyController.h
//  Sketch
//

//
//

#import <Cocoa/Cocoa.h>
#import "SKTGraphic.h"

@interface SKTPropertyController : NSWindowController
{

    NSObject *_graphicsContainer;
    NSString *_graphicsKeyPath;
    NSObject *_selectionIndexesContainer;
    NSString *_selectionIndexesKeyPath;
@public
    SKTGraphic *_editingGraphic1;
}
+ (id)sharedPropertyController;
-(void)setEditingGraphic:(SKTGraphic*)graphic;

///[SKTSwitch class]

@end
