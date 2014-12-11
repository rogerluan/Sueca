//
//  JogoViewController.m
//  Sueca
//
//  Created by Bruno Pedroso on 25/10/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import "JogoViewController.h"

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

@interface JogoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *botaoSortear;
@property (weak, nonatomic) IBOutlet UILabel *rule;
@property (strong, nonatomic) IBOutlet UIView *cardContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *gameLogo;

@property (strong,nonatomic) NSManagedObjectContext *moc;

@property (strong,nonatomic) NSMutableArray *deckArray;
@property (strong,nonatomic) Deck *deck;
@property (strong,nonatomic) Card *displayCard;

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
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self createDefaultDeck];
	}
	
	
	//TODO: load the deck being used
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
	[self sortCard];
}

- (IBAction)reembaralhar:(id)sender {
    [self shuffle];
}

- (void) sortCard {
	/* If there're no more cards in the deck, it reshuffles and warns the user */
	if([self.deckArray count] == 0) {
		[self shuffle];
		return;
	}
	
    /* Randomly picks a card from the deck */
	NSUInteger randomIndex = arc4random() % [self.deckArray count];
	self.displayCard = [self.deckArray objectAtIndex:randomIndex];
	[self.deckArray removeObjectAtIndex: randomIndex];
	
	
	/* Declaração, inicialização e execução das animações */
    int containerWidth = self.cardContainerView.frame.size.width;
    int containerHeight = self.cardContainerView.frame.size.height;
    int indexX = arc4random()%(containerWidth-119);
    int indexY = arc4random()%(containerHeight-177);
	
    CGRect newFrame = CGRectMake(indexX,indexY,119,177);
    UIImageView *imagemcard = [[UIImageView alloc]initWithImage:[UIImage imageNamed: [NSString stringWithFormat: @"%@",self.displayCard.cardName]]];
    imagemcard.layer.anchorPoint = CGPointMake(0.5,0.5);
//    CGAffineTransform newTransform;
//    CGAffineTransformRotate(newTransform, 2*M_PI);
    CGAffineTransform transform = CGAffineTransformMakeRotation(2*M_PI);
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
//						 imagemcard.transform = newTransform;
						 imagemcard.transform = transform;
                         imagemcard.frame = newFrame;
                     }
                     completion: nil];
	
	for (UIImageView *view in [self.cardContainerView subviews]) {
		if (![view isEqual:self.gameLogo] ) {
			view.alpha/=1.2;
		}
	}
    [self.cardContainerView addSubview:imagemcard];
	
	/* Shows the rule on screen */
    self.rule.text = self.displayCard.cardRule;
}

/**
 *  Remove all cards on the screen.
 *  @author Roger Oba
 */
- (void) limparMesa {
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
	[self limparMesa];
	
	/* Reinicialização do baralho (para voltar ao original) */
	[self.deckArray removeAllObjects];
	self.deckArray = [self fullDeck];
	
	/* Warns the user that the deck was reshuffled */
	UIAlertView *alertaParaReembaralhar = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Baralho reembaralhado", nil) message: NSLocalizedString(@"Todas as cartas já tiradas foram inseridas novamente no baralho e reembaralhadas.", nil) delegate: nil cancelButtonTitle: nil otherButtonTitles: NSLocalizedString(@"OK", nil), nil];
	[alertaParaReembaralhar show];
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
    if (motion == UIEventSubtypeMotionShake)
        [self sortCard];
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
 *  @return nothing
 *  @author Roger Oba
 */
- (void) createDefaultDeck {
	
	self.moc = [self managedObjectContext];
	
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
	
	NSArray *cardDescriptions = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Quem tirar essa carta escolhe 1 pessoa para beber.", nil),
						  NSLocalizedString(@"Quem tirar essa carta escolhe 2 pessoas para beber.", nil),
						  NSLocalizedString(@"Quem tirar essa carta escolhe 3 pessoas para beber.", nil),
						  NSLocalizedString(@"Quem tirou essa carta deve escolher uma letra e um tema para o Stop. Então, na sequência da roda de amigos, cada um tem que falar uma palavra que comece com a letra escolhida, relacionada ao tema. Não vale repetir palavra! O primeiro que não souber, ou repetir palavra, bebe!", nil),
						  NSLocalizedString(@"Quem tirou a carta fala uma palavra qualquer. O próximo tem que repetir a sequência de palavras anterior e adicionar uma. E assim por diante. Exemplo: Quem tirou a carta fala “mesa”. O próximo fala “mesa cachorro”. O próximo diz “mesa cachorro lápis”, e assim por diante. O primeiro que errar ou demorar, bebe.", nil),
						  NSLocalizedString(@"Quem tirar essa carta, “guarda” ela mentalmente consigo. Discretamente no meio do jogo, essa pessoa deve colocar a mão na testa, fazendo continência e observar os outros jogadores. O último que perceber e fizer continência, bebe.", nil),
						  NSLocalizedString(@"Começando pela pessoa que tirar a carta, esta deve escolher um número. Assim, todos devem seguir uma sequência começando em 1, e quando o número da sequência for múltiplo do número escolhido, a pessoa deve falar “Pi”. Por exemplo: foi escolhido o número 3, então: 1, 2, pi, 4, 5, pi, 7, 8, pi, etc. O primeiro que errar, bebe!", nil),
						  NSLocalizedString(@"Quem tira essa carta determina uma regra para todos obedecerem. Pode ser algo do tipo “está proíbido falar a palavra ‘beber’ e seus derivados”, ou “antes de beber uma dose, a pessoa tem que rebolar”. Quem quebrar a regra, deve beber (às vezes, de novo). A Regra Geral pode ser substituída por outra Regra Geral, caso contrário, dura o jogo todo.", nil),
						  NSLocalizedString(@"A pessoa que tirar essa carta pode transformá-la em qualquer outra!", nil),
						  NSLocalizedString(@"Como teoricamente ninguém pode sair para ir ao banheiro enquanto estiver jogando, esta carta dá o direito à quem a tirou de ir ao banheiro. A carta só vale 1 vez. Ela pode guardar para ir mais tarde, ou “vender” à alguém, em troca de “favores” 😉", nil),
						  NSLocalizedString(@"Todos que estiverem jogando bebem uma dose, inclusive quem tirou a carta!", nil),
						  NSLocalizedString(@"Todas as damas bebem uma dose.", nil),
						  NSLocalizedString(@"Todos os cavalheiros bebem uma dose.", nil), nil];
	
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

#pragma mark - Core Data

- (NSManagedObjectContext *) managedObjectContext {
	NSManagedObjectContext *context = nil;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		context = [delegate managedObjectContext];
	}
	return context;
}

@end
