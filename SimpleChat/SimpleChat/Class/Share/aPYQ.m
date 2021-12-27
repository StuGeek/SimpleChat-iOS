#import <Foundation/Foundation.h>
#import "aPYQ.h"

@interface aPYQ()

@property (nonatomic) NSString *cellID, *userid, *name, *avatarUrl, *article, *time;
@property (nonatomic) NSArray *photos;
@property (nonatomic) NSMutableArray *comments;
@property (nonatomic) UILabel *articleLabel, *commentNum, *nameLabel, *likeNum, *timeLabel;//
@property (nonatomic) UIButton *like, *comment;
@property (nonatomic) UIImageView *avatar;
@property (nonatomic) NSInteger width, height, avatarW, avatarX, avatarY, articleX, articleY, photoY, calY, calH;
@property (nonatomic) NSInteger numOfLike, numOfComment, numOfPic;
@property (nonatomic) float labelHeight, cellHeight;
@property (nonatomic) UIView *commentAndLike, *commentBox, *commentArea;
@property (nonatomic) Boolean likeWasClicked, commentWasClicked;
@property (nonatomic) UITextField* input;
@property (nonatomic) NSMutableArray* userLabel;

@end

@implementation aPYQ

@synthesize PYQdelegate = _PYQdelegate;

- (id) initWithData: (NSDictionary*) dictionary
         Identifier: (NSString*) identifier
           Delegate: (id) delegate {
    
    self = [super initWithStyle: UITableViewCellStyleDefault
                reuseIdentifier: identifier];
    if(self){
        self.width = [UIScreen mainScreen].bounds.size.width;
        self.height = 350;
        self.frame = CGRectMake(0, 0, self.width, 200);
        self.selectionStyle = NO;
        
        self.cellID = identifier;
        self.userid = [dictionary objectForKey: @"userID"];
        self.name = [dictionary objectForKey: @"name"];
        self.avatarUrl = [dictionary objectForKey: @"avatarUrl"];
        self.article = [dictionary objectForKey: @"article"];
        self.photos = [dictionary objectForKey: @"photos"];
        self.time = [dictionary objectForKey: @"date"];
        self.comments = [dictionary objectForKey: @"comments"];
        self.userLabel = [NSMutableArray arrayWithCapacity: 20];
        self.PYQdelegate = delegate;
        self.numOfPic = self.photos.count;
        
        self.numOfLike = 0;
        self.numOfComment = self.comments.count;
        self.commentWasClicked = NO;
        self.likeWasClicked = NO;
        self.avatarX = 20;
        self.avatarY = 20;
        self.avatarW = 60;
        
        // 头像
        self.avatar = [[UIImageView alloc] initWithFrame:
                       CGRectMake(self.avatarX, self.avatarY, self.avatarW, self.avatarW)];
    
        if(self.avatarUrl != nil && ![self.avatarUrl isEqualToString: @""]){
            NSURL* url = [NSURL URLWithString: self.avatarUrl];
            [self.avatar sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
        }
        else{
            [self.avatar setImage: [UIImage imageNamed: @"default.jpg"]];
        }
        self.avatar.layer.borderWidth = 0.5;
        self.avatar.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width/8.0;
        self.avatar.layer.masksToBounds = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(personData:)];
        [self.avatar addGestureRecognizer: tapGestureRecognizer];
        [self.avatar setUserInteractionEnabled:YES];
        /*
        self.avatar = [[UIButton alloc] initWithFrame:
                       CGRectMake(self.avatarX, self.avatarY, self.avatarW, self.avatarW)];
        
        if(self.avatarUrl != nil && ![self.avatarUrl isEqualToString: @""]){
            [self.avatar setBackgroundImage: [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: self.avatarUrl]]] forState: UIControlStateNormal];
        }
        else{
            [self.avatar setBackgroundImage: [UIImage imageNamed: @"default.jpg"] forState: UIControlStateNormal];
        }
        self.avatar.layer.borderWidth = 0.5;
        self.avatar.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width/8.0;
        self.avatar.layer.masksToBounds = YES;
        [self.avatar addTarget: self
                        action: @selector(personData:)
              forControlEvents: UIControlEventTouchUpInside];*/
        
        // 名字
        self.nameLabel = [[UILabel alloc] initWithFrame:
                          CGRectMake(self.avatarX + self.avatarW + 15, self.avatarY, 300, self.avatarW)];
        self.nameLabel.text = self.name;
        self.nameLabel.font = [UIFont boldSystemFontOfSize: 22];
        self.nameLabel.textColor = [UIColor colorWithRed: 50/255.0
                                                   green: 60/255.0
                                                    blue: 150/255.0
                                                   alpha: 100];
        
        // 朋友圈文案
        self.articleX = self.avatarX + 2 * self.avatarX;
        self.articleY = self.avatarY + self.avatarW + 15;
        self.articleLabel = [[UILabel alloc] initWithFrame:
                             CGRectMake(self.articleX,
                                        self.articleY,
                                        self.width - 4 * self.avatarX,
                                        100)];
        self.articleLabel.text = self.article;
        self.articleLabel.font = [UIFont systemFontOfSize: 21];
        self.articleLabel.numberOfLines = 3;
        self.articleLabel.backgroundColor = [UIColor lightTextColor];
        
        self.articleLabel.numberOfLines = 0;
        [self.articleLabel sizeToFit];
        self.labelHeight = [self.articleLabel sizeThatFits:CGSizeMake(self.articleLabel.frame.size.width,
                                                                      MAXFLOAT)].height;
        // 朋友圈配图
        NSInteger photoW = 110;
        NSInteger photoX = self.articleX;
        self.photoY = self.articleY + self.labelHeight + 15;
        
        // uiimageview 被点击的手势
        
        for(NSInteger i = 0; i < self.photos.count; i++){
            UIImageView* photo = [[UIImageView alloc] initWithFrame:
                                  CGRectMake(photoX + (i % 3) * (photoW + 5),
                                             self.photoY + (i / 3) * (photoW + 5),
                                             photoW, photoW)];
            photo.image = self.photos[i];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(scanImageClick:)];
            [photo addGestureRecognizer: tapGestureRecognizer];
            [photo setUserInteractionEnabled:YES];
            
            [self.contentView addSubview: photo];
        }
        
        // 点赞和评论 commentAndLike: 简称 cal
        NSInteger calW = 140;
        self.calH = 40;
        NSInteger calX = self.width - calW - 10;
        NSInteger row = self.numOfPic / 3;
        if(self.numOfPic % 3 > 0) row++;
        self.calY = self.photoY + (photoW + 20) * row;
        
        self.commentAndLike = [[UIView alloc] initWithFrame:
                               CGRectMake(calX, self.calY, calW, self.calH)];
        self.commentAndLike.layer.borderWidth = 1;
        self.commentAndLike.layer.cornerRadius = 5;
        self.commentAndLike.layer.borderColor = [UIColor blackColor].CGColor;
        
        // like
        self.like = [[UIButton alloc] initWithFrame:
                     CGRectMake(3, 3, self.calH - 6, self.calH - 6)];
        [self.like setBackgroundImage: [UIImage imageNamed:@"like"]
                             forState: UIControlStateNormal];
        [self.like addTarget: self
                      action: @selector(likeClicked:)
            forControlEvents: UIControlEventTouchUpInside];
        self.like.showsTouchWhenHighlighted = YES;
        
        // like num
        self.likeNum = [[UILabel alloc] initWithFrame:
                        CGRectMake(3 + self.calH - 6 + 10, 3, self.calH - 6, self.calH - 6)];
        self.likeNum.text = [[NSString alloc] initWithFormat:@"%ld", self.numOfLike];
        self.likeNum.font = [UIFont boldSystemFontOfSize: 20];
        
        // comment
        self.comment = [[UIButton alloc] initWithFrame:
                        CGRectMake(calW/2 + 4, 6, self.calH - 12, self.calH - 12)];
        [self.comment setBackgroundImage: [UIImage imageNamed:@"comment"]
                                forState: UIControlStateNormal];
        self.comment.showsTouchWhenHighlighted = YES;
        [self.comment addTarget: self
                         action: @selector(commentClicked:)
               forControlEvents: UIControlEventTouchUpInside];
        
        // comment num
        self.commentNum = [[UILabel alloc] initWithFrame:
                           CGRectMake(calW/2 + self.calH - 12 + 16, 3, self.calH - 6, self.calH - 6)];
        self.commentNum.text = [[NSString alloc] initWithFormat:@"%ld", self.numOfComment];
        self.commentNum.font = [UIFont boldSystemFontOfSize: 20];
        
        // 发送时间
        NSInteger timeLabelW = 180;
        NSInteger timeLabelH = 40;
        self.timeLabel = [[UILabel alloc] initWithFrame:
                     CGRectMake(self.articleX, self.calY, timeLabelW, timeLabelH)];
        self.timeLabel.text = self.time;
        self.timeLabel.font = [UIFont systemFontOfSize: 16];
        self.timeLabel.textColor = [UIColor lightGrayColor];
        //self.timeLabel.backgroundColor = [UIColor blackColor];
        
        [self.commentAndLike addSubview: self.comment];
        [self.commentAndLike addSubview: self.commentNum];
        [self.commentAndLike addSubview: self.like];
        [self.commentAndLike addSubview: self.likeNum];
        
        [self.contentView addSubview: self.avatar];
        [self addSubview: self.nameLabel];
        [self addSubview: self.articleLabel];
        [self addSubview: self.timeLabel];
        [self.contentView addSubview: self.commentAndLike];
        
        // 评论区
        if(self.comments.count > 0){
            NSInteger commentY = self.calY + self.calH + 10;
            NSInteger commentW = self.width - 10 - self.articleX;
            NSInteger commentH = 0;
            NSInteger nameLabelX = 5;
            NSInteger commentLabelX = 40;
            self.commentArea = [[UIView alloc] init];
            self.commentArea.backgroundColor = [UIColor colorWithRed: 247/255.0
                                                          green: 252/255.0
                                                           blue: 252/255.0
                                                          alpha: 1];
            
            for(NSInteger i = 0; i < self.comments.count; i++){
                NSDictionary* aComment = self.comments[i];
                
                // nameLabel
                UILabel* nameLabel = [[UILabel alloc] initWithFrame:
                                      CGRectMake(nameLabelX, commentH + 8, commentW - 2*nameLabelX , 10)];
                [self.userLabel addObject: nameLabel];
                nameLabel.text = [[NSString alloc] initWithFormat:@"%@ :", [aComment objectForKey: @"userid"]];
                nameLabel.font = [UIFont boldSystemFontOfSize: 20];
                nameLabel.textColor = [UIColor colorWithRed: 77/255.0
                                                      green: 124/255.0
                                                       blue: 198/255.0
                                                      alpha: 1];
                nameLabel.numberOfLines = 0;
                [nameLabel sizeToFit];
                NSInteger labelHeight = [nameLabel sizeThatFits: CGSizeMake(nameLabel.frame.size.width, MAXFLOAT)].height;
                commentH += labelHeight;
                /*
                UITapGestureRecognizer *Tap = [[UITapGestureRecognizer alloc]
                                                                     initWithTarget: self
                                                                     action: @selector(personDataFromLabel:)];
                nameLabel.userInteractionEnabled = YES;
                [[self.userLabel objectAtIndex: i] addGestureRecognizer: Tap];
                */
                // commentLabel
                UILabel* commentLabel = [[UILabel alloc] initWithFrame:
                                         CGRectMake(commentLabelX, commentH + 10,
                                                    commentW - commentLabelX - nameLabelX, 10)];
                commentLabel.text = [aComment objectForKey: @"comment"];
                
                commentLabel.font = [UIFont systemFontOfSize: 20];
                commentLabel.numberOfLines = 0;
                [commentLabel sizeToFit];
                labelHeight = [commentLabel sizeThatFits:CGSizeMake(commentLabel.frame.size.width, MAXFLOAT)].height;
                commentH += labelHeight;
                
                [self.commentArea addSubview: nameLabel];
                [self.commentArea addSubview: commentLabel];
                [self.commentArea bringSubviewToFront: nameLabel];
                [self.commentArea bringSubviewToFront: commentLabel];
            }
            self.commentArea.frame = CGRectMake(self.articleX, commentY, commentW, commentH + 10);
            
            [self addSubview: self.commentArea];
            [self bringSubviewToFront: self.commentArea];
            self.cellHeight = commentY + commentH + 30;
        }
        else{
            self.cellHeight = self.calY + self.calH + 10;
        }
    }
    return self;
}

