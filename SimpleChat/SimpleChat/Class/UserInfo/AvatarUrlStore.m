//
//  AvatarUrlStore.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "AvatarUrlStore.h"

@interface AvatarUrlStore()
@property (nonatomic,strong) NSDictionary* dicAvatarUrl;
@end

static AvatarUrlStore *avatarUrlStoreInstance = nil;

@implementation AvatarUrlStore

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        avatarUrlStoreInstance = [[AvatarUrlStore alloc] init];
    });
    return avatarUrlStoreInstance;
}

- (void)fetchListFromServer
{
    NSMutableDictionary* mutableDic = [NSMutableDictionary dictionary];
    for (int i = 1; i <= 9; ++i) {
        NSString *key = [NSString stringWithFormat:@"可选头像%d", i];
        [mutableDic setObject:[kBaseAvatarUrl stringByAppendingString:[NSString stringWithFormat:@"Avatar%d.png", i]] forKey:key];
    }
    self.dicAvatarUrl = [mutableDic copy];
}

- (NSDictionary*)getAvatarUrlList
{
    return self.dicAvatarUrl;
}

- (NSDictionary*)dicAvatarUrl
{
    if(!_dicAvatarUrl) {
        _dicAvatarUrl = [NSDictionary dictionary];
    }
    return _dicAvatarUrl;
}
@end
