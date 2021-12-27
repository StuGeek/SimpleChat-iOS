#import <Foundation/Foundation.h>
#import "ShareViewController.h"

@interface ShareViewController() //<EaseConversationsViewControllerDelegate>

@property (nonatomic) UITableView* tableView;
@property (nonatomic) ShareViewController *shareVC;
@property (nonatomic) EaseChatViewController *chatController;
@property (nonatomic) EMUserInfo* userInfo;
@property (nonatomic) CGFloat width, height, overfill;
@property (nonatomic) NSMutableArray* data;
@property (nonatomic) NSInteger identifier;
@property (nonatomic) NSString* cellIDcommented;

@end

@implementation ShareViewController

@synthesize tableView = _tableView;

- (id) init{
    if(self = [super init]){
        self.width = [[UIScreen mainScreen] bounds].size.width;
        self.height = [[UIScreen mainScreen] bounds].size.height - 45;
        self.overfill = -50;
        self.identifier = 0;
        self.data = [[NSMutableArray alloc] initWithCapacity: 10];
        
        NSString* article = @"Hello world !";
        NSArray* photos = [NSArray array];
        NSDictionary* aComment = @{@"userid": @"buser",
                                   @"comment": @"不错"};
        NSMutableArray* comments = [NSMutableArray arrayWithCapacity: 1];
        [comments addObject: aComment];
        [self.data insertObject: @{ @"userID": @"cuser",
                                    @"name": @"cuser",
                                    @"avatarUrl": @"http://stugeek.gitee.io/digital-media/SimpleChatAvatar/Avatar6.png",
                                    @"article": article,
                                    @"photos": photos,
                                    @"date": @"2021年12月26日 21:45",
                                    @"comments": comments,
                                    @"commentPop": @"NO" }
                        atIndex: 0];
        self.view = [[UIView alloc] initWithFrame: CGRectMake(0, self.overfill, self.width, self.height)];
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self layout];
        
        // 这里面存了头像的信息
        self.userInfo = [[UserInfoStore sharedInstance] getUserInfoById:
                         [EMClient sharedClient].currentUsername];
        
        //
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(windmillAni)];
        [swipe setDirection: UISwipeGestureRecognizerDirectionDown];
        swipe.delegate = self;
        [self.tableView addGestureRecognizer:swipe];
    }
    return self;
}

-(void) refresh{
    [self windmillAni];
    [self.tableView reloadData];
}

-(void) layout{
    // tableview
    self.tableView =  [[UITableView alloc]
                       initWithFrame: CGRectMake(0, self.overfill, self.width, self.height)
                       style: UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self; // 设置数据源代理，必须实现协议UITableViewDataSource中的相关方法
    self.tableView.userInteractionEnabled = YES;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview: self.tableView]; // 添加UITableView
}

- (NSString*) getUserid{
    return self.userInfo.userId;
}

- (void) addNewPYQ: (id) sender {
    NSLog(@"add new pyq");
    UIView* addPYQview = [[ConfigureView alloc] initWithDelegate: self];
    [self.view addSubview: addPYQview];
}

- (void) openPersonalDataVC: (UIViewController*) vc{
    [self.navigationController pushViewController: vc animated: YES];
}

- (void) openPicker: (id) picker {
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) closePicker: (id) picker{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) setCOMMENTPOPwithCellID: (NSString*) cellID{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary: self.data[[cellID intValue]]];
    if([[data objectForKey: @"commentPop"] isEqualToString: @"NO"]){
        [data setObject: @"YES" forKey: @"commentPop"];
    }
    else{
        [data setObject: @"NO" forKey: @"commentPop"];
    }
    self.data[[cellID intValue]] = data;
    [self.tableView reloadData];
}

//----------------------------------- 发送出朋友圈的后端部分

