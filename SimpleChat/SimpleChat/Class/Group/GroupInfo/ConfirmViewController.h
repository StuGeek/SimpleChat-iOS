//
//  ConfirmViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfirmViewController : UIViewController

@property (nonatomic, copy) BOOL (^doneCompletion)(BOOL aConfirm);

- (instancetype)initWithMembername:(NSString *)name titleText:(NSString *)titleText;

@end

NS_ASSUME_NONNULL_END
