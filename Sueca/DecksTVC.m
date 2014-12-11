//
//  DecksTVC.m
//  Sueca
//
//  Created by Roger Luan on 10/15/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import "DecksTVC.h"

@interface DecksTVC () <NSFetchedResultsControllerDelegate>

@property (strong,nonatomic) NSManagedObjectContext *moc;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong,nonatomic) NSIndexPath *indexPathForSelectedDeck;
@property (strong,nonatomic) Deck *deckToShowDetails;

@end

@implementation DecksTVC

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
	
//	self.clearsSelectionOnViewWillAppear = YES;
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Deck *reusableDeck  = nil;
	if ([[self.fetchedResultsController sections] count] >= [indexPath section]){
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
		if ([sectionInfo numberOfObjects] >= [indexPath row]){
			reusableDeck = [self.fetchedResultsController objectAtIndexPath:indexPath];
		}
	}
	if (reusableDeck) {
		cell.textLabel.text = reusableDeck.deckName;
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
			abort();
			//TODO: remove all abort(); before production
		}
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle: nil];
	editDeckTVC *editDeckTVC = [storyboard instantiateViewControllerWithIdentifier:@"editDeckTVC"];
	editDeckTVC.thisDeck = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.navigationController pushViewController:editDeckTVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
			abort();
			//TODO: remove all abort(); before production
		}
		
		[tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldSelectedCellIndex.row inSection:oldSelectedCellIndex.section],[NSIndexPath indexPathForRow:self.indexPathForSelectedDeck.row inSection:self.indexPathForSelectedDeck.section]] withRowAnimation:UITableViewRowAnimationNone];
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
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deckName" ascending:YES];
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
		//TODO: remove all abort(); before production
	}
	else {
		return [fetchedObjects firstObject];
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([[segue identifier] isEqualToString:@"newDeck"]) {
		editDeckTVC *tempTVC = [segue destinationViewController];
		tempTVC.thisDeck = nil;
	}
}


@end
