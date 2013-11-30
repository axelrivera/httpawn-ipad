//
//  UIImage+Tint.h
//  ATHMovil
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 EVERTEC, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *)tintedGradientImageWithColor:(UIColor *)tintColor;
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

+ (UIImage *)backgroundGradientImageWithColor:(UIColor *)tintColor;
+ (UIImage *)backgroundTintedImageWithColor:(UIColor *)tintColor;

@end
