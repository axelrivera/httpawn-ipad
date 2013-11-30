//
//  RequestViewCell.h
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RequestMethodView;

@interface RequestViewCell : UITableViewCell

@property (strong, nonatomic, readonly) RequestMethodView *methodView;
@property (strong, nonatomic, readonly) UILabel *titleLabel;

@property (strong, nonatomic) RCRequest *request;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setRequest:(RCRequest *)request ignoreName:(BOOL)ignoreName;

+ (CGFloat)cellHeight;

@end
