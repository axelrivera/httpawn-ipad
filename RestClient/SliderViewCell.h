//
//  SliderViewCell.h
//  RestClient
//
//  Created by Axel Rivera on 12/7/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSliderCellPaddingTop 10.0
#define kSliderCellPaddingBottom 10.0
#define kSliderCellPaddingLeft 15.0
#define kSliderCellPaddingRight 15.0

#define kSliderCellRow1Height 18.0
#define kSliderCellRow3Height 18.0

#define kSecondSliderFactor 1000.0

@interface SliderViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *minLabel;
@property (strong, nonatomic) UILabel *maxLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
