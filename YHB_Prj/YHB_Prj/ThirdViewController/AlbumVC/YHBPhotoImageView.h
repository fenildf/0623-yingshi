//
//  YHBPhotoImageView.h
//  YHB_Prj
//
//  Created by Johnny's on 14/12/1.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHBPhotoImageView : UIImageView

- (instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic, strong) UIImageView *maskingView;
@property (nonatomic, assign) BOOL isSelected;
- (void)changeSelected;
- (void)showMaskingView;
- (void)hiddenMaskingView;
@end
