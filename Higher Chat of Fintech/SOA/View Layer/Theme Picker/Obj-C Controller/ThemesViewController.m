//
//  ThemesViewController.m
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 11/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

#import "ThemesViewController.h"
#import "Themes.h"

@interface ThemesViewController ()

@property (weak, nonatomic) NSMutableDictionary *colorsForThemes;

@end

@implementation ThemesViewController

// MARK: - Overrided UIViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTopBarThemeView];
    [self fillColorsForThemes];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: true];
    _themes = [[Themes alloc] init];
    [_themes setThemes: [_colorsForThemes objectForKey: @"DefaultTheme"]
             setTheme1: [_colorsForThemes objectForKey: @"Theme1"]
             setTheme2: [_colorsForThemes objectForKey: @"Theme2"]
             setTheme3: [_colorsForThemes objectForKey: @"Theme3"]];
}

// MARK: - Deallocation Function

- (void)dealloc {
    [_topBarThemeView release];
    [_themes release];
    [_colorsForThemes release];
    [super dealloc];
}

// MARK: - Additional Functions

- (void) configureTopBarThemeView {
    _topBarThemeView.layer.cornerRadius = 10;
    _topBarThemeView.layer.borderColor = [[UIColor blackColor]CGColor];
    _topBarThemeView.layer.borderWidth = 1;
}

-(void) fillColorsForThemes {
    _colorsForThemes = [[NSMutableDictionary alloc] init];
    [_colorsForThemes setObject: [UIColor redColor] forKey: @"Theme1"];
    [_colorsForThemes setObject: [UIColor yellowColor] forKey: @"Theme2"];
    [_colorsForThemes setObject: [UIColor greenColor] forKey: @"Theme3"];
    [_colorsForThemes setObject: [UIColor whiteColor] forKey: @"DefaultTheme"];
}

-(void) setDelegateTheme: (UIColor *)theme {
    self.view.backgroundColor = theme;
    [_delegate themesViewController:self didSelectTheme:theme];
}

// MARK: - Button Actions

- (IBAction)pickTheme1:(id)sender {
    [self setDelegateTheme:[_themes theme1]];
}

- (IBAction)pickTheme2:(id)sender {
    [self setDelegateTheme:[_themes theme2]];
}

- (IBAction)pickTheme3:(id)sender {
    [self setDelegateTheme:[_themes theme3]];
}

- (IBAction)pickDefaultTheme:(id)sender {
    [self setDelegateTheme:[_themes defaultTheme]];
}

@end