- (void) addNewToMyPageWithUserID: (NSString*) userid
                        AvatarUrl: (NSString*) avatarUrl
                          Article: (NSString*) article
                           Photos: (NSMutableArray*) photos {
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSString* dateString = [df stringFromDate:currentDate];
    NSMutableArray* emptyComment = [NSMutableArray arrayWithCapacity:5];;
    [self.data addObject: @{ @"userID": userid,
                             @"name": userid, // 应该为昵称
                             @"avatarUrl": avatarUrl,
                             @"article": article,
                             @"photos": photos,
                             @"date": dateString,
                             @"comments": emptyComment,
                             @"commentPop": @"NO" }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) backendSendWithUserID: (NSString*) userid
                     AvatarUrl: (NSString*) avatarUrl
                       Article: (NSString*) article
                        Photos: (NSMutableArray*) photos {
    // 将朋友圈发送给每个好友
    EMCustomMessageBody* body = [[EMCustomMessageBody alloc] initWithEvent: nil
                                                                       ext: nil];
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = [EMClient.sharedClient.chatManager getConversation: @"mytest2"
                                                                 type: EMConversationTypeChat
                                                     createIfNotExist: YES].conversationId;
    
    EMMessage *message = [[EMMessage alloc] initWithConversationID: to
                                                              from: from
                                                                to: to
                                                              body: body
                                                               ext: @{@"type": @"pyq",
                                                                      @"userID": userid,
                                                                      @"name": userid, // 应该为昵称
                                                                      @"avatarUrl": avatarUrl,
                                                                      @"article": article,
                                                                      @"photos": photos}];
    message.chatType = EMChatTypeChat;
    NSMutableArray *formated = [[NSMutableArray alloc] init];
    [[EMClient sharedClient].chatManager sendMessageReadAck: message.messageId
                                                     toUser: message.conversationId
                                                 completion: nil];
        
    EaseMessageModel *model = [[EaseMessageModel alloc] initWithEMMessage: message];
    [formated addObject:model];
    
    [self.dataArray addObjectsFromArray:formated];
    
    [[EMClient sharedClient].chatManager sendMessage: message
                                            progress: nil
                                          completion: ^(EMMessage *message, EMError *error) {}];
}

- (void) sendPYQWithUserID: (NSString*) userid
                 AvatarUrl: (NSString*) avatarUrl
                   Article: (NSString*) article
                    Photos: (NSMutableArray*) photos{
    NSLog(@"send the PYQ with article: %@", article);
    // 更新自己的朋友圈
    [self addNewToMyPageWithUserID: userid
                         AvatarUrl: avatarUrl
                           Article: article
                            Photos: photos];
    // 在后端发送
    // [self backendSendWithUserID: userid AvatarUrl: avatarUrl Article: article Photos: photos];
}

//------------------------------------每行的高度--------------------------------------------

-(CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath{
    float height;
    
    if(indexPath.row == 0 && indexPath.section == 0){
        height = self.width / 8 * 7 ;
    }
    else if(indexPath.section == 2){
        height = 50;
    }
    else{
        NSInteger avatarY = 20;
        NSInteger avatarW = 70;
        NSInteger articleY = avatarY + avatarW + 15;
        
        UILabel* label = [[UILabel alloc] initWithFrame:
                          CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width - 80, 1)];
        label.text = [self.data[self.data.count - indexPath.row - 1] objectForKey: @"article"];
        label.font = [UIFont systemFontOfSize: 21];
        label.numberOfLines = 0;
        [label sizeToFit];
        float labelHeight = [label sizeThatFits:CGSizeMake(label.frame.size.width,MAXFLOAT)].height;
        float photoY = articleY + labelHeight + 15;
        NSInteger photoW = 110;
        
        NSMutableArray* photos = [self.data[self.data.count - indexPath.row - 1] objectForKey: @"photos"];
        NSInteger numOfPic = photos.count;
        NSInteger row = numOfPic / 3;
        if(numOfPic % 3 > 0) row++;
        float calY = photoY + (photoW + 20) * row;
        NSInteger calH = 40;
        
        NSArray* comments = [self.data[self.data.count - indexPath.row - 1] objectForKey: @"comments"];
        
        height = calY + calH + 10;
        if(comments.count > 0){
            NSInteger commentW = self.width - 70;
            NSInteger commentH = 0;
            NSInteger nameLabelX = 5;
            NSInteger commentLabelX = 40;
            
            for(NSInteger i = 0; i < comments.count; i++){
                NSDictionary* aComment = comments[i];
                UILabel* nameLabel = [[UILabel alloc] initWithFrame:
                                      CGRectMake(nameLabelX, commentH + 8, commentW - 2*nameLabelX , 10)];
                nameLabel.text = [[NSString alloc] initWithFormat:@"%@ :", [aComment objectForKey: @"userid"]];
                nameLabel.font = [UIFont boldSystemFontOfSize: 20];
                nameLabel.numberOfLines = 0;
                [nameLabel sizeToFit];
                NSInteger labelHeight = [nameLabel sizeThatFits: CGSizeMake(nameLabel.frame.size.width, MAXFLOAT)].height;
                commentH += labelHeight;
                
                
                UILabel* commentLabel = [[UILabel alloc] initWithFrame:
                                         CGRectMake(commentLabelX, commentH + 10,
                                                    commentW - commentLabelX - nameLabelX, 10)];
                commentLabel.text = [aComment objectForKey: @"comment"];
                commentLabel.font = [UIFont systemFontOfSize: 20];
                commentLabel.numberOfLines = 0;
                [commentLabel sizeToFit];
                labelHeight = [commentLabel sizeThatFits:CGSizeMake(commentLabel.frame.size.width, MAXFLOAT)].height;
                commentH += labelHeight;
            }
            height += 20 + commentH;
        }
        if([[self.data[self.data.count - indexPath.row - 1] objectForKey: @"commentPop"]
            isEqualToString: @"YES"]){
            height += 60;
        }
    }
    return height;
}

//----------------------- height of section header footer --------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

// 返回tableView中的分区中的数据的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0 || section == 2){
        return 1;
    }
    else{
        return self.data.count;
    }
}

-  (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.row)  {
        return NO;  /*第一行不能进行编辑*/
    } else {
        return YES;
   }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 不同的行, 可以设置不同的编辑样式, 编辑样式是一个枚举类型
    return UITableViewCellEditingStyleNone;
}

