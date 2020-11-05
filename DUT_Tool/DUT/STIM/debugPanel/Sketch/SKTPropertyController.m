//
//  SKTPropertyController.m
//  Sketch
//

//
//
#import "SKTDocument.h"
#import "SKTPropertyController.h"
#import "SKTSwitch.h"

@interface SKTPropertyController ()
{
    
    IBOutlet NSTextField *Prefix;
    IBOutlet NSTextField *tfClassid;
    IBOutlet NSButton *cbState;
}
-(IBAction)SetProperty:(id)sender;
-(IBAction)OnStateChange:(id)sender;
@end

extern NSString *SKTGraphicViewGraphicsBindingName;
extern NSString *SKTGraphicViewSelectionIndexesBindingName;
extern NSString *SKTGraphicViewGridBindingName;
static NSString *SKTGraphicViewGraphicsObservationContext = @"com.apple.SKTGraphicView.graphics";
static NSString *SKTGraphicViewIndividualGraphicObservationContext = @"com.apple.SKTGraphicView.individualGraphic";
static NSString *SKTGraphicViewSelectionIndexesObservationContext = @"com.apple.SKTGraphicView.selectionIndexes";
static NSString *SKTGraphicViewAnyGridPropertyObservationContext = @"com.apple.SKTGraphicView.anyGridProperty";


@implementation SKTPropertyController

- (id)init {
    self = [self initWithWindowNibName:@"SKTPropertyController"];
    if (self) {
        [self setWindowFrameAutosaveName:@"SKTPropertyController"];
    }
    return self;
}

+ (id)sharedPropertyController {
    static SKTPropertyController *sharedPropertyController = nil;
    if (!sharedPropertyController) {
        sharedPropertyController = [[SKTPropertyController allocWithZone:NULL] init];
    }
    return sharedPropertyController;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (void)textDidChange:(NSNotification *)notification
 {
     if ([[notification object] isEqual:tfClassid])
     {
         if (_editingGraphic1) {
             [_editingGraphic1 setIdentifier:[tfClassid integerValue]];
         }
     }else if ([[notification object] isEqual:Prefix])
     {
         if (_editingGraphic1) {
             [_editingGraphic1 setPrefix:[Prefix stringValue]];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"NewGraphicIDPrefixchangeNotification" object:[Prefix stringValue]];
         }
     }
 }
-(IBAction)OnStateChange:(id)sender
{
    if (_editingGraphic1) {
        [_editingGraphic1 setState:[sender state]];
    }
}
-(SKTGraphic*)_editingGraphic
{
    return _editingGraphic1;
}
-(void)setEditingGraphic:(SKTGraphic*)graphic
{
    if (_editingGraphic1) {
        [_editingGraphic1 release];
    }
    if (graphic) {
        _editingGraphic1=[graphic retain];
        [self LoadValue];
    }else
    {
        _editingGraphic1=nil;
        [self LoadValue];
    }
    
}
-(IBAction)SetProperty:(id)sender
{
    if (_editingGraphic1) {
        [_editingGraphic1 setIdentifier:[tfClassid integerValue]];
        [_editingGraphic1 setState:[cbState state]];
        [_editingGraphic1 setPrefix:[Prefix stringValue]];
    }
}
-(void)setPropertyEnabled:(BOOL)enabled
{
    [tfClassid setEnabled:enabled];
    [cbState setEnabled:enabled];
    [Prefix setEnabled:enabled];
}
-(void)LoadValue
{
    if (_editingGraphic1)
    {
        [tfClassid setIntegerValue:[_editingGraphic1 identifier]];
        [cbState setState:[_editingGraphic1 state]];
        [Prefix setStringValue:[_editingGraphic1 prefix]];
        [self setPropertyEnabled:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewGraphicIDPrefixchangeNotification" object:[Prefix stringValue]];
    }else
    {
        [tfClassid setStringValue:@""];
        [self setPropertyEnabled:NO];
    }
}
@end
