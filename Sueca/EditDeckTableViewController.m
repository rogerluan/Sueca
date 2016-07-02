//
//  EditDeckTableViewController.m
//  Sueca
//
//  Created by Roger Oba on 10/16/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import "EditDeckTableViewController.h"
#import "Constants.h"
#import "AnalyticsManager.h"

@interface EditDeckTableViewController () <NSFetchedResultsControllerDelegate,CardRuleCellDelegate>

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation EditDeckTableViewController

#pragma mark - Lifecycle -

+ (instancetype)viewControllerWithDeck:(Deck *)deck {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MainStoryboard bundle:nil];
	EditDeckTableViewController *instance = [storyboard instantiateViewControllerWithIdentifier:EditDeckTableViewControllerIdentifier];
	instance.thisDeck = deck;
	return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupLayout];
}

- (void)setupLayout {
	UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	[tempImageView setFrame:self.tableView.frame];
	self.tableView.backgroundView = tempImageView;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	if (self.thisDeck) { //editting deck
		NSError *error;
		if (![[self fetchedResultsController] performFetch:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
		self.title = NSLocalizedString(self.thisDeck.deckName, nil);
	} else { //it's a new deck
		self.title = NSLocalizedString(@"New Deck", @"Navigation bar title");
		self.thisDeck = [Deck newDeckWithLabel:self.deckLabel];
		NSError *error;
		if (![[self fetchedResultsController] performFetch:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
	}
	
	if ([self.thisDeck.isEditable isEqualToNumber:@YES]) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
#warning test this
	NSDictionary *attributes;
	if (![self.thisDeck.deckName isEqualToString:@""]) {
		attributes = @{@"Deck Name":self.thisDeck.deckName};
	} else if (![self.deckLabel isEqualToString:@""]){
		attributes = @{@"Deck Name":self.deckLabel};
	}
	[AnalyticsManager logContentViewEvent:AnalyticsEventViewEditDeckVC contentType:@"UIViewController" customAttributes:attributes];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSError *error = nil;
    if(![self.moc save: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        [self.navigationController popViewControllerAnimated:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeck" object:self userInfo:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.thisDeck) {
        return NUMBER_OF_CARDS;
    } else {
        return [_fetchedResultsController.fetchedObjects count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cardCellIdentifier = @"cardCell";
    CardRulesCell *cell = [tableView dequeueReusableCellWithIdentifier:cardCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[CardRulesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cardCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(CardRulesCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Card *reusableCard = nil;
    //Validate fetchedResultsController
    if ([[self.fetchedResultsController sections] count] >= [indexPath section]){
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
        if ([sectionInfo numberOfObjects] >= [indexPath row]){
            reusableCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    if (reusableCard) {
		NSString *tableOptimizedImagePath = [reusableCard.cardName stringByAppendingString:@"-TableOptimized"];
		cell.cardImageView.image = [UIImage imageNamed:tableOptimizedImagePath];
        cell.cardRuleTextField.text = NSLocalizedString(reusableCard.cardRule, nil);
        
        if ([reusableCard.cardDescription isEqualToString:@""] || reusableCard.cardDescription == nil) {
            cell.cardDescriptionTextView.textColor = [UIColor lightGrayColor];
            cell.cardDescriptionTextView.text = NSLocalizedString(@"Tap to add a description", nil);
        } else {
            cell.cardDescriptionTextView.textColor = [UIColor whiteColor];
            cell.cardDescriptionTextView.text = NSLocalizedString(reusableCard.cardDescription, nil);
        }
        cell.delegate = self;
        cell.cardRuleTextField.tag = indexPath.row;
        cell.cardDescriptionTextView.tag = indexPath.row;
    }
    
    if ([self.thisDeck.isEditable isEqualToNumber:@0]) {
        cell.cardRuleTextField.userInteractionEnabled = NO;
        [cell.cardDescriptionTextView setEditable:NO];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_fetchedResultsController.fetchedObjects count] <= 1) {
        return NO;
    } else if ([self.thisDeck.isEditable isEqualToNumber:@0]) { //is editting Default deck
        return NO;
    }
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Card *cardToBeDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.moc deleteObject:cardToBeDeleted];
		
		
		NSMutableDictionary *attributes;
		if (cardToBeDeleted.cardName) {
			[attributes addEntriesFromDictionary:@{@"Card Name":cardToBeDeleted.cardName}];
		}
		if (cardToBeDeleted.cardRule) {
			[attributes addEntriesFromDictionary:@{@"Card Rule":cardToBeDeleted.cardRule}];
		}
		if (cardToBeDeleted.cardDescription) {
			[attributes addEntriesFromDictionary:@{@"Card Description":cardToBeDeleted.cardDescription}];
		}
		[AnalyticsManager logEvent:AnalyticsEventDidDeleteCard withAttributes:[attributes copy]];
		
        for (NSInteger i = indexPath.row ; i < ([tableView numberOfRowsInSection:0]-1) ; i++) {
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
            [self configureCell:(CardRulesCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

#pragma mark - CardRuleCellDelegate Methods

- (void)cardRuleCell:(UITableViewCell *)cell didPressReturnKeyFromTextField:(UITextField *)cardRuleTextField {
    NSLog(@"Pressed return from text field.");
	[AnalyticsManager logEvent:AnalyticsEventDidPressReturnKeyFromTextField];
    [[(CardRulesCell*)cell cardDescriptionTextView] becomeFirstResponder];
}

- (void)cardRuleCell:(UITableViewCell *)cell didPressReturnKeyFromTextView:(UITextView *)cardDescriptionTextView {
	[AnalyticsManager logEvent:AnalyticsEventDidPressReturnKeyFromTextView];
    NSLog(@"Pressed return from text view.");
    
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:currentIndexPath.section];
    
    NSLog(@"Current index path row: %ld, next index path row: %ld",(long)currentIndexPath.row,(long)nextIndexPath.row);
    
    CardRulesCell *nextCell = (CardRulesCell*)[self.tableView cellForRowAtIndexPath:nextIndexPath];
    
    if (nextCell) {
        [nextCell.cardRuleTextField becomeFirstResponder];
    } else {
        NSLog(@"That was the last cell.");
        [self.view endEditing:YES];
    }
}

- (void)cardRuleCell:(UITableViewCell *)cell textFieldDidEndEditingWithContent:(UITextField *)cardRuleTextField {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Card *editedCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
    editedCard.cardRule = cardRuleTextField.text;
    
    NSError *error = nil;
    if(![self.moc save: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	NSMutableDictionary *attributes;
	if (editedCard.cardName) {
		[attributes addEntriesFromDictionary:@{@"Card Name":editedCard.cardName}];
	}
	if (editedCard.cardRule) {
		[attributes addEntriesFromDictionary:@{@"Card Rule":editedCard.cardRule}];
	}
	if (editedCard.cardDescription) {
		[attributes addEntriesFromDictionary:@{@"Card Description":editedCard.cardDescription}];
	}
	[AnalyticsManager logEvent:AnalyticsEventDidEditCardRule withAttributes:[attributes copy]];
}

- (void)cardRuleCell:(UITableViewCell *)cell textViewDidEndEditingWithContent:(UITextView *)cardDescriptionTextView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Card *editedCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
    editedCard.cardDescription = cardDescriptionTextView.text;
    
    NSError *error = nil;
    if(![self.moc save: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	NSMutableDictionary *attributes;
	if (editedCard.cardName) {
		[attributes addEntriesFromDictionary:@{@"Card Name":editedCard.cardName}];
	}
	if (editedCard.cardRule) {
		[attributes addEntriesFromDictionary:@{@"Card Rule":editedCard.cardRule}];
	}
	if (editedCard.cardDescription) {
		[attributes addEntriesFromDictionary:@{@"Card Description":editedCard.cardDescription}];
	}
	[AnalyticsManager logEvent:AnalyticsEventDidEditCardDescription withAttributes:[attributes copy]];
}

@end