// tableView 中显示的数据s
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 可重用标识符
    NSString* cellID;
    if(indexPath.row == 0 && indexPath.section == 0){
        cellID = @"pyq";
    }
    else{
        cellID = [[NSString alloc] initWithFormat:@"%ld", self.data.count - indexPath.row - 1];
    }
    
    // 根据cellID获取可重用的UITableViewCell对象
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellID];
    //UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(!cell){
        if(indexPath.section == 0 && indexPath.row == 0){
            //创建一个UITableViewCell对象，并绑定到cellID
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                          reuseIdentifier: cellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.userInteractionEnabled = YES;
            // 朋友圈封面
            UIImageView* cover = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"cover"]];
            cover.frame = CGRectMake(0, 0, self.width, self.width*7/8);
            cover.layer.borderWidth = 0;
            [cell addSubview: cover];
            
            // add button
            NSInteger btnX = 30, btnY = 50, btnWidth = 30;
            UIButton* addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addBtn.frame = CGRectMake(btnX, btnY, btnWidth, btnWidth);
            [addBtn setBackgroundImage: [UIImage imageNamed: @"add@32"] forState: UIControlStateNormal];
            addBtn.showsTouchWhenHighlighted = YES;
            [addBtn addTarget: self
                       action: @selector(addNewPYQ:)
             forControlEvents: UIControlEventTouchDown];
            [cell.contentView addSubview: addBtn];
            
            // 用户头像
            NSInteger headW = 70;
            NSInteger headX = self.width - headW - 30;
            NSInteger headY = self.width*7/8 - headW - 20;
            
            UIImageView* head = [[UIImageView alloc] init];
            NSURL* url = [NSURL URLWithString:self.userInfo.avatarUrl];
            [head sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
            
            head.frame = CGRectMake(headX, headY, headW, headW);
            head.layer.cornerRadius = 10;
            head.layer.masksToBounds = YES;
            
            // 用户名
            NSInteger nameH = headW;
            NSInteger nameW = 100;
            NSInteger nameX = headX - nameW - 20;
            NSInteger nameY = headY;
            UILabel* username = [[UILabel alloc] initWithFrame:
                                 CGRectMake(nameX, nameY, nameW, nameH)];
            
            username.text = self.userInfo.nickname;
            if([username.text isEqualToString: @""] || username.text == nil){
                username.text = self.userInfo.userId;
            }

            username.textAlignment = NSTextAlignmentRight;
            username.font = [UIFont boldSystemFontOfSize: 22];
            username.textColor = [UIColor whiteColor];
            username.shadowColor = [UIColor blackColor];
            username.shadowOffset = CGSizeMake(1.5, 1.5); //阴影偏移  x，y为正表示向右下偏移
            
            [cell addSubview: head];
            [cell addSubview: username];
            [cell bringSubviewToFront: username];
        }
        else if(indexPath.section == 1){
            NSInteger index = self.data.count - indexPath.row - 1;
            NSDictionary* dictionary = self.data[index];
            
            cell = [[aPYQ alloc] initWithData: dictionary
                                   Identifier: cellID
                                     Delegate: self];
            self.identifier++;
        }
        else{
            cell = [[UITableViewCell alloc] initWithFrame:
                    CGRectMake(0, 0, self.width, 50)];
            cell.selectionStyle = NO;
            UILabel* bottomLabel = [[UILabel alloc] initWithFrame:
                                    CGRectMake(0, 0, self.width, 50)];
            bottomLabel.backgroundColor = [UIColor clearColor];
            bottomLabel.text = @"已经翻到底了哦 ~";
            bottomLabel.textColor = [UIColor lightGrayColor];
            bottomLabel.font = [UIFont systemFontOfSize: 19];
            bottomLabel.textAlignment = NSTextAlignmentCenter;
            [cell addSubview: bottomLabel];
        }
        // 设置列的按钮类型
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // 根据分区设置UITableViewCell显示的数据
    return cell;
}

// ------------------------------ 以下内容不用修改

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

// 风车的动画
-(void) windmillAni{
    NSInteger x = 40;
    NSInteger y = -40;
    NSInteger width = 40;
    
    UIImage* icon = [UIImage imageNamed: @"inpyq"];
    UIImageView* iconView = [[UIImageView alloc] initWithImage: icon];
    iconView.frame = CGRectMake(x, y, width, width);
    [self.view addSubview: iconView];
    [UIView animateWithDuration: 0.4
                          delay: 0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         iconView.frame = CGRectMake(x, 70, width, width);
                     }
                     completion: nil
     ];
    [UIView animateWithDuration: 1.4
                          delay: 0.4
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         iconView.transform = CGAffineTransformMakeRotation(M_PI);
                         iconView.transform = CGAffineTransformMakeRotation(2*M_PI);
                         iconView.transform = CGAffineTransformMakeRotation(3*M_PI);
                     }
                     completion: nil
     ];
    [UIView animateWithDuration: 0.4
                          delay: 1.7
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         iconView.frame = CGRectMake(x, y, width, width);
                     }
                     completion: nil
     ];
}
@end
