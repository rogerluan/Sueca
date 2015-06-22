//
//  GameViewController.m
//  Sueca
//
//  Created by Roger Oba on 25/10/13.
//  Copyright (c) 2013 Roger Oba. All rights reserved.
//

#import "GameViewController.h"
@import AVFoundation;
#import <Parse/Parse.h>
#import "CardDescriptionView.h"
#import "JBWhatsAppActivity.h"
#import "TSMessage.h"
#import "iVersion.h"

//#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface GameViewController () <UIGestureRecognizerDelegate,CustomIOS7AlertViewDelegate,TSMessageViewProtocol,iVersionDelegate,iRateDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shuffleDeckButton;
@property (weak, nonatomic) IBOutlet UIButton *drawCardButton;
@property (weak, nonatomic) IBOutlet UIButton *ruleButton;
@property (strong, nonatomic) IBOutlet UIView *cardContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *gameLogo;

@property (strong,nonatomic) NSManagedObjectContext *moc;

@property (strong,nonatomic) NSMutableArray *deckArray;
@property (strong,nonatomic) Deck *deck;
@property (strong,nonatomic) Card *displayCard;
@property (strong,nonatomic) UIImageView *previousCard;

@property (assign) SystemSoundID cardShuffle;
@property (assign) SystemSoundID cardSlide;

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.deckArray = [[NSMutableArray alloc] init];
	[self setupViewsLayout];
	
	//0: never decided
	//1: displays warning
	//2: opted out
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"] == 0) {
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showShuffledDeckWarning"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showNoDescriptionWarning"] == 0) {
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showNoDescriptionWarning"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	/* Creates default deck only once */
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeRunning"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self createDefaultDeck];
	}
	else {
		[self performSelector:@selector(showWelcomeBackMessage) withObject:nil afterDelay:3.0];
	}
	

	[[iVersion sharedInstance] checkForNewVersion];
	[[iVersion sharedInstance] setDelegate:self];
	[[iRate sharedInstance] setDelegate:self];
	
	/* Inits the deck that should be used*/
	self.deck = [self deckBeingUsed];
	if (self.deck) {
		[self.deckArray removeAllObjects];
		for (Card *card in self.deck.cards) {
			for (int i = 0; i < 8; i++) {
				[self.deckArray addObject:card];
			}
		}
	}
	else {
		NSLog(@"Deck is nil. Aborting.");
//		abort();
	}
}

- (IBAction)displayCardDescription:(id)sender {
	if ([self.cardContainerView.subviews count]) {
		CardDescriptionView *descriptionView = [[CardDescriptionView alloc] init];
		[descriptionView showAlertWithHeader:NSLocalizedString(@"#Sueca", @"Card description popover header") image:[UIImage imageNamed:self.displayCard.cardName] title:NSLocalizedString(self.displayCard.cardRule,nil) description:NSLocalizedString(self.displayCard.cardDescription,nil) sender:self];
		descriptionView.delegate = self;
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.deck = [self deckBeingUsed];
	if (self.deck) {
		[self.deckArray removeAllObjects];
		self.deckArray = [self fullDeck];
	}
	else {
		NSLog(@"Deck is nil. Aborting.");
	}
}

- (void) showWelcomeBackMessage {
	
	NSString *welcomeBackMessage = [self randomWelcomeBackMessage];
	NSString *buttonTitle = nil;
	if ([welcomeBackMessage rangeOfString:@"😇"].location != NSNotFound) {
		buttonTitle = NSLocalizedString(@"Review", @"Welcome Back Message Button Title");
	}
	
	[TSMessage showNotificationInViewController:self.tabBarController
										  title:NSLocalizedString(@"Welcome Back! 😎", @"TSMessage Welcome Back Title")
									   subtitle:welcomeBackMessage
										  image:[UIImage imageNamed:@"notification-beer"]
										   type:TSMessageNotificationTypeDarkMessage
									   duration:TSMessageNotificationDurationAutomatic
									   callback:^{
										   [PFAnalytics trackEventInBackground:@"interactionWithWelcomeBack" dimensions:nil block:^(BOOL succeeded, NSError *error) {
											   if (!error) {
												   NSLog(@"Successfully logged the 'interactionWithWelcomeBack' event");
											   }
										   }];
									   }
									buttonTitle:buttonTitle
								 buttonCallback:^{
									 [PFAnalytics trackEventInBackground:@"updatedViaWelcomeBackButton" dimensions:nil block:^(BOOL succeeded, NSError *error) {
										 if (!error) {
											 NSLog(@"Successfully logged the 'updatedViaWelcomeBackButton' event");
										 }
									 }];
									 
									 [[iVersion sharedInstance] openAppPageInAppStore];
								 }
									 atPosition:TSMessageNotificationPositionTop
						   canBeDismissedByUser:YES];
	
}

- (IBAction)sortCard:(id)sender {
	[[iRate sharedInstance] logEvent:NO];
	
	NSInteger globalSortCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"globalSortCount"];
	globalSortCount++;
	[[NSUserDefaults standardUserDefaults] setInteger:globalSortCount forKey:@"globalSortCount"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self sortCard];
}

