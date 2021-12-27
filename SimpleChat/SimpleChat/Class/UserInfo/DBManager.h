//
//  DBManager.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject
+(instancetype _Nonnull ) alloc __attribute__((unavailable("call sharedInstance instead")));
+(instancetype _Nonnull ) new __attribute__((unavailable("call sharedInstance instead")));
-(instancetype _Nonnull ) copy __attribute__((unavailable("call sharedInstance instead")));
-(instancetype _Nonnull ) mutableCopy __attribute__((unavailable("call sharedInstance instead")));
+(instancetype) sharedInstance;
-(void) addUserInfos:(NSArray<EMUserInfo*>*)aUserInfos;
-(NSArray<EMUserInfo*>*) loadUserInfos;
@end

NS_ASSUME_NONNULL_END
