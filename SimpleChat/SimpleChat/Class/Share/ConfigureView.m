#import <Foundation/Foundation.h>
#import "ConfigureView.h"

@interface ConfigureView()

@property (nonatomic) UILabel* Header;
@property (nonatomic) UITextView* textView;
@property (nonatomic) UIButton *addPicBtn, *rtnBtn, *sendBtn;
@property (nonatomic) CGFloat width, height;
@property (nonatomic) NSMutableArray * assets;
@property (nonatomic) NSMutableArray * photos;
@property (nonatomic) NSInteger PicW, PicX, PicY;

@end

@implementation ConfigureView

@synthesize PYQdelegate = _PYQdelegate;

- (id) initWithDelegate: (id) delegate {
    self.width = [[UIScreen mainScreen] bounds].size.width;
    self.height = [[UIScreen mainScreen] bounds].size.height;
    self.PYQdelegate = delegate;
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, self.width, self.height);
        self.backgroundColor = [UIColor whiteColor];
        self.photos = [[NSMutableArray alloc] initWithCapacity: 6];
        [self layout];
    }
    return self;
}

- (void) layout{
    NSInteger headerH = 110;
    // 顶部栏
    self.Header = [[UILabel alloc] initWithFrame:
                   CGRectMake(0, 0, self.width, headerH)];
    self.Header.textAlignment = NSTextAlignmentCenter;
    self.Header.textColor = [UIColor blackColor];
    self.Header.text = @"编辑分享";
    self.Header.font = [UIFont boldSystemFontOfSize:20];
    [self addSubview: self.Header];
    
    // 返回按钮
    self.rtnBtn = [[UIButton alloc] initWithFrame:
                   CGRectMake(20, 40, 30, 30)];
    [self.rtnBtn setBackgroundImage: [UIImage imageNamed:@"return"]
                           forState: UIControlStateNormal];
    [self.rtnBtn addTarget: self
                    action: @selector(returnToPYQ:)
          forControlEvents: UIControlEventTouchDown];
    [self addSubview: self.rtnBtn];
    
    // 发送朋友圈按钮
    NSInteger sendBtnW = 70;
    self.sendBtn = [[UIButton alloc] initWithFrame:
                   CGRectMake(self.width - sendBtnW - 20, 40, sendBtnW, 30)];
    self.sendBtn.tintColor = [UIColor whiteColor];
    self.sendBtn.backgroundColor = [UIColor colorWithRed: 95.0/255
                                                   green: 160.0/255
                                                    blue: 85.0/255
                                                   alpha: 100];
    [self.sendBtn setTitle: @"发送"
                  forState: UIControlStateNormal];
    self.sendBtn.layer.cornerRadius = 5.0;
    [self.sendBtn addTarget: self
                     action: @selector(sendPYQ:)
           forControlEvents: UIControlEventTouchDown];
    [self addSubview: self.sendBtn];
    [self bringSubviewToFront: self.sendBtn];
    
    // 文案
    NSInteger textViewH = 200;
    NSInteger textViewY = headerH + 10;
    self.textView = [[UITextView alloc] initWithFrame:
                     CGRectMake(20, textViewY, self.width - 40, textViewH)];
    self.textView.font = [UIFont systemFontOfSize: 18];
    self.textView.text = @"说说此刻的想法...";
    [self addSubview: self.textView];
    
    // 配图添加按钮
    NSInteger i = 20;
    self.PicW = (self.width - 6*i)/3;
    self.PicX = 2*i;
    self.PicY = textViewY + textViewH + 20;
    self.addPicBtn = [[UIButton alloc] initWithFrame:
                      CGRectMake(self.PicX, self.PicY, self.PicW, self.PicW)];
    self.addPicBtn.backgroundColor = [UIColor blueColor];
    [self.addPicBtn setBackgroundImage: [UIImage imageNamed: @"addPic.jpg"]
                              forState: UIControlStateNormal];
    [self.addPicBtn addTarget: self
                       action: @selector(addPic:)
             forControlEvents: UIControlEventTouchDown];
    [self addSubview: self.addPicBtn];
}

- (void) returnToPYQ: (id) sender{
    NSLog(@"returnToPYQ");
    [self removeFromSuperview];
}

- (void) sendPYQ: (id) sender{
    NSLog(@"sendPYQ");
    if([self.textView.text isEqualToString: @""]){
        NSLog(@"the article is empty.");
    }
    else{
        NSString* article = self.textView.text;
        NSString* userid = [EMClient sharedClient].currentUsername;
        EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById: userid];
        NSLog(@"url: %@", userInfo.avatarUrl);
        // 发送
        [self.PYQdelegate sendPYQWithUserID: userid
                                  AvatarUrl: userInfo.avatarUrl
                                    Article: article
                                     Photos: self.photos];
        // 返回朋友圈页面
        [self removeFromSuperview];
    }
}

// 选择图片
- (void) addPic: (id) sender {
    NSLog(@"add a pic");
    UIImagePickerController *choice = [[UIImagePickerController alloc] init];
    choice.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    choice.delegate = self;
    choice.allowsEditing = YES;
    [self.PYQdelegate openPicker: choice];
}

// 实现UIImagePickerController的委托方法，获取图片后的操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 将图片放进配图数组中
    [self.photos addObject:photo];
    NSInteger i = self.photos.count - 1;
    UIImage* image = self.photos[i];
    [self.addPicBtn removeFromSuperview];
    [self viewWithTag: i - 1];

    //[self viewWithTag: i-1 setback]
    UIImageView * imageview = [[UIImageView alloc] initWithFrame:
                                CGRectMake(self.PicX + (i % 3)*(self.PicW + 20),
                                           self.PicY + (i / 3)*(self.PicW + 20),
                                           self.PicW,
                                           self.PicW)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [self addSubview: imageview];
    [self.PYQdelegate closePicker: picker];
        
    // add button
    if(i < 8){
        self.addPicBtn.frame = CGRectMake(self.PicX + (i+1) % 3 * (self.PicW + 20),
                                          self.PicY + (i+1) / 3 * (self.PicW + 20),
                                          self.PicW,
                                          self.PicW);
        [self addSubview: self.addPicBtn];
    }
}


@end