- (IBAction)shuffleButton:(id)sender {
	
	[[iRate sharedInstance] logEvent:NO];
	
	[self showWelcomeBackMessage];
	
	NSInteger globalSortCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"globalShuffleCount"];
	globalSortCount++;
	[[NSUserDefaults standardUserDefaults] setInteger:globalSortCount forKey:@"globalShuffleCount"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    [self shuffle];
}

/**
 *  Method called to draw a random card. It checks if there are cards available, sorts a card and animates it.
 *  @author Roger Oba
 */
- (void) sortCard {
	
	[self playRandomCardSlideSoundFX];
	
	/* If there're no more cards in the deck, it reshuffles and warns the user */
	if([self.deckArray count] == 0) {
		/* Warns the user that the deck was reshuffled */
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"] == 1) {
			NSInteger warningCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"noShuffleDeckWarningCount"];
			
			warningCount++;
			[[NSUserDefaults standardUserDefaults] setInteger:warningCount forKey:@"noShuffleDeckWarningCount"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[TSMessage showNotificationInViewController:self.tabBarController
												  title:NSLocalizedString(@"Deck Shuffled", @"Deck shuffled warning title")
											   subtitle:NSLocalizedString(@"There're no more cards to be drawn. We shuffled the deck for you.", @"Deck shuffled warning message")
												  image:nil
												   type:TSMessageNotificationTypeWarning
											   duration:TSMessageNotificationDurationAutomatic
											   callback:nil
											buttonTitle:NSLocalizedString(@"Never Show Again",nil)
										 buttonCallback:^{
											 [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"showShuffledDeckWarning"];
											 [[NSUserDefaults standardUserDefaults] synchronize];
//
//											 [PFAnalytics trackEvent:@"showShuffledDeckWarning" dimensions:@{ @"warningCount": [NSString stringWithFormat:@"%ld",(long)warningCount]}];
											 
											 [PFAnalytics trackEventInBackground:@"showShuffledDeckWarning" dimensions:@{ @"warningCount": [NSString stringWithFormat:@"%ld",(long)warningCount]} block:^(BOOL succeeded, NSError *error) {
												 if (!error) {
													 NSLog(@"Successfully logged the 'showShuffledDeckWarning' event");
												 }
											 }];
										 }
											 atPosition:TSMessageNotificationPositionTop
								   canBeDismissedByUser:YES];
			[self shuffle];
		}
		else {
			NSLog(@"showShuffledDeckWarning = %ld\nIf it's 0, bug. Else if it's 2, user opted out.",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"]);
			[self shuffle];
		}
		return;
	}
	
	/* Randomly picks a card from the deck */
	NSUInteger randomIndex = arc4random() % [self.deckArray count];
	self.displayCard = [self.deckArray objectAtIndex:randomIndex];
	[self.deckArray removeObjectAtIndex: randomIndex];
	
	/* Animation initialization and execution */
	int containerWidth = self.cardContainerView.frame.size.width;
	int containerHeight = self.cardContainerView.frame.size.height;
	int indexX = arc4random()%(containerWidth-119);
	int indexY = arc4random()%(containerHeight-177);
	
	CGRect newFrame = CGRectMake(indexX,indexY,119,177);
	UIImageView *cardImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.displayCard.cardName]];
	cardImage.layer.anchorPoint = CGPointMake(0.5,0.5);
	//    CGAffineTransform newTransform;
	//    CGAffineTransformRotate(newTransform, 2*M_PI);
	CGAffineTransform transform = CGAffineTransformMakeRotation(2*M_PI);
	
	//Setting the previousCard
	if (self.previousCard) {
		for (UIGestureRecognizer *recognizer in self.previousCard.gestureRecognizers) {
			[self.previousCard removeGestureRecognizer:recognizer];
		}
	}
	self.previousCard = cardImage;
	
	[UIView animateWithDuration:0.5
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 //						 cardImage.transform = newTransform;
						 cardImage.transform = transform;
						 cardImage.frame = newFrame;
					 }
					 completion: nil];
	
	for (UIImageView *view in [self.cardContainerView subviews]) {
		if (![view isEqual:self.gameLogo] ) {
			view.alpha/=1.2;
		}
		if (view.alpha <= 0.012579) { //removes invisible images
			[view removeFromSuperview];
		}
	}
	
	[self.cardContainerView addSubview:cardImage];
	
	/* Shows the rule on screen */
	[self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule,nil) forState:UIControlStateNormal];
	[self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule,nil) forState:UIControlStateSelected];
	[self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule,nil) forState:UIControlStateHighlighted];
	
	if (!self.displayCard.cardDescription && [[NSUserDefaults standardUserDefaults] integerForKey:@"showNoDescriptionWarning"] == 2) {
		//user opted-out warning message, so we disable the button
		[self.ruleButton setUserInteractionEnabled:NO];
	}
}

