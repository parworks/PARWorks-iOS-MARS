//
//  PVIntroExampleView.m
//  PARViewer
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "PVAppDelegate.h"
#import "PVIntroExampleView.h"

@implementation PVIntroExampleView

+ (id)viewFromNIB
{
    NSString *nibName = @"PVIntroExampleView";
    if ([PVAppDelegate isiPhone5]) {
        nibName = [nibName stringByAppendingString:@"_4"];
    }
    
    PVIntroExampleView *ev = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:0];
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
    [self addTarget:self action:@selector(fireAugmentation) forControlEvents:UIControlEventTouchUpInside];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowRadius = 3.0;
}

- (void)fireAugmentation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"augmentButtonTapped" object:_siteName];
}

- (void)touchDown
{
    [UIView animateWithDuration:0.1 animations:^{
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
