//
//  TitleNavigationView.m
//  RestClient
//
//  Created by Axel Rivera on 12/7/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "TitleNavigationView.h"

#import <UIView+AutoLayout.h>

@implementation TitleNavigationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];

        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

        [self addSubview:_textLabel];

        _detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.backgroundColor = [UIColor clearColor];
        _detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        _detailTextLabel.textColor = [UIColor darkGrayColor];
        _detailTextLabel.textAlignment = NSTextAlignmentCenter;
        _detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

        [self addSubview:_detailTextLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.textLabel autoSetDimension:ALDimensionHeight toSize:kTitleNavigationViewRow1Height];
    [self.textLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.textLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.textLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [self.detailTextLabel autoSetDimension:ALDimensionHeight toSize:kTitleNavigationViewRow2Height];
    [self.detailTextLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textLabel];
    [self.detailTextLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.detailTextLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [super updateConstraints];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(350.0, kTitleNavigationViewRow1Height + kTitleNavigationViewRow2Height);
}

@end
