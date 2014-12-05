//
//  editDeckTVC.m
//  Sueca
//
//  Created by Roger Luan on 10/16/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import "editDeckTVC.h"

#define NUMBER_OF_CARDS 13

@interface editDeckTVC () <NSFetchedResultsControllerDelegate,UITextFieldDelegate>

@property (strong,nonatomic) NSManagedObjectContext *moc;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation editDeckTVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.thisDeck) { //editting deck
		NSError *error;
		if (![[self fetchedResultsController] performFetch:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);
		}
		
		self.title = self.thisDeck.deckName;
	}
	else {
		self.title = NSLocalizedString(@"New Deck", @"Navigation bar title");
		NSArray *cardRules = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Escolhe 1 pessoa para beber", nil),
							  NSLocalizedString(@"Escolhe 2 pessoas para beber", nil),
							  NSLocalizedString(@"Escolhe 3 pessoas para beber", nil),
							  NSLocalizedString(@"Jogo do “Stop”", nil),
							  NSLocalizedString(@"Jogo da Memória", nil),
							  NSLocalizedString(@"Continência", nil),
							  NSLocalizedString(@"Jogo do “Pi”", nil),
							  NSLocalizedString(@"Regra Geral", nil),
							  NSLocalizedString(@"Coringa", nil),
							  NSLocalizedString(@"Vale-banheiro", nil),
							  NSLocalizedString(@"Todos bebem 1 dose", nil),
							  NSLocalizedString(@"Todas as damas bebem", nil),
							  NSLocalizedString(@"Todos os cavalheiros bebem", nil), nil];
		
		NSArray *cardImages = [[NSArray alloc] initWithObjects: @"AC",@"2C",@"3C",@"4C",@"5C",@"6C",@"7C",@"8C",@"9C",@"10C",@"JC",@"QC",@"KC", nil];
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
		self.thisDeck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:moc];
		self.thisDeck.deckName = NSLocalizedString(@"New Deck", nil);
		
		for (int i = 0 ; i<NUMBER_OF_CARDS ; i++) {
			Card *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:moc];
			newCard.cardName = [cardImages objectAtIndex:i];
			newCard.cardRule = [cardRules objectAtIndex:i];
			//TODO: newCard.cardDescription = [cardDescriptions objectAtIndex:i];
			
			[self.thisDeck addCardsObject:newCard];
		}
		
		NSError *error;
		if (![[self fetchedResultsController] performFetch:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);
		}
	}
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButton)];

	if([self.thisDeck.isEditable isEqualToNumber:@1]) {
		self.navigationItem.rightBarButtonItems = @[saveButton,self.editButtonItem];
	}

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.thisDeck) {
		return NUMBER_OF_CARDS;
	}
	else {
		return [_fetchedResultsController.fetchedObjects count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cardCellIdentifier = @"cardCell";
	
    CustomCardCell *cell = [tableView dequeueReusableCellWithIdentifier:cardCellIdentifier forIndexPath:indexPath];
    
	if (!cell) {
		cell = [[CustomCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cardCellIdentifier];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(CustomCardCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Card *reusableCard  = nil;
	//Validate fetchedResultsController
	if ([[self.fetchedResultsController sections] count] >= [indexPath section]){
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
		if ([sectionInfo numberOfObjects] >= [indexPath row]){
			reusableCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
		}
	}
	if (reusableCard) {
		cell.cardImageView.image = [UIImage imageNamed:reusableCard.cardName];
		cell.cardRuleTextField.text = reusableCard.cardRule;
		cell.cardDescriptionTextField.text = reusableCard.cardDescription;
		cell.cardRuleTextField.tag = [[NSString stringWithFormat:@"17079%ld",(long)indexPath.row] integerValue];
		cell.cardDescriptionTextField.tag = [[NSString stringWithFormat:@"27079%ld",(long)indexPath.row] integerValue];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_fetchedResultsController.fetchedObjects count] < 1) {
		return NO;
	}
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Card *cardToBeDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.moc deleteObject:cardToBeDeleted];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

#pragma mark - NSFetchedResultsController Delegate Methods

- (NSFetchedResultsController*) fetchedResultsController {
	
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	self.moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.moc];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deck == %@",self.thisDeck];
	[fetchRequest setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cardName" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
	
	
	[fetchRequest setFetchBatchSize:20];
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		managedObjectContext:self.moc
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
	_fetchedResultsController.delegate = self;
	
	return _fetchedResultsController;
	
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(CustomCardCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeMove:
			break;
		case NSFetchedResultsChangeUpdate:
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}

#pragma mark - Core Data Method

- (NSManagedObjectContext *) managedObjectContext {
	NSManagedObjectContext *context = nil;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		context = [delegate managedObjectContext];
	}
	return context;
}

- (void) saveButton {
	NSError *error = nil;
	if(![self.moc save: &error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
		//TODO: remove all abort(); before production
	}
	else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark - Keyboard Methods

/**
 *  Dismisses the keyboard when the Return button is pressed.
 */
- (BOOL) textFieldShouldReturn:(UITextField *)selectedTextField {
	//TODO: make it jump to the next item
	[selectedTextField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[[[[NSString stringWithFormat:@"%ld",textField.tag] componentsSeparatedByString:@"7079"] objectAtIndex: 1] integerValue] inSection:0];
	CustomCardCell *editedCell = (CustomCardCell*)[self.tableView cellForRowAtIndexPath:indexPath];
	Card *editedCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
	editedCard.cardRule = editedCell.cardRuleTextField.text;
	editedCard.cardDescription = editedCell.cardDescriptionTextField.text;
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
