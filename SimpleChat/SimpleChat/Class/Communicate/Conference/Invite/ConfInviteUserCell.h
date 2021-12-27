//
//  ConfInviteUserCell.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfInviteUserCellDelegate;

@interface ConfInviteUserCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic) BOOL isChecked;

@end
