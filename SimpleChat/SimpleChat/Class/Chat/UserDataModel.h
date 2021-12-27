//
//  UserDataModel.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserDataModel : NSObject <EaseUserDelegate>
@property (nonatomic, copy) NSString *easeId;           // 环信id
@property (nonatomic, copy, readonly) UIImage *defaultAvatar;     // 默认头像显示
@property (nonatomic, copy) NSString *showName;         // 显示昵称
@property (nonatomic, copy) NSString *avatarURL;        // 显示头像的url

- (instancetype)initWithEaseId:(NSString *)easeId;
@end

NS_ASSUME_NONNULL_END
