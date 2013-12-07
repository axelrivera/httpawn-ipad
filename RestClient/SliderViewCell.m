//
//  SliderViewCell.m
//  RestClient
//
//  Created by Axel Rivera on 12/7/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "SliderViewCell.h"

#import <UIView+AutoLayout.h>

#define kSliderViewTag 100

@implementation SliderViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = YES;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;

        [self.contentView addSubview:_titleLabel];

        _slider = nil;

        _minLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _minLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _minLabel.backgroundColor = [UIColor clearColor];
        _minLabel.font = [UIFont systemFontOfSize:14.0];
        _minLabel.textColor = [UIColor lightGrayColor];
        _minLabel.textAlignment = NSTextAlignmentLeft;

        [self.contentView addSubview:_minLabel];

        _maxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _maxLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _maxLabel.backgroundColor = [UIColor clearColor];
        _maxLabel.font = [UIFont systemFontOfSize:14.0];
        _maxLabel.textColor = [UIColor lightGrayColor];
        _maxLabel.textAlignment = NSTextAlignmentRight;

        [self.contentView addSubview:_maxLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.titleLabel autoSetDimension:ALDimensionHeight toSize:kSliderCellRow1Height];

    [self.minLabel autoSetDimension:ALDimensionWidth toSize:60.0];
    [self.minLabel autoSetDimension:ALDimensionHeight toSize:kSliderCellRow3Height];

    [self.maxLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.minLabel];
    [self.maxLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.minLabel];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kSliderCellPaddingTop];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kSliderCellPaddingLeft];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kSliderCellPaddingRight];

    [self.slider autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kSliderCellPaddingLeft];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kSliderCellPaddingRight];

    [self.minLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kSliderCellPaddingBottom];
    [self.minLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kSliderCellPaddingLeft];

    [self.maxLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kSliderCellPaddingBottom];
    [self.maxLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kSliderCellPaddingRight];

    [super updateConstraints];
}

- (void)setSlider:(UISlider *)slider
{
    UIView *view = [self.contentView viewWithTag:kSliderViewTag];
    if (view) {
        [view removeFromSuperview];
    }

    _slider = slider;
    _slider.tag = kSliderViewTag;
    _slider.translatesAutoresizingMaskIntoConstraints = NO;
    [_slider addTarget:self action:@selector(updateSeconds:) forControlEvents:UIControlEventValueChanged];
    [self updateSeconds:_slider];

    [self.contentView addSubview:_slider];
    [self setNeedsUpdateConstraints];
}

- (void)updateSeconds:(UISlider *)slider
{
    NSInteger value = (int)(slider.value * kSecondSliderFactor);
    NSString *valueStr = [NSString stringWithFormat:@"%@ s", [[NSNumber numberWithInteger:value] stringValue]];
    NSString *string = [NSString stringWithFormat:@"Timeout Interval  %@", valueStr];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];

    NSRange valueRange = [string rangeOfString:valueStr];
    if (valueRange.location != NSNotFound) {
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:valueRange];
    }
    self.titleLabel.attributedText = attributedStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