/**
 *  Remove all cards on the screen.
 *  @author Roger Oba
 */
- (void) clearTable {
    for (UIImageView *view in [self.cardContainerView subviews]) {
        if (![view isEqual:self.gameLogo] ) {
            [view removeFromSuperview];
		}
	}
	
	[self.ruleButton setTitle:@"" forState:UIControlStateNormal];
	[self.ruleButton setTitle:@"" forState:UIControlStateSelected];
	[self.ruleButton setTitle:@"" forState:UIControlStateHighlighted];
}

/**
 *  Method that do all the stuff related with the shuffling
 *  @author Roger Oba
 */
- (void) shuffle {
	
	[self playShuffleSoundFX];
	[self clearTable];
	
	/* Reinicialização do baralho (para voltar ao original) */
	[self.deckArray removeAllObjects];
	self.deckArray = [self fullDeck];
}

/**
 *  Method to select the deck being used.
 *  @return Deck containing the cards that should be used, or nil if any error occurs.
 *  @author Roger Oba
 */
- (Deck*) deckBeingUsed {
	self.moc = [self managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:self.moc];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isBeingUsed == %@",[NSNumber numberWithBool:YES]];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *deckBeingUsedFetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
	if (deckBeingUsedFetchedObjects == nil || ([deckBeingUsedFetchedObjects count] == 0)) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		
		@try {
			if ([self defaultDeckExist]) {
				Deck *defaultDeck = [self defaultDeckExist];
				defaultDeck.isBeingUsed = [NSNumber numberWithBool:YES];
				
				NSError *coreDataError = nil;
				if(![self.moc save: &coreDataError]) {
					NSLog(@"Unresolved error %@, %@", coreDataError, [coreDataError userInfo]);
				}
				else {
					NSLog(@"Successfully solved a potential crash! Identifier: There was no deck being used, so it selected default deck to be used.");
				}
			}
			else {
				@throw [NSException exceptionWithName:@"noDefaultDeck" reason:@"For some reason, the default deck wasn't instantiated." userInfo:nil];
			}
		}
		@catch (NSException *exception) {
			NSLog(@"Exception %@ caught. %@ Trying to solve it now.",exception.name,exception.reason);
			if (![self defaultDeckExist]) {
				[self createDefaultDeck];
			}
			else {
				NSLog(@"Everything was tried. No solution found. Aborting.");
				abort();
			}
		}
		@finally {
			NSLog(@"Successfully solved a potential crash! Hell yeah!");
			return [self deckBeingUsed];
		}
	}
	else {
		return [deckBeingUsedFetchedObjects firstObject];
	}
}

/**
 *  @author Roger Oba
 *
 *  Verifies if the default deck already exists.
 *
 *  @return Returns the default deck if it exists, else nil.
 */
