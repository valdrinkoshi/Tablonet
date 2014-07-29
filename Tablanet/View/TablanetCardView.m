//
//  CardView.m
//  Tablanet
//
//  Created by Valdrin on 16/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import "TablanetCardView.h"

#define kValueSize 20
#define kBottomValueSize 44

@implementation TablanetCardView
@synthesize card;
@synthesize isSelected;
@dynamic rotation;

@dynamic identity;

-(CATransform3D)identity{
    CATransform3D identity = CATransform3DIdentity;
    identity.m34 = -1.0/1000;
    return identity;
}

-(CGFloat)rotation{
    return rotation;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int m = 5;
        
        
        CGFloat angle = 6*M_PI_2/90.0;
        rotation = angle*(arc4random()%100)/100 - angle/2.0;
        
        
        cardBG = [[CATransformLayer layer] retain];        
        
        CALayer *cardBack  = [CALayer layer];
        cardBack.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cardbg.png"]].CGColor;
        cardBack.cornerRadius = m;
        cardBack.zPosition = -1;
        cardBack.doubleSided = NO;
        
        // Flip cardBack image so it is facing outward and visible when flipped
        cardBack.transform = CATransform3DMakeRotation(M_PI,0,1,0);
        [cardBG addSublayer:cardBack];
        
        CALayer *cardFront  = [CALayer layer];        
        cardFront.backgroundColor = [UIColor whiteColor].CGColor;// [UIColor colorWithPatternImage:[UIImage imageNamed:@"card.png"]].CGColor;
        cardFront.cornerRadius = m;
        cardFront.zPosition = 0; // Put front of card on top relative to back of card
        cardFront.doubleSided = NO;
        [cardBG addSublayer:cardFront];
        
        cardValue = [[UILabel alloc] init];
        cardValue.backgroundColor = [UIColor clearColor];
        cardValue.textAlignment = NSTextAlignmentCenter;
        cardValue.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:kValueSize];
        [cardBG addSublayer:cardValue.layer];
        cardValueBottom = [[UILabel alloc] init];
        cardValueBottom.backgroundColor = [UIColor clearColor];
        cardValueBottom.textAlignment = NSTextAlignmentCenter;
        cardValueBottom.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:kBottomValueSize];
        [cardBG addSublayer:cardValueBottom.layer];
        
        self.layer.cornerRadius = m;
        self.layer.borderColor = [UIColor colorWithWhite:.6 alpha:1].CGColor;
        self.layer.borderWidth = 1;
        self.layer.allowsEdgeAntialiasing = YES;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 3.0;
        self.layer.shadowOpacity = .6;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kCardWidth, kCardHeight) cornerRadius:m];
        self.layer.shadowPath = path.CGPath;
        
            self.layer.shouldRasterize = YES;
        //retina scale
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        [self.layer addSublayer:cardBG];
        self.layer.transform = self.identity;
        self.layer.sublayerTransform = self.identity;
    }
    return self;
}

-(void)setCard:(TablanetCard *)c{
    [card release];
    card = [c retain];
    cardValue.textColor = cardValueBottom.textColor = card.type == TablanetCardTypeHearts || card.type == TablanetCardTypePainting ? [UIColor colorWithRed:180/255.0 green:50/255.0 blue:40/255.0 alpha:1] : [UIColor blackColor];
    cardValue.text = card.formattedValue;
    cardValueBottom.text = card.formattedSymbol;
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    CGRect parentBounds = self.bounds;
    int m = 8;
    for (CALayer *l in cardBG.sublayers) {
        l.frame = parentBounds;
    }
    [cardValue sizeToFit];
    cardValue.layer.frame = CGRectMake(m, m, parentBounds.size.width - m*2, cardValue.bounds.size.height);
    [cardValueBottom sizeToFit];
    cardValueBottom.layer.frame = CGRectMake(m, parentBounds.size.height - kBottomValueSize - m * 1.5, parentBounds.size.width - m*2, cardValueBottom.bounds.size.height);
    cardBG.frame = parentBounds;
}

-(void)animateLayerProperty:(NSString*)property toValue:(id)value withDuration:(CGFloat)duration{
    if (duration>0) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:property];
        anim.fromValue = [self.layer valueForKey:property];
        anim.toValue = value;
        anim.duration = duration;
        [self.layer addAnimation:anim forKey:property];
    }    
    [self.layer setValue:value forKey:property];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)dealloc{
    self.card = nil;
    [cardBG release];
    [cardValue release];
    [cardValueBottom release];
    [super dealloc];
}

@end
