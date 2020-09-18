//
//  TMCompressImageController.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/16.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMCompressImageController.h"
#import "TMImageGenerator-Swift.h"
#import "TMCompressTool.h"

static NSString *apikey = @"tinypng_apikey";

@interface TMCompressImageController ()
@property (weak) IBOutlet NSTextField *pathTF;
@property (weak) IBOutlet NSButton *apiKeyButton;
@property (weak) IBOutlet NSTextField *apiKeyTF;
@property (weak) IBOutlet NSButton *generateButton;
@property (weak) IBOutlet NSProgressIndicator *tinypngLoadingView;


@property (weak) IBOutlet NSView *sepratorLine;
@property (weak) IBOutlet NSProgressIndicator *localLoadingView;


@end

@implementation TMCompressImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tinypngLoadingView.hidden = true;
    self.localLoadingView.hidden = true;
    
    self.sepratorLine.wantsLayer = true;
    self.sepratorLine.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    self.generateButton.enabled = false;
    
    NSString *apikey_ = [[NSUserDefaults standardUserDefaults] objectForKey:apikey];
    if (apikey_.length>0) {
        self.apiKeyTF.stringValue = apikey_;
    };
    
}
- (IBAction)requestAPIKEYOfTinyfy:(id)sender {
    
    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"https://tinify.cn/developers"]];
    
}
- (IBAction)selectPath:(id)sender {
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    //设置是否解析别名
    panel.resolvesAliases = NO;
    //设置是否允许选择文件夹
    panel.canChooseDirectories = YES;
    //设置是否允许选择文件
    panel.canChooseFiles = YES;
    //设置是否允许多选
    panel.allowsMultipleSelection = YES;
    panel.canCreateDirectories = true;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result==NSModalResponseOK) {
            
            NSString *path = [panel.URLs.firstObject.absoluteString substringFromIndex:7];
            
            self.pathTF.stringValue = path;
            
            self.generateButton.enabled = true;
            
        }
    }];
    
}

- (IBAction)startCompress:(id)sender{
    
    if (self.apiKeyTF.stringValue.length<=0) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"❌\n需要tinypng申请的key,去申请一个key";
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseCancel) {
                [self requestAPIKEYOfTinyfy:nil];
            }
        }];
        
        return;
    }
    
    if (self.apiKeyButton.state == 1) {//记住apikey
        [[NSUserDefaults standardUserDefaults] setObject:self.apiKeyTF.stringValue forKey:apikey];
    }
    
    self.tinypngLoadingView.hidden = false;
    [self.tinypngLoadingView startAnimation:nil];
    [self runScript];
    
}

-(void)runScript{
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"tiny_compress" ofType:@"py"];
    CocoaPython *script = [[CocoaPython alloc] initWithScrPath:scriptPath args:[self getScriptArg] complete:^(NSArray<NSString *> * _Nonnull arg1, NSString * _Nullable arg2) {
        NSLog(@"脚本回调 --- %@\n 脚本回调 --- %@",arg1,arg2);
        
        if (arg2 == nil){//压缩成功

            self.tinypngLoadingView.hidden = true;
            [self.tinypngLoadingView stopAnimation:nil];
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"图片压缩完成!!!✅";
            alert.alertStyle = NSAlertStyleInformational;
            [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSModalResponseCancel) {
                    [[NSWorkspace sharedWorkspace] openFile:self.pathTF.stringValue];
                }
            }];
        }
        
    }];
    
    [script runAsyncWithAsyncComlete:YES];
    
}

-(NSArray <NSString *>*)getScriptArg
{
    NSMutableArray *args = @[].mutableCopy;
    
    if (self.pathTF.stringValue.length>0) {
        [args addObject: self.pathTF.stringValue];
    }
    if (self.apiKeyTF.stringValue.length>0) {
        //"T3I7TzW5o0M4GU32GmQlebAHgPkwAsde"
        [args addObject:self.apiKeyTF.stringValue];        
    }
    
    return args;
}
- (IBAction)compress:(id)sender {
    
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    //设置是否解析别名
    panel.resolvesAliases = NO;
    //设置是否允许选择文件夹
    panel.canChooseDirectories = YES;
    //设置是否允许选择文件
    panel.canChooseFiles = NO;
    //设置是否允许多选
    panel.allowsMultipleSelection = YES;
    panel.canCreateDirectories = true;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
       if (result==NSModalResponseOK) {
           
           NSString *path = [panel.URLs.firstObject.absoluteString substringFromIndex:7];
           
//           NSURL *url = [NSURL fileURLWithPath:path];
           
           self.localLoadingView.hidden = false;
           [self.localLoadingView startAnimation:nil];
           
           [[TMCompressTool shareInstance] compressImagesWithDirectory:path outPath:nil completeBlock:^(NSString *outPath) {

               NSLog(@"图片压缩完成回调!!!!!");
               
               dispatch_async(dispatch_get_main_queue(), ^{

                   self.localLoadingView.hidden = true;
                   [self.localLoadingView stopAnimation:nil];
                   
                   NSAlert *alert = [[NSAlert alloc] init];
                   alert.messageText = @"图片压缩完成!!!✅";
                   alert.alertStyle = NSAlertStyleInformational;
                   [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                       if (returnCode == NSModalResponseCancel) {
                           [[NSWorkspace sharedWorkspace] openFile:path];
                       }
                   }];
               });
               
           }];
           
           
       }
    }];
    
}



@end
