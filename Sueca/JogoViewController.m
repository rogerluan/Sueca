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
	
	/* Modificações do botão de sortear e do imagens de background */
	self.botaoSortear.layer.cornerRadius = 10;
    self.botaoSortear.clipsToBounds = YES;
    self.botaoSortear.layer.borderColor=[UIColor whiteColor].CGColor;
    self.botaoSortear.layer.borderWidth=2.0f;

	self.resetButton.layer.cornerRadius = 10;
    self.resetButton.clipsToBounds = YES;
    self.resetButton.layer.borderColor=[UIColor whiteColor].CGColor;
    self.resetButton.layer.borderWidth=2.0f;
	
	
    self.cardContainerView.backgroundColor = [UIColor clearColor];
	self.rule.text = nil;
	
	self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
	self.tabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
	
	[self preferredContentSize];
	
	/* Inicialização das regras Padrões */
	self.rulesPadrao = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Escolhe 1 pessoa para beber", nil),
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
	
	/* Inicialização do baralho */
    self.deck = [[Deck alloc] initWithRule: self.rulesPadrao];
	
}

- (IBAction)sortCard:(id)sender {
	[self sortCard];
}

- (IBAction)reembaralhar:(id)sender {
    [self limparMesa];
	
	/* Reinicialização do baralho (para voltar ao original) */
    self.deck = [[Deck alloc] initWithRule: self.rulesPadrao];
	
	/* Alerta o usuário que o baralho foi reembaralhad (reinicializado) */
    UIAlertView *alertaParaReembaralhar = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Baralho reembaralhado", nil) message: NSLocalizedString(@"Todas as cartas já tiradas foram inseridas novamente no baralho e reembaralhadas.", nil) delegate: nil cancelButtonTitle: nil otherButtonTitles: NSLocalizedString(@"OK", nil), nil];
    [alertaParaReembaralhar show];
}

- (void) sortCard {
    /* Sorteia uma card do deck */
    self.cardDaVez = [self.deck sortCard];
	
	/* Declaração, inicialização e execução das animações */
    int containerWidth = self.cardContainerView.frame.size.width;
    int containerHeight = self.cardContainerView.frame.size.height;
    int indexX = arc4random()%(containerWidth-119);
    int indexY = arc4random()%(containerHeight-177);
	
    CGRect newFrame = CGRectMake(indexX,indexY,119,177);
    UIImageView *imagemcard = [[UIImageView alloc]initWithImage:[UIImage imageNamed: [NSString stringWithFormat: @"%@",self.cardDaVez.suit]]];
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
	
	/* Mostra na tela a regra da vez */
    self.rule.text = [NSString stringWithFormat: @"%@",self.cardDaVez.rule];
    
	/* Se não existe mais cards no baralho, ele declara um novo (reembaralha), e alerta o usuário do ocorrido */
    if(self.deck.cards.count==0) {
        UIAlertView *alertaParaReembaralhar = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Reembaralhe!", nil) message: NSLocalizedString(@"Não há mais cartas para serem sorteadas. Reembaralhamos o baralho para você.", nil) delegate: nil cancelButtonTitle: nil otherButtonTitles: NSLocalizedString(@"OK", nil), nil];
        [alertaParaReembaralhar show];
		[self limparMesa];
        self.deck = [[Deck alloc] initWithRule: self.rulesPadrao];
    }
}

/**
 * Percorre todas as subviews
 * Se a subview é do tipo UIImageView
 * Remove a view da superView
 */
- (void) limparMesa {
	//to-do: melhorar esse loop, substituindo id por UIImageView
    for (UIImageView *view in [self.cardContainerView subviews]) {
        if (![view isEqual:self.gameLogo] ) {
            [view removeFromSuperview];
		}
	}

	/* Limpa a regra da mesa e chama a viewDidLoad */
    self.rule.text = @"";
}

/* Função para ativar a ViewController para a execução de Motion */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Motion Delegate Methods

/* Sorteia a carta quando detecta que começou uma Motion (shake) */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
        [self sortCard];
}
@end
