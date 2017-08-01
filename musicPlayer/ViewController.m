//
//  ViewController.m
//  musicPlayer
//
//  Created by iMacQIU on 16/1/11.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "ViewController.h"
#import "LSFLrcManerger.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>

{
    NSArray *_mp3Array;//歌曲数组
    NSArray *_lrcArray;
    NSArray *_imageArray;
    int _count;//播放歌曲在数组中的位置
    
    AVAudioPlayer *_player;//音频播放器
    NSTimer *_timer;//定时器
    
    int _loopCount;
    
    UIImageView *_voiceView;
    
    UIView *_menuView;
    UIView *_backgView;
    UIView *_worldView;
    
    UIButton *_colorBtn;
    NSMutableArray  *_colorArray;
    
    UISlider *_fontSlider;
    CGFloat _font;
    UILabel *_fontlabe;
    
    LSFLrcManerger *_lrcmanerger;
    CGFloat _vioce;
    
    int _loopCount1;
    UIImageView *_headImageView;
    
    NSTimer *_timer2;
}


@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UIView      *backgroundView;

@property (weak, nonatomic) IBOutlet UIButton    *playButton;

@property (weak, nonatomic) IBOutlet UIButton    *nextButton;

@property (weak, nonatomic) IBOutlet UIButton    *preButton;

@property (weak, nonatomic) IBOutlet UIButton    *menuButton;

@property (weak, nonatomic) IBOutlet UIButton    *loopButton;

@property (weak, nonatomic) IBOutlet UISlider    *ProgressSlider;

@property (weak, nonatomic) IBOutlet UILabel     *SongNameLabel;

@property (weak, nonatomic) IBOutlet UILabel     *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel     *allTimeLabel;


@property (nonatomic, strong) UIScrollView *myScrollView;

@property (nonatomic, strong) UITableView  *tabelView1;

@property (nonatomic, strong) UITableView  *tabelView2;

@property (nonatomic, strong) UILabel      *singerLabel;

@property (nonatomic, strong) UIImageView  *HeadPortraitView;

@property (nonatomic,assign)  BOOL   isLarge;

@property (nonatomic,assign) CGRect  oldFrame;

@property (nonatomic, strong) UIPageControl *page;

@property (nonatomic, strong) UILabel       *lrcLabel;


@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) NSInteger currentRow;



@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        
        _mp3Array   = @[@"匆匆那年 - 王菲",@"可念不可说 - 崔子格",@"南山南 - 马頔",@"夏洛特烦恼 - 金志文"];
        _lrcArray   = @[@"匆匆那年",@"可念不可说",@"南山南",@"夏洛特烦恼"];
        
        _imageArray  = @[@"匆匆那年.jpg",@"可念不可说.jpg",@"南山南.jpg",@"夏洛特烦恼.jpg"];
        
        _colorArray = [[NSMutableArray alloc]init];
        
        _count      = 0;
        _loopCount  = 1;
        _loopCount1 = 1;
        
        _font       = 12;
        
        _vioce      = 0.8;
        
        _colorBtn.backgroundColor = [UIColor greenColor];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initScrollView];
   
    [self initPage];
    
    
    //默认播放第一首
    [self createPlayerWihtFileName:_mp3Array[0] lrcName:_lrcArray[0] imageName:_imageArray[0]];
    
    //拉动进度条,可以修改播放进度
    [_ProgressSlider addTarget:self action:@selector(chang:) forControlEvents:UIControlEventValueChanged];

    
}

- (void)initScrollView
{

    self.myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height-55-160)];
    
    self.myScrollView.contentSize = CGSizeMake(2*self.myScrollView.frame.size.width, self.myScrollView.frame.size.height);
    
    self.myScrollView.backgroundColor = [UIColor clearColor];
    
    self.myScrollView.showsHorizontalScrollIndicator = NO;
    
    self.myScrollView.showsVerticalScrollIndicator   = NO;
    
    self.myScrollView.bounces = NO;
    
    //设置代理
    self.myScrollView.delegate      = self;
    //打开页
    self.myScrollView.pagingEnabled = YES;
    
    [self initHeadPortrait];
    
    [self initTableView];
    
    [self initlrcLabel];
    
    
    
    [self.view insertSubview:self.myScrollView atIndex:2];

}