- (Deck*) defaultDeckExist {
	self.moc = [self managedObjectContext];
	
	//Double checks if the default deck doesn't already exist.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:self.moc];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isEditable == %@",[NSNumber numberWithBool:NO]];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *defaultDeckFetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
	
	NSLog(@"defaultDeckExist response: %ld",(long)defaultDeckFetchedObjects.count);
	return defaultDeckFetchedObjects.count ? [defaultDeckFetchedObjects objectAtIndex:0] : nil;
}

/**
 *  Method to initialize the default deck on the app first run.
 *  This will only be runned once.
 *  @author Roger Oba
 */
- (void) createDefaultDeck {
	if(![self defaultDeckExist]) {
		NSArray *cardRules = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Escolha 1 pessoa para beber", nil),
							  NSLocalizedString(@"Escolha 2 pessoas para beber", nil),
							  NSLocalizedString(@"Escolha 3 pessoas para beber", nil),
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
		
		NSArray *cardDescriptions = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Quem tirar essa carta escolhe 1 pessoa para beber.", @"Description Card 1"),
									 NSLocalizedString(@"Quem tirar essa carta escolhe 2 pessoas para beber.", @"Description Card 2"),
									 NSLocalizedString(@"Quem tirar essa carta escolhe 3 pessoas para beber.", @"Description Card 3"),
									 NSLocalizedString(@"Quem tirou essa carta deve escolher uma letra e um tema para o Stop. Então, na sequência da roda de amigos, cada um tem que falar uma palavra que comece com a letra escolhida, relacionada ao tema. Não vale repetir palavra! O primeiro que não souber, ou repetir palavra, bebe!", @"Description Card 4"),
									 NSLocalizedString(@"Quem tirou a carta fala uma palavra qualquer. O próximo tem que repetir a sequência de palavras anterior e adicionar uma. E assim por diante. Exemplo: Quem tirou a carta fala “mesa”. O próximo fala “mesa cachorro”. O próximo diz “mesa cachorro lápis”, e assim por diante. O primeiro que errar ou demorar, bebe.", @"Description Card 5"),
									 NSLocalizedString(@"Quem tirar essa carta, “guarda” ela mentalmente consigo. Discretamente no meio do jogo, essa pessoa deve colocar a mão na testa, fazendo continência e observar os outros jogadores. O último que perceber e fizer continência, bebe.", @"Description Card 6"),
									 NSLocalizedString(@"Começando pela pessoa que tirar a carta, esta deve escolher um número. Assim, todos devem seguir uma sequência começando em 1, e quando o número da sequência for múltiplo do número escolhido, a pessoa deve falar “Pi”. Por exemplo: foi escolhido o número 3, então: 1, 2, pi, 4, 5, pi, 7, 8, pi, etc. O primeiro que errar, bebe!", @"Description Card 7"),
									 NSLocalizedString(@"Quem tira essa carta determina uma regra para todos obedecerem. Pode ser algo do tipo “está proíbido falar a palavra ‘beber’ e seus derivados”, ou “antes de beber uma dose, a pessoa tem que rebolar”. Quem quebrar a regra, deve beber (às vezes, de novo). A Regra Geral pode ser substituída por outra Regra Geral, caso contrário, dura o jogo todo.", @"Description Card 8"),
									 NSLocalizedString(@"A pessoa que tirar essa carta pode transformá-la em qualquer outra!", @"Description Card 9"),
									 NSLocalizedString(@"Como teoricamente ninguém pode sair para ir ao banheiro enquanto estiver jogando, esta carta dá o direito à quem a tirou de ir ao banheiro. A carta só vale 1 vez. Ela pode guardar para ir mais tarde, ou “vender” à alguém, em troca de “favores” 😉", @"Description Card 10"),
									 NSLocalizedString(@"Todos que estiverem jogando bebem uma dose, inclusive quem tirou a carta!", @"Description Card 11"),
									 NSLocalizedString(@"Todas as damas bebem uma dose.", @"Description Card 12"),
									 NSLocalizedString(@"Todos os cavalheiros bebem uma dose.", @"Description Card 13"), nil];
		
		NSArray *cardImages = [[NSArray alloc] initWithObjects: @"01-Um",@"02-Dois",@"03-Tres",@"04-Quatro",@"05-Cinco",@"06-Seis",@"07-Sete",@"08-Oito",@"09-Nove",@"10-Dez",@"11-Valete",@"12-Dama",@"13-Rei", nil];
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
		Deck *defaultDeck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:moc];
		defaultDeck.deckName = NSLocalizedString(@"Default", nil);
		defaultDeck.isEditable = [NSNumber numberWithBool:NO];
		defaultDeck.isBeingUsed = [NSNumber numberWithBool:YES];
		
		for (int i = 0 ; i<13 ; i++) {
			Card *defaultDeckCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:moc];
			defaultDeckCard.cardName = [cardImages objectAtIndex:i];
			defaultDeckCard.cardRule = [cardRules objectAtIndex:i];
			defaultDeckCard.cardDescription = [cardDescriptions objectAtIndex:i];
			
			[defaultDeck addCardsObject:defaultDeckCard];
		}
		
		NSError *coreDataError = nil;
		if(![moc save: &coreDataError]) {
			NSLog(@"Unresolved error %@, %@", coreDataError, [coreDataError userInfo]);
			//		abort();
		}
	}
}

