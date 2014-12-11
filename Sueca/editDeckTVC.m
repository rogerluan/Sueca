//
//  editDeckTVC.m
//  Sueca
//
//  Created by Roger Luan on 10/16/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import "editDeckTVC.h"

#define NUMBER_OF_CARDS 13

@interface editDeckTVC () <NSFetchedResultsControllerDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (strong,nonatomic) NSManagedObjectContext *moc;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation editDeckTVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
	[tempImageView setFrame:self.tableView.frame];
	self.tableView.backgroundView = tempImageView;
	
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
		
		NSArray *cardImages = [[NSArray alloc] initWithObjects: @"01-C",@"02-C",@"03-C",@"04-C",@"05-C",@"06-C",@"07-C",@"08-C",@"09-C",@"10-C",@"11-C",@"12-C",@"13-C", nil];
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
		self.thisDeck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:moc];

		NSInteger deckNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"DeckNumber"];
		self.thisDeck.deckName = [NSString stringWithFormat:NSLocalizedString(@"Custom Deck %d", nil),deckNumber];
		deckNumber++;
		[[NSUserDefaults standardUserDefaults] setInteger:deckNumber forKey:@"DeckNumber"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		for (int i = 0 ; i<NUMBER_OF_CARDS ; i++) {
			Card *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:moc];
			newCard.cardName = [cardImages objectAtIndex:i];
			newCard.cardRule = [cardRules objectAtIndex:i];
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
//	
//	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButton)];

	if([self.thisDeck.isEditable isEqualToNumber:@1]) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self saveButton];
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
		
		if ([reusableCard.cardDescription isEqualToString:@""] || reusableCard.cardDescription==nil) {
			cell.cardDescriptionTextView.textColor = [UIColor lightGrayColor];
			cell.cardDescriptionTextView.text = NSLocalizedString(@"Tap to add a description", nil);
		}
		else {
			cell.cardDescriptionTextView.text = reusableCard.cardDescription;
		}
		
		cell.cardDescriptionTextView.delegate = self;
		cell.cardRuleTextField.delegate = self;
		
		cell.cardRuleTextField.tag = indexPath.row;
		cell.cardDescriptionTextView.tag = indexPath.row;
	}
	
	if ([self.thisDeck.isEditable isEqualToNumber:@0]) {
		cell.cardRuleTextField.userInteractionEnabled = NO;
		[cell.cardDescriptionTextView setEditable:NO];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_fetchedResultsController.fetchedObjects count] < 1) {
		return NO;
	}
	else if([self.thisDeck.isEditable isEqualToNumber:@0]) { //is editting Default deck
		return NO;
	}
	else {
		return YES;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Card *cardToBeDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.moc deleteObject:cardToBeDeleted];
    }
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

- (void) textViewDidBeginEditing:(UITextView *)textView	{
	[textView setText: @""];
	[textView setTextColor:[UIColor whiteColor]];
}

- (void) textViewDidEndEditing:(UITextView *)textView {
	if([textView.text isEqualToString:@""] || textView.text == nil) {
		textView.textColor = [UIColor lightGrayColor];
		textView.text = NSLocalizedString(@"Tap to add a description", nil);
	}
	else {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:textView.tag inSection:0];
		CustomCardCell *editedCell = (CustomCardCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		Card *editedCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
		editedCard.cardDescription = editedCell.cardDescriptionTextView.text;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if([textField.text isEqualToString:@""] || textField.text == nil) {
		textField.textColor = [UIColor lightGrayColor];
		textField.text = NSLocalizedString(@"Tap to add a rule", nil);
	}
	else {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:textField.tag inSection:0];
		CustomCardCell *editedCell = (CustomCardCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		Card *editedCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
		editedCard.cardRule = editedCell.cardRuleTextField.text;
	}
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