- (void)initTableView
{
    //歌词显示
    self.tabelView1 = [[UITableView alloc]initWithFrame:CGRectMake(_myScrollView.frame.size.width, 0, _myScrollView.frame.size.width, _myScrollView.frame.size.height) style:UITableViewStylePlain];
    
    self.tabelView1.delegate   = self;
    self.tabelView1.dataSource = self;
    
    
    self.tabelView1.backgroundColor = [UIColor clearColor];
    
    self.tabelView1.separatorStyle  = UITableViewCellSeparatorStyleNone;
    
    self.tabelView1.showsHorizontalScrollIndicator = NO;
    
    self.tabelView1.showsVerticalScrollIndicator   = NO;
    
    self.tabelView1.scrollEnabled  = NO;
    
    [self.myScrollView addSubview:self.tabelView1];
    
    
    //歌曲显示(菜单)
    
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height*3.0/4)];
    
    _menuView.backgroundColor = [UIColor darkGrayColor];
    
    //音量符号
    _voiceView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    
    _voiceView.image = [UIImage imageNamed:@"img_background_button_splash_audio_enabled_normal"];
    
    [_menuView addSubview:_voiceView];
    
    
    //调节音量滑块
    UISlider *voiceSlider = [[UISlider alloc]initWithFrame:CGRectMake(50, 5, self.view.frame.size.width-100, 30)];
    
    voiceSlider.value = _vioce;
    
    [voiceSlider addTarget:self action:@selector(voiceChang:) forControlEvents:UIControlEventValueChanged];
    
    [_menuView addSubview:voiceSlider];
    
    //线
    UIImageView *lineImgViewTop = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 1)];
    
    lineImgViewTop.backgroundColor = [UIColor whiteColor];
    
      [_menuView addSubview:lineImgViewTop];
    
    
    UIImageView *lineImgViewBttom = [[UIImageView alloc]initWithFrame:CGRectMake(0, _menuView.frame.size.height-50, self.view.frame.size.width, 1)];
    
    lineImgViewBttom.backgroundColor = [UIColor whiteColor];
    
    [_menuView addSubview:lineImgViewBttom];
    
    //关闭
    
    UIButton *CloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CloseButton.frame     = CGRectMake(0, _menuView.frame.size.height-49, self.view.frame.size.width, 49);
    
    [CloseButton setTintColor:[UIColor whiteColor]];
    [CloseButton setTitle:@"关闭" forState:UIControlStateNormal];
    CloseButton.titleLabel.font = [UIFont systemFontOfSize:17];
    
    [CloseButton addTarget:self action:@selector(closeBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [_menuView addSubview:CloseButton];
    

    //背景
    _backgView = [[UIView alloc]initWithFrame:self.view.bounds];
    
    _backgView.backgroundColor = [UIColor darkGrayColor];
    
    _backgView.alpha  = 0;
    
    _backgView.hidden = YES;
    
    
    self.tabelView2 = [[UITableView alloc]initWithFrame:CGRectMake(0, 42, self.view.frame.size.width,  _menuView.frame.size.height-95) style:UITableViewStylePlain];
    
    self.tabelView2.delegate   = self;
    self.tabelView2.dataSource = self;
    
    self.tabelView1.showsHorizontalScrollIndicator = NO;
    
    self.tabelView1.showsVerticalScrollIndicator   = NO;
    
    self.tabelView2.backgroundColor = [UIColor darkGrayColor];
    
    [_menuView addSubview:self.tabelView2];
    
    
    [self.view addSubview:_backgView];

    
    [self.view addSubview:_menuView];
    
    
    //开关歌词
    UIButton *opendAndCloseBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    opendAndCloseBtn.frame     = CGRectMake(self.view.frame.size.width+15, self.myScrollView.frame.size.height-40, 30, 30);
    
    [opendAndCloseBtn setTintColor:[UIColor whiteColor]];
    [opendAndCloseBtn setTitle:@"关" forState:UIControlStateNormal];
    opendAndCloseBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    opendAndCloseBtn.backgroundColor = [UIColor blackColor];
    
    opendAndCloseBtn.layer.borderWidth = 1.0;
    opendAndCloseBtn.layer.borderColor = [[UIColor whiteColor]CGColor];
    opendAndCloseBtn.layer.cornerRadius = opendAndCloseBtn.frame.size.width/2.0;
    
    [opendAndCloseBtn addTarget:self action:@selector(opendCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_myScrollView addSubview:opendAndCloseBtn];
    
    //词
    

    UIButton *worldButton =[UIButton buttonWithType:UIButtonTypeCustom];
    worldButton.frame     = CGRectMake(2*self.view.frame.size.width-45, self.myScrollView.frame.size.height-40, 30, 30);
    
    [worldButton setTintColor:[UIColor whiteColor]];
    [worldButton setTitle:@"词" forState:UIControlStateNormal];
    worldButton.titleLabel.font = [UIFont systemFontOfSize:13];
    worldButton.backgroundColor = [UIColor blackColor];
    
    worldButton.layer.borderWidth = 1.0;
    worldButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    worldButton.layer.cornerRadius = opendAndCloseBtn.frame.size.width/2.0;
    
    [worldButton addTarget:self action:@selector(worldBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_myScrollView addSubview:worldButton];
    
    
    //词菜单
    _worldView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200)];
    
    _worldView.backgroundColor = [UIColor darkGrayColor];
    
    _colorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _colorBtn.frame = CGRectMake(5, 10, 40, 40);
    _colorBtn.backgroundColor = [UIColor greenColor];
    
    [_worldView addSubview:_colorBtn];
    
    CGFloat x      = 45;
    CGFloat y      = 6;
    CGFloat min    = (self.view.frame.size.width-200)/7;
    CGFloat with   = 25;
    CGFloat height = 25;
    
    
    [self setColor];
    
    
    for (int i=0; i<2; i++)
    {
        for (int j=0; j<6; j++)
        {
            
            UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
            colorButton.frame = CGRectMake(x+with*j+min*(j+1), y*(i+1)+height*i, with, height);
            colorButton.backgroundColor = _colorArray[i*6+j];
            colorButton.tag = 100+i*6+j;
            [colorButton addTarget:self action:@selector(colorBtn:) forControlEvents:UIControlEventTouchUpInside];

            [_worldView addSubview:colorButton];
        }
    }
    
    
    //线
    UIImageView *lineImgView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 75, self.view.frame.size.width, 1)];
    
    lineImgView1.backgroundColor = [UIColor whiteColor];
    
    [_worldView addSubview:lineImgView1];
    
    
    _fontSlider = [[UISlider alloc]initWithFrame:CGRectMake(30, 100, self.view.frame.size.width-60, 30)];
    
    _fontSlider.value = 1.0/3;
    
    [_fontSlider addTarget:self action:@selector(fontChang:) forControlEvents:UIControlEventValueChanged];
    
    [_worldView addSubview:_fontSlider];
    
    NSArray *fontLabelArray =@[@"小",@"标准",@"大",@"更大"];
    
    for (int i=0; i<4; i++)
    {
        _fontlabe =[[UILabel alloc]initWithFrame:CGRectMake(i*(_fontSlider.frame.size.width-30)/3.0, -20, 30, 18)];
        _fontlabe.text = fontLabelArray[i];
        _fontlabe.textAlignment = NSTextAlignmentCenter;
        _fontlabe.textColor = [UIColor whiteColor];
        _fontlabe.font = [UIFont systemFontOfSize:12];
        
        [_fontSlider addSubview:_fontlabe];
        
    }
    
    
    UIImageView *lineImgView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 1)];
    
    lineImgView2.backgroundColor = [UIColor whiteColor];
    
    [_worldView addSubview:lineImgView2];
    
    //取消
    
    UIButton *CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CancelButton.frame     = CGRectMake(0, _worldView.frame.size.height-39, self.view.frame.size.width, 39);
    
    [CancelButton setTintColor:[UIColor whiteColor]];
    [CancelButton setTitle:@"取消" forState:UIControlStateNormal];
    CancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    
    [CancelButton addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [_worldView addSubview:CancelButton];

    
    [self.view addSubview:_worldView];





}

