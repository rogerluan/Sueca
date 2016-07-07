//
//  DecksTableViewController.m
//  Sueca
//
//  Created by Roger Oba on 10/15/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import "DecksTableViewController.h"
#import "GameManager.h"
#import "AnalyticsManager.h"

#import <TSMessages/TSMessageView.h>

@interface DecksTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) GameManager *gameManager;

@property (strong, nonatomic) NSIndexPath *indexPathForSelectedDeck;
@property (strong, nonatomic) NSString *creatingDeckName; //can't use "newDeckName"

@end

@implementation DecksTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.gameManager = [GameManager sharedInstance];
	[self setupLayout];
	
	NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"showNewFeatureNotification"]) {
        [TSMessage showNotificationInViewController:self
                                              title:NSLocalizedString(@"Customizable!", @"TSMessage Customizable Notification Title")
                                           subtitle:NSLocalizedString(@"You can now edit the name of your decks by tapping Edit and selecting the deck. Enjoy!", @"TSMessage Customizable Notification Subtitle")
                                              image:[UIImage imageNamed:@"notification-arrow"]
                                               type:TSMessageNotificationTypeMessage
                                           duration:TSMessageNotificationDurationEndless
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showNewFeatureNotification"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView reloadData];
	[AnalyticsManager logContentViewEvent:AnalyticsEventViewDecksVC contentType:@"UIViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupLayout {
	UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	tempImageView.frame = self.view.frame;
	self.tableView.backgroundView = tempImageView;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

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
        if (reusableDeck.isDefault) {
            cell.textLabel.text = NSLocalizedString(reusableDeck.deckName, nil);
        } else {
            cell.textLabel.text = reusableDeck.deckName;
        }
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        
        if ([reusableDeck.isBeingUsed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            self.indexPathForSelectedDeck = indexPath;
            cell.imageView.image = [UIImage imageNamed:@"check"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"empty"];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Deck *deckBeingEdited = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([deckBeingEdited.isEditable isEqualToNumber:@1] && [deckBeingEdited.isBeingUsed isEqualToNumber:@0]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Deck *deckToBeDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.moc deleteObject:deckToBeDeleted];
        self.indexPathForSelectedDeck = [self.fetchedResultsController indexPathForObject:self.gameManager.deck];
        
        NSError *error = nil;
        if(![self.moc save: &error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
		
		NSMutableDictionary *attributes;
		if (deckToBeDeleted.deckName) {
			[attributes addEntriesFromDictionary:@{@"Deck Name":deckToBeDeleted.deckName}];
		}
		[AnalyticsManager logEvent:AnalyticsEventDidDeleteDeck withAttributes:[attributes copy]];
    }
}

#pragma mark - UITableView Delegate Methods -

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[EditDeckTableViewController viewControllerWithDeck:[self.fetchedResultsController objectAtIndexPath:indexPath]] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.isEditing == NO) {
        NSIndexPath *oldSelectedCellIndex = self.indexPathForSelectedDeck;
        self.indexPathForSelectedDeck = indexPath;
        
        if (![oldSelectedCellIndex isEqual:self.indexPathForSelectedDeck]) {
            Deck *selectedDeck = [self.fetchedResultsController objectAtIndexPath:self.indexPathForSelectedDeck];
            selectedDeck.isBeingUsed = [NSNumber numberWithBool:YES];
            Deck *deselectedDeck = [self.fetchedResultsController objectAtIndexPath:oldSelectedCellIndex];
            deselectedDeck.isBeingUsed = [NSNumber numberWithBool:NO];
            
            NSError *coreDataError = nil;
            if (![self.moc save:&coreDataError]) { //error
                NSLog(@"Unresolved error %@, %@", coreDataError, [coreDataError userInfo]);
			} else { //everything went fine
				[tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldSelectedCellIndex.row inSection:oldSelectedCellIndex.section],[NSIndexPath indexPathForRow:self.indexPathForSelectedDeck.row inSection:self.indexPathForSelectedDeck.section]] withRowAnimation:UITableViewRowAnimationNone];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeck" object:self userInfo:nil];
				
				NSMutableDictionary *attributes;
				if (deselectedDeck.deckName) {
					[attributes addEntriesFromDictionary:@{@"From Deck":deselectedDeck.deckName}];
				}
				if (selectedDeck.deckName) {
					[attributes addEntriesFromDictionary:@{@"To Deck":selectedDeck.deckName}];
				}
				[AnalyticsManager logEvent:AnalyticsEventDidSelectDeck withAttributes:[attributes copy]];
			}
        }
    } else {
        Deck *deckToEditName = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([deckToEditName.isEditable isEqualToNumber:@YES]) {
			
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Change Deck Label", @"editDeckLabelAlert Title") message:NSLocalizedString(@"Type the new label for your deck.", @"editDeckLabelAlert Message") preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"editDeckLabelAlert OK Button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				
				NSString *alertViewText = [[[[[alert textFields] firstObject] text] capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				
				NSLog(@"alertViewtext: %@",alertViewText);
				if (!alertViewText || !(alertViewText.length>0)) {
					return;
				} else if (deckToEditName) {
					deckToEditName.deckName = alertViewText;
					NSError *error = nil;
					if(![self.moc save: &error]) {
						NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					}
					
					NSMutableDictionary *attributes;
					if (deckToEditName.deckName) {
						[attributes addEntriesFromDictionary:@{@"Deck Name":deckToEditName.deckName}];
					}
					[AnalyticsManager logEvent:AnalyticsEventDidRenameDeck withAttributes:[attributes copy]];
				} else {
					NSLog(@"Handle error: invalid deckToEditName");
				}
			}];
			
			[alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
				textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
				textField.placeholder = deckToEditName.deckName;
			}];
			
			UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"editDeckLabelAlert Cancel Button") style:UIAlertActionStyleCancel handler:nil];
			[alert addAction:action];
			[alert addAction:cancelAction];
			
			[self presentViewController:alert animated:YES completion:nil];
			
			
			NSMutableDictionary *attributes;
			if (deckToEditName.deckName) {
				[attributes addEntriesFromDictionary:@{@"Deck Name":deckToEditName.deckName}];
			}
			[AnalyticsManager logContentViewEvent:AnalyticsEventDeckEditView contentType:@"UIAlertController" customAttributes:[attributes copy]];
        }
    }
}