/**
 *  Creates a full deck with 104 cards
 *  @return NSMutableArray containing the full deck
 *  @author Roger Oba
 */
- (NSMutableArray*) fullDeck{
	NSMutableArray *fullDeck = [[NSMutableArray alloc] init];
	
	/* If it's the default deck, simply create 13 * 4 = 52 cards */
	if ([self.deck.isEditable isEqualToNumber:[NSNumber numberWithBool:NO]]) {
		for (Card *card in self.deck.cards) {
			for (int i = 0; i < 4; i++) {
				[fullDeck addObject:card];
			}
		}
	}
	/* Else if it's a custom deck, create cards accordingly with the suit */
	else {
		for (Card *card in self.deck.cards) {
			Card *c_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
			c_tempCard.cardRule = card.cardRule;
			c_tempCard.cardDescription = card.cardDescription;
			c_tempCard.cardName = [NSString stringWithFormat:@"%@C",[card.cardName substringToIndex:3]];
			[fullDeck addObject:c_tempCard];
			
			Card *d_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
			d_tempCard.cardRule = card.cardRule;
			d_tempCard.cardDescription = card.cardDescription;
			d_tempCard.cardName = [NSString stringWithFormat:@"%@D",[card.cardName substringToIndex:3]];
			[fullDeck addObject:d_tempCard];
			
			Card *h_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
			h_tempCard.cardRule = card.cardRule;
			h_tempCard.cardDescription = card.cardDescription;
			h_tempCard.cardName = [NSString stringWithFormat:@"%@H",[card.cardName substringToIndex:3]];
			[fullDeck addObject:h_tempCard];
			
			Card *s_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
			s_tempCard.cardRule = card.cardRule;
			s_tempCard.cardDescription = card.cardDescription;
			s_tempCard.cardName = [NSString stringWithFormat:@"%@S",[card.cardName substringToIndex:3]];
			[fullDeck addObject:s_tempCard];
		}
	}
	return fullDeck;
}

#pragma mark - Style

/**
 *  Layouts the buttons accordingly, setting corners and borders.
 *  @author Roger Oba
 */
- (void) setupViewsLayout {
	self.drawCardButton.layer.cornerRadius = 10;
	self.drawCardButton.clipsToBounds = YES;
	self.drawCardButton.layer.borderColor = [UIColor whiteColor].CGColor;
	self.drawCardButton.layer.borderWidth = 1.0f;
	
	self.shuffleDeckButton.layer.cornerRadius = 10;
	self.shuffleDeckButton.clipsToBounds = YES;
	self.shuffleDeckButton.layer.borderColor = [UIColor whiteColor].CGColor;
	self.shuffleDeckButton.layer.borderWidth = 1.0f;
	
	[self.ruleButton setTitle:@"" forState:UIControlStateNormal];
	[self.ruleButton setTitle:@"" forState:UIControlStateSelected];
	[self.ruleButton setTitle:@"" forState:UIControlStateHighlighted];
	[self.ruleButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
	[self.ruleButton.titleLabel setNumberOfLines: 2];
	
	self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
	self.tabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
	
	[self addShadowToLayer:self.ruleButton.layer];
	
	if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
		[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
	}
	else {
		[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
	}
}

#pragma mark - Sound FX

/**
 *  Sorts a random card slide sound effect and plays it.
 *  @author Roger Oba
 */
- (void) playRandomCardSlideSoundFX {
	
	/* Stops whatever sound that might be playing */
	AudioServicesDisposeSystemSoundID(self.cardShuffle);
	AudioServicesDisposeSystemSoundID(self.cardSlide);
	
	/* Randomly sorts a cardSlide sound */
	NSUInteger randomIndex = arc4random() % 8;
	
	/* Plays Card Slide Sound FX */
	NSString *cardSlidePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"cardSlide%ld",(unsigned long)randomIndex] ofType:@"wav"];
	NSURL *cardSlideURL = [NSURL fileURLWithPath:cardSlidePath];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)cardSlideURL, &_cardSlide);
	AudioServicesPlaySystemSound(self.cardSlide);
}

