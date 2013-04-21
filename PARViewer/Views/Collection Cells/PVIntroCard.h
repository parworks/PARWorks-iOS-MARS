//
//  PVIntroCard.h
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

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "PVIntroExampleView.h"

typedef enum {
    PVIntroCardStyle_1,
    PVIntroCardStyle_2,
    PVIntroCardStyle_3,
    PVIntroCardStyle_4
} PVIntroCardStyle;

@interface PVIntroCard : PSUICollectionViewCell
{
    BOOL _isiPhone5;
}
@property(nonatomic, strong) UIView *outerCard;
@property(nonatomic, strong) UIView *innerCard;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIButton *skipButton;
@property(nonatomic, strong) UIImageView *swipeImageView;
@property(nonatomic, strong) PVIntroExampleView *topExampleView;
@property(nonatomic, strong) PVIntroExampleView *bottomExampleView;
@property(nonatomic, assign) PVIntroCardStyle cardStyle;

@end