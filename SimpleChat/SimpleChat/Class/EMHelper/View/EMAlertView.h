//
//  EMAlertView.h
//  SimpleChat
//
//  Created by qtdmz on 2020/9/27.
//  Copyright © 2020 qtdmz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMAlertView : UIView

- (instancetype)initWithTitle:(nullable NSString *)title message:(NSString *)message;

- (void)show;

@end

NS_ASSUME_NONNULL_END
