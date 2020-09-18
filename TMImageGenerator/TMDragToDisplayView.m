//
//  TMDragToDisplayView.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/4.
//  Copyright © 2020 admin. All rights reserved.
//

#import "TMDragToDisplayView.h"

@interface TMDragToDisplayView ()
@end

@implementation TMDragToDisplayView

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self regist];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

/**
    注册响拖拽入文件的事件
 */
- (void)regist
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

/**
   文件拖拽到视图上方时调用
*/
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    
    NSLog(@"%s",__FUNCTION__);
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;

}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    
    //1.获取拖拽数据的粘贴板
    NSPasteboard *board = [sender draggingPasteboard];
    NSArray *list = [board propertyListForType:NSFilenamesPboardType];
//    for (NSString *fileName in list) {
//        NSLog(@"---%@",fileName);
//    }
    if ([self.delegate respondsToSelector:@selector(dragViewCompleteWithFiles:)]) {
        [self.delegate dragViewCompleteWithFiles:list];
    }
    
    return true;

//    // 1）、获取拖动数据中的粘贴板
//    NSPasteboard *zPasteboard = [sender draggingPasteboard];
//    // 2）、从粘贴板中提取我们想要的NSFilenamesPboardType数据，这里获取到的是一个文件链接的数组，里面保存的是所有拖动进来的文件地址，如果你只想处理一个文件，那么只需要从数组中提取一个路径就可以了。
//    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    // 3）、将接受到的文件链接数组通过代理传送
//    if(self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewFileList:)])
//        [self.delegate dragDropViewFileList:list];
//    return YES;

}



@end
