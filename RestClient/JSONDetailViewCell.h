//
//  JSONDetailViewCell.h
//  RestClient
//
//  Created by Axel Rivera on 1/25/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJSONDetailViewCellPaddingTop 10.0
#define kJSONDetailViewCellPaddingBottom 10.0
#define kJSONDetailViewCellPaddingLeft 15.0
#define kJSONDetailViewCellPaddingRight 15.0
#define kJSONDetailViewCellPaddingVertical 3.0

#define kJSONDetailViewCellRow1Height 18.0
#define kJSONDetailViewCellRow2Height 18.0

@interface JSONDetailViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *supportLabel;
@property (strong, nonatomic) UIButton *button;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)cellHeight;

@end
