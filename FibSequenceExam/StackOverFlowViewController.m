//
//  StackOverFlowViewController.m
//  FibSequenceExam
//
//  Created by Louis Tur on 1/19/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "StackOverFlowViewController.h"
#import "ViewController.h"

@interface StackOverFlowViewController ()

@property (strong, nonatomic) UITabBarItem * tabBar;

@end

@implementation StackOverFlowViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    UIButton * showAnotherViewController = [UIButton buttonWithType:UIButtonTypeSystem];
    [showAnotherViewController setFrame:CGRectMake(20, 100, 100, 50)];
    [showAnotherViewController setTitle:@"Show" forState:UIControlStateNormal];
    [showAnotherViewController addTarget:self action:@selector(showATableView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:showAnotherViewController];
    
    self.tabBar = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1];
    
    self.tabBarItem = self.tabBar;
}

-(void) showATableView:(id)sender{
    ViewController * viewController = [[ViewController alloc] init];

    [self.navigationController pushViewController:viewController animated:YES];

 
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}
@end
