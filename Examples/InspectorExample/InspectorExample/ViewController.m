//
//  ViewController.m
//  InspectorExample
//
//  Created by Du, Xiaochen (Harry) on 3/25/14.
//  Copyright (c) 2014 Xiaochen Du. All rights reserved.
//

#import "ViewController.h"
#import "UIView+SPY.h"
#import "NSObject+SPY.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%@",[[self.view rootWindow] printTree]);
    
    
}

@end
