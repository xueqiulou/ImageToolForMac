//
//  TMAppStoreViewItem.h
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/14.
//  Copyright © 2020 TM728. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMAppStoreModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMAppStoreViewItem : NSCollectionViewItem
@property (weak) IBOutlet NSImageView *imageView;

@property (strong,nonatomic) TMAppStoreModel *model;

@end

NS_ASSUME_NONNULL_END
