//
//  JogoViewController.m
//  Sueca
//
//  Created by Bruno Pedroso on 25/10/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import "JogoViewController.h"

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
	
	[self preferredContentSize];
	
	/* Creates default deck only once */
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]) {
		NSLog(@"firsttime: %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]);
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeRunning"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self createDefaultDeck];
	}
	
	
	//TODO: load the deck being used
	/* Inits the default deck */
	self.deck = [self setDefaultDeck];
	if (self.deck) {
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
	for (Card *card in self.deck.cards) {
		[self.deckArray addObject:card];
	}
	
	/* Alerta o usuário que o baralho foi reembaralhado (reinicializado) */
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
 *  Method to init the deck with the default rules.
 *  @return Deck containing the default cards and rules, or nil if some error occurs.
 *  @author Roger Oba
 */
- (Deck*) setDefaultDeck {
	self.moc = [self managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:self.moc];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deckName == %@",NSLocalizedString(@"Default", nil)];
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
	
	NSArray *cardImages = [[NSArray alloc] initWithObjects: @"Um",@"Dois",@"Tres",@"Quatro",@"Cinco",@"Seis",@"Sete",@"Oito",@"Nove",@"Dez",@"Valete",@"Dama",@"Rei", nil];
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	Deck *defaultDeck = [NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:moc];
	defaultDeck.deckName = NSLocalizedString(@"Default", nil);
	defaultDeck.isEditable = [NSNumber numberWithBool:NO];
	
	for (int i = 0 ; i<13 ; i++) {
		Card *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:moc];
		newCard.cardName = [cardImages objectAtIndex:i];
		newCard.cardRule = [cardRules objectAtIndex:i];
//		newCard.cardDescription = [cardDescriptions objectAtIndex:i];
		
		[defaultDeck addCardsObject:newCard];
	}
	
	NSError *coreDataError = nil;
	if(![moc save: &coreDataError]) {
		NSLog(@"Unresolved error %@, %@", coreDataError, [coreDataError userInfo]);
		//TODO: remove all aborts();
		abort();
	}
}

#pragma mark - Style

/**
 *  Layouts the buttons accordingly, setting corners and borders.
 *  @author Roger Oba
 */
- (void) setupViewsLayout {
	self.botaoSortear.layer.cornerRadius = 10;
	self.botaoSortear.clipsToBounds = YES;
	self.botaoSortear.layer.borderColor=[UIColor whiteColor].CGColor;
	self.botaoSortear.layer.borderWidth=2.0f;
	
	self.resetButton.layer.cornerRadius = 10;
	self.resetButton.clipsToBounds = YES;
	self.resetButton.layer.borderColor=[UIColor whiteColor].CGColor;
	self.resetButton.layer.borderWidth=2.0f;
	
	self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
	self.tabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
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