#pragma mark - NSFetchedResultsController Delegate Methods

- (NSFetchedResultsController*)fetchedResultsController {
    
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

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - Navigation

- (IBAction)newDeck:(id)sender {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Deck", @"newDeckAlert Title") message:NSLocalizedString(@"Please name your custom deck.", @"newDeckAlert Message") preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"newDeckAlert Create Button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
		NSString *alertViewText = [[[[[alert textFields ] firstObject] text] capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if (alertViewText && alertViewText.length>0) { //with custom deck name
			self.creatingDeckName = alertViewText;
		} else { //deck name left blank
			NSInteger deckNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"DeckNumber"];
			
			deckNumber++;
			[[NSUserDefaults standardUserDefaults] setInteger:deckNumber forKey:@"DeckNumber"];
			
			self.creatingDeckName = [NSString stringWithFormat:NSLocalizedString(@"Custom Deck %ld", nil),(long)deckNumber];
		}
	
		[self performSegueWithIdentifier:@"newDeck" sender:nil];
	}];
	
	[alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.placeholder = NSLocalizedString(@"Custom Deck", @"New Deck Default Label");
	}];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"newDeckAlert Cancel Button") style:UIAlertActionStyleCancel handler:nil];
	[alert addAction:action];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
	[AnalyticsManager logContentViewEvent:AnalyticsEventDeckCreationView contentType:@"UIAlertController"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"newDeck"]) {
        EditDeckTableViewController *tempTVC = [segue destinationViewController];
        tempTVC.thisDeck = nil;
        tempTVC.deckLabel = self.creatingDeckName;
		
		NSMutableDictionary *attributes;
		if (self.creatingDeckName) {
			[attributes addEntriesFromDictionary:@{@"Deck Name":self.creatingDeckName}];
		}
		[AnalyticsManager logEvent:AnalyticsEventDidCreateDeck withAttributes:[attributes copy]];
    }
}

@end
