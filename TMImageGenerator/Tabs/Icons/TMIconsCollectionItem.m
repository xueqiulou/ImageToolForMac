//
//  TMIconsCollectionItem.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/8.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMIconsCollectionItem.h"

@interface TMIconsCollectionItem ()

@end

@implementation TMIconsCollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.view.wantsLayer = true;
    
    NSArray *colorAry = @[NSColor.redColor,NSColor.greenColor,NSColor.blueColor,NSColor.orangeColor,NSColor.yellowColor];
    
    
    self.view.layer.backgroundColor = [colorAry[arc4random() % 5] CGColor];
    
    self.lineView.layer.backgroundColor = NSColor.cyanColor.CGColor;
    
}


@end
