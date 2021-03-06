//
//  EMAvatarNameModel.h
//  SimpleChat
//
//  Created by qtdmz on 2020/8/19.
//  Copyright © 2020 qtdmz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMAvatarNameModel : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImage *avatarImg;

@property (nonatomic, strong) NSString *from;

@property (nonatomic, strong) NSAttributedString *detail;

@property (nonatomic, strong) NSString *timestamp;

- (instancetype)initWithInfo:(NSString *)keyWord img:(UIImage *)img msg:(EMMessage *)msg time:(NSString *)timestamp;

@end

NS_ASSUME_NONNULL_END
