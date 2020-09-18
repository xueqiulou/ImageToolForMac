//
//  TMGenerateIconsController.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/7.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMGenerateIconsController.h"
#import "TMIconsCollectionItem.h"
#import "HeaderView.h"
#import "TMIconItem.h"
#import "TMIconsModel.h"
#import "TMCompressTool.h"

static NSString * countKey = @"count";

@interface TMGenerateIconsController ()<NSCollectionViewDataSource,NSCollectionViewDelegate,NSCollectionViewDelegateFlowLayout>
@property (weak) IBOutlet NSImageView *iconView;
@property (weak) IBOutlet  NSCollectionView *collectionView;
@property (strong,nonatomic) NSMutableArray *dataArr;
@property (weak) IBOutlet NSTextField *customTF;
@property (weak) IBOutlet NSButton *isCompressButton;

@property (assign,nonatomic) BOOL isInSandBox;

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSStackView *alertStack;
@property (weak) IBOutlet NSProgressIndicator *loadingView;


@end

@implementation TMGenerateIconsController

-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        
        NSMutableArray *array = @[
            @"40",
            @"58",
            @"60",
            @"80",
            @"87",
            @"120",
            @"180",
            @"1024"
        ].mutableCopy;
        
        NSInteger count1 = [[NSUserDefaults standardUserDefaults] integerForKey:countKey];
        
        if (count1>0) {
            
            for (NSUInteger index = array.count; index<count1; index++) {
                [array addObject:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"iconkey%zd",index+1]]];
            }
        }
        _dataArr = @[].mutableCopy;
        for (NSString *title in array) {
            TMIconsModel *model = [[TMIconsModel alloc]init];
            model.sizeWidth = title;
            model.isSelected = true;
            [_dataArr addObject:model];
        }
        
    }
    
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[TMIconItem class] forItemWithIdentifier:@"icon"];
 
    [self.collectionView reloadData];
    
}

-(BOOL)validateNumerStr:(NSString*)text{
    
    NSScanner* scan = [NSScanner scannerWithString:text];
    int val;
    BOOL result = [scan scanInt:&val] && [scan isAtEnd];
    return result;
}

//添加尺寸
- (IBAction)generateIcons:(id)sender {
    
    if (self.customTF.stringValue == nil ||
        self.customTF.stringValue.length == 0||
        ![self validateNumerStr:self.customTF.stringValue]||
        self.customTF.stringValue.intValue == 0){
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"请输入正确数值";
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        return;
    }
    
    TMIconsModel *model = [[TMIconsModel alloc] init];
    model.sizeWidth = self.customTF.stringValue;
    model.isSelected = true;
    
    [self.dataArr addObject: model];
    
    [[NSUserDefaults standardUserDefaults] setObject:model.sizeWidth forKey:[NSString stringWithFormat:@"iconkey%lu",(unsigned long)self.dataArr.count]];
    [[NSUserDefaults standardUserDefaults] setInteger:self.dataArr.count forKey:countKey];
    
    [self.collectionView reloadData];
    
}

//生成图片
- (IBAction)exportIcons:(id)sender {
    
    BOOL hasSelectedModel = false;
    for (TMIconsModel *model in self.dataArr) {
        if (model.isSelected){
            hasSelectedModel = true;
        }
    }
    if (!hasSelectedModel){
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"至少选择一个尺寸";
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        return;
    }

    NSImage *image = self.iconView.image;
    if (image == nil){
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"请拖入一张1024*1024图片";
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        return;
    }
    
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
//    NSInteger result = [panel runModal];
//    if (result==NSModalResponseOK) {
//        NSLog(@"%@",panel.URLs);
//
//        //生成icons
//        [self generateIconsWithDic:self.dataArr originalImage:image directoryPath:[[NSString stringWithFormat:@"%@",panel.URLs.firstObject] substringFromIndex:7]];
//
//    }
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result==NSModalResponseOK) {
            NSLog(@"%@",panel.URLs);
            
            self.alertStack.hidden = false;
            self.titleLabel.stringValue = @"正在生成图片...";
            [self.loadingView startAnimation:nil];
            //生成icons
            [self generateIconsWithDic:self.dataArr originalImage:image directoryPath:[[NSString stringWithFormat:@"%@",panel.URLs.firstObject] substringFromIndex:7]];

        }
    }];
    
}

