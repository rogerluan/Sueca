//
//  RegrasViewController.m
//  Sueca
//
//  Created by Roger Luan on 11/1/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import "RegrasViewController.h"

@interface RegrasViewController ()

@end

@implementation RegrasViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	
    self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	/* Inicialização das regra na table view */
	self.rules = [[NSArray alloc] initWithObjects: @"Escolhe 1 pessoa para beber",@"Escolhe 2 pessoas para beber",@"Escolhe 3 pessoas para beber",@"Jogo do “Stop”",@"Jogo da Memória",@"Continência",@"Jogo do “Pi”",@"Regra Geral",@"Coringa",@"Vale-banheiro",@"Todos bebem 1 dose",@"Todas as damas bebem",@"Todos os cavalheiros bebem", nil];
	self.imagemcards = [[NSArray alloc] initWithObjects: @"Um",@"Dois",@"Tres",@"Quatro",@"Cinco",@"Seis",@"Sete",@"Oito",@"Nove",@"Dez",@"Valete",@"Dama",@"Rei", nil];

	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];

	[self preferredContentSize];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rules count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
		cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
    }
//	cell.textLabel.font = [UIFont fontWithName:@"Bradley Hand" size:20.0f];
    cell.textLabel.text = [self.rules objectAtIndex:indexPath.row];
	cell.imageView.image = [UIImage imageNamed: [NSString stringWithFormat: @"%@",[self.imagemcards objectAtIndex: indexPath.row ]]];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if([self.tableView indexPathForSelectedRow].row == indexPath.row){
		return 100;
	}
	return 44;
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