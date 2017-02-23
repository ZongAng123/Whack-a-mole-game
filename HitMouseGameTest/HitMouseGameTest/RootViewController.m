//
//  RootViewController.m
//  HitMouseGameTest
//
//  Created by Earl on 16/4/12.
//  Copyright (c) 2016年 Earl. All rights reserved.
//

#import "RootViewController.h"
#import "GameViewController.h"
@interface RootViewController ()<UIAlertViewDelegate>
//声明一个游戏级别字符串
@property (nonatomic, strong)NSString *gameClassTitle;
//级别button
@property (weak, nonatomic) IBOutlet UIButton *gameClassButton;
@property (nonatomic, assign)float time;


@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//选择难度按钮方法实现
- (IBAction)chooseButtonAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请您选择难度级别" delegate:self cancelButtonTitle:nil otherButtonTitles:@"初级",@"中级",@"高级", nil];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
           self.gameClassTitle = @"初级";
            self.time = 2.5;
        }
            
            break;
        case 1:{
            self.gameClassTitle = @"中级";
            self.time = 2;
        }
            
            break;
        case 2:{
            self.gameClassTitle = @"高级";
            self.time = 1.5;
        }
            break;
            
        default:
            break;
    }
    //重新修改标题
    [self.gameClassButton setTitle:self.gameClassTitle forState:UIControlStateNormal];
}
//开始游戏按钮方法实现
- (IBAction)startGame:(id)sender {
    GameViewController *gameVC = [[GameViewController alloc] init];
    //防止未点击
    if (self.time == 0) {
        self.time = 2.5;
    }
    gameVC.showTime = self.time;
    self.view.window.rootViewController = gameVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