-(void)generateIconsWithDic:(NSArray*)iconArr originalImage:(NSImage*)originalImage directoryPath:(NSString *)directoryPath{
    for (TMIconsModel *model in iconArr) {
        if (!model.isSelected){
            continue;
        }
        NSSize size = NSMakeSize(model.sizeWidth.intValue, model.sizeWidth.intValue);
        NSImage *appIcon = [self generateAppIconWithImage:originalImage forSize:size];
        int width = size.width;
        NSString *imageName= [NSString stringWithFormat:@"%dx%d",width,width];
        NSLog(@"生成尺寸-%@-图片",imageName);
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", directoryPath, imageName];
        [self exportImage:appIcon toPath:filePath];
    }
    
    
    
    if(self.isCompressButton.state == 1){//需要压缩图片
        
        self.titleLabel.stringValue = @"正在压缩图片...";
        
        [[TMCompressTool shareInstance] compressImagesWithDirectory:directoryPath outPath:nil completeBlock:^(NSString *outPath) {
           
            dispatch_async(dispatch_get_main_queue(), ^{

                self.alertStack.hidden = true;
                [self.loadingView stopAnimation:nil];
                
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"图片压缩完成!!!✅";
                alert.alertStyle = NSAlertStyleInformational;
                [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                    if (returnCode == NSModalResponseCancel) {
                        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:directoryPath isDirectory:YES]];
                    }
                }];
                
            });
            
        }];
        
    }else{
        
        self.alertStack.hidden = true;
        [self.loadingView stopAnimation:nil];
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"图片生成完成!!!✅";
        alert.alertStyle = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseCancel) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:directoryPath isDirectory:YES]];
            }
        }];
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

///分组的头/尾视图
//-(NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath{
//    NSString *nibName = @"";
//    if (kind == NSCollectionElementKindSectionHeader) {
//        nibName = @"HeaderView";
//    } else if (kind == NSCollectionElementKindSectionFooter) {
//        nibName = @"FooterView";
//    }
//    HeaderView * view = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:nibName forIndexPath:indexPath];
//    view.controller = self;
//
//    view.titleButton.stringValue = [NSString stringWithFormat:@"section_%ld_item_%ld",indexPath.section,indexPath.item];
//    return view;
//}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    TMIconItem *item = [collectionView makeItemWithIdentifier:@"icon" forIndexPath:indexPath];
    
    item.model = self.dataArr[indexPath.item];
    
    return item;
}

#pragma mark --- layout代理方法 ---
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return NSMakeSize(0, 30);
}

#pragma mark --- 裁剪图片方法 ---

- (void)generateImagesForPlatform:(NSString *)platform fromOriginalImage:(NSImage *)originalImage {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"QiConfiguration" ofType:@"plist"];
    NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray<NSDictionary *> *items = configuration[platform];
    
    NSString *directoryPath = [[@"替换" stringByAppendingPathComponent:platform] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    if ([platform containsString:@"AppIcons"]) {
        [self generateAppIconsWithConfigurations:items fromOriginalImage:originalImage toDirectoryPath:directoryPath];
    }
    else if ([platform containsString:@"LaunchImages"]) {
        [self generateLaunchImagesWithConfigurations:items fromOriginalImage:originalImage toDirectoryPath:directoryPath];
    }
}

- (void)generateAppIconsWithConfigurations:(NSArray<NSDictionary *> *)configurations fromOriginalImage:(NSImage *)originalImage toDirectoryPath:(NSString *)directoryPath {
    
    for (NSDictionary *configuration in configurations) {
        NSImage *appIcon = [self generateAppIconWithImage:originalImage forSize:NSSizeFromString(configuration[@"size"])];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", directoryPath, configuration[@"name"]];
        [self exportImage:appIcon toPath:filePath];
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:directoryPath isDirectory:YES]];
}

- (void)generateLaunchImagesWithConfigurations:(NSArray<NSDictionary *> *)configurations fromOriginalImage:(NSImage *)originalImage toDirectoryPath:(NSString *)directoryPath {
    
    
    
    for (NSDictionary *configuration in configurations) {
        NSImage *launchImage = [self generateLaunchImageWithImage:originalImage forSize: NSSizeFromString(configuration[@"size"])];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", directoryPath, configuration[@"name"]];
        [self exportImage:launchImage toPath:filePath];
    }
}

