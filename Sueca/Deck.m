//
//  Deck.m
//  Sueca
//
//  Created by Roger Oba on 12/5/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import "Deck.h"
#import "Card.h"

@implementation Deck

@dynamic deckName;
@dynamic isBeingUsed;
@dynamic isEditable;
@dynamic cards;
@dynamic defaultDeck;

- (BOOL)isDefault {
	if ([self.isEditable isEqualToNumber:@0] && ([self.deckName isEqualToString:@"Default"] || [self.deckName isEqualToString:@"Padrão"] || [self.deckName isEqualToString:@"Standard"])) {
		return YES;
	}
	return NO;
}

- (BOOL)isDefaultDeck {
	return [self isDefault];
}

- (NSDictionary *)attributes {
	NSMutableDictionary *attributes = [NSMutableDictionary new];
	if (self.deckName) {
		[attributes addEntriesFromDictionary:@{@"Deck Name":self.deckName}];
	}
	return [attributes copy];
}

+ (Deck *)newDeckWithLabel:(NSString *)deckLabel {
	NSArray *cardRules = [[NSArray alloc] initWithObjects:@"Card Rule 1",
						  @"Card Rule 2",
						  @"Card Rule 3",
						  @"Card Rule 4",
						  @"Card Rule 5",
						  @"Card Rule 6",
						  @"Card Rule 7",
						  @"Card Rule 8",
						  @"Card Rule 9",
						  @"Card Rule 10",
						  @"Card Rule 11",
						  @"Card Rule 12",
						  @"Card Rule 13",
						  @"Card Rule 14", nil];
	
	NSArray *cardImages = [[NSArray alloc] initWithObjects:@"01-C", @"02-C", @"03-C", @"04-C", @"05-C", @"06-C", @"07-C", @"08-C", @"09-C", @"10-C", @"11-C", @"12-C", @"13-C", @"14-C", nil];
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	Deck *deck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:moc];
	deck.deckName = deckLabel;
	deck.isEditable = [NSNumber numberWithBool:YES];
	
	for (int i = 0 ; i < CUSTOM_NUMBER_OF_CARDS ; i++) {
		Card *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:moc];
		newCard.cardName = [cardImages objectAtIndex:i];
		newCard.cardRule = [cardRules objectAtIndex:i];
		[deck addCardsObject:newCard];
	}
	return deck;
}

/**
 *  Method to initialize the default deck on the app first run.
 *  This will only be runned once.
 */
+ (void)createDefaultDeck {
	if (![self defaultDeckExist]) {
		
		//Self note: Core Data and localization best practice: DO NOT save Localized strings into core data. Instead, save identifiers, and only localize when READING them.
		
		NSArray *cardRules = [[NSArray alloc] initWithObjects:@"Card Rule 1",
							  @"Card Rule 2",
							  @"Card Rule 3",
							  @"Card Rule 4",
							  @"Card Rule 5",
							  @"Card Rule 6",
							  @"Card Rule 7",
							  @"Card Rule 8",
							  @"Card Rule 9",
							  @"Card Rule 10",
							  @"Card Rule 11",
							  @"Card Rule 12",
							  @"Card Rule 13", nil];
		
		NSArray *cardDescriptions = [[NSArray alloc] initWithObjects:@"Description Card 1",
									 @"Description Card 2",
									 @"Description Card 3",
									 @"Description Card 4",
									 @"Description Card 5",
									 @"Description Card 6",
									 @"Description Card 7",
									 @"Description Card 8",
									 @"Description Card 9",
									 @"Description Card 10",
									 @"Description Card 11",
									 @"Description Card 12",
									 @"Description Card 13", nil];
		
		NSArray *cardImages = [[NSArray alloc] initWithObjects: @"01-Um",@"02-Dois",@"03-Tres",@"04-Quatro",@"05-Cinco",@"06-Seis",@"07-Sete",@"08-Oito",@"09-Nove",@"10-Dez",@"11-Valete",@"12-Dama",@"13-Rei", nil];
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
		Deck *defaultDeck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:moc];
		defaultDeck.deckName = @"Default";
		defaultDeck.isEditable = [NSNumber numberWithBool:NO];
		defaultDeck.isBeingUsed = [NSNumber numberWithBool:YES];
		
		NSInteger i = 0;
		for (; i < DEFAULT_NUMBER_OF_CARDS ; i++) { 
			Card *defaultDeckCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:moc];
			defaultDeckCard.cardName = [cardImages objectAtIndex:i];
			defaultDeckCard.cardRule = [cardRules objectAtIndex:i];
			defaultDeckCard.cardDescription = [cardDescriptions objectAtIndex:i];
			[defaultDeck addCardsObject:defaultDeckCard];
		}
		
		NSError *coreDataError = nil;
		if(![moc save: &coreDataError]) {
			NSLog(@"Unresolved error %@, %@", coreDataError, [coreDataError userInfo]);
		}
	}
}


/**
 *  Verifies if the default deck already exists.
 *
 *  @return Returns the default deck if it exists, else nil.
 */
+ (Deck *)defaultDeckExist {
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	//Double checks if the default deck doesn't already exist.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isEditable == %@",[NSNumber numberWithBool:NO]];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *defaultDeckFetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
	
	NSLog(@"defaultDeckExist response: %ld",(long)defaultDeckFetchedObjects.count);
	return defaultDeckFetchedObjects.count > 0 ? [defaultDeckFetchedObjects firstObject] : nil;
}

#pragma mark - Core Data Method

+ (NSManagedObjectContext *)managedObjectContext {
	NSManagedObjectContext *context = nil;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		context = [delegate managedObjectContext];
	}
	return context;
}

@end