- (void)refresh{
    self.likeNum.text = [[NSString alloc] initWithFormat:@"%ld", self.numOfLike];
    self.commentNum.text = [[NSString alloc] initWithFormat:@"%ld", self.numOfComment];
}

-(void)scanImageClick: (UITapGestureRecognizer *) tap {
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [ScanImage scanBigImageWithImageView: clickedImageView];
}

- (void)likeClicked: (id) sender{
    if(self.likeWasClicked == YES){
        NSLog(@"likeCancel");
        [self.like setBackgroundImage: [UIImage imageNamed: @"like"]
                             forState: UIControlStateNormal];
        self.likeWasClicked = NO;
        self.numOfLike--;
    }
    else{
        NSLog(@"likeClicked");
        [self.like setBackgroundImage: [UIImage imageNamed: @"liked"]
                             forState: UIControlStateNormal];
        self.likeWasClicked = YES;
        self.numOfLike++;
    }
    [self refresh];
}

- (void) sendClick: (id) sender{
    NSLog(@"send comment");
    
    self.numOfComment++;
    [self refresh];
    
    NSString* userid = [self.PYQdelegate getUserid];
    [self.comments addObject: @{ @"userid": userid,
                                 @"comment": self.input.text}];
    self.input.text = @"";
    [self commentClicked: self.comment];
    [self refreshCommentArea];
}

