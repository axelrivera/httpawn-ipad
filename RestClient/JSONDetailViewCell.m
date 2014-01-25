//
//  JSONDetailViewCell.m
//  RestClient
//
//  Created by Axel Rivera on 1/25/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "JSONDetailViewCell.h"

#import <UIView+AutoLayout.h>

@implementation JSONDetailViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;

        self.accessoryType = UITableViewCellAccessoryNone;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];

        _supportLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _supportLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _supportLabel.font = [UIFont systemFontOfSize:14.0];
        _supportLabel.backgroundColor = [UIColor clearColor];
        _supportLabel.textColor = [UIColor blackColor];
        _supportLabel.highlightedTextColor = [UIColor whiteColor];
        _supportLabel.textAlignment = NSTextAlignmentRight;

        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _descriptionLabel.font = [UIFont systemFontOfSize:14.0];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.textColor = [UIColor lightGrayColor];
        _descriptionLabel.highlightedTextColor = [UIColor whiteColor];

        _button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        _button.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_supportLabel];
        [self.contentView addSubview:_descriptionLabel];
        [self.contentView addSubview:_button];
    }
    return self;
}

- (void)updateConstraints
{
    [self.titleLabel autoSetDimension:ALDimensionHeight toSize:kJSONDetailViewCellRow1Height];
    [self.supportLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:_titleLabel];
    [self.descriptionLabel autoSetDimension:ALDimensionHeight toSize:kJSONDetailViewCellRow2Height];

    [self.button autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kJSONDetailViewCellPaddingRight];
    [self.button autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kJSONDetailViewCellPaddingTop];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kJSONDetailViewCellPaddingLeft];

    [self.supportLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
    [self.supportLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.button withOffset:-10.0];

    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.supportLabel withOffset:-5.0];


    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kJSONDetailViewCellPaddingBottom];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kJSONDetailViewCellPaddingLeft];
    [self.descriptionLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.button withOffset:-10.0];

    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight
{
    return (kJSONDetailViewCellPaddingTop +
            kJSONDetailViewCellPaddingBottom +
            kJSONDetailViewCellPaddingVertical +
            kJSONDetailViewCellRow1Height +
            kJSONDetailViewCellRow2Height);
}

@end
