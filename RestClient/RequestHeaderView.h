//
//  RequestHeaderView.h
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RequestHeaderViewType) {
    RequestHeaderViewTypeSingle,
    RequestHeaderViewTypeGrouped
};

typedef NS_ENUM(NSInteger, RequestHeaderViewButtonType) {
    RequestHeaderViewButtonTypeURLAction = 100,
    RequestHeaderViewButtonTypeParameters,
    RequestHeaderViewButtonTypeHeaders,
    RequestHeaderViewButtonTypeSend,
    RequestHeaderViewButtonTypePreview,
    RequestHeaderViewButtonTypeSave,
    RequestHeaderViewButtonTypeGroup,
    RequestHeaderViewButtonTypeAdvanced,
    RequestHeaderViewButtonTypeReset
};

@protocol RequestHeaderViewDelegate;

@interface RequestHeaderView : UIView

@property (weak, nonatomic) id <RequestHeaderViewDelegate> delegate;

@property (assign, nonatomic) RequestHeaderViewType headerViewType;

@property (strong, nonatomic, readonly) UITextField *URLTextField;
@property (strong, nonatomic, readonly) UIButton *URLActionButton;
@property (strong, nonatomic, readonly) UIButton *sendButton;
@property (strong, nonatomic, readonly) UIButton *headersButton;
@property (strong, nonatomic, readonly) UIButton *parametersButton;
@property (strong, nonatomic, readonly) UIButton *previewButton;
@property (strong, nonatomic, readonly) UIButton *saveButton;
@property (strong, nonatomic, readonly) UIButton *groupButton;
@property (strong, nonatomic, readonly) UIButton *advancedButton;
@property (strong, nonatomic, readonly) UIButton *resetButton;
@property (strong, nonatomic, readonly) UILabel *statusLabel;

+ (CGFloat)viewHeight;

@end

@protocol RequestHeaderViewDelegate <NSObject>

- (void)requestHeaderView:(RequestHeaderView *)headerView didSelectButtonType:(RequestHeaderViewButtonType)buttonType;

@end
