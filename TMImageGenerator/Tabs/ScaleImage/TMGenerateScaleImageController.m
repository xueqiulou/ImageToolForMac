//
//  TMGeneratoeScaleImageController.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/7.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMGenerateScaleImageController.h"
#import <Automator/Automator.h>
#import "TMImageTools.h"
#import "WebPImage.h"
#import "TMCompressTool.h"

@interface TMGenerateScaleImageController ()
@property (weak) IBOutlet NSButton *x1button;
@property (weak) IBOutlet NSButton *x2button;
@property (weak) IBOutlet NSButton *x3button;
@property (weak) IBOutlet NSTextField *pathTextField;//图片目录
@property (weak) IBOutlet NSTextField *exportPathTF;//图片导出目录

@property (strong,nonatomic) NSMutableArray *imagePaths;

@property (assign,nonatomic) BOOL isSpecifyExportDir;
@property (assign,nonatomic) BOOL isSelectOnePicture;
@property (strong,nonatomic) NSMutableString *exportPath;
@property (weak) IBOutlet NSButton *isCompressButton;
@property (weak) IBOutlet NSProgressIndicator *loadingView;
@property (weak) IBOutlet NSTextField *loadingLabel;
@property (weak) IBOutlet NSButton *generateButton;
@property (weak) IBOutlet NSStackView *alertStackView;

///是否生成 1x/2x/3x 图
@property (assign,nonatomic) BOOL contain1x;
@property (assign,nonatomic) BOOL contain2x;
@property (assign,nonatomic) BOOL contain3x;

@end

@implementation TMGenerateScaleImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePaths = @[].mutableCopy;
    
    self.generateButton.enabled = false;
    
}

///判断生成图片按钮是否可点击
-(void)judgeButtonEnable
{
    if(self.pathTextField.stringValue.length>0 &&
       self.exportPathTF.stringValue.length>0){
        self.generateButton.enabled = true;
    }else{
        self.generateButton.enabled = false;
    }
}


- (IBAction)selectDir:(id)sender {
    
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
            
            if (![path hasSuffix:@"/"]){//不是目录
                if ([[path pathExtension] isEqualTo:@"webp"]||
                    [[path pathExtension] isEqualTo:@"png"]||
                    [[path pathExtension] isEqualTo:@"jpg"]) {
                    self.isSelectOnePicture = true;
                }else{
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = @"选择文件不是图片";
                    alert.alertStyle = NSAlertStyleInformational;
                    [alert runModal];
                    return;
                }
            }
            NSLog(@"%@",panel.URLs);
            
            self.pathTextField.stringValue = [panel.URLs.firstObject.absoluteString substringFromIndex:7];
            [self judgeButtonEnable];
        }
    }];
}
- (IBAction)generate:(id)sender {
    //获取要处理的图片数据
    [self enumerator:self.pathTextField.stringValue];
    //处理图片
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{2
    
    //动画loading
    [self.loadingView startAnimation:nil];
    //提示语
    self.loadingLabel.stringValue = @"正在生成图片...";
    
    self.alertStackView.hidden = false;
    
    if (self.isSpecifyExportDir) {
        self.exportPath = [[NSMutableString alloc]initWithString:self.exportPathTF.stringValue];
    }else{
        self.exportPath = [[NSMutableString alloc]initWithString:self.pathTextField.stringValue];
    }
    
    self.contain1x = self.x1button.state==1;
    self.contain2x = self.x2button.state==1;
    self.contain3x = self.x3button.state==1;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self handleFiles:self.imagePaths];
    });
    
}

- (IBAction)selectExportDir:(id)sender {
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
            NSLog(@"%@",panel.URLs);
            self.exportPathTF.stringValue = [panel.URLs.firstObject.absoluteString substringFromIndex:7];
            self.isSpecifyExportDir = true;
            
            [self judgeButtonEnable];
        }
    }];
    
    
}

-(void)enumerator:(NSString*)path{
    
    if (self.isSelectOnePicture){
        [self.imagePaths addObject:path];
        return;
    }
    
    //文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    //文件夹路径
    NSString *home = path;
    //枚举器
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:home];
    
    //遍历文件夹内部所有txt文档 ，读取内容
    NSString *filename;
    while (filename = [direnum nextObject]) {
        NSLog(@"-----%@%@",home,filename);
        if ([[filename pathExtension] isEqualTo:@"webp"]||
            [[filename pathExtension] isEqualTo:@"png"]||
            [[filename pathExtension] isEqualTo:@"jpg"]) {
            [self.imagePaths addObject:[home stringByAppendingString:filename]];
        }
    }
}

