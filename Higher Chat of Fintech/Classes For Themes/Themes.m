//
//  Themes.m
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 11/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

#import "Themes.h"

@implementation Themes
{
    UIColor *_theme1;
    UIColor *_theme2;
    UIColor *_theme3;
    UIColor *_defaultTheme;
}

//MARK: - Setters

-(void) setThemes: (UIColor *)newDefaultTheme setTheme1:(UIColor *)newTheme1 setTheme2:(UIColor *)newTheme2 setTheme3:(UIColor *)newTheme3 {
    
    //Set themes
    _defaultTheme = newDefaultTheme;
    _theme1 = newTheme1;
    _theme2 = newTheme2;
    _theme3 = newTheme3;
    
    //Release
    [newDefaultTheme release];
    [newTheme1 release];
    [newTheme2 release];
    [newTheme3 release];
}

//MARK: - Getters

- (UIColor *) theme1 {
    return [_theme1 autorelease];
}
- (UIColor *) theme2 {
    return [_theme2 autorelease];
}
- (UIColor *) theme3 {
    return [_theme3 autorelease];
}
-(UIColor *) defaultTheme {
    return [_defaultTheme autorelease];
}

@end
