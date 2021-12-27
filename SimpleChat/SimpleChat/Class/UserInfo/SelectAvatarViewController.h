//
//  SelectAvatarViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectAvatarViewController : EMRefreshViewController
- (instancetype)initWithCurrentAvatar:(NSString*)aAvatarUrl;
@end

NS_ASSUME_NONNULL_END
