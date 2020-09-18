//
//  TMAppStoreNewImageController.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/14.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMAppStoreNewImageController.h"
#import "TMAppStoreViewItem.h"
#import "HeaderView.h"

@interface TMAppStoreNewImageController ()<NSCollectionViewDataSource,NSCollectionViewDelegate,NSCollectionViewDelegateFlowLayout>
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (strong,nonatomic) NSMutableArray *dataArr;
@property (weak) IBOutlet NSTextField *pathTF;
@property (weak) IBOutlet NSTextField *exportPathTF;

@property (strong,nonatomic) NSMutableArray *exportPaths;
@property (strong,nonatomic) NSMutableArray *exportImages;
@property (strong,nonatomic) NSMutableArray *imagePaths;//要生成图片的图片路径

@end

@implementation TMAppStoreNewImageController

-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        
        NSArray *sizeArr = @[
            @"1242x2688",
            @"1242x2208",
            @"750x1334"
        ];
        for (NSString *size in sizeArr) {
            TMAppStoreModel *model = [TMAppStoreModel new];
            model.sectionTitle = size;
            NSMutableArray* sectionArr = @[].mutableCopy;
            model.imagesArr = sectionArr;
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}

///选择图片/目录
- (IBAction)selectImage:(id)sender {
    
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
                    //                self.isSelectOnePicture = true;
                }else{
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = @"选择文件不是图片";
                    alert.alertStyle = NSAlertStyleInformational;
                    [alert runModal];
                    return;
                }
            }else{//选择的是目录
                
                self.pathTF.stringValue = [panel.URLs.firstObject.absoluteString substringFromIndex:7];
                [self enumerator:path];
                for (NSString *filePath in self.imagePaths) {
                    [self generateImages:filePath];
                    
                }
                return;
                
            }
            NSLog(@"%@",panel.URLs);
            
            self.pathTF.stringValue = [panel.URLs.firstObject.absoluteString substringFromIndex:7];
            
            [self generateImages:self.pathTF.stringValue];
            
            
        }
    }];
    
}

-(void)generateImages:(NSString *)filePath
{

    dispatch_queue_t queue = dispatch_queue_create("生成图片", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t group = dispatch_group_create();
    __block int index=0;
    for (TMAppStoreModel *model in self.dataArr) {

        dispatch_group_async(group, queue, ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSData * imageData = [fileManager contentsAtPath:filePath];
            NSImage *image = [[NSImage alloc] initWithData:imageData];
            
            NSString *sizeStr = model.sectionTitle;
            int width = [[[sizeStr componentsSeparatedByString:@"x"] firstObject] intValue];
            int height = [[[sizeStr componentsSeparatedByString:@"x"] lastObject] intValue];
            CGSize size = CGSizeMake(width, height);
            
            NSImage *resultImage = [self generateAppStoreImageWithImage:image forSize:size];
            
            //展示图片
            [model.imagesArr addObject:resultImage];
            
            //导出图片
            NSString *exportPath = [self getFilePath:self.pathTF.stringValue name:[NSString stringWithFormat:@"%@_%d_%lu",sizeStr,index+1,model.imagesArr.count]];
            if (![self.exportPaths containsObject:exportPath]){
                [self.exportPaths addObject:exportPath];
            }
            
            if (![self.exportImages containsObject:resultImage]){
                [self.exportImages addObject:resultImage];
            }
            index++;
        });
        
        dispatch_group_notify(group, queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{

                [self.collectionView reloadData];
            });
        });
    }
}

-(NSString*)getFilePath:(NSString*)filePath name:(NSString*)name
{
    NSString *result = filePath;
    if([[filePath lastPathComponent] containsString:@"."]){//包含 . 图片文件
        NSString *newName = [NSString stringWithFormat:@"%@_%@.%@",[[filePath lastPathComponent] componentsSeparatedByString:@"."].firstObject,name,[[filePath lastPathComponent] componentsSeparatedByString:@"."].lastObject];
        result = [filePath stringByReplacingOccurrencesOfString:[filePath lastPathComponent] withString:newName];
    }else{//目录
        result = [NSString stringWithFormat:@"%@%@.png",filePath,name];
    }
    return result;
}

///生成图片
- (IBAction)generateImage:(id)sender {
    
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
            __block NSString *urlPath = path;
            
            __block int index = 0;
            dispatch_queue_t queue = dispatch_queue_create("导出图片", DISPATCH_QUEUE_CONCURRENT);
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_async(group, queue, ^{
                for (NSString *path_ in self.exportPaths) {
                       urlPath = [NSString stringWithFormat:@"%@%@", path,[path_ lastPathComponent]];
                        [self exportImage:self.exportImages[index] toPath:urlPath];
                        index ++;
                }
            });
            
            dispatch_group_notify(group, queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path isDirectory:YES]];
                });
            });
            
            
        }
    }];
    
}

