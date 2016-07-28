//  Created by Naval on 16/7/28.
//  Copyright © 2016年 Naval. All rights reserved.
//  GitHub address: https://github.com/ouyangbin/Bird

#import "ViewController.h"

#import "BirdUserMessageManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BirdUserMessageManager sharedManager] userLogin:@"15889731562" :@"5244"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