- (void)setColor
{
    
    UIColor *color = [UIColor colorWithRed:128/255.0 green:216/255.0 blue:255/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:212/255.0 green:65/255.0 blue:0/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:25/255.0 green:150/255.0 blue:221/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:144/255.0 green:1/255.0 blue:12/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:9/255.0 green:133/255.0 blue:49/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:255/255.0 green:35/255.0 blue:72/255.0 alpha:1.0];
    [_colorArray addObject:color];
    
    color = [UIColor colorWithRed:255/255.0 green:73/255.0 blue:0/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:135/255.0 green:81/255.0 blue:239/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:81/255.0 green:125/255.0 blue:0/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:237/255.0 green:0/255.0 blue:168/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:255/255.0 green:116/255.0 blue:167/255.0 alpha:1.0];
    [_colorArray addObject:color];
    color = [UIColor colorWithRed:27/255.0 green:255/255.0 blue:0/255.0 alpha:1.0];
    [_colorArray addObject:color];
    

}

- (void)fontChang:(UISlider *)slider
{
    _font = 12;

    if (slider.value<=1.0/6)
    {
        _fontSlider.value = 0;
        _font = 11;
        
    }else if (slider.value>1.0/6&&slider.value<=1.0/3+1.0/6)
    {
    
        _fontSlider.value = 1.0/3;
        _font = 12;
        
    }else if (slider.value>1.0/3+1.0/6&&slider.value<=2.0/3+1.0/6)
    {
        _fontSlider.value = 2.0/3;
        _font = 13;
        
    }
    else if (slider.value>2.0/3+1.0/6&&slider.value<=1.0)
    {
        _fontSlider.value = 1.0;
        _font = 14;
    }
    
    [self.tabelView1 reloadData];
    
}

