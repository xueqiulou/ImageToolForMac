//
//  TMDragToDisplayView.h
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/4.
//  Copyright © 2020 admin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TMDragImageDelegate <NSObject>

-(void)dragViewCompleteWithFiles:(NSArray*)filePaths;

@end

@interface TMDragToDisplayView : NSView

@property (weak,nonatomic) id<TMDragImageDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
