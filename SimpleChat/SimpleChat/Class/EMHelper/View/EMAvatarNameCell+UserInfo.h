//
//  EMAvatarNameCell+UserInfo.h
//  SimpleChat
//
//  Created by qtdmz on 2021/3/31.
//  Copyright © 2021 qtdmz. All rights reserved.
//

#import "EMAvatarNameCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMAvatarNameCell (UserInfo)
-(void) refreshUserInfo:(NSString*)aUid;
@end

NS_ASSUME_NONNULL_END
