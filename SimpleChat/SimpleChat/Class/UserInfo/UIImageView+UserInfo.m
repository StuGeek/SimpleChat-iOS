//
//  UIImageView+UserInfo.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "UIImageView+UserInfo.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (UserInfo)
-(void)showUserInfoAvatar:(NSString*)aUid
{
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUid];
    if(userInfo && userInfo.avatarUrl.length > 0) {
        NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
        if(url) {
            [self sd_setImageWithURL:url completed:nil];
        }
    }
}
@end
