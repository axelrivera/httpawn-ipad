//
//  RequestHeaderView.m
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestHeaderView.h"

#import <UIView+AutoLayout.h>

@implementation HeaderTextField

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rect = CGRectMake(CGRectGetWidth(bounds) - (22.0 + 10.0),
                             (CGRectGetHeight(bounds) / 2.0) - (22.0 / 2.0),
                             22.0,
                             22.0);
    return rect;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    rect.size.width -= 10.0;
    return rect;
}

@end

@interface RequestHeaderView ()

@property (strong, nonatomic, readwrite) HeaderTextField *URLTextField;
@property (strong, nonatomic, readwrite) UIButton *URLRecentButton;
@property (strong, nonatomic, readwrite) UIButton *URLActionButton;
@property (strong, nonatomic, readwrite) UIButton *parametersButton;
@property (strong, nonatomic, readwrite) UIButton *headersButton;
@property (strong, nonatomic, readwrite) UIButton *sendButton;
@property (strong, nonatomic, readwrite) UIButton *previewButton;
@property (strong, nonatomic, readwrite) UIButton *saveButton;
@property (strong, nonatomic, readwrite) UIButton *groupButton;

@property (strong, nonatomic) UIView *bottomLine;

- (void)setupSaveButton;

@end

@implementation RequestHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        _headerViewType = RequestHeaderViewTypeSingle;

        SEL buttonSelector = @selector(buttonAction:);

        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomLine.backgroundColor = [UIColor lightGrayColor];

        [self addSubview:_bottomLine];

        _URLRecentButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _URLRecentButton.frame = CGRectMake(0.0, 0.0, 22.0, 22.0);
        _URLRecentButton.tintColor = [UIColor lightGrayColor];
        [_URLRecentButton setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
        [_URLRecentButton setImage:[UIImage imageNamed:@"clock-selected"] forState:UIControlStateHighlighted];
        [_URLRecentButton setImage:[UIImage imageNamed:@"clock-selected"] forState:UIControlStateSelected];
        _URLRecentButton.tag = RequestHeaderViewButtonTypeRecent;
        [_URLRecentButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        _URLTextField = [[HeaderTextField alloc] initWithFrame:CGRectZero];
        _URLTextField.borderStyle = UITextBorderStyleRoundedRect;
        _URLTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _URLTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _URLTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _URLTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _URLTextField.placeholder = @"http://example.com";
        _URLTextField.text = @"";
        _URLTextField.keyboardType = UIKeyboardTypeURL;

        _URLTextField.rightView = _URLRecentButton;
        _URLTextField.rightViewMode = UITextFieldViewModeUnlessEditing;

        [self addSubview:_URLTextField];

        _URLActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _URLActionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_URLActionButton setTitle:RCRequestMethodGet forState:UIControlStateNormal];
        _URLActionButton.tag = RequestHeaderViewButtonTypeURLAction;
        _URLActionButton.contentHorizontalAlignment = UIViewContentModeLeft;
        [_URLActionButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_URLActionButton];

        _parametersButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _parametersButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_parametersButton setTitle:@"Parameters" forState:UIControlStateNormal];
        _parametersButton.tag = RequestHeaderViewButtonTypeParameters;
        [_parametersButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_parametersButton];

        _headersButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _headersButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_headersButton setTitle:@"Headers" forState:UIControlStateNormal];
        _headersButton.tag = RequestHeaderViewButtonTypeHeaders;
        [_headersButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_headersButton];

        _sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _sendButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_sendButton setTitle:@"Send Request" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _sendButton.tag = RequestHeaderViewButtonTypeSend;
        [_sendButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_sendButton];

        _previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _previewButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_previewButton setTitle:@"Preview" forState:UIControlStateNormal];
        _previewButton.tag = RequestHeaderViewButtonTypePreview;
        [_previewButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_previewButton];

        _groupButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _groupButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_groupButton setTitle:@"Add to Group" forState:UIControlStateNormal];
        _groupButton.tag = RequestHeaderViewButtonTypeGroup;
        [_groupButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_groupButton];

        _advancedButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _advancedButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_advancedButton setTitle:@"Advanced" forState:UIControlStateNormal];
        _advancedButton.tag = RequestHeaderViewButtonTypeAdvanced;
        [_advancedButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_advancedButton];

        _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _resetButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        _resetButton.tag = RequestHeaderViewButtonTypeReset;
        [_resetButton addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];
        _resetButton.tintColor = [UIColor redColor];

        [self addSubview:_resetButton];

        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = [UIFont systemFontOfSize:14.0];
        _statusLabel.textColor = [UIColor lightGrayColor];

        [self addSubview:_statusLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self autoSetDimension:ALDimensionHeight toSize:[[self class] viewHeight]];

    [self.bottomLine autoSetDimension:ALDimensionHeight toSize:0.5];
    [self.bottomLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.bottomLine autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [self.bottomLine autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.5];

    [self.URLTextField autoSetDimension:ALDimensionHeight toSize:37.0];
    [self.URLTextField autoSetDimension:ALDimensionWidth toSize:450.0];
    [self.URLTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15.0];
    [self.URLTextField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20.0];

    [self.URLActionButton autoSetDimension:ALDimensionWidth toSize:80.0];
    [self.URLActionButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.URLTextField withOffset:10.0];
    [self.URLActionButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.URLTextField];

    [self.sendButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20.0];
    [self.sendButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.URLActionButton];

    [self.headersButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.URLTextField withOffset:10.0];
    [self.headersButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.URLTextField];

    [self.parametersButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.headersButton withOffset:20.0];
    [self.parametersButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.headersButton];

    [self.previewButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.parametersButton withOffset:20.0];
    [self.previewButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.headersButton];

    if (self.headerViewType == RequestHeaderViewTypeSingle) {
        [self.groupButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.previewButton withOffset:20.0];
    } else {
        [self.saveButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.previewButton withOffset:20.0];
        [self.saveButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.headersButton];

        [self.groupButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.saveButton withOffset:20.0];
    }

    [self.groupButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.headersButton];

    [self.advancedButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.groupButton withOffset:20.0];
    [self.advancedButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.headersButton];

    [self.resetButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.advancedButton withOffset:20.0];
    [self.resetButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.headersButton];

    [self.statusLabel autoSetDimension:ALDimensionHeight toSize:18.0];
    [self.statusLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headersButton withOffset:4.0];
    [self.statusLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.URLTextField];
    [self.statusLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20.0];

    [super updateConstraints];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake([[self class] viewHeight], UIViewNoIntrinsicMetric);
}

- (void)setHeaderViewType:(RequestHeaderViewType)headerViewType
{
    _headerViewType = headerViewType;

    [self autoRemoveConstraintsAffectingViewAndSubviews];

    if (self.saveButton) {
        [self.saveButton removeFromSuperview];
        self.saveButton = nil;
    }

    if (headerViewType == RequestHeaderViewTypeGrouped) {
        [self setupSaveButton];
    }

    [self setNeedsUpdateConstraints];
}

- (void)setupSaveButton
{
    _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
    _saveButton.tag = RequestHeaderViewButtonTypeSave;
    [_saveButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_saveButton];
}

#pragma mark - Selector Methods

- (void)buttonAction:(id)sender
{
    [self.delegate requestHeaderView:self didSelectButtonType:[sender tag]];
}

+ (CGFloat)viewHeight
{
    return 15.0 + 37.0 + 15.0 + 37.0 + 15.0 + 5.0;
}

@end
