//
//  TablanetButton.m
//  Tablanet
//
//  Created by Valdrin on 19/06/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "TablanetButton.h"

@implementation TablanetButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        self.titleLabel.shadowColor = [UIColor blackColor];
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpOutside];
        [self touchUp];
    }
    return self;
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self touchUp];
}
-(void)touchDown{
    self.backgroundColor = [UIColor darkGrayColor];
}
-(void)touchUp{
    self.backgroundColor = self.selected ? [UIColor darkGrayColor] : [UIColor grayColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
