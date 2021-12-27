//
//  OneLoadingAnimation.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneLoadingAnimationView : UIView
- (void)startAnimation;

- (void)stopTimer;

- (instancetype)initWithRadius:(CGFloat)radius;
@end
