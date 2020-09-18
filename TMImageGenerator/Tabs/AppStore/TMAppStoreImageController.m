//
//  TMAppStoreImageController.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/7.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMAppStoreImageController.h"
#import "TMDragView.h"

@interface TMAppStoreImageController ()<TMDragViewReceivedFileDelegate,NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet TMDragView *dragView;
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) NSMutableArray *dataArr;

@end

@implementation TMAppStoreImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dragView.wantsLayer = true;
    self.dragView.layer.backgroundColor = [NSColor blueColor].CGColor;
    
    self.dragView.delegate = self;
    
    
    
}

//-(NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//
//
//
//}

#pragma mark --- TMDragViewReceivedFileDelegate ---
- (void)receiveFilesWithPaths:(NSArray*)list {
    NSLog(@"路径---%@",list);
    NSLog(@"路径---%@",list.firstObject);
    NSImage *originalImage = [[NSImage alloc] initByReferencingFile:list.firstObject];
    NSImage *resultImage = [self generateAppStoreImageWithImage:originalImage forSize:CGSizeMake(1242, 2208)];
    [self exportImage:resultImage toPath:@"/Users/xueqiulou/Desktop/result.png"];
}

#pragma mark --- 生成图片方法 ---
- (NSImage *)generateAppStoreImageWithImage:(NSImage *)fromImage forSize:(CGSize)toSize {
    
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

///导出图片
- (void)exportImage:(NSImage *)image toPath:(NSString *)path {
    
    NSData *imageData = image.TIFFRepresentation;
    NSData *exportData = [[NSBitmapImageRep imageRepWithData:imageData] representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    
    [exportData writeToFile:path atomically:YES];
}

@end