- (void)opendCloseBtn:(UIButton *)button;
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        
        self.tabelView1.hidden = YES;
        
        [button setTitle:@"开" forState:UIControlStateNormal];

        
    }else
    {
        self.tabelView1.hidden = NO;
        
        [button setTitle:@"关" forState:UIControlStateNormal];

    
    }

}

- (void)colorBtn:(UIButton *)button
{
    NSInteger tag = button.tag-100;
    switch (tag)
    {
        case 0:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        } case 1:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 2:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 3:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 4:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 5:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 6:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 7:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 8:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 9:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 10:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }
        case 11:
        {
            _colorBtn.backgroundColor = _colorArray[tag];
            break;
        }

            
        default:
            break;
    }
    
    [self.tabelView1 reloadData];

}


- (void)worldBtn: (UIButton *)buttton
{

    [self.view bringSubviewToFront:_worldView];
    
    CGRect rect = _worldView.frame;
    
    rect.origin.y = self.view.frame.size.height-200;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        _worldView.frame = rect;
        
        _backgView.alpha  = 0.5;
        
        _backgView.hidden = NO;
        
        
    }];

}

- (void)cancelBtn
{

    CGRect rect = _worldView.frame;
    
    rect.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        _worldView.frame = rect;
        
        _backgView.alpha  = 0;
        
        _backgView.hidden = YES;
        
        
    }];


}

- (void)closeBtn
{
    CGRect rect = _menuView.frame;
    
    rect.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _menuView.frame = rect;
        
        _backgView.alpha  = 0;
        
        _backgView.hidden = YES;

        
    }];

}