- (void)commentClicked: (id) sender{
    NSLog(@"commentClicked");
    
    if(self.commentWasClicked == NO){
        float width = [UIScreen mainScreen].bounds.size.width;
        float height = 60;
        
        self.commentBox = [[UIView alloc] initWithFrame: CGRectMake(0, self.cellHeight, width, height)];
        self.commentBox.backgroundColor = [UIColor colorWithRed: 221/255.0
                                                           green: 221/255.0
                                                            blue: 221/255.0
                                                           alpha: 1];
        
        self.input = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, width - 100, height - 20)];
        self.input.layer.cornerRadius = 5;
        self.input.clipsToBounds = YES;
        self.input.backgroundColor = [UIColor whiteColor];
        self.input.placeholder = @" 评论";
        self.input.font = [UIFont fontWithName: @"Arial" size: 20.0f];
        self.input.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        UIButton* send = [[UIButton alloc] initWithFrame:
                          CGRectMake(width - 80, 10, 70, height - 20)];
        [send setTitle:@"发送" forState:UIControlStateNormal];
        send.layer.cornerRadius = 5;
        send.backgroundColor = [UIColor colorWithRed: 95.0/255
                                               green: 160.0/255
                                                blue: 85.0/255
                                               alpha: 100];
        
        [send addTarget: self
                 action: @selector(sendClick:)
       forControlEvents: UIControlEventTouchUpInside];
        
        [self.commentBox addSubview: self.input];
        [self.commentBox addSubview: send];
        [self.contentView addSubview: self.commentBox];
        [self bringSubviewToFront: self.commentBox];
        self.commentWasClicked = YES;
    }
    else{
        [self.commentBox removeFromSuperview];
        self.commentWasClicked = NO;
    }
    [self.PYQdelegate setCOMMENTPOPwithCellID: self.cellID];
}

