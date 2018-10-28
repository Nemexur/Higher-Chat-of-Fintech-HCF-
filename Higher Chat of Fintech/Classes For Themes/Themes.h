//
//  Themes.h
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 11/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Themes : NSObject { }

@property (nonatomic, retain) UIColor *theme1;
@property (nonatomic, retain) UIColor *theme2;
@property (nonatomic, retain) UIColor *theme3;
@property (nonatomic, retain) UIColor *defaultTheme;

- (void) setThemes: (UIColor *)newDefaultTheme setTheme1: (UIColor *)newTheme1 setTheme2: (UIColor *)newTheme2 setTheme3: (UIColor *)newTheme3;

- (UIColor *) theme1;
- (UIColor *) theme2;
- (UIColor *) theme3;
- (UIColor *) defaultTheme;

@end

NS_ASSUME_NONNULL_END
