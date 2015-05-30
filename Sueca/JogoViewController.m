//
//  JogoViewController.m
//  Sueca
//
//  Created by Bruno Pedroso on 25/10/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import "JogoViewController.h"
@import AVFoundation;
#import <Parse/Parse.h>

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

@interface JogoViewController () <UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *botaoSortear;
@property (weak, nonatomic) IBOutlet UILabel *rule;
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

@implementation JogoViewController

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
	self.rule.text = nil;
	
	[self setupViewsLayout];
	
//	[self preferredContentSize];
	
	/* Creates default deck only once */
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]) {
		NSLog(@"firsttime: %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]);
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeRunning"];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"DeckNumber"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showAlert"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self createDefaultDeck];
	}
	
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
		abort();
	}
}

- (void) handleCardFlick: (UIGestureRecognizer *)recognizer {
	if ([recognizer state] == UIGestureRecognizerStateBegan) {
		NSLog(@"Flick Gesture detected: %@",recognizer.description);
		
//		self.previousCard.layer.shadowColor = [UIColor blackColor].CGColor;
//		self.previousCard.layer.shadowOpacity = 0.75;
//		self.previousCard.layer.shadowRadius = 15.0;
//		self.previousCard.layer.shadowOffset = (CGSize){0.0,20.0};
		
		float previousY = self.previousCard.transform.d;
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^(void) {
//							 self.previousCard.transform = CGAffineTransformMakeScale(1, -self.previousCard.transform.d);
							 self.previousCard.transform = CGAffineTransformMakeScale(1, 0.0000000001);
						 }
						 completion:^(BOOL completion) {
							 
							 //create custom view here with the card description, and flip it over, bigger.
							 self.previousCard.image = [UIImage imageNamed:@"descriptionCardBackground"];
							 
								[UIView animateWithDuration:0.5
													  delay:0.0
													options:UIViewAnimationOptionCurveEaseIn
												 animations:^(void) {
													 self.previousCard.transform = CGAffineTransformMakeScale(1, -previousY);
												 }
												 completion:^(BOOL completion) {
													 
												 }
								 ];
//							 self.previousCard.layer.shadowColor = [UIColor clearColor].CGColor;
//							 self.previousCard.layer.shadowOpacity = 0.0;
//							 self.previousCard.layer.shadowRadius = 0.0;
//							 self.previousCard.layer.shadowOffset = (CGSize){0.0, 0.0};
						 }];
	}
}

- (void) handleCardTap: (UITapGestureRecognizer*) recognizer {
	if ([recognizer state] == UIGestureRecognizerStateRecognized) {
		NSLog(@"Tap Gesture detected: %@",recognizer.description);
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
		abort();
	}
}

- (IBAction)sortCard:(id)sender {
	[[iRate sharedInstance] logEvent:NO];
	[self sortCard];
}

- (IBAction)shuffleButton:(id)sender {
	[[iRate sharedInstance] logEvent:NO];
	
	
	NSDictionary *dimensions = @{@"ShuffleDeckButtonPress": @"shuffled"};
	
	[PFAnalytics trackEventInBackground:@"ShuffleDeckButtonPress" dimensions:dimensions block:^(BOOL succeeded, NSError *error) {
		if (!error) {
			NSLog(@"Successfully sent the screenView Log");
		}
		else {
			[[[UIAlertView alloc] initWithTitle:@"Error" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
		}
	}];
	
	[self playShuffleSoundFX];
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
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showAlert"]) {
			UIAlertView *shuffleAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Baralho reembaralhado", nil) message: NSLocalizedString(@"Todas as cartas já tiradas foram inseridas novamente no baralho e reembaralhadas.", nil) delegate: nil cancelButtonTitle: nil otherButtonTitles: NSLocalizedString(@"Never Show Again",nil),NSLocalizedString(@"OK", nil), nil];
			shuffleAlert.delegate = self;
			[self playShuffleSoundFX];
			[shuffleAlert show];
		}
		else {
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
    UIImageView *cardImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed: [NSString stringWithFormat: @"%@",self.displayCard.cardName]]];
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
	
	UITapGestureRecognizer *cardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCardTap:)];
	UIPanGestureRecognizer *cardFlick = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCardFlick:)];
	
	[cardImage addGestureRecognizer:cardFlick];
	[cardImage addGestureRecognizer:cardTap];
	cardImage.userInteractionEnabled = YES;
	
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
	}
	
    [self.cardContainerView addSubview:cardImage];
	
	/* Shows the rule on screen */
    self.rule.text = self.displayCard.cardRule;
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
    self.rule.text = @"";
}

/**
 *  Method that do all the stuff related with the shuffling
 *  @author Roger Oba
 */
- (void) shuffle {
	[self clearTable];
	
	/* Reinicialização do baralho (para voltar ao original) */
	[self.deckArray removeAllObjects];
	self.deckArray = [self fullDeck];
}

/**
 *  This delegate call enables device motion delegate.
 */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Motion Delegate Methods

/**
 *  Sorts a new card when it detecs a motion (shake)
 */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake) {
		[[iRate sharedInstance] logEvent:NO];
        [self sortCard];
	}
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
	NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil || ([fetchedObjects count] == 0)) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//TODO: remove all aborts();
		abort();
	}
	else {
		return [fetchedObjects firstObject];
	}
}

/**
 *  Method to initialize the default deck on the app first run.
 *  This will only be runned once.
 *  @author Roger Oba
 */
- (void) createDefaultDeck {
	
	self.moc = [self managedObjectContext];
	
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
		//TODO: remove all aborts();
		abort();
	}
}

/**
 *  Creates a full deck with 104 cards
 *  @return NSMutableArray containing the full deck
 *  @author Roger Oba
 */
- (NSMutableArray*) fullDeck{
	NSMutableArray *fullDeck = [[NSMutableArray alloc] init];
	
	/* If it's the default deck, simply create 13 * 8 = 104 cards */
	if ([self.deck.isEditable isEqualToNumber:[NSNumber numberWithBool:NO]]) {
		for (Card *card in self.deck.cards) {
			for (int i = 0; i < 8; i++) {
				[fullDeck addObject:card];
			}
		}
	}
	/* Else if it's a custom deck, create cards accordingly with the suit */
	else {
		for (Card *card in self.deck.cards) {
			for (int i = 0; i < 2; i++) {
				[fullDeck addObject:card];
				
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
	}
	
	return fullDeck;
}

#pragma mark - Style

/**
 *  Layouts the buttons accordingly, setting corners and borders.
 *  @author Roger Oba
 */
- (void) setupViewsLayout {
	self.botaoSortear.layer.cornerRadius = 10;
	self.botaoSortear.clipsToBounds = YES;
	self.botaoSortear.layer.borderColor = [UIColor whiteColor].CGColor;
	self.botaoSortear.layer.borderWidth = 1.0f;
	
	self.resetButton.layer.cornerRadius = 10;
	self.resetButton.clipsToBounds = YES;
	self.resetButton.layer.borderColor = [UIColor whiteColor].CGColor;
	self.resetButton.layer.borderWidth = 1.0f;
	
	self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
	self.tabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
	
	if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
		[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
	}
	else {
		[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
	}
}

#pragma mark - UIAlertViewDelegate

/**
 *  This method will be called when the user presses the OK button on AlertView.
 */
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showAlert"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self shuffle];
	}
	else {
		[self shuffle];
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
