//
//  TMIconsCollectionItem.h
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/8.
//  Copyright © 2020 TM728. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMIconsCollectionItem : NSCollectionViewItem
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSImageView *iconView;
@property (weak) IBOutlet NSButton *checkButton;
@property (weak) IBOutlet NSView *lineView;

@end

NS_ASSUME_NONNULL_END
