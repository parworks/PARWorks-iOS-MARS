//
//  PVIntroExampleView.m
//  PARViewer
//
//  Created by Demetri Miller on 2/17/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVIntroExampleView.h"

@implementation PVIntroExampleView

+ (id)viewFromNIB
{
    PVIntroExampleView *ev = [[[NSBundle mainBundle] loadNibNamed:@"PVIntroExampleView" owner:nil options:nil] objectAtIndex:0];
    return ev;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    _dimView = [[UIView alloc] initWithFrame:self.bounds];
    _dimView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    _dimView.alpha = 0.0;
    [self addSubview:_dimView];

    [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragInside];
    [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragOutside];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowRadius = 3.0;
}

- (void)touchDown
{
    [UIView animateWithDuration:0.2 animations:^{
        _dimView.alpha = 1.0;
    }];
}

- (void)touchUp
{
    [UIView animateWithDuration:0.2 animations:^{
        _dimView.alpha = 0.0;
    }];
}


@end