-(void)handleFiles:(NSArray*)fileList
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.tipLabel.stringValue = @"生成中...";
    });
    
    for (int i = 0; i < fileList.count; i++) {

        NSString * filePath = fileList[i];
        NSString * exestr = [filePath lastPathComponent];
        NSString *fileName = [exestr stringByDeletingPathExtension];
        NSString * type = [filePath pathExtension];
        

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSData * imageData = [fileManager contentsAtPath:filePath];
        CGImageRef imageRef3x = nil;
        NSSize imageSize = NSMakeSize(0, 0);
        
        if (([type isEqualToString:@"png"]) || ([type isEqualToString:@"jpg"]) ) {
            NSImage * pendingImage = [[NSImage alloc]initWithData:imageData];
            imageSize = pendingImage.size;
            imageRef3x = createCGImageRefFromNSImage(pendingImage);
        }
        
        if (([type isEqualToString:@"webp"])) {
            imageRef3x = CreateImageForData(imageData);
            
            imageSize.height = CGImageGetHeight(imageRef3x);
            imageSize.width = CGImageGetWidth(imageRef3x);
        }
        
        if (imageRef3x == nil) {
            continue;
        }
        
        NSMutableString * address = [[NSMutableString alloc] initWithFormat:@"%@%@",self.exportPath,@"ScaleImages/"];
        NSError *error;
        [fileManager createDirectoryAtPath:address withIntermediateDirectories:true attributes:nil error:&error];
        if (error){
            NSLog(@"error---%@",error);
        }
        
        if (self.contain3x) {
            NSString * extraStr = @"@3x";
            NSString *pathOf3x = [NSString stringWithFormat:@"%@/%@%@.png",address,fileName,extraStr];
            saveImagepng(imageRef3x, pathOf3x);
        }
        if (self.contain2x) {
            NSString * extraStr = @"@2x";
            CGImageRef imageRef2x = createScaleImageByXY(imageRef3x,imageSize.width*2/3, imageSize.height*2/3);
            NSString *pathOf2x = [NSString stringWithFormat:@"%@/%@%@.png",address,fileName,extraStr];
            saveImagepng(imageRef2x, pathOf2x);
        }
        
        if (self.contain1x) {
            NSString * extraStr = @"";
            CGImageRef imageRef1x = createScaleImageByXY(imageRef3x,imageSize.width*1/3, imageSize.height*1/3);
            NSString *pathOf1x = [NSString stringWithFormat:@"%@/%@%@.png",address,fileName,extraStr];
            saveImagepng(imageRef1x, pathOf1x);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            self.progress.doubleValue = (i + 1.0) * 100 /(float)fileList.count;
        });
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *path = [self.exportPath stringByAppendingPathComponent:@"ScaleImages/"];
        
        if (self.isCompressButton.state == 1){//需要压缩图片
            //提示语
            self.loadingLabel.stringValue = @"正在压缩图片...";
            //压缩图片
            [[TMCompressTool shareInstance] compressImagesWithDirectory:path outPath:nil completeBlock:^(NSString *outPath) {
                //压缩完成回调
                dispatch_async(dispatch_get_main_queue(), ^{
                    //停止动画
                    [self.loadingView stopAnimation:nil];
                    self.alertStackView.hidden = true;
                    self.pathTextField.stringValue = @"";
                    self.exportPathTF.stringValue = @"";
                    self.generateButton.enabled = false;
                    
                    NSLog(@"压缩完成回调");
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
        }else{
            //停止动画
            [self.loadingView stopAnimation:nil];
            self.alertStackView.hidden = true;
            self.pathTextField.stringValue = @"";
            self.exportPathTF.stringValue = @"";
            self.generateButton.enabled = false;
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"图片已生成!!!✅";
            alert.alertStyle = NSAlertStyleInformational;
            [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSModalResponseCancel) {
                    [[NSWorkspace sharedWorkspace] openFile:path];
                }
            }];
            return;
        }
    });
}


@end
