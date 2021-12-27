//
//  LoginViewController.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "LoginViewController.h"

#import "MBProgressHUD.h"

#import "RegisterViewController.h"

#import "GlobalVariables.h"
#import "Options.h"
#import "EMAlertController.h"
#import "RightViewToolView.h"
#import "AuthorizationView.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) RightViewToolView *pswdRightView;
@property (nonatomic, strong) RightViewToolView *userIdRightView;
@property (nonatomic, strong) AuthorizationView *authorizationView;//授权操作视图

@property (nonatomic) BOOL isLogin;

@property (nonatomic, strong) UIImageView* titleTextImageView;
@property (nonatomic, strong) UIImageView* sdkVersionBackView;
@property (nonatomic, strong) UILabel* sdkVersionLable;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isLogin = false;
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.authorizationView originalView];//恢复原始视图
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Subviews

- (void)initView
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"BootPage"];
    [self.view insertSubview:imageView atIndex:0];
    
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.titleImageView = [[UIImageView alloc]init];
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.titleImageView.image = [UIImage imageNamed:@"titleImage"];
    [self.backView addSubview:self.titleImageView];
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backView);
        make.width.equalTo(@120.00);
        make.height.equalTo(@120.00);
        make.top.equalTo(self.backView.mas_top).offset(96);
    }];
    
    self.titleTextImageView = [[UIImageView alloc]init];
    self.titleTextImageView.image = [UIImage imageNamed:@"titleTextImage"];
    [self.backView addSubview:self.titleTextImageView];
    [self.titleTextImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backView);
        make.width.equalTo(@256);
        make.height.equalTo(@68);
        make.top.equalTo(self.titleImageView.mas_bottom).offset(2);
    }];
    
    self.nameField = [[UITextField alloc] init];
    self.nameField.backgroundColor = [UIColor whiteColor];
    self.nameField.delegate = self;
    self.nameField.borderStyle = UITextBorderStyleNone;
    self.nameField.placeholder = @"用户名";
    self.nameField.returnKeyType = UIReturnKeyGo;
    self.nameField.font = [UIFont systemFontOfSize:17];
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.layer.cornerRadius = 25;
    self.nameField.layer.borderWidth = 1;
    self.nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userIdRightView = [[RightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
    [self.userIdRightView.rightViewBtn addTarget:self action:@selector(clearUserIdAction) forControlEvents:UIControlEventTouchUpInside];
    self.nameField.rightView = self.userIdRightView;
    self.userIdRightView.hidden = YES;
    [self.backView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.titleTextImageView.mas_bottom).offset(40);
        make.height.equalTo(@55);
    }];
    self.pswdField = [[UITextField alloc] init];
    self.pswdField.backgroundColor = [UIColor whiteColor];
    self.pswdField.delegate = self;
    self.pswdField.borderStyle = UITextBorderStyleNone;
    self.pswdField.placeholder = @"密码";
    self.pswdField.font = [UIFont systemFontOfSize:17];
    self.pswdField.returnKeyType = UIReturnKeyGo;
    self.pswdField.secureTextEntry = YES;
    self.pswdField.clearsOnBeginEditing = NO;
    self.pswdRightView = [[RightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.pswdField.rightView = self.pswdRightView;
    self.pswdRightView.hidden = YES;
    self.pswdField.rightViewMode = UITextFieldViewModeAlways;
    self.pswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.pswdField.leftViewMode = UITextFieldViewModeAlways;
    self.pswdField.layer.cornerRadius = 25;
    self.pswdField.layer.borderWidth = 1;
    self.pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.backView addSubview:self.pswdField];
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.nameField.mas_bottom).offset(20);
        make.height.equalTo(@55);
    }];
    
    [self _setupLoginButton];
}

