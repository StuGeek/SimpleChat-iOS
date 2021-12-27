//
//  PersonalDataViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PersonalDataViewController : EMRefreshViewController

- (instancetype)initWithNickName:(NSString *)aNickName;

- (instancetype)initWithNickName:(NSString *)aNickName isChatting:(BOOL)isChatting;

@property (nonatomic, copy) void (^shieldingContactSuccess)(void);

@end

NS_ASSUME_NONNULL_END