/**
 *  Plays the card shuffle sound effect.
 *  @author Roger Oba
 */
- (void) playShuffleSoundFX {
	
	/* Stops whatever sound that might be playing */
	AudioServicesDisposeSystemSoundID(self.cardShuffle);
	AudioServicesDisposeSystemSoundID(self.cardSlide);
	
	/* Plays Card Shuffle Sound FX */
	NSString *cardShufflePath = [[NSBundle mainBundle] pathForResource:@"cardShuffle" ofType:@"wav"];
	NSURL *cardShuffleURL = [NSURL fileURLWithPath:cardShufflePath];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)cardShuffleURL, &_cardShuffle);
	AudioServicesPlaySystemSound(self.cardShuffle);
}

#pragma mark - Shadowing Method

/**
 *  Adds a shadow to the given layer.
 *
 *  Shadow is black, with 90% of opacity and radius of 10.0f.
 *
 *  @param layer that will have the shadow added on.
 *  @author Roger Oba
 *
 */

- (void) addShadowToLayer: (CALayer*) layer {
	layer.shadowColor = [UIColor blackColor].CGColor;
	layer.shadowOpacity = 0.9f;
	layer.shadowRadius = 10.0f;
	layer.shadowOffset = CGSizeZero;
	layer.masksToBounds = NO;
}

#pragma mark - CustomIOS7dialogButton Delegate Method

- (void) customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *sharingString = [NSString stringWithFormat: NSLocalizedString(@"Everyone's drinking shots on Sueca Drinking Game. Come over to have some fun! #sueca", @"Activity View Sharing String")];
	
	UIImage *sharingImage = nil;
	
	if ([self.displayCard.deck.isEditable isEqualToNumber:@NO]) {
		sharingImage = [UIImage imageNamed:self.displayCard.cardName];
	}
	else {
		sharingImage = [UIImage imageNamed:@"sharingSuecaLogoImage"];
	}

	NSURL *sharingURL = [NSURL URLWithString:@"bit.ly/1JwDmry"];
	
	NSString *fullSharingString = [NSString stringWithFormat:@"%@ %@",sharingString,sharingURL];
	
	WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:fullSharingString forABID:nil];
	
	UIActivityViewController *activityViewController =
	[[UIActivityViewController alloc] initWithActivityItems:@[fullSharingString,sharingImage,sharingURL,whatsappMsg]
									  applicationActivities:@[[[JBWhatsAppActivity alloc] init]]];
	
	activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
													 UIActivityTypeCopyToPasteboard,
													 UIActivityTypeAssignToContact,
													 UIActivityTypeSaveToCameraRoll,
													 UIActivityTypeAddToReadingList,
													 UIActivityTypePostToFlickr,
													 UIActivityTypePostToVimeo,
													 UIActivityTypeAirDrop];
	[alertView close];
	[self presentViewController:activityViewController animated:YES completion:^{}];
}