- (void)initHeadPortrait
{


    _singerLabel =[[UILabel alloc]initWithFrame:CGRectMake(50, 5, self.myScrollView.frame.size.width-100, 21)];
    _singerLabel.font          = [UIFont systemFontOfSize:13];
    _singerLabel.textColor     = [UIColor whiteColor];
    _singerLabel.textAlignment = NSTextAlignmentCenter;
    
    [_myScrollView addSubview:_singerLabel];
    
    
    _HeadPortraitView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 70, self.myScrollView.frame.size.width-100, self.myScrollView.frame.size.width-100)];
    
    self.HeadPortraitView.layer.cornerRadius = self.HeadPortraitView.frame.size.height *0.5;
    self.HeadPortraitView.layer.borderColor  = [UIColor darkGrayColor].CGColor;
    self.HeadPortraitView.layer.borderWidth  = 5;
    self.HeadPortraitView.clipsToBounds      = YES;
    self.HeadPortraitView.contentMode        = UIViewContentModeScaleAspectFill;
    
    self.HeadPortraitView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    
    [self.HeadPortraitView addGestureRecognizer:tap];
    
    [_myScrollView addSubview:_HeadPortraitView];
    
}

- (void)click:(UITapGestureRecognizer *)tap
{
    NSLog(@"de");
    if (_isLarge == NO)
    {
        //放大
        _oldFrame = tap.view.frame;
        
        _myScrollView.scrollEnabled = NO;
        
        
        if ([_timer2 isValid])
        {
            [_timer2 invalidate];
            _timer2 = nil;
            [self.HeadPortraitView.layer removeAllAnimations];
        }

        
        [UIView animateWithDuration:0.2 animations:^{
            tap.view.frame = CGRectMake(0, 0, self.myScrollView.frame.size.width, self.myScrollView.frame.size.height);
            
            [self.view bringSubviewToFront:_myScrollView];
            //        [_myScrollView bringSubviewToFront:_HeadPortraitView];
            
            self.HeadPortraitView.layer.cornerRadius = 0;
            self.HeadPortraitView.layer.borderColor  = [UIColor darkGrayColor].CGColor;
            self.HeadPortraitView.layer.borderWidth  = 0;
            self.HeadPortraitView.clipsToBounds      = YES;
            
//                        [self.view bringSubviewToFront:tap.view];
            for (UIView *view in self.myScrollView.subviews)
            {
                if (view != tap.view)
                {
                    view.alpha = 0;
                }
            }
            
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
        //缩小
        
        if (![_timer2 isValid]&&_playButton.selected==YES)
        {
            [self headPortraitTransformRoationAnnimation];
            _timer2 = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(headPortraitTransformRoationAnnimation) userInfo:nil repeats:YES];
        }
        
        
        [UIView animateWithDuration:0.2 animations:^{
            tap.view.frame = _oldFrame;
            
            [self.view insertSubview:_myScrollView atIndex:2];
            
            self.HeadPortraitView.layer.cornerRadius = self.HeadPortraitView.frame.size.height *0.5;
            self.HeadPortraitView.layer.borderColor  = [UIColor darkGrayColor].CGColor;
            self.HeadPortraitView.layer.borderWidth  = 5;
            self.HeadPortraitView.clipsToBounds      = YES;
            

//                        [self.view sendSubviewToBack:tap.view];
            for (UIView *view in self.myScrollView.subviews)
            {
                if (view != tap.view)
                {
                    view.alpha = 1.0;
                }
            }
            
        } completion:^(BOOL finished) {
            
            _myScrollView.scrollEnabled = YES;
            
        }];
    }
    _isLarge = !_isLarge;


}

-(void)headPortraitTransformRoationAnnimation{
    //核心动画使用步骤
    //1.创建一个动画对象
    CABasicAnimation *animation = [CABasicAnimation animation];
    
    //设置动画类型
    animation.keyPath = @"transform.rotation.z";
    
    // 设置动画的时间
    animation.duration = 4.5;

    //byValue的数据类型 由 keyPath 决定
    animation.byValue = @(2*M_PI);
    
    //保存动画执行状态
    //解决方案2：使动画保存执行之后的状态，只要设置动画的两个属性
    animation.removedOnCompletion = NO;//动画对象不要移除
    animation.fillMode = kCAFillModeForwards;//保存当前的状态
    
    
    //2.往控件的图层添加动画
    [self.HeadPortraitView.layer addAnimation:animation forKey:nil];
    
}


- (void)initlrcLabel
{
    _lrcLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.myScrollView.frame.size.height - 21, self.view.frame.size.width, 21)];
    _lrcLabel.textAlignment = NSTextAlignmentCenter;
    _lrcLabel.font          = [UIFont systemFontOfSize:12];
    _lrcLabel.textColor     = [UIColor darkGrayColor];
    
    [self.myScrollView addSubview:_lrcLabel];

}

