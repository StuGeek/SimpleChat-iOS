//
//  AboutViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "AboutViewController.h"
#import "Masonry.h"

@interface AboutViewController ()

@property (nonatomic, strong) UIView *logoView;

@property (nonatomic, strong) UIView *TextView;

@property (nonatomic, strong) UILabel *productTxt;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showRefreshHeader = NO;
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [self initView];
}

- (void)initView
{
    [self addPopBackLeftItem];
    self.title = @"关于SimpleChat";
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:18]};
    }
    else {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:28]};
    }
    
    [self.view addSubview:self.logoView];
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@150);
        make.top.left.equalTo(self.view);
    }];
    
    [self.view addSubview:self.TextView];
    [_TextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@500);
        make.top.equalTo(self.logoView.mas_bottom).offset(12);
    }];
}

- (UIView*)logoView
{
    if (_logoView == nil) {
        _logoView = [[UIView alloc]init];
        _logoView.backgroundColor = [UIColor whiteColor];
        UIImageView *logoImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
        [_logoView addSubview:logoImg];
        [logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@82);
            make.height.equalTo(@82);
            make.centerX.equalTo(_logoView);
            make.top.equalTo(_logoView.mas_top).offset(20);
        }];
        UILabel *productName = [[UILabel alloc]init];
        productName.text = [NSString stringWithFormat:@"SimpleChat"];
        productName.textAlignment = NSTextAlignmentCenter;
        productName.textColor = [UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1.0];
        productName.font = [UIFont systemFontOfSize:14.f];
        [_logoView addSubview:productName];
        [productName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@20);
            make.centerX.equalTo(logoImg);
            make.top.equalTo(logoImg.mas_bottom).offset(12);
        }];
    }
    return _logoView;
}

- (UIView*)TextView
{
    if (_TextView == nil && _productTxt == nil) {
        _TextView = [[UIView alloc]init];
        _TextView.backgroundColor = [UIColor whiteColor];
        _productTxt = [[UILabel alloc]init];
        _productTxt.text = [NSString stringWithFormat:@"\n\n这是一个简单的聊天的软件\n\n使用清新简洁的界面帮助人们\n\n帮助人们专注于聊天和社交\n\n无论男女老少都可轻易地上手使用"];
        _productTxt.textAlignment = NSTextAlignmentCenter;
        _productTxt.textColor = [UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1.0];
        _productTxt.lineBreakMode = NSLineBreakByWordWrapping;
        _productTxt.numberOfLines = 0;
        [_TextView addSubview:_productTxt];
        [_productTxt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@400);
            make.height.equalTo(@300);
            make.centerX.equalTo(_TextView);
            make.top.equalTo(_TextView.mas_top);
        }];
    }
    Options *options = [Options sharedOptions];
    if (!options.isEnlargerFontMode) {
        self.productTxt.font = [UIFont systemFontOfSize:15];
    }
    else {
        self.productTxt.font = [UIFont systemFontOfSize:20];
    }
    return _TextView;
}

@end

