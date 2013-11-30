//
//  RequestMethodView.h
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRequestMethodViewWidth 55.0
#define kRequestMethodViewHeight 22.0

@interface RequestMethodView : UIView

@property (strong, nonatomic, readonly) UILabel *textLabel;

- (void)setRequestMethod:(NSString *)requestMethod;

@end
