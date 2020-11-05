

#import "SKTToolPaletteController.h"
#import "SKTCircle.h"
#import "SKTLine.h"
#import "SKTRectangle.h"
#import "SKTButton.h"
#import "SKTText.h"
#import "SKTSwitch.h"
#import "SKTIOName.h"
#import "SKTColorButton.h"
#import "SKTAppDelegate.h"
#import "SKTSwitch2.h"
#import "SKTSwitch1.h"
#import "SKTSwitch4.h"
#import "SKTTextFile.h"
enum {
    SKTArrowToolRow = 0,
    SKTRectToolRow,
    SKTCircleToolRow,
    SKTLineToolRow,
    SKTTextToolRow,
};

NSString *SKTSelectedToolDidChangeNotification = @"SKTSelectedToolDidChange";
NSString *SKTBackGrounpNotification = @"SKTBackGrounpNotification";

@implementation SKTToolPaletteController

+ (id)sharedToolPaletteController {
    static SKTToolPaletteController *sharedToolPaletteController = nil;

    if (!sharedToolPaletteController) {
        sharedToolPaletteController = [[SKTToolPaletteController allocWithZone:NULL] init];
    }

    return sharedToolPaletteController;
}

- (id)init {
    self = [self initWithWindowNibName:@"ToolPalette"];
    if (self) {
        [self setWindowFrameAutosaveName:@"ToolPalette"];
    }
    return self;
}

- (void)windowDidLoad {
    NSArray *cells = [toolButtons cells];
    NSUInteger i, c = [cells count];
    
    [super windowDidLoad];

    for (i=0; i<c; i++) {
        [[cells objectAtIndex:i] setRefusesFirstResponder:YES];
    }
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];

    // Interface Builder (IB 2.4.1, anyway) won't let us set the window's width to less than 59 pixels, but we really only need 42.
    [[self window] setContentSize:[toolButtons frame].size];
}

- (IBAction)selectToolAction:(id)sender {
//    NSInteger row = [toolButtons selectedRow];
//    if (row == SKTRectToolRow) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:SKTBackGrounpNotification object:self];
//    }else
//    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SKTSelectedToolDidChangeNotification object:self];
//    }
}
- (Class)currentGraphicClass {
    NSInteger row = [toolButtons selectedRow];
    Class theClass = nil;
    if (row == 1) {
        theClass = row;
    } else if (row == 2) {
        theClass = [SKTText class];
    }
//    } else if (row == 3) {
//        SKTAppDelegate *d = (SKTAppDelegate *)[[NSApplication sharedApplication] delegate]; }
    else if (row == 3) {
        theClass=[SKTColorButton class];
//        theClass = 4;
    }else if (row==4)
    {
        theClass = [SKTSwitch class];
    }
    else if (row==5)
    {
        theClass = [SKTSwitch1 class];
    }
    else if (row==6)
    {
        theClass = [SKTSwitch2 class];
    }
    else if (row==7)
    {
        theClass = [SKTSwitch4 class];
    }
    else if(row==8)
    {
        theClass = [SKTButton class];
    }
    else if(row==9)
    {
        theClass = [SKTTextFile class];
    }

    return theClass;
}

- (void)selectArrowTool {
    [toolButtons selectCellAtRow:SKTArrowToolRow column:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:SKTSelectedToolDidChangeNotification object:self];
}

@end