//授权登录按钮
- (void)_setupLoginButton
{
    self.authorizationView = [[AuthorizationView alloc]initWithAuthType:EMAuthLogin];
    self.authorizationView.userInteractionEnabled = YES;
    [self.authorizationView.authorizationBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.authorizationView];
    [self.authorizationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.pswdField.mas_bottom).offset(40);
        make.height.equalTo(@55);
    }];
    
    UIButton *registerButton = [[UIButton alloc] init];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [registerButton setTitle:@"账户注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@70);
        make.height.equalTo(@17);
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.authorizationView.mas_bottom).offset(14);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.backView endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.nameField.text.length > 0 && self.pswdField.text.length > 0){
        [self.authorizationView setupAuthBtnBgcolor:YES];
        self.isLogin = true;
        [self loginAction];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = kColor_Blue.CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if (textField == self.nameField && [self.nameField.text length] == 0)
        self.userIdRightView.hidden = YES;
    if (textField == self.pswdField && [self.pswdField.text length] == 0)
        self.pswdRightView.hidden = YES;
    if(self.nameField.text.length > 0 && self.pswdField.text.length > 0){
        [self.authorizationView setupAuthBtnBgcolor:YES];
        self.isLogin = true;
        return;
    }
    [self.authorizationView setupAuthBtnBgcolor:NO];
    self.isLogin = false;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField == self.nameField) {
        self.userIdRightView.hidden = NO;
        if ([self.nameField.text length] <= 1 && [string isEqualToString:@""])
            self.userIdRightView.hidden = YES;
    }
    if (textField == self.pswdField) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = updatedString;
        self.pswdRightView.hidden = NO;
        if ([self.pswdField.text length] <= 0 && [string isEqualToString:@""]) {
            self.pswdRightView.hidden = YES;
            self.pswdField.secureTextEntry = YES;
            [self.pswdRightView.rightViewBtn setSelected:NO];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField
{
    UITextRange *rang = textField.markedTextRange;
    if (rang == nil) {
        if(![self.nameField.text isEqualToString:@""] && ![self.pswdField.text isEqualToString:@""]){
            [self.authorizationView setupAuthBtnBgcolor:YES];
            self.isLogin = true;
            return;
        }
        [self.authorizationView setupAuthBtnBgcolor:NO];
        self.isLogin = false;
    }
}

#pragma mark - Action

//清除用户名
- (void)clearUserIdAction
{
    self.nameField.text = @"";
    self.userIdRightView.hidden = YES;
}

- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}

- (void)loginAction
{
    if(!self.isLogin) {
        return;
    }
    [self.backView endEditing:YES];
    
    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;

    __weak typeof(self) weakself = self;
    void (^finishBlock) (NSString *aName, EMError *aError) = ^(NSString *aName, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            Options *options = [Options sharedOptions];
            options.isAutoLogin = YES;
            options.loggedInUsername = aName;
            options.loggedInPassword = pswd;
            [options archive];
            [weakself.authorizationView originalView];
            //发送自动登录状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:[NSNumber numberWithBool:YES]];
            
            return ;
        }
        
        NSString *errorDes = @"登录失败，请重试";
        switch (aError.code) {
            case EMErrorUserNotFound:
                errorDes = @"用户ID不存在";
                break;
            case EMErrorNetworkUnavailable:
                errorDes = @"网络未连接";
                break;
            case EMErrorServerNotReachable:
                errorDes = @"无法连接服务器";
                break;
            case EMErrorUserAuthenticationFailed:
                errorDes = @"您输入的用户名或密码不正确";
                break;
            case EMErrorUserLoginTooManyDevices:
                errorDes = @"登录设备数已达上限";
                break;
            case EMErrorUserLoginOnAnotherDevice:
                errorDes = @"已在其他设备登录";
                break;
            case EMErrorUserRemoved:
                errorDes = @"当前帐号已被后台删除";
                break;
            default:
                break;
        }
        [EMAlertController showErrorAlert:errorDes];
        [self.authorizationView originalView];//恢复原始视图
    };
    
    [weakself.authorizationView beingLoadedView];//正在加载视图
    [[EMClient sharedClient] loginWithUsername:[name lowercaseString] password:pswd completion:finishBlock];
}

- (void)registerAction
{
    [self.backView endEditing:YES];
    
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    
    __weak typeof(self) weakself = self;
    [controller setSuccessCompletion:^(NSString * _Nonnull aName) {
        weakself.nameField.text = aName;
        weakself.pswdField.text = @"";
    }];
    
    controller.modalPresentationStyle = 0;
    //[self presentViewController:controller animated:YES completion:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
