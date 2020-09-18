//
//  TMCompressTool.h
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/17.
//  Copyright © 2020 TM728. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  void(^TMCompressCompleteBlock)(NSString* outPath);

@interface TMCompressTool : NSObject

+(instancetype)shareInstance;
-(void)compressImagesWithDirectory:(NSString *)directoryPath outPath:(NSString*)outPath completeBlock:(TMCompressCompleteBlock)completeBlock;
-(void)compressOneImageWithImage:(NSString *)imagePath outPath:(NSString*)outPath;

@end