///遍历目录下图片
-(void)enumerator:(NSString*)path{
    
//    if (self.isSelectOnePicture){
//        [self.imagePaths addObject:path];
//        return;
//    }
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.exportPaths = @[].mutableCopy;
    self.exportImages = @[].mutableCopy;
    self.imagePaths = @[].mutableCopy;

    [self.collectionView registerClass:[TMAppStoreViewItem class] forItemWithIdentifier:@"appstore"];
    
    self.collectionView.selectable = YES;
    
    [self registerForCollectionViewDragAndDrop];
    
    [self.collectionView reloadData];
}

- (void)registerForCollectionViewDragAndDrop {
    // Register for the dropped object types we can accept.
    [self.collectionView registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeURL]];

    // Enable dragging items from our CollectionView to other applications.
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    
    // Enable dragging items within and into our CollectionView.
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
}

#pragma mark --- NSCollectionView数据源方法 ---

///分组的头/尾视图
-(NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath{
    NSString *nibName = @"";
    if (kind == NSCollectionElementKindSectionHeader) {
        nibName = @"HeaderView";
    } else if (kind == NSCollectionElementKindSectionFooter) {
        nibName = @"FooterView";
    }
    HeaderView * view = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:nibName forIndexPath:indexPath];
    view.wantsLayer = true;
    view.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
//    view.controller = self;

    TMAppStoreModel *model = self.dataArr[indexPath.section];
    view.titleButton.title = [NSString stringWithFormat:@"%@",model.sectionTitle];
    
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    return self.dataArr.count;
}
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    TMAppStoreModel *model = self.dataArr[section];
    return model.imagesArr.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    TMAppStoreViewItem *item = [collectionView makeItemWithIdentifier:@"appstore" forIndexPath:indexPath];
    
    
    TMAppStoreModel *model = self.dataArr[indexPath.section];
    item.model = model;
    NSImage *image = model.imagesArr[indexPath.item];
    NSLog(@"%@ --- %@",image,indexPath);
    item.imageView.image = image;

    
    return item;
}

-(NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TMAppStoreModel *model = self.dataArr[indexPath.section];
    
    NSString *sizeStr = model.sectionTitle;
    int width = [[[sizeStr componentsSeparatedByString:@"x"] firstObject] intValue];
    int height = [[[sizeStr componentsSeparatedByString:@"x"] lastObject] intValue];
    CGFloat scale = 130.0/width;
    CGSize size = CGSizeMake(130, height*scale+30);
    
    return size;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    NSLog(@"%s",__func__);
//    currentIndexPaths = indexPaths;
//    session.draggingFormation = NSDraggingFormationList;
}
-(void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation {
    NSLog(@"%s",__func__);
//    [collectionView reloadData];
//    NSLog(@"%@",NSStringFromPoint(screenPoint));
//    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:screenPoint];
//    [collectionView moveItemAtIndexPath:currentIndexPath toIndexPath:indexPath];
//    NSLog(@"%d",indexPath.item);
}

-(BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard {
    
    NSLog(@"%s",__func__);

    return YES;
}
-(BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event {
    
     NSLog(@"%s",__func__);
    return YES;
}

-(id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndex:(NSUInteger)index {
    NSLog(@"%s",__func__);
    
    NSPasteboardItem *item = [[NSPasteboardItem alloc]init];
    NSString *imageName = [NSString stringWithFormat:@"%ld",(long)index];

    [item setString:imageName forType:NSPasteboardTypeString];
    
    return item;

}
-(BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation {
    NSLog(@"%s",__func__);
    return YES;
}
//-(NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
//    NSLog(@"%s",__func__);
//    if (proposedDropOperation == NSCollectionViewDropOn) {
////        proposedDropOperation = NSCollectionViewDropBefore;
//    }
//    return NSDragOperationMove;
//}
- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath * __nonnull * __nonnull)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
//    NSIndexPath * currentIndex = currentIndexPaths.allObjects.firstObject;


    if (*proposedDropOperation == NSCollectionViewDropBefore) {
        *proposedDropOperation = NSCollectionViewDropOn;
        return NSDragOperationNone;
    }
    NSIndexPath *proposedIndexPath = *proposedDropIndexPath;
//    for (NSIndexPath *tmpIndexPath in currentIndexPaths.allObjects) {
//        [collectionView moveItemAtIndexPath:tmpIndexPath toIndexPath: proposedIndexPath];
////        if (tmpIndexPath.item < proposedIndexPath.item) {
////            [self.dataArr removeObjectAtIndex:proposedIndexPath.item];
////        }else {
////            [self.dataArr removeObjectAtIndex:proposedIndexPath.item + 1];
////        }
////        [collectionView reloadData];
////        self.dataArr insertObject:<#(nonnull id)#> atIndex:<#(NSUInteger)#>
//    }
    return NSDragOperationMove;
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