- (void)initPage
{
    
    _page = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.myScrollView.frame.origin.y + self.myScrollView.frame.size.height, self.view.frame.size.width, 20)];
    
    _page.currentPage   = 0;
    _page.numberOfPages = 2;
    _page.pageIndicatorTintColor        = [UIColor darkGrayColor];
    _page.currentPageIndicatorTintColor = [UIColor whiteColor];
    
    [self.view addSubview:_page];
    

}



- (void)createPlayerWihtFileName:(NSString *)fileName lrcName:(NSString *)lrcName imageName:(NSString *)imageName
{
    
    self.tabelView1.contentOffset = CGPointMake(0, -self.tabelView1.center.y);
    
    //取到MP3文件路径
    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"mp3"];
    
    //通过路径生成文件URL
    NSURL *url = [NSURL fileURLWithPath:path];
    
    //通过文件URL生成播放器对象
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    
    //预播放,读取音乐长度等信息
    [_player prepareToPlay];
    
    //设置音量
    _player.volume = _vioce;
    
    //代理.音乐播放完成,音乐被打断等事件
    _player.delegate = self;
    
    
    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //歌曲名字
    NSRange range = [fileName rangeOfString:@" "];
    
    _SongNameLabel.text = [fileName substringToIndex:range.location];
    
    //歌收名字
    NSRange range1 = [fileName rangeOfString:@"-"];
    
    _singerLabel.text =[NSString stringWithFormat:@"－  %@  －",[fileName substringFromIndex:range1.location+2]];
    
    //循环
//     _player.numberOfLoops = -1;
    
    //没有开始播放时,就是00:00
    _currentTimeLabel.text = @"00:00";
    
    //设置歌曲总时间
    _allTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)_player.duration/60,(int)_player.duration%60];
    
    //起一个定时器,来修改播放进度
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(musicPlay) userInfo:nil repeats:YES];
    
    //设置进度条总长度
    _ProgressSlider.maximumValue = _player.duration;
    
    
    
    NSString *lrcPath = [[NSBundle mainBundle]pathForResource:lrcName ofType:@"lrc"];
    
    _lrcmanerger = [[LSFLrcManerger alloc]initWithPath:lrcPath];
    
    _dataArray  = _lrcmanerger.lrcArray;
    
    
    _imgView.image = [UIImage imageNamed:imageName];
    
    self.HeadPortraitView.image = [UIImage imageNamed:imageName];

    
    _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, self.myScrollView.frame.origin.y+70, self.myScrollView.frame.size.width-100, self.myScrollView.frame.size.width-100)];
    
    _headImageView.layer.cornerRadius = self.HeadPortraitView.frame.size.height *0.5;
    _headImageView.layer.borderColor  = [UIColor darkGrayColor].CGColor;
    _headImageView.layer.borderWidth  = 5;
    _headImageView.clipsToBounds      = YES;
    _headImageView.contentMode        = UIViewContentModeScaleAspectFill;
    _headImageView.image              = _HeadPortraitView.image;
     _headImageView.hidden            = YES;
    
    [self.view addSubview:_headImageView];

    
}

- (void)musicPlay
{
    //_player.currentTime  当前播放时间
    //%02d   数字有两位,如果不足两位,则补0
    _currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)_player.currentTime/60,(int)_player.currentTime%60];
    
    //修改进度
    [_ProgressSlider setValue:_player.currentTime animated:YES];
    
    //歌词解析,滚动显示
    
    for (NSInteger i = 0; i < _lrcmanerger.timeArray.count ;i++)
    {
        
        if (_player.currentTime > [_lrcmanerger.timeArray[i] floatValue] )
        {
            _currentRow = i;
        }
        else
        {
            break;
        }
    }