- (NSImage *)generateAppIconWithImage:(NSImage *)fromImage forSize:(CGSize)toSize  {
    
    // 生成即将绘制的目标图和目标Rect
    NSRect toRect = NSMakeRect(.0, .0, toSize.width, toSize.height);
    toRect = [[NSScreen mainScreen] convertRectFromBacking:toRect];
    NSImage *toImage = [[NSImage alloc] initWithSize:toRect.size];
    
    // 先转成对应rect，再绘制
    [toImage lockFocus];
    [fromImage drawInRect:toRect fromRect:CGRectMake(0, 0, fromImage.size.width, fromImage.size.height) operation:NSCompositingOperationCopy fraction:1.0];
    [toImage unlockFocus];
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[toImage TIFFRepresentation], NULL);// 把image转成cgImageSource
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL); // 将cgImageSource转成cgImageRef
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, toSize.width, toSize.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), kCGImageAlphaNoneSkipLast); // cgImageRef生成大小一致的cgContext，包含RBGX通道，去除alpha通道。
    CGContextDrawImage(bitmapContext, CGRectMake(.0, .0, toSize.width, toSize.height), imageRef); // 将cgImageRef写入cgContext
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);//生成cgImage
    NSImage *finalImage = [[NSImage alloc] initWithCGImage:decompressedImageRef size:toSize];// 生成NSImage
//    CGImageRef cg = [finalImage CGImageForProposedRect:nil context:nil hints:nil];
//    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]initWithCGImage:cg];
//    [finalImage addRepresentation:rep];
    CGImageRelease(decompressedImageRef);
    CGContextRelease(bitmapContext);
    
    
    
    return finalImage;
}

- (NSImage *)generateLaunchImageWithImage:(NSImage *)fromImage forSize:(CGSize)toSize {
    
    // 计算目标小图去贴合源大图所需要放大的比例
    CGFloat wFactor = fromImage.size.width / toSize.width;
    CGFloat hFactor = fromImage.size.height / toSize.height;
    CGFloat toFactor = fminf(wFactor, hFactor);
    
    // 根据所需放大的比例，计算与目标小图同比例的源大图的剪切Rect
    CGFloat scaledWidth = toSize.width * toFactor;
    CGFloat scaledHeight = toSize.height * toFactor;
    CGFloat scaledOriginX = (fromImage.size.width - scaledWidth) / 2;
    CGFloat scaledOriginY = (fromImage.size.height - scaledHeight) / 2;
    NSRect fromRect = NSMakeRect(scaledOriginX, scaledOriginY, scaledWidth, scaledHeight);
    
    // 生成即将绘制的目标图和目标Rect
    NSRect toRect = NSMakeRect(.0, .0, toSize.width, toSize.height);
    toRect = [[NSScreen mainScreen] convertRectFromBacking:toRect];
    NSImage *toImage = [[NSImage alloc] initWithSize:toRect.size];
    
    // 先转成对应rect，再绘制
    [toImage lockFocus];
    [fromImage drawInRect:toRect fromRect:fromRect operation:NSCompositingOperationCopy fraction:1.0];
    [toImage unlockFocus];
    
    // 去alpha处理：
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[toImage TIFFRepresentation], NULL);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, toSize.width, toSize.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(bitmapContext, CGRectMake(.0, .0, toSize.width, toSize.height), imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);
    NSImage *finalImage = [[NSImage alloc] initWithCGImage:decompressedImageRef size:NSZeroSize];
    CGImageRelease(decompressedImageRef);
    CGContextRelease(bitmapContext);
    
    return finalImage;
}

- (void)exportImage:(NSImage *)image toPath:(NSString *)path {
    
    NSData *imageData = image.TIFFRepresentation;
    NSData *exportData = [[NSBitmapImageRep imageRepWithData:imageData] representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    
    [exportData writeToFile:path atomically:YES];
}

///全选逻辑
- (IBAction)clickSelectAllBtn:(NSButton *)sender {
    
    for (TMIconsModel *model in self.dataArr) {
        model.isSelected = sender.state == 1;
    }
    
    [self.collectionView reloadData];
}

@end
