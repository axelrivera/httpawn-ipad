//
//  RequestViewCell.m
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestViewCell.h"

#import <UIView+AutoLayout.h>
#import "RequestMethodView.h"

@interface RequestViewCell ()

@property (strong, nonatomic, readwrite) RequestMethodView *methodView;
@property (strong, nonatomic, readwrite) UILabel *titleLabel;

@end

@implementation RequestViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = YES;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;

        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.accessoryType = UITableViewCellAccessoryNone;

        _methodView = [[RequestMethodView alloc] initWithFrame:CGRectZero];
        _methodView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_methodView];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:13.0];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];

        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.methodView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0];
    [self.methodView autoCenterInSuperviewAlongAxis:ALAxisHorizontal];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.methodView withOffset:5.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0];

    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRequest:(RCRequest *)request
{
    [self setRequest:request ignoreName:NO];
}

- (void)setRequest:(RCRequest *)request ignoreName:(BOOL)ignoreName
{
    _request = request;

    if (request) {
        if (ignoreName || IsEmpty(request.requestName)) {
            self.titleLabel.text = [request fullURLString];
            self.titleLabel.font = [UIFont systemFontOfSize:13.0];
            self.titleLabel.numberOfLines = 2.0;
            self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        } else {
            self.titleLabel.text = request.requestName;
            self.titleLabel.font = [UIFont systemFontOfSize:16.0];
            self.titleLabel.numberOfLines = 1.0;
            self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }

        [self.methodView setRequestMethod:request.requestMethod];
    }
}

+ (CGFloat)cellHeight
{
    return 60.0;
}

@end
