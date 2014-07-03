//
//  MainViewController.m
//  Sueca
//
//  Created by Roger Luan on 10/23/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.botaoJogar.layer.cornerRadius = 20;
    self.botaoJogar.clipsToBounds = YES;
    self.botaoJogar.layer.borderColor=[UIColor whiteColor].CGColor;
    self.botaoJogar.layer.borderWidth=2.0f;
    
    self.botaoRegras.layer.cornerRadius = 20;
    self.botaoRegras.clipsToBounds = YES;
    self.botaoRegras.layer.borderColor=[UIColor whiteColor].CGColor;
    self.botaoRegras.layer.borderWidth=2.0f;
    
    self.botaoSobre.layer.cornerRadius = 20;
    self.botaoSobre.clipsToBounds = YES;
    self.botaoSobre.layer.borderColor=[UIColor whiteColor].CGColor;
    self.botaoSobre.layer.borderWidth=2.0f;
	
	self.barraSuperior.layer.borderColor=[UIColor blackColor].CGColor;
    self.barraSuperior.layer.borderWidth=1;
	self.barraInferior.layer.borderColor=[UIColor blackColor].CGColor;
    self.barraInferior.layer.borderWidth=1;
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"GameCenter.png"]]];
	[self preferredContentSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
