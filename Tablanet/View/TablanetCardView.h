//
//  CardView.h
//  Tablanet
//
//  Created by Valdrin on 16/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TablanetCard.h"
#define kCardWidth 70
#define kCardHeight 95

@interface TablanetCardView : UIView{
    TablanetCard *card;
    UILabel *cardValue;
    UILabel *cardValueBottom;
    BOOL isSelected;
    CGFloat rotation;
    CATransformLayer *cardBG;
}

@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic) BOOL isSelected;
@property(nonatomic,retain) TablanetCard *card;
@property(nonatomic,readonly) CATransform3D identity;

-(void)animateLayerProperty:(NSString*)property toValue:(id)value withDuration:(CGFloat)duration;
@end
