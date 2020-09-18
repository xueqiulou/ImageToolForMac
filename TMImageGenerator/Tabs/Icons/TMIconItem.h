//
//  TMIconItem.h
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/9.
//  Copyright © 2020 TM728. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMIconsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMIconItem : NSCollectionViewItem

@property (strong) NSButton *checkBtn;
@property (nonatomic, strong) TMIconsModel *model;


@end

NS_ASSUME_NONNULL_END
