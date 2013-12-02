//
//  RequestMethodView.m
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestMethodView.h"

#import <UIView+AutoLayout.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Tint.h"

@interface RequestMethodView ()

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic, readwrite) UILabel *textLabel;

@end

@implementation RequestMethodView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];

        self.layer.cornerRadius = 3.0;
        self.layer.masksToBounds = YES;

        self.clipsToBounds = YES;

        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundView.image = [UIImage backgroundTemplateImage];

        [self addSubview:_backgroundView];

        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _textLabel.textAlignment = NSTextAlignmentCenter;

        [self addSubview:_textLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.backgroundView autoSetDimension:ALDimensionWidth toSize:self.intrinsicContentSize.width];
    [self.backgroundView autoSetDimension:ALDimensionHeight toSize:self.intrinsicContentSize.height];
    [self.backgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self.textLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)];
    [super updateConstraints];
}

#pragma mark - Public Methods

- (void)setRequestMethod:(NSString *)requestMethod
{
    UIColor *backgroundColor = nil;

    if ([requestMethod isEqualToString:RCRequestMethodGet]) {
        backgroundColor = [UIColor greenColor];
    } else if ([requestMethod isEqualToString:RCRequestMethodPost]) {
        backgroundColor = [UIColor orangeColor];
    } else if ([requestMethod isEqualToString:RCRequestMethodPut]) {
        backgroundColor = [UIColor purpleColor];
    } else if ([requestMethod isEqualToString:RCRequestMethodDelete]) {
        backgroundColor = [UIColor redColor];
    } else if ([requestMethod isEqualToString:RCRequestMethodHead]) {
        backgroundColor = [UIColor blueColor];
    } else if ([requestMethod isEqualToString:RCRequestMethodTrace]) {
        backgroundColor = [UIColor brownColor];
    } else if ([requestMethod isEqualToString:RCRequestMethodPatch]) {
        backgroundColor = [UIColor magentaColor];
    } else {
        backgroundColor = [UIColor blackColor];
    }

    self.textLabel.text = requestMethod;
    self.backgroundView.tintColor = backgroundColor;

    [self updateConstraintsIfNeeded];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(kRequestMethodViewWidth, kRequestMethodViewHeight);
}

@end