//    _currentRow = [_lrcmanerger lrcFromTime:_player.currentTime];
    
//    NSLog(@"%d,====%f",_currentRow,_player.currentTime);
    
    [self.tabelView1 reloadData];
    
    [self.tabelView1 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    
}
- (void)chang:(UISlider *)slider
{
    //修改进度
    _player.currentTime = slider.value;
}

- (void)setHeadViewMove
{

    _headImageView.hidden = self.myScrollView.contentOffset.x >  self.myScrollView.frame.size.width/2.0 ? YES : NO;
    CGRect rect           = _headImageView.frame;
    
    rect.origin.y         = -_headImageView.frame.size.height;
    
    _backgView.hidden     = NO;
    _backgView.alpha      = 0.5;
    
    [UIView animateWithDuration:0.7 animations:^{
        
        _headImageView.frame = rect;
        _headImageView.alpha = 0;
        
        
    } completion:^(BOOL finished) {
        
        _headImageView.hidden = YES;
         _backgView.hidden    = YES;
        _backgView.alpha      = 0;
    }];
    
}


- (IBAction)preMusic:(id)sender
{
    
    
    if ([_timer2 isValid])
    {
        [_timer2 invalidate];
        _timer2 = nil;
        [self.HeadPortraitView.layer removeAllAnimations];
    }

    [self setHeadViewMove];
    
    _currentRow = 0;
    //上一曲
    _player = nil;
    
    switch (_loopCount1)
    {
        case 1:
            _count --;
            break;
        case 2:
            _count = arc4random()%_mp3Array.count;
            break;
        case 3:
            //            _count ++;
            break;
            
            
        default:
            break;
    }

    if (_count <0)
    {
        _count = (int)_mp3Array.count-1;
    }
    
    [self createPlayerWihtFileName:_mp3Array[_count] lrcName:_lrcArray[_count] imageName:_imageArray[_count]];
//    [_player play];
    _playButton.selected = NO;
    
     [self play:_playButton];
    
    [_ProgressSlider setValue:0 animated:YES];
    
    [self buttonclick];
    
}

- (IBAction)play:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if (button.selected)
    {
        //播放
        [_player play];
        
        if ([_timer2 isValid])
        {
            return;
        }
        
        [self headPortraitTransformRoationAnnimation];
        _timer2 = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(headPortraitTransformRoationAnnimation) userInfo:nil repeats:YES];

        
    }else
    {
        if ([_timer2 isValid])
        {
            [_timer2 invalidate];
            _timer2 = nil;
            
            [self.HeadPortraitView.layer removeAllAnimations];
        }
        
        //暂停
        [_player pause];
    }
    
  
}


- (IBAction)nextMusic:(id)sender
{
    
    if ([_timer2 isValid])
    {
        [_timer2 invalidate];
        _timer2 = nil;
        
        [self.HeadPortraitView.layer removeAllAnimations];
    }

    
    [self setHeadViewMove];
    
    _currentRow = 0;
    _player = nil;
    
    switch (_loopCount1)
    {
        case 1:
            _count ++;
            break;
        case 2:
            _count = arc4random()%_mp3Array.count;
            break;
        case 3:
//            _count ++;
            break;

            
        default:
            break;
    }
    
    if (_count >_mp3Array.count-1)
    {
        _count = 0;
    }
    
    
    //重新创建音乐播放器
    [self createPlayerWihtFileName:_mp3Array[_count] lrcName:_lrcArray[_count] imageName:_imageArray[_count]];
    //播放
//    [_player play];
    _playButton.selected = NO;
    
    [self play:_playButton];
    
    _currentTimeLabel.text = @"00:00";
    [_ProgressSlider setValue:0 animated:YES];
    
    [self buttonclick];
}