#pragma mark - iVersion Delegate Methods

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails {
	NSLog(@"New version detected!");
	[TSMessage showNotificationInViewController:self.tabBarController
										  title:NSLocalizedString(@"Update Available",@"Update available warning title")
									   subtitle:NSLocalizedString(@"You're using an outdated version of Sueca. Update to have the most awesome new features!", @"Update available warning subtitle")
										  image:nil
										   type:TSMessageNotificationTypeWarning
									   duration:TSMessageNotificationDurationEndless
									   callback:nil
									buttonTitle:NSLocalizedString(@"Update", @"Update app button")
								 buttonCallback:^{
									 [PFAnalytics trackEventInBackground:@"updatedViaNotificationButton" dimensions:nil block:^(BOOL succeeded, NSError *error) {
										 if (!error) {
											 NSLog(@"Successfully logged the 'updatedViaNotificationButton' event");
										 }
									 }];
									 
									 [[iVersion sharedInstance] openAppPageInAppStore];
								 }
									 atPosition:TSMessageNotificationPositionTop
						   canBeDismissedByUser:YES];
}

- (void)iVersionDidNotDetectNewVersion {
	NSLog(@"No new version. Your app is up to date.");
}

#pragma mark - iRate Delegate

- (void) iRateUserDidAttemptToRateApp {
	[PFAnalytics trackEventInBackground:@"iRateUserDidAttemptToRateApp" dimensions:nil block:^(BOOL succeeded, NSError *error) {
		if (!error) {
			NSLog(@"Successfully logged the 'iRateUserDidAttemptToRateApp' event");
		}
	}];
}

- (void) iRateUserDidDeclineToRateApp {
	[PFAnalytics trackEventInBackground:@"iRateUserDidDeclineToRateApp" dimensions:nil block:^(BOOL succeeded, NSError *error) {
		if (!error) {
			NSLog(@"Successfully logged the 'iRateUserDidDeclineToRateApp' event");
		}
	}];
}

- (void) iRateUserDidRequestReminderToRateApp {
	[PFAnalytics trackEventInBackground:@"iRateUserDidRequestReminderToRateApp" dimensions:nil block:^(BOOL succeeded, NSError *error) {
		if (!error) {
			NSLog(@"Successfully logged the 'iRateUserDidRequestReminderToRateApp' event");
		}
	}];
}

- (void)iRateDidOpenAppStore {
	[PFAnalytics trackEventInBackground:@"iRateDidOpenAppStore" dimensions:nil block:^(BOOL succeeded, NSError *error) {
		if (!error) {
			NSLog(@"Successfully logged the 'iRateDidOpenAppStore' event");
		}
	}];
}

#pragma mark - Randomizing Methods

- (NSString*) randomWelcomeBackMessage {
	
	NSArray *welcomeBackMessages = @[NSLocalizedString(@"Enjoy!", @"Welcome Back Message 1"),
									 NSLocalizedString(@"If you were expecting a signal to do something, this is it. Do it!", @"Welcome Back Message 2"),
									 NSLocalizedString(@"Do not drink if you're going to drive! #ConsciousDrinking", @"Welcome Back Message 3"),
									 NSLocalizedString(@"The more people, the better! Call everyone around to join the game!", @"Welcome Back Message 4"),
									 NSLocalizedString(@"If you like these messages, express yourself in an App Store review! 😇", @"Welcome Back Message 5"),
									 NSLocalizedString(@"Something missing in the app? Share your thoughts! 😇", @"Welcome Back Message 6"),
									 NSLocalizedString(@"Did you know the app has cool sound effects around?", @"Welcome Back Message 7"),
									 NSLocalizedString(@"Because an epic story doesn't start with 'Certain day I was eating a salad and…' ;)", @"Welcome Back Message 8"),
									 NSLocalizedString(@"Beer, vodka, tequilla, whiskey… It doesn't matter, just enjoy the game!", @"Welcome Back Message 9"),
									 NSLocalizedString(@"I wonder if anyone even read these texts…", @"Welcome Back Message 10")];
	
	
	return [welcomeBackMessages objectAtIndex:arc4random() % [welcomeBackMessages count]];
}

- (BOOL) doesString:(NSString *)string containCharacter:(char)character {
	if ([string rangeOfString:[NSString stringWithFormat:@"%c",character]].location != NSNotFound) {
		return YES;
	}
	return NO;
}





#pragma mark - Core Data

/**
 *  Default method to init self.moc
 */
- (NSManagedObjectContext *) managedObjectContext {
	NSManagedObjectContext *context = nil;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		context = [delegate managedObjectContext];
	}
	return context;
}

@end
