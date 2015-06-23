//
//  DecksTableViewController.m
//  Sueca
//
//  Created by Roger Oba on 10/15/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import "DecksTableViewController.h"
#import "TSMessage.h"

@interface DecksTableViewController () <NSFetchedResultsControllerDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) NSManagedObjectContext *moc;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong,nonatomic) NSIndexPath *indexPathForSelectedDeck;
@property (strong,nonatomic) Deck *deckToShowDetails;
@property (strong,nonatomic) Deck *deckToEditLabel;

@property (strong,nonatomic) NSString *creatingDeckName; //can't use "newDeckName"

@end

@implementation DecksTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
	[tempImageView setFrame:self.tableView.frame];
	self.tableView.backgroundView = tempImageView;
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);
	}

	self.navigationItem.leftBarButtonItem = self.editButtonItem;
		
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"showNewFeatureNotification"]) {
		[TSMessage showNotificationInViewController:self
											  title:NSLocalizedString(@"Customizable!", @"TSMessage Customizable Notification Title")
										   subtitle:NSLocalizedString(@"You can now edit the name of your decks by tapping Edit and selecting the deck. Enjoy! 🍻", @"TSMessage Customizable Notification Subtitle")
											  image:[UIImage imageNamed:@"notification-arrow"]
											   type:TSMessageNotificationTypeDarkMessage
										   duration:TSMessageNotificationDurationEndless
										   callback:nil
										buttonTitle:nil
									 buttonCallback:^{
//										 NSLog(@"User tapped the button");
									 }
										 atPosition:TSMessageNotificationPositionTop
							   canBeDismissedByUser:YES];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showNewFeatureNotification"];
		[[NSUserDefaults standardUserDefaults] synchronize];
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
	return [_fetchedResultsController.fetchedObjects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *deckCellIdentifier = @"deckCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deckCellIdentifier forIndexPath:indexPath];
    
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deckCellIdentifier];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


/**
 *  @author Roger Oba
 *
 *  Method used to configure UITableViewCells
 *
 *  @param cell      the cell that is being configured
 *  @param indexPath the indexPath of the given cell
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Deck *reusableDeck  = nil;
	if ([[self.fetchedResultsController sections] count] >= [indexPath section]){
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
		if ([sectionInfo numberOfObjects] >= [indexPath row]){
			reusableDeck = [self.fetchedResultsController objectAtIndexPath:indexPath];
		}
	}
	if (reusableDeck) {
		if ([reusableDeck.isEditable isEqualToNumber:[NSNumber numberWithBool:NO]]) {
			cell.textLabel.text = NSLocalizedString(reusableDeck.deckName, nil);
		}
		else {
			cell.textLabel.text = reusableDeck.deckName;
		}
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryDetailButton;
		
		if ([reusableDeck.isBeingUsed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
			self.indexPathForSelectedDeck = indexPath;
			cell.imageView.image = [UIImage imageNamed:@"check"];
		}
		else {
			cell.imageView.image = [UIImage imageNamed:@"empty"];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	Deck *deckBeingEdited = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if ([deckBeingEdited.isEditable isEqualToNumber:@1] && [deckBeingEdited.isBeingUsed isEqualToNumber:@0]) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Deck *deckToBeDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.moc deleteObject:deckToBeDeleted];
		
		self.indexPathForSelectedDeck = [self.fetchedResultsController indexPathForObject:[self playingDeck]];
		
		NSError *error = nil;
		if(![self.moc save: &error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//abort();
		}
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle: nil];
	EditDeckTableViewController *editDeckTVC = [storyboard instantiateViewControllerWithIdentifier:@"editDeckTVC"];
	editDeckTVC.thisDeck = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.navigationController pushViewController:editDeckTVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView.isEditing == NO) {
		NSIndexPath *oldSelectedCellIndex = self.indexPathForSelectedDeck;
		self.indexPathForSelectedDeck = indexPath;
		
		if (oldSelectedCellIndex != self.indexPathForSelectedDeck) {
			Deck *selectedDeck = [self.fetchedResultsController objectAtIndexPath:self.indexPathForSelectedDeck];
			selectedDeck.isBeingUsed = [NSNumber numberWithBool:YES];
			Deck *deselectedDeck = [self.fetchedResultsController objectAtIndexPath:oldSelectedCellIndex];
			deselectedDeck.isBeingUsed = [NSNumber numberWithBool:NO];
			
			NSError *coreDataError = nil;
			if(![self.moc save: &coreDataError]) {
				NSLog(@"Unresolved error %@, %@", coreDataError, [coreDataError userInfo]);
				//abort();
			}
			
			[tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldSelectedCellIndex.row inSection:oldSelectedCellIndex.section],[NSIndexPath indexPathForRow:self.indexPathForSelectedDeck.row inSection:self.indexPathForSelectedDeck.section]] withRowAnimation:UITableViewRowAnimationNone];
		}
	}
	else {
		self.deckToEditLabel = [self.fetchedResultsController objectAtIndexPath:indexPath];
		if ([self.deckToEditLabel.isEditable isEqualToNumber:@YES]) {
			UIAlertView *newDeckAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Change Deck Label", @"editDeckLabelAlert Title")
																   message:NSLocalizedString(@"Type the new label for your deck.", @"editDeckLabelAlert Message")
																  delegate:self
														 cancelButtonTitle:NSLocalizedString(@"Cancel", @"editDeckLabelAlert Cancel Button")
														 otherButtonTitles:NSLocalizedString(@"Ok", @"editDeckLabelAlert OK Button"), nil];
			
			newDeckAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
			[newDeckAlert textFieldAtIndex:0].placeholder = self.deckToEditLabel.deckName;
			newDeckAlert.tag = 1;
			
			[newDeckAlert show];
		}
	}
}

#pragma mark - NSFetchedResultsController Delegate Methods

- (NSFetchedResultsController*) fetchedResultsController {
	
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	self.moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:self.moc];
	[fetchRequest setEntity:entity];
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"isEditable" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"deckName" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
	
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
			[self configureCell:(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

/**
 *  @author Roger Oba
 *
 *  Method that returns the deck that is currently being used in the game.
 *
 *  @return Deck that is currently being used in the game.
 */
- (Deck*) playingDeck {
	self.moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:self.moc];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isBeingUsed == %@", [NSNumber numberWithBool:YES]];
	[fetchRequest setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isBeingUsed"
																   ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	else {
		return [fetchedObjects firstObject];
	}
}

#pragma mark - UIAlertView Delegate Methods

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex	{
	
	NSString *alertViewText = [[[[alertView textFieldAtIndex:0] text] capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if (buttonIndex == 0) {
		return;
	}
	else {
		if (alertView.tag == 0) { //new deck
			if (alertViewText && alertViewText.length>0) { //with custom deck name
				self.creatingDeckName = alertViewText;
			}
			else {//deck name left blank
				NSInteger deckNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"DeckNumber"];
				
				deckNumber++;
				[[NSUserDefaults standardUserDefaults] setInteger:deckNumber forKey:@"DeckNumber"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				self.creatingDeckName = [NSString stringWithFormat:NSLocalizedString(@"Custom Deck %ld", nil),(long)deckNumber];
			}
			[[alertView textFieldAtIndex:0]resignFirstResponder];
			[alertView dismissWithClickedButtonIndex:1 animated:YES];
			[self performSegueWithIdentifier:@"newDeck" sender:nil];
		}
		else { //editing existing deck
			NSLog(@"alertViewtext: %@",alertViewText);
			if (!alertViewText || !alertViewText.length>0) {
				return;
			}
			else {
				if (self.deckToEditLabel) {
					self.deckToEditLabel.deckName = alertViewText;
					NSError *error = nil;
					if(![self.moc save: &error]) {
						NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
						//abort();
					}
				}
			}
		}
	}
}

#pragma mark - Navigation

- (IBAction)newDeck:(id)sender {
    UIAlertView *newDeckAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Deck", @"newDeckAlert Title")
														   message:NSLocalizedString(@"Please name your custom deck.", @"newDeckAlert Message")
														  delegate:self
												 cancelButtonTitle:NSLocalizedString(@"Cancel", @"newDeckAlert Cancel Button")
												 otherButtonTitles:NSLocalizedString(@"Create", @"newDeckAlert Create Button"), nil];
    
    newDeckAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[newDeckAlert textFieldAtIndex:0].placeholder = NSLocalizedString(@"Custom Deck", @"New Deck Default Label");
	newDeckAlert.tag = 0;
    
	[newDeckAlert show];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([[segue identifier] isEqualToString:@"newDeck"]) {
		EditDeckTableViewController *tempTVC = [segue destinationViewController];
		tempTVC.thisDeck = nil;
		tempTVC.deckLabel = self.creatingDeckName;
	}
}


@end
