//
//  GameViewController.m
//  HitMouseGameTest
//
//  Created by Earl on 16/4/12.
//  Copyright (c) 2016年 Earl. All rights reserved.
//

#import "GameViewController.h"
#import "RootViewController.h"
//导入视图媒体框架
#import <AVFoundation/AVFoundation.h>
@interface GameViewController ()<UIAlertViewDelegate>
{
    int _score;//分数
    BOOL _isOrPause;//YES:暂停，NO：没有暂停
    BOOL _isOrPauseMusic;//YES:暂停，NO：没有暂停
    int _showNumber;//显示的是第几个，下标从0开始
    BOOL _isOrPauseBlastMusic;//YES:暂停，NO：没有暂停
}
//地鼠出现视图
@property (nonatomic, strong)UIImageView *mouseShowView;
//地鼠出现的定时器
@property (nonatomic, strong)NSTimer *timer;
//装按钮的数组
@property (nonatomic, strong)NSMutableArray *buttonArray;
//声明一个媒体音频播放器
@property (nonatomic, strong)AVAudioPlayer *player;
//声明一个锤子视图
@property (nonatomic, strong)UIImageView *hammerView;
//记录上一个被选中的button
@property (nonatomic, strong)UIButton *lastSelectButton;
//声明一个爆炸音频播放器
@property (nonatomic, strong)AVAudioPlayer *blastPlayer;
//地鼠消失的视图
@property (nonatomic, strong)UIImageView *mouseDeadView;
//爆炸视图
@property (nonatomic, strong)UIImageView *blastView;
//分数lable
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation GameViewController
//地鼠显示的视图懒加载
- (UIImageView *)mouseShowView {
    if (!_mouseShowView) {
        self.mouseShowView = [[UIImageView alloc] init];
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            UIImage *image = [UIImage imageNamed: [NSString stringWithFormat:@"ds%d",i]];
            [imageArray addObject:image];
        }
        _mouseShowView.userInteractionEnabled = YES;
        _mouseShowView.animationImages = imageArray;
        _mouseShowView.animationDuration = 0.8;
        _mouseShowView.animationRepeatCount = 1;
    }
    return _mouseShowView;
}
//装button的数组懒加载
- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        self.buttonArray = [NSMutableArray array];
        for (int i = 0; i < 9; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(25 + i % 3 * (50 + 60) , 195 + i / 3 *(60 + 15)  , 60, 60);
            button.tag = i;
            button.backgroundColor = [UIColor redColor];
            button.alpha = 0.3;
            [button addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            [_buttonArray addObject:button];
        }
    }
    return _buttonArray;
}

//音频的播放器懒加载
- (AVAudioPlayer *)player {
    if (!_player) {
        //这个类的对象，代表了 app 中代码和资源的文件在文件系统里所在的位置，通俗的说，就是定位了程序使用的资源（代码，图形，音乐等数据）在文件系统里的位置，并可以动态的加载、or卸载掉可执行代码。
        //[NSBundle mainBundle]其获取的路径是你程序的安装路径下的资源文件位置。
        // + mainBundle返回一个 NSBundle类的对象，这个对象就是一个完全path，这个 path 保存的当前可执行的app路径，或者是 返回nil。app ，Build之后， 资源文件直接就复制到了根目录下，于是读取的方法，应该是这样：
        NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"森林" ofType:@"mp3"];
//        NSLog(@"%@",[NSBundle mainBundle]);
        NSURL *sourceURL = [NSURL fileURLWithPath:pathStr];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:sourceURL error:nil];
        //设置循环次数，0为不循环，负数为无限循环，大于0，则为循环次数
        _player.numberOfLoops = 100;
        
    }
    return _player;
}
//锤子的懒加载
- (UIImageView *)hammerView {
    if (!_hammerView) {
        self.hammerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        _hammerView.image = [UIImage imageNamed:@"chuizi"];
        _hammerView.hidden = YES;
    }
    return _hammerView;
}
//爆炸播放器
- (AVAudioPlayer *)blastPlayer {
        NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"爆炸" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:pathStr];
        self.blastPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _blastPlayer.numberOfLoops = 1;
    return _blastPlayer;
}
//老鼠死的时候视图懒加载
- (UIImageView *)mouseDeadView {
    if (!_mouseDeadView) {
        self.mouseDeadView = [[UIImageView alloc] init];
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"ys%d",i]];
            [imageArray addObject:image];
        }
        _mouseDeadView.animationImages = imageArray;
        _mouseDeadView.animationDuration = 0.3;
        _mouseDeadView.animationRepeatCount = 1;
    }
    return _mouseDeadView;
}
- (UIImageView *)blastView {
    if (!_blastView) {
        self.blastView = [[UIImageView alloc] init];
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i = 0; i < 7; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"b%d",i]];
            [imageArray addObject:image];
        }
        _blastView.animationImages = imageArray;
        _blastView.animationDuration = 0.7;
        _blastView.animationRepeatCount = 1;
    }
    return _blastView;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//退出按钮的方法实现
