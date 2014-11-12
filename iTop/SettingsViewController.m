//
//  SettingsViewController.m
//  CPU Watchdog
//
//  Created by Bradley Slayter on 11/12/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self.view setBackgroundColor:[UIColor colorWithRed:39.0/255.0 green:40.0/255.0 blue:33.0/255.0 alpha:1.0]];
	[self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:89.0/255.0 green:92.0/255.0 blue:98.0/255.0 alpha:1.0]];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	
	self.navigationItem.title = @"Settings";
	
	CGSize scrSize = [[UIScreen mainScreen] bounds].size;
	meter = [[Meter alloc] initWithFrame:CGRectMake(scrSize.width/2-320/2, 100, 320, 85)];
	meter.textAlignment = NSTextAlignmentCenter;
	
	float fontSize = 20.0;
	
	if (IS_IPHONE_5 || IS_IPHONE_4) {
		fontSize = 14.0;
	}
	
	meter.font = [UIFont fontWithName:@"Courier-Bold" size:fontSize];
	
	meter.value = 1.0;
	[meter updateBar];
	
	[self.view addSubview:meter];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	doneBtn.tintColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = doneBtn;
}

-(void) done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
