//
//  LoadVC.m
//  DUT_Tool
//
//  Created by ciwei luo on 2020/8/21.
//  Copyright © 2020 ___Intelligent Automation___. All rights reserved.
//

#import "LoadVC.h"

@interface LoadVC ()
@property (assign) IBOutlet NSTextField *dfuPrFileView;
@property (assign) IBOutlet NSTextField *restoreView;
@property (assign) IBOutlet NSTextField *bundleDirView;
@property (assign) IBOutlet NSTextField *diagsFileView;
@property (assign) IBOutlet NSTextField *diagsRootView;
@property (assign) IBOutlet NSTextField *addressView;



@property (assign) IBOutlet NSButton *isCheckDiagsRoot;

@end

@implementation LoadVC{
    NSString *diagsFilePath;
    NSString *budelDirPath;
    
  
}


- (IBAction)loadPrFile:(NSButton *)btn {
    
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    //NSString *openPath =[[NSBundle mainBundle] resourcePath];
    NSString *openPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
    
    //    NSArray *fileType=[NSArray arrayWithObjects:@"csv",nil];
    //    [openPanel setAllowedFileTypes:fileType];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    
    [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
        if (result==NSFileHandlingPanelOKButton)
        {
            
            //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSArray *urls=[openPanel URLs];
            
            for (int i=0; i<[urls count]; i++)
            {
                NSString *csvPath = [[urls objectAtIndex:i] path];
                self.dfuPrFileView.stringValue = csvPath;
  
            }
            // });
        }
    }];
    
}


- (IBAction)budleDirPath:(NSButton *)btn {
    
 
    
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    //NSString *openPath =[[NSBundle mainBundle] resourcePath];
    NSString *openPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
    
    //    NSArray *fileType=[NSArray arrayWithObjects:@"csv",nil];
    //    [openPanel setAllowedFileTypes:fileType];

    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    
    [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
        if (result==NSFileHandlingPanelOKButton)
        {
            
            //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSArray *urls=[openPanel URLs];
            
            for (int i=0; i<[urls count]; i++)
            {
                NSString *csvPath = [[urls objectAtIndex:i] path];
                self.bundleDirView.stringValue = csvPath;
              
//                    file1 =[NSString stringWithFormat:@"%@",csvPath];
//                    NSMutableString * pstr = [[textView textStorage] mutableString];
//                    [pstr appendFormat:@"%@\n",file1];
//
                
            }
            // });
        }
    }];
    
}
- (IBAction)loadRestore:(NSButton *)sender {
    
    
    
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    //NSString *openPath =[[NSBundle mainBundle] resourcePath];
    NSString *openPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
    
    //    NSArray *fileType=[NSArray arrayWithObjects:@"csv",nil];
    //    [openPanel setAllowedFileTypes:fileType];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    
    [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
        if (result==NSFileHandlingPanelOKButton)
        {
            
            //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSArray *urls=[openPanel URLs];
            
            for (int i=0; i<[urls count]; i++)
            {
                NSString *csvPath = [[urls objectAtIndex:i] path];
                self.restoreView.stringValue = csvPath;
                
                //                    file1 =[NSString stringWithFormat:@"%@",csvPath];
                //                    NSMutableString * pstr = [[textView textStorage] mutableString];
                //                    [pstr appendFormat:@"%@\n",file1];
                //
                
            }
            // });
        }
    }];
    
}


- (IBAction)diagsFileBrowse:(NSButton *)btn {
    
    
    
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    //NSString *openPath =[[NSBundle mainBundle] resourcePath];
    NSString *openPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
    
    //    NSArray *fileType=[NSArray arrayWithObjects:@"csv",nil];
    //    [openPanel setAllowedFileTypes:fileType];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    
    [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
        if (result==NSFileHandlingPanelOKButton)
        {
            
            //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSArray *urls=[openPanel URLs];
            
            for (int i=0; i<[urls count]; i++)
            {
                NSString *csvPath = [[urls objectAtIndex:i] path];
                self.diagsFileView.stringValue = csvPath;
                
                
                //                    file1 =[NSString stringWithFormat:@"%@",csvPath];
                //                    NSMutableString * pstr = [[textView textStorage] mutableString];
                //                    [pstr appendFormat:@"%@\n",file1];
                //
                
            }
            // });
        }
    }];
    
}


