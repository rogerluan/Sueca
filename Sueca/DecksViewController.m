//
//  DecksViewController.m
//  Sueca
//
//  Created by Roger Oba on 10/15/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import "DecksViewController.h"
#import "GameManager.h"
#import "AnalyticsManager.h"
#import "Deck.h"
#import "Constants.h"
#import "NotificationManager.h"
#import "AppearanceHelper.h"
#import "CloudKitManager.h"
#import "PromotionView.h"
#import "ErrorManager.h"

@interface DecksViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;


@property (strong, nonatomic) PromotionView *promotionView;
@property (strong, nonatomic) Promotion *latestPromotion;
@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) GameManager *gameManager;
@property (strong, nonatomic) CloudKitManager *CKManager;

@property (strong, nonatomic) NSIndexPath *indexPathForSelectedDeck;
@property (strong, nonatomic) NSString *creatingDeckName; //can't use "newDeckName"

@end

@implementation DecksViewController

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.gameManager = [GameManager sharedInstance];
	self.CKManager = [CloudKitManager new];
	[self setupLayout];
	
	NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	[self updatePromotionAnimated:YES];
	[self registerForNotification];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView reloadData];
	[AnalyticsManager logContentViewEvent:AnalyticsEventViewDecksVC contentType:@"UIViewController"];
	[NotificationManager resetPendingNotificationCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[self unregisterFromNotification];
}

- (void)setupLayout {
	UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	tempImageView.frame = self.view.frame;
	self.tableView.backgroundView = tempImageView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
	return sectionInfo.numberOfObjects;
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
	if (self.tableView.editing) {
		if (indexPath.row > 0) {
			for (UIView *subview in cell.subviews) {
				for (UIView *deeperSubview in subview.subviews) {
					[deeperSubview.layer addAnimation:[AppearanceHelper bounceHorizontallyAnimation] forKey:@"bounceHorizontally"];
					[deeperSubview.layer addAnimation:[AppearanceHelper bounceVerticallyAnimation] forKey:@"bounceVertically"];
				}
				[subview.layer addAnimation:[AppearanceHelper bounceHorizontallyAnimation] forKey:@"bounceHorizontally"];
				[subview.layer addAnimation:[AppearanceHelper bounceVerticallyAnimation] forKey:@"bounceVertically"];
			}
		}
	} else {
		[cell.layer removeAllAnimations];
		cell.transform = CGAffineTransformIdentity;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Deck *deckBeingEdited = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([deckBeingEdited.isBeingUsed isEqualToNumber:@0] && [deckBeingEdited.isEditable isEqualToNumber:@1]) {
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
	Deck *selectedDeck = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:[EditDeckTableViewController viewControllerWithDeck:selectedDeck] animated:YES];
	NSMutableDictionary *attributes = [NSMutableDictionary new];
	if (selectedDeck.deckName) {
		[attributes addEntriesFromDictionary:@{@"Deck Name":selectedDeck.deckName}];
	}
	[AnalyticsManager logContentViewEvent:AnalyticsEventViewEditDeckVC contentType:@"UIViewController" customAttributes:[attributes copy]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.isEditing == NO) {
        NSIndexPath *oldSelectedCellIndex = self.indexPathForSelectedDeck;
        self.indexPathForSelectedDeck = indexPath;
        
        if (![oldSelectedCellIndex isEqual:self.indexPathForSelectedDeck]) {
			if ([self.gameManager switchToDeck:[self.fetchedResultsController objectAtIndexPath:self.indexPathForSelectedDeck]]) {
				[tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldSelectedCellIndex.row inSection:oldSelectedCellIndex.section], [NSIndexPath indexPathForRow:self.indexPathForSelectedDeck.row inSection:self.indexPathForSelectedDeck.section]] withRowAnimation:UITableViewRowAnimationNone];
			} else {
				//to-do: treat core data error here. This was never been treated before and have never failed.
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
			
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[self presentViewController:alert animated:YES completion:nil];
			});
			
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
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
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

#pragma mark - Core Data Method -

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - Notification Center -

- (void)registerForNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationUpdateLatestPromotion object:nil];
}

- (void)unregisterFromNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	if ([notification.name isEqualToString:SuecaNotificationUpdateLatestPromotion]) {
		[self updatePromotionAnimated:NO];
	}
}

- (void)updatePromotionAnimated:(BOOL)animated {
	[self.CKManager fetchLatestPromotionWithCompletion:^(NSError *error, Promotion *promotion) {
		if (!error) {
			self.latestPromotion = promotion;
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				if (self.promotionView) {
					[self.promotionView removeFromSuperview];
				}
				self.promotionView = [PromotionView viewWithPromotion:self.latestPromotion];
				if (animated) {
					[self.promotionView.layer addAnimation:[AppearanceHelper pushFromBottom] forKey:nil];
				}
				[self.view addSubview:self.promotionView];
			});
		} else {
			NSLog(@"Fetch latest promotion returned error: %@", error);
			if ([error.domain isEqualToString:[[NSBundle mainBundle] bundleIdentifier]] && error.code == SuecaErrorNoValidPromotionsFound) {
				//to-do: show button to link to our facebook page anyway.
			} else {
				//to-do: analytics
				NSLog(@"Silent error when trying to fetch latest promotions: %@", error);
			}
		}
	}];
}

#pragma mark - Actions -

- (IBAction)editButtonPress:(UIBarButtonItem *)button {
	if (self.tableView.editing) {
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit navigation bar button item") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPress:)];
		self.navigationItem.leftBarButtonItem = editButton;
		[CATransaction setCompletionBlock:^{
			[self.tableView reloadData];
		}];
		[self.tableView setEditing:NO animated:YES];
	} else {
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done navigation bar button item") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPress:)];
		self.navigationItem.leftBarButtonItem = doneButton;
		[CATransaction setCompletionBlock:^{
			[self.tableView reloadData];
		}];
		[self.tableView setEditing:YES animated:YES];
	}
}

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

#pragma mark - Navigation - 

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
