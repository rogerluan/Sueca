//
//  SobreViewController.m
//  Sueca
//
//  Created by Bruno Pedroso on 28/10/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import "SobreViewController.h"

@interface SobreViewController ()

@end

@implementation SobreViewController

- (void) viewDidAppear:(BOOL)animated {
    [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	/* Inserção de background */
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"GameCenter.png"]]];
	[self preferredContentSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