- (IBAction)menuBtn:(id)sender
{
    [self.view bringSubviewToFront:_menuView];
    
    [self.tabelView2 reloadData];
    
    CGRect rect = _menuView.frame;
    
    rect.origin.y = self.view.frame.size.height/4.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _menuView.frame = rect;
        
        _backgView.alpha  = 0.5;
        
        _backgView.hidden = NO;

        
    }];
    
    
}

- (void)buttonclick
{
    
    _preButton.selected  = YES;
    _nextButton.selected = YES;
    
    [self performSelector:@selector(delay) withObject:self afterDelay:0.3];

}

- (void)delay
{

    _preButton.selected  = NO;
    _nextButton.selected = NO;
}


- (IBAction)loopBtn:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    
    _loopCount++;
    switch (_loopCount)
    {
        case 1:
        {
            //顺序
            [button setImage:[UIImage imageNamed:@"img_appwidget91_playmode_repeat_all"] forState:UIControlStateNormal];
            _loopCount1 = 1;
            
            break;
        }
        case 2:
        {
            [button setImage:[UIImage imageNamed:@"img_appwidget91_playmode_shuffle"] forState:UIControlStateNormal];
            //随机播放
            
            _loopCount1 = 2;
            
             break;
        }
           
        case 3:
        {
            [button setImage:[UIImage imageNamed:@"img_appwidget91_playmode_repeat_current"] forState:UIControlStateNormal];
            //单曲循环
           
            _loopCount1 = 3;
            
            _loopCount = 0;
            
            break;
        }
            
        default:
            break;
    }
}


- (void)voiceChang:(UISlider *)slider
{
    //修改音量
    
    _player.volume = slider.value;
    _vioce = slider.value;
    
    if (slider.value == 0.00)
    {
         _voiceView.image = [UIImage imageNamed:@"img_background_button_splash_audio_disabled_normal"];
        
    }else
    {
         _voiceView.image = [UIImage imageNamed:@"img_background_button_splash_audio_enabled_normal"];
    }
}



#pragma mark-UIScrollViewDelegate
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > self.myScrollView.frame.size.width/2.0)
    {
        _page.currentPage     = 1;
        
    }else
    {
        _page.currentPage     = 0;
        
    }
    
}


#pragma mark-UITableViewDataSource&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tabelView1)
    {
        return _dataArray.count;
        
    }else if (tableView == _tabelView2)
    {
        return _mp3Array.count;
    }
    
    return 0;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reusedID =@"reusedID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedID];
    }

    
    if (tableView == _tabelView1)
    {
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSeparatorStyleNone;
        
        NSString *lrc = _dataArray[indexPath.row];
        
        cell.textLabel.text          = lrc;
        cell.textLabel.font          = [UIFont systemFontOfSize:_font];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor     = [UIColor whiteColor];
        
        if (indexPath.row == _currentRow)
        {
            cell.textLabel.textColor     = _colorBtn.backgroundColor;
        }
        
        
    }else if (tableView == _tabelView2)
    {
        
        cell.backgroundColor = [UIColor clearColor];
        
        NSString *mp3 = _mp3Array[indexPath.row];
        
        cell.textLabel.text          = mp3;
        cell.textLabel.font          = [UIFont systemFontOfSize:17];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor     = [UIColor blackColor];
        
        if (indexPath.row == _count)
        {
            cell.textLabel.textColor     = [UIColor purpleColor];
        }

    }
    

    return cell;
    
}

//点击某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tabelView2)
    {
        _count = (int)indexPath.row;
        
        //重新创建音乐播放器
        [self createPlayerWihtFileName:_mp3Array[_count] lrcName:_lrcArray[_count] imageName:_imageArray[_count]];
        //播放
        [_player play];
        _playButton.selected = YES;
        
        _currentTimeLabel.text = @"00:00";
        [_ProgressSlider setValue:0 animated:YES];
        
        [self.tabelView2 reloadData];
        

    }
    
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark -AVAudioPlayerDelegate

//歌曲播放完毕
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //播放下一曲
    [self nextMusic:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
