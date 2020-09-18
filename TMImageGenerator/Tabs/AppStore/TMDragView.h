//
//  TMDragView.h
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/11.
//  Copyright © 2020 TM728. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TMDragViewReceivedFileDelegate <NSObject>

-(void)receiveFilesWithPaths:(NSArray *)list;

@end


NS_ASSUME_NONNULL_BEGIN

@interface TMDragView : NSView

@property (weak) id<TMDragViewReceivedFileDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