- (IBAction)exitButtonAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您一共得分为%d分确定要退出么？",_score] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}
//暂停或开始的按钮的方法
- (IBAction)pauseButtonAction:(UIButton *)sender {
    //每次点击之后，状态都修改
    _isOrPause = !_isOrPause;
    if (_isOrPause) {
        [sender setTitle:@"继续" forState:UIControlStateNormal];
    }else {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
//暂停或继续背景音乐的按钮方法实现
- (IBAction)pauseMusicButtonAction:(id)sender {
    _isOrPauseMusic = !_isOrPauseMusic;
    if (_isOrPauseMusic) {
        [sender setTitle:@"播放音乐" forState:UIControlStateNormal];
        [self.player stop];//让音乐停止
    }else {
        [sender setTitle:@"暂停音乐" forState:UIControlStateNormal];
        [self.player play];//让音乐播放
    }
}
//爆炸声音的按钮点击方法实现
- (IBAction)blastMusicButtonAction:(UIButton *)sender {
    //
    _isOrPauseBlastMusic = !_isOrPauseBlastMusic;
    if (_isOrPauseBlastMusic) {
        [sender setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }else  {
        [sender setBackgroundImage:[UIImage imageNamed:@"music"] forState:UIControlStateNormal];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }else {
        RootViewController *rootVC = [[RootViewController alloc] init];
        self.view.window.rootViewController = rootVC;
        //音乐停止
        [self.player stop];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //添加地鼠显示的视图
    [self.view addSubview:self.mouseShowView];
    //创建定时器，让地鼠出现
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.showTime target:self selector:@selector(mouseShowAction) userInfo:nil repeats:YES];
    //让音乐播放
    [self.player play];
    //添加锤子
    [self.view addSubview:self.hammerView];
    //添加地鼠打死的视图
    [self.view addSubview:self.mouseDeadView];
    //添加爆炸的视图
    [self.view addSubview:self.blastView];
}
//地鼠出现的方法实现
- (void)mouseShowAction {
    //如果没有暂停,就让其随机显示
    if (_isOrPause == NO) {
        //设置上一个被选中的button的状态为可用
        self.lastSelectButton.enabled = YES;
        _showNumber = arc4random() % 9;
        UIButton *showButton = self.buttonArray[_showNumber];
        self.mouseShowView.frame = showButton.frame;
        [self.mouseShowView startAnimating];
    }
}
//点击按钮button按钮出现的方法
- (void)handleButtonAction:(UIButton *)button {
    //如果没有暂停才去执行
    if (_isOrPause == NO) {
        //点击完后，让它的状态不可以被点击(防止重复点击)，定时器再次执行方法的时候，要修改回来
        button.enabled = NO;
        //每次点击之后都要记录被点击的button
        self.lastSelectButton = button;
        //如果出现的视图和点中的button在同一个位置
        if (_showNumber == button.tag) {
            //每次点击之后让其恢复原始位置
            self.hammerView.transform = CGAffineTransformIdentity;
            //设置锤子显示
            self.hammerView.hidden = NO;
            self.hammerView.frame = CGRectMake(button.frame.origin.x + 10, button.frame.origin.y - 30, 60, 50);
            //设置锤子的锚点(值的默认点为0.5,0.5)
            self.hammerView.layer.anchorPoint = CGPointMake(0.9, 0.7);
            [UIView animateWithDuration:0.5 animations:^{
                //设置锤子旋转
                self.hammerView.transform = CGAffineTransformMakeRotation(-60 * M_PI / 180);
            }];
            //爆炸帧动画
            self.blastView.frame = button.frame;
            [self.blastView startAnimating];
            //地鼠被打死帧动画
            self.mouseDeadView.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y + 10, 50, 50);
            [self.mouseDeadView startAnimating];
            if (_isOrPauseBlastMusic == NO) {
                //让音乐响
                [self.blastPlayer play];
            }
            //0.8S后锤子消失,音乐暂停
            [self performSelector:@selector(hammerViewHidden) withObject:nil afterDelay:0.8];
            //分数+10；
            _score += 10;
            self.scoreLabel.text = [NSString stringWithFormat:@"分数：%d",_score];
        }
    }
}
//锤子消失
- (void)hammerViewHidden {
    self.hammerView.hidden = YES;
    //并让播放器停止，但是一旦停止，要想重新播放，那么需要重新创建
    [self.blastPlayer stop];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
