//
//  TMCompressTool.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/17.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMCompressTool.h"
#import <Cocoa/Cocoa.h>

@implementation TMCompressTool

+(instancetype)shareInstance
{
    static TMCompressTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [TMCompressTool new];
    });
    return tool;
}

///压缩一个目录下的图片
-(void)compressImagesWithDirectory:(NSString *)directoryPath outPath:(NSString*)outPath completeBlock:(TMCompressCompleteBlock)completeBlock
{
    NSMutableArray *paths = [self enumerator:directoryPath];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("tm.compress.queue", DISPATCH_QUEUE_SERIAL);
    
    for (NSString *imagePath in paths) {
        dispatch_group_async(group, queue, ^{
           [self compressImage:imagePath outPath:outPath];
        });
    }
    ///group
    dispatch_group_notify(group, queue, ^{
       NSLog(@"目录图片压缩全部结束!!!");
        completeBlock(outPath);
    });
}
///压缩一张图片,传图片路径
-(void)compressOneImageWithImage:(NSString *)imagePath outPath:(NSString*)outPath
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self compressImage:imagePath outPath:outPath];
        
    });
}

-(NSMutableArray *)enumerator:(NSString*)path{
    
    NSMutableArray *paths = @[].mutableCopy;
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
        if ([[filename pathExtension] isEqualTo:@"png"]) {
            [paths addObject:[home stringByAppendingPathComponent:filename]];
        }
    }
    
    return paths;
}


///压缩一张图片的方法
-(void)compressImage:(NSString*)path outPath:(NSString*)outPath
{
    ///1.图片文件路径
    NSString *originalPath = path;
    ///1.1文件名称
    NSString* fileName = [path lastPathComponent];
    
    
    ///2.压缩图片输出路径
    NSString *outputPath = originalPath;
    if (outPath != nil) {
        outputPath = [outPath stringByAppendingString:fileName];
    }
    
    NSTask *task = [NSTask new];
    task.launchPath = [[NSBundle mainBundle] pathForResource:@"pngquant" ofType:nil];
    task.arguments = @[@"--force", @"--quality", @"50-80", @"-v", @"--out", outputPath, @"--", originalPath];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardError:pipe];

//    NSFileHandle *reader = [pipe fileHandleForReading];

    [task launch];
    [task waitUntilExit];

//    NSData *data = [reader readDataToEndOfFile];
//    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"压缩一张图片结束");
    
//    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:outputPath isDirectory:YES]];
}

#pragma mark --- 压缩图片 ---

@end