- (IBAction)diagsRootClick:(NSButton *)sender {
    
    
    
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    //NSString *openPath =[[NSBundle mainBundle] resourcePath];
    NSString *openPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
    
    //    NSArray *fileType=[NSArray arrayWithObjects:@"csv",nil];
    //    [openPanel setAllowedFileTypes:fileType];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    
    [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
        if (result==NSFileHandlingPanelOKButton)
        {
            
            //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSArray *urls=[openPanel URLs];
            
            for (int i=0; i<[urls count]; i++)
            {
                NSString *csvPath = [[urls objectAtIndex:i] path];
                self.diagsRootView.stringValue = csvPath;
                
                //                    file1 =[NSString stringWithFormat:@"%@",csvPath];
                //                    NSMutableString * pstr = [[textView textStorage] mutableString];
                //                    [pstr appendFormat:@"%@\n",file1];
                //
                
            }
            // });
        }
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Load Diags File";
    // Do view setup here.
    
}

- (void)viewWillAppear {
    [super viewWillAppear];

    
    NSDictionary *dict = [self getJsonDatasWithFileName:@"restore.json"];
    NSString *filePath = dict[@"restoreFilePath"];
    
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if ([content containsString:@"\n"]) {
        NSArray *arr = [content componentsSeparatedByString:@"\n"];
        if (arr.count == 8) {
            [self serDefautPath:arr];
        }
    }
    
    // Do view setup here.
    
}

-(void)serDefautPath:(NSArray *)pathArr{
    self.dfuPrFileView.stringValue=pathArr[1];
    self.restoreView.stringValue=pathArr[2];
    self.bundleDirView.stringValue=pathArr[3];
    self.diagsFileView.stringValue=pathArr[4];
    self.diagsRootView.stringValue=pathArr[6];
    if ([pathArr[5] isEqualToString:@"1"]) {
        self.isCheckDiagsRoot.state = NSOnState;
    }else{
       self.isCheckDiagsRoot.state = NSOffState;
    }
    
    self.addressView.stringValue=pathArr[7];
    
  
}


-(void)close{
//    [_parentVC.window orderBack:nil];
    [_parentVC.window close];
    
}
-(id)getJsonDatasWithFileName:(NSString *)file{
    
    NSString *configfile = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    // NSString *configfile = [[NSBundle mainBundle] pathForResource:@"Property List.plist" ofType:nil];
    
    //    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    //    NSString *eCodePath=[desktopPath stringByDeletingLastPathComponent];
    //    NSString *configfile=[eCodePath stringByAppendingPathComponent:@"pinList.json"];
    
    //    if (![[NSFileManager defaultManager] fileExistsAtPath:configfile]) {
    //        [MyEexception RemindException:@"check fail" Information:@"not found file"];
    //        [NSApp terminate:nil];E
    //
    //    }
    NSString* items = [NSString stringWithContentsOfFile:configfile encoding:NSUTF8StringEncoding error:nil];
    if (items.length<10) {
        return nil;
    }
    NSData *data= [items dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    //    effDict = jsonObject;
    return jsonObject;
}

- (IBAction)applyClick:(NSButton *)btn {
    
    NSString *budleDirPath = self.bundleDirView.stringValue;
    NSString *restoreFile = self.restoreView.stringValue;
    NSString *diagsFilePath = self.diagsFileView.stringValue;
    NSString *address = self.addressView.stringValue;
    NSString *prFile = self.dfuPrFileView.stringValue;
    NSString *diagsRoot = self.diagsRootView.stringValue;
    
//    nss
    
    if (!(budleDirPath.length && diagsFilePath.length&&prFile.length&&address.length)) {
        return;
    }
    
    LoadMode *loadMode = [[LoadMode alloc]init];
    loadMode.prFile = prFile;
    loadMode.restoreFile = restoreFile;
    loadMode.diagsBinary = budleDirPath;
    loadMode.iBootFile = diagsFilePath;
    loadMode.usbArr = address;
    loadMode.isCheckDiagsRoot = [NSString stringWithFormat:@"%ld",(long)_isCheckDiagsRoot.state];
    loadMode.diagsRoot =diagsRoot;
    
    
    if (self.loadVCDelegate && [self.loadVCDelegate respondsToSelector:@selector(LoadVCApplyClickWithLoadMode:)]) {

        [self.loadVCDelegate LoadVCApplyClickWithLoadMode:loadMode];
    }
    
//    [self dismissController:self];
    
    [self close];
}

- (IBAction)btnEnterDiags:(NSButton *)btn {
    
    
    
    NSString *budleDirPath = self.bundleDirView.stringValue;
    NSString *restoreFile = self.restoreView.stringValue;
    NSString *diagsFilePath = self.diagsFileView.stringValue;
    NSString *address = self.addressView.stringValue;
    NSString *prFile = self.dfuPrFileView.stringValue;
    NSString *diagsRoot = self.diagsRootView.stringValue;
    
    //    nss
    
    if (!(budleDirPath.length && diagsFilePath.length&&prFile.length&&address.length)) {
        return;
    }
    
    LoadMode *loadMode = [[LoadMode alloc]init];
    loadMode.prFile = prFile;
    loadMode.restoreFile = restoreFile;
    loadMode.diagsBinary = budleDirPath;
    loadMode.iBootFile = diagsFilePath;
    loadMode.usbArr = address;
    loadMode.isCheckDiagsRoot = [NSString stringWithFormat:@"%ld",(long)_isCheckDiagsRoot.state];
    loadMode.diagsRoot =diagsRoot;
    
    
    if (self.loadVCDelegate && [self.loadVCDelegate respondsToSelector:@selector(LoadVCEnterDiagsClickWithLoadMode:)]) {
        
        [self.loadVCDelegate LoadVCEnterDiagsClickWithLoadMode:loadMode];
    }
    
    [self close];
}


- (IBAction)cancel:(NSButton *)btn {
    [self close];
}

@end
