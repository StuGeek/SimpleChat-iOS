//
//  ContactModel.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactModel : NSObject <EaseUserDelegate>
@property (nonatomic, strong) NSString *easeId;
@property (nonatomic, copy) NSString *showName;         // 显示昵称
@property (nonatomic, copy) NSString *avatarURL;        // 显示头像的url
@property (nonatomic, copy) UIImage *defaultAvatar;     //默认头像
@end

NS_ASSUME_NONNULL_END
