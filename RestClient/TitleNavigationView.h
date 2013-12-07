//
//  TitleNavigationView.h
//  RestClient
//
//  Created by Axel Rivera on 12/7/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTitleNavigationViewRow1Height 18.0
#define kTitleNavigationViewRow2Height 16.0

@interface TitleNavigationView : UIView

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *detailTextLabel;

@end
