//
//  UIViewController+HUD.m
//  SimpleChat
//
//  Created by qtdmz on 2019/2/22.
//  Copyright © 2019 qtdmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HUD)

- (void)showHudInView:(UIView *)view hint:(NSString *)hint;

- (void)hideHud;

- (void)showHint:(NSString *)hint;

- (void)showHint:(NSString *)hint yOffset:(float)yOffset;

@end