// 刷新评论区
- (void)refreshCommentArea{
    NSInteger commentY = self.calY + self.calH + 10;
    NSInteger commentW = self.width - 10 - self.articleX;
    NSInteger commentH = 0;
    NSInteger nameLabelX = 5;
    NSInteger commentLabelX = 40;
    self.commentArea = [[UIView alloc] init];
    self.commentArea.backgroundColor = [UIColor colorWithRed: 247/255.0
                                                  green: 252/255.0
                                                   blue: 252/255.0
                                                  alpha: 1];
    
    for(NSInteger i = 0; i < self.comments.count; i++){
        NSDictionary* aComment = self.comments[i];
        
        // nameLabel
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:
                              CGRectMake(nameLabelX, commentH + 8, commentW - 2*nameLabelX , 10)];
        [self.userLabel addObject: nameLabel];
        nameLabel.text = [[NSString alloc] initWithFormat:@"%@ :", [aComment objectForKey: @"userid"]];
        nameLabel.font = [UIFont boldSystemFontOfSize: 20];
        nameLabel.textColor = [UIColor colorWithRed: 77/255.0
                                              green: 124/255.0
                                               blue: 198/255.0
                                              alpha: 1];
        nameLabel.numberOfLines = 0;
        [nameLabel sizeToFit];
        NSInteger labelHeight = [nameLabel sizeThatFits: CGSizeMake(nameLabel.frame.size.width, MAXFLOAT)].height;
        commentH += labelHeight;
        /*
        UITapGestureRecognizer *Tap = [[UITapGestureRecognizer alloc]
                                                             initWithTarget: self
                                                             action: @selector(personDataFromLabel:)];
        nameLabel.userInteractionEnabled = YES;
        [[self.userLabel objectAtIndex: i] addGestureRecognizer: Tap];
        */
        // commentLabel
        UILabel* commentLabel = [[UILabel alloc] initWithFrame:
                                 CGRectMake(commentLabelX, commentH + 10,
                                            commentW - commentLabelX - nameLabelX, 10)];
        commentLabel.text = [aComment objectForKey: @"comment"];
        
        NSLog(@" comment %@", [aComment objectForKey: @"comment"]);
        
        commentLabel.font = [UIFont systemFontOfSize: 20];
        commentLabel.numberOfLines = 0;
        [commentLabel sizeToFit];
        labelHeight = [commentLabel sizeThatFits:CGSizeMake(commentLabel.frame.size.width, MAXFLOAT)].height;
        commentH += labelHeight;
        
        [self.commentArea addSubview: nameLabel];
        [self.commentArea addSubview: commentLabel];
        [self.commentArea bringSubviewToFront: nameLabel];
        [self.commentArea bringSubviewToFront: commentLabel];
    }
    self.commentArea.frame = CGRectMake(self.articleX, commentY, commentW, commentH + 10);
    
    [self addSubview: self.commentArea];
    [self bringSubviewToFront: self.commentArea];
    self.cellHeight = commentY + commentH + 30;
}

//个人资料页
- (void)personData: (id) sender{
    UIViewController* controller = nil;
    if([[EMClient sharedClient].currentUsername isEqualToString: self.userid]) {
        controller = [[AccountViewController alloc] init];
    }
    else{
        controller = [[PersonalDataViewController alloc]initWithNickName: self.userid];
    }
    [self.PYQdelegate openPersonalDataVC: controller];
}
/*
- (void)personDataFromLabel: (UITapGestureRecognizer *) sender{
    NSLog(@"11");
    NSString* userid = ((UILabel*)sender).text;
    userid = [userid substringToIndex: ([userid length] - 2)];
    //UIViewController* controller = [[EMPersonalDataViewController alloc]initWithNickName: userid];
    NSLog(@"%@a", userid);
    //[self.PYQdelegate openPersonalDataVC: controller];
}
*/
@end
