//
//  HeaderView.h
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/9.
//  Copyright © 2020 TM728. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMGenerateIconsController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeaderView : NSView

@property (weak) IBOutlet NSButton *titleButton;
@property (weak) TMGenerateIconsController *controller;


@end

NS_ASSUME_NONNULL_END
