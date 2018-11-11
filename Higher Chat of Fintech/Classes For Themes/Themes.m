//
//  Themes.m
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 11/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

#import "Themes.h"

@implementation Themes { }

// MARK: - Setters

-(void) setThemes: (UIColor *)newDefaultTheme setTheme1:(UIColor *)newTheme1 setTheme2:(UIColor *)newTheme2 setTheme3:(UIColor *)newTheme3 {
    
    //Set themes
    if (newDefaultTheme != _defaultTheme) {
        UIColor *oldDefaultTheme = _defaultTheme;
        _defaultTheme = [newDefaultTheme retain];
        [oldDefaultTheme release];
    }
    if (newTheme1 != _theme1) {
        UIColor *oldTheme1 = _theme1;
        _theme1 = [newTheme1 retain];
        [oldTheme1 release];
    }
    if (newTheme2 != _theme2) {
        UIColor *oldTheme2 = _theme2;
        _theme2 = [newTheme2 retain];
        [oldTheme2 release];
    }
    if (newTheme3 != _theme3) {
        UIColor *oldTheme3 = _theme3;
        _theme3 = [newTheme3 retain];
        [oldTheme3 release];
    }
}

// MARK: - Getters

- (UIColor *) theme1 {
    return _theme1;
}
- (UIColor *) theme2 {
    return _theme2;
}
- (UIColor *) theme3 {
    return _theme3;
}
-(UIColor *) defaultTheme {
    return _defaultTheme;
}

@end
