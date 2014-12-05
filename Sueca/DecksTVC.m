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

@end

@implementation DecksTVC

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);
	}
	
     self.clearsSelectionOnViewWillAppear = YES;
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
	NSInteger numberOfRows = [_fetchedResultsController.fetchedObjects count];

	if (numberOfRows%2 == 0) {
		[self.tableView setBackgroundColor: [UIColor colorWithRed:0.772 green:0.980 blue:0.794 alpha:1.000]];
	}
	else {
		[self.tableView setBackgroundColor: [UIColor colorWithRed:0.941 green:1.000 blue:0.971 alpha:1.000]];
	}
	
	return numberOfRows;
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
		
		if (indexPath.row%2 == 0) {
			[cell setBackgroundColor: [UIColor colorWithRed:0.772 green:0.980 blue:0.794 alpha:1.000]];
		}
		else {
			[cell setBackgroundColor: [UIColor colorWithRed:0.941 green:1.000 blue:0.971 alpha:1.000]];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	Deck *deckBeingEdited = [self.fetchedResultsController objectAtIndexPath:indexPath];
	NSLog(@"current deck: %@ isEditable: %@",deckBeingEdited.deckName,deckBeingEdited.isEditable);
	if ([deckBeingEdited.isEditable isEqualToNumber:@1]) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Deck *deckToBeDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.moc deleteObject:deckToBeDeleted];
		
		NSError *error = nil;
		if(![self.moc save: &error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
			//TODO: remove all abort(); before production
		}
		else {
			[tableView reloadData];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([[segue identifier] isEqualToString:@"newDeck"]) {
		editDeckTVC *tempTVC = [segue destinationViewController];
		tempTVC.thisDeck = nil;
	}
	else if([[segue identifier] isEqualToString:@"viewDeckSegue"]) {
		editDeckTVC *tempTVC = [segue destinationViewController];
		Deck *selectedDeck = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
		NSLog(@"selectedDeckName: %@",selectedDeck.deckName);
		tempTVC.thisDeck = selectedDeck;
	}
}


@end
